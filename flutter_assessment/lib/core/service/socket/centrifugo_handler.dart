import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../constant/end_points.dart';
import '../../network/request/api_client.dart';
import '../storage/local_storage_service.dart';

/// Minimal WS handler (Centrifugo-ready placeholder).
///
/// For the assessment, we mainly need a single stream of "banner events".
class CentrifugoHandler {
  CentrifugoHandler({required this.storage, required this.api});

  final LocalStorageService storage;
  final ApiClient api;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  bool _connecting = false;
  int _reconnectAttempts = 0;

  final _events = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get events => _events.stream;

  int _nextId = 1;
  final Set<String> _subscribed = {};

  Future<void> connect({bool force = false}) async {
    if (!force && _channel != null) return;
    if (_connecting) return;
    if ((storage.accessToken ?? '').isEmpty) return;

    _connecting = true;
    _reconnectTimer?.cancel();

    // 1) Fetch Centrifugo connection token from backend
    try {
      final tokenRes = await api.get(Endpoints.centrifugoToken);
      final token = (tokenRes is Map<String, dynamic>)
          ? (tokenRes['token'] as String?)
          : null;
      if (token == null || token.isEmpty) return;

      // If we are forcing a reconnect, fully reset old state first.
      await _sub?.cancel();
      _sub = null;
      try {
        await _channel?.sink.close();
      } catch (_) {}
      _channel = null;

      // 2) Open websocket
      _channel = WebSocketChannel.connect(Uri.parse(Endpoints.centrifugoWsUrl));
      _sub = _channel!.stream.listen(
        (raw) => _handleMessage(raw),
        onError: (_, __) => _scheduleReconnect(),
        onDone: () => _scheduleReconnect(),
      );

      // 3) Send connect command
      _send({
        'id': _nextId++,
        'connect': {
          'token': token,
        }
      });

      // 4) Make sure we include personal channel + subscribed categories.
      final userId = storage.userId;
      if (userId != null) {
        _subscribed.add('user.$userId');
      }

      final subs = await api.get(Endpoints.subscriptions);
      if (subs is List) {
        for (final item in subs) {
          if (item is Map<String, dynamic>) {
            final cid = item['category_id'];
            if (cid is num) {
              _subscribed.add('category.${cid.toInt()}');
            }
          }
        }
      }

      // 5) Resubscribe everything we know about (important after reconnect).
      for (final ch in _subscribed) {
        _send({
          'id': _nextId++,
          'subscribe': {'channel': ch}
        });
      }

      _reconnectAttempts = 0;
    } finally {
      _connecting = false;
    }
  }

  Future<void> disconnect({bool clearSubscriptions = false}) async {
    _reconnectTimer?.cancel();
    await _sub?.cancel();
    await _channel?.sink.close();
    _sub = null;
    _channel = null;
    if (clearSubscriptions) _subscribed.clear();
  }

  Future<void> subscribe(String channel) async {
    if (_subscribed.contains(channel)) return;
    _subscribed.add(channel);
    if (_channel == null) return;
    _send({'id': _nextId++, 'subscribe': {'channel': channel}});
  }

  Future<void> unsubscribe(String channel) async {
    if (!_subscribed.contains(channel)) return;
    _subscribed.remove(channel);
    if (_channel == null) return;
    _send({'id': _nextId++, 'unsubscribe': {'channel': channel}});
  }

  void _send(Map<String, dynamic> msg) {
    try {
      _channel?.sink.add(jsonEncode(msg));
    } catch (_) {}
  }

  void _scheduleReconnect() {
    if ((storage.accessToken ?? '').isEmpty) return;
    if (_reconnectTimer?.isActive ?? false) return;

    // Mark disconnected so connect() can proceed.
    _channel = null;
    _sub = null;

    final attempt = min(_reconnectAttempts, 5);
    final delaySeconds = min(30, pow(2, attempt).toInt());
    _reconnectAttempts++;

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      connect(force: true);
    });
  }

  void _handleMessage(dynamic raw) {
    try {
      final text = raw is String ? raw : (raw?.toString() ?? '');
      final msg = jsonDecode(text);
      if (msg is! Map<String, dynamic>) return;

      // connect ack
      if (msg.containsKey('result') && msg['id'] != null) {
        // connect/subscribe acks - no-op
      }

      // Centrifugo pushes publications under "push" (varies by protocol versions)
      final push = msg['push'];
      if (push is Map<String, dynamic>) {
        // Possible shapes:
        // - push: {pub: {data: {...}, channel: "..."}}
        // - push: {publication: {data: {...}}, channel: "..."}
        // - push: {pub: {data: {...}}, channel: "..."}
        final channel = (push['channel'] ?? push['pub']?['channel'])?.toString();

        Map<String, dynamic>? data;
        final pub = push['pub'];
        if (pub is Map<String, dynamic> && pub['data'] is Map<String, dynamic>) {
          data = pub['data'] as Map<String, dynamic>;
        }
        final publication = push['publication'];
        if (data == null && publication is Map<String, dynamic> && publication['data'] is Map<String, dynamic>) {
          data = publication['data'] as Map<String, dynamic>;
        }

        if (data != null) {
          _events.add({
            'channel': channel,
            ...data,
          });
        }
      }
    } catch (_) {
      // ignore
    }
  }
}


