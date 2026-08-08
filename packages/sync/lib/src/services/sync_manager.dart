import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:opendelivery_sync/opendelivery_sync.dart';

/// Orchestrates processing the SyncQueue when connectivity is restored.
/// Handles exponential backoff and drops requests that exceed max retries.
class SyncManager {
  final SyncQueue _queue;
  final DioClient _dioClient;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isProcessing = false;

  /// Fires once per request that exhausted its retries and was dropped, so a
  /// caller can surface something to the user ("your cancellation couldn't
  /// be sent") instead of the failure vanishing into a log line.
  final _permanentFailures = StreamController<SyncRequest>.broadcast();
  Stream<SyncRequest> get permanentFailures => _permanentFailures.stream;

  SyncManager(this._queue, this._dioClient, this._connectivity);

  void start() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    unawaited(_processQueue());
  }

  void stop() {
    _connectivitySubscription?.cancel();
  }

  void dispose() {
    stop();
    _permanentFailures.close();
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => r != ConnectivityResult.none);
    if (hasConnection) {
      AppLogger.info('Connectivity restored. Processing sync queue...', tag: 'SyncManager');
      unawaited(_processQueue());
    }
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      // Snapshot how many requests exist *before* this pass starts. A failed
      // request gets requeued (appended to the back) for a later attempt —
      // without this bound, requeuing would push the queue length back up
      // and the `while (length > 0)` loop would keep retrying the same
      // stuck request forever instead of moving on to the others behind it.
      var remaining = await _queue.length;

      while (remaining > 0) {
        remaining--;
        final request = await _queue.dequeue();
        if (request == null) break;

        if (!request.shouldRetry) {
          AppLogger.error('Sync request exceeded max retries: ${request.path}', tag: 'SyncManager');
          _permanentFailures.add(request);
          continue;
        }

        final success = await _executeRequest(request);
        if (!success) {
          await _queue.requeue(request);
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<bool> _executeRequest(SyncRequest request) async {
    try {
      if (request.retryCount > 0) {
        final delaySeconds = 1 << request.retryCount;
        await Future.delayed(Duration(seconds: delaySeconds));
      }

      final response = await _dioClient.post(
        request.path,
        data: request.body,
        options: Options(headers: {'Idempotency-Key': request.idempotencyKey}),
      );

      return response.success;
    } catch (e) {
      AppLogger.error('Sync execution failed for ${request.path}', error: e, tag: 'SyncManager');
      return false;
    }
  }
}
