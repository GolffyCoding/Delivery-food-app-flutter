import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Thin wrapper around the single `/ws` realtime endpoint.
///
/// The backend multiplexes everything over one socket: after connecting with
/// a JWT (sent as an `Authorization` header at handshake time), the client
/// asks to join specific rooms — `order:<id>`, `driver:<id>` — and the server
/// pushes `{"type","event","payload","timestamp"}` messages for whichever
/// rooms it has joined.
class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;

  bool get isConnected => _channel != null;

  Stream<Map<String, dynamic>> get messages =>
      _messageController?.stream.asBroadcastStream() ?? const Stream.empty();

  Future<void> connect(String url, {String? token}) async {
    try {
      final uri = Uri.parse(url);
      final channel = IOWebSocketChannel.connect(
        uri,
        headers: token != null ? {HttpHeaders.authorizationHeader: 'Bearer $token'} : null,
      );
      await channel.ready;
      _channel = channel;
      _messageController = StreamController<Map<String, dynamic>>.broadcast();
      _reconnectAttempts = 0;

      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            _messageController?.add(json);
          } catch (e) {
            AppLogger.error('WebSocket message parse error', error: e, tag: 'WebSocket');
          }
        },
        onDone: _onDisconnected,
        onError: _onError,
      );

      AppLogger.info('WebSocket connected to $url', tag: 'WebSocket');
    } catch (e) {
      AppLogger.error('WebSocket connection failed', error: e, tag: 'WebSocket');
      _scheduleReconnect(url, token: token);
    }
  }

  void send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void sendEvent(String event, [Map<String, dynamic>? payload]) {
    send({
      'event': event,
      'payload': payload,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Subscribes to a realtime room, e.g. `order:<id>` or `driver:<id>`.
  void joinRoom(String room) {
    send({'action': 'join', 'room': room});
  }

  void leaveRoom(String room) {
    send({'action': 'leave', 'room': room});
  }

  void _onDisconnected() {
    AppLogger.warning('WebSocket disconnected', tag: 'WebSocket');
    _channel = null;
  }

  void _onError(Object error) {
    AppLogger.error('WebSocket error', error: error, tag: 'WebSocket');
  }

  void _scheduleReconnect(String url, {String? token}) {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      AppLogger.error('Max reconnect attempts reached', tag: 'WebSocket');
      return;
    }

    _reconnectTimer?.cancel();
    final delay = Duration(seconds: 1 << _reconnectAttempts);
    _reconnectAttempts++;

    _reconnectTimer = Timer(delay, () => connect(url, token: token));
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    await _channel?.sink.close();
    _channel = null;
    await _messageController?.close();
    _messageController = null;
  }
}
