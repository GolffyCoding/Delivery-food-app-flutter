import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:opendelivery_sync/opendelivery_sync.dart';

/// Local persistence layer for failed/pending network requests.
class SyncQueue {
  static const String _indexKey = '_sync_queue_index';
  final LocalStorageService _storage;

  SyncQueue(this._storage);

  Future<List<String>> _index() async => (await _storage.get<List<dynamic>>(_indexKey))?.cast<String>() ?? [];

  Future<void> enqueue(SyncRequest request) async {
    final ids = await _index();
    ids.add(request.localId);
    await _storage.save(_indexKey, ids);
    await _storage.save('sync_req_${request.localId}', request.toJson());
    AppLogger.debug('Enqueued sync request: ${request.path}', tag: 'SyncQueue');
  }

  Future<SyncRequest?> dequeue() async {
    final ids = await _index();
    if (ids.isEmpty) return null;
    final id = ids.removeAt(0);
    await _storage.save(_indexKey, ids);
    final json = await _storage.get<Map<String, dynamic>>('sync_req_$id');
    await _storage.delete('sync_req_$id');
    return json == null ? null : SyncRequest.fromJson(json);
  }

  Future<void> requeue(SyncRequest request) async {
    final updated = request.copyWith(retryCount: request.retryCount + 1);
    final ids = await _index();
    ids.add(updated.localId);
    await _storage.save(_indexKey, ids);
    await _storage.save('sync_req_${updated.localId}', updated.toJson());
    AppLogger.warning('Requeued sync request (attempt ${updated.retryCount}): ${updated.path}', tag: 'SyncQueue');
  }

  Future<void> clear() async {
    final ids = await _index();
    for (final id in ids) {
      await _storage.delete('sync_req_$id');
    }
    await _storage.delete(_indexKey);
  }

  Future<int> get length async => (await _index()).length;
}
