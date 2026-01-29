import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../features/offers/controller/offers_controller.dart';
import '../../../features/requests/controller/requests_controller.dart';
import '../../service/storage/local_storage_service.dart';
import '../../service/socket/centrifugo_handler.dart';

/// Shows premium in-app banners for incoming realtime events.
class InAppNotificationService extends GetxService {
  StreamSubscription<Map<String, dynamic>>? _sub;
  final Map<String, DateTime> _lastRefreshAt = {};

  void start(CentrifugoHandler ws) {
    if (_sub != null) return;

    _sub = ws.events.listen((event) {
      final parsed = _parse(event);
      if (parsed == null) return;
      _showBanner(parsed.$1, parsed.$2, variant: parsed.$3);
      _refreshRelated(event);
    });
  }

  void disposeService() {
    _sub?.cancel();
    _sub = null;
  }

  /// Returns (title, message, variant)
  (String, String, _Variant)? _parse(Map<String, dynamic> event) {
    final type = (event['type'] ?? '').toString();
    if (type.isEmpty) return null;

    // Generic payload support (useful for admin/dev test broadcast endpoints).
    // Expected shapes:
    // - { type, payload: { title, message } }
    // - { type, title, message }
    final p = event['payload'];
    if (p is Map<String, dynamic>) {
      final t = (p['title'] ?? '').toString().trim();
      final m = (p['message'] ?? p['body'] ?? '').toString().trim();
      if (t.isNotEmpty || m.isNotEmpty) {
        return (
          t.isNotEmpty ? t : 'Notification',
          m.isNotEmpty ? m : type,
          _Variant.info
        );
      }
    } else {
      final t = (event['title'] ?? '').toString().trim();
      final m = (event['message'] ?? '').toString().trim();
      if (t.isNotEmpty || m.isNotEmpty) {
        return (
          t.isNotEmpty ? t : 'Notification',
          m.isNotEmpty ? m : type,
          _Variant.info
        );
      }
    }

    switch (type) {
      case 'request_created':
        final req = event['request'];
        if (req is Map<String, dynamic>) {
          final title = (req['title'] ?? 'New request').toString();
          final city = (req['delivery_city'] ?? '').toString();
          final qty = (req['quantity'] ?? '').toString();
          final unit = (req['unit'] ?? '').toString();
          final msg = [
            if (qty.isNotEmpty || unit.isNotEmpty) '$qty $unit'.trim(),
            if (city.isNotEmpty) city,
          ].where((e) => e.trim().isNotEmpty).join(' • ');
          return (
            'New Request',
            title + (msg.isNotEmpty ? '\n$msg' : ''),
            _Variant.info
          );
        }
        return ('New Request', 'A new request was posted.', _Variant.info);

      case 'offer_created':
        final offer = event['offer'];
        if (offer is Map<String, dynamic>) {
          final title = (offer['title'] ?? 'New offer').toString();
          final price = (offer['price_per_unit'] ?? '').toString();
          final unit = (offer['unit'] ?? '').toString();
          final msg = (price.isNotEmpty || unit.isNotEmpty)
              ? '$price / $unit'.trim()
              : '';
          return (
            'New Offer',
            title + (msg.isNotEmpty ? '\n$msg' : ''),
            _Variant.promo
          );
        }
        return ('New Offer', 'A company posted a new offer.', _Variant.promo);

      case 'quotation_created':
        final q = event['quotation'];
        final requestId = event['request_id'];
        if (q is Map<String, dynamic>) {
          final total = (q['total_price'] ?? '').toString();
          final delivery = (q['delivery_time_days'] ?? '').toString();
          final msg = [
            if (requestId != null) 'Request #$requestId',
            if (total.isNotEmpty) 'Total: $total',
            if (delivery.isNotEmpty) 'Delivery: $delivery days',
          ].join(' • ');
          return (
            'New Quotation',
            msg.isEmpty ? 'You received a new quotation.' : msg,
            _Variant.success
          );
        }
        return (
          'New Quotation',
          requestId != null
              ? 'Request #$requestId'
              : 'You received a new quotation.',
          _Variant.success
        );

      default:
        return ('Notification', type, _Variant.info);
    }
  }

  void _showBanner(String title, String message, {required _Variant variant}) {
    final theme = Get.theme;
    final scheme = theme.colorScheme;

    final Color bg = switch (variant) {
      _Variant.info => scheme.primaryContainer,
      _Variant.promo => scheme.tertiaryContainer,
      _Variant.success => scheme.secondaryContainer,
      _Variant.error => scheme.errorContainer,
    };
    final Color fg = switch (variant) {
      _Variant.info => scheme.onPrimaryContainer,
      _Variant.promo => scheme.onTertiaryContainer,
      _Variant.success => scheme.onSecondaryContainer,
      _Variant.error => scheme.onErrorContainer,
    };

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 18,
      backgroundColor: bg,
      colorText: fg,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      animationDuration: const Duration(milliseconds: 250),
      titleText:
          Text(title, style: TextStyle(color: fg, fontWeight: FontWeight.w900)),
      messageText: Text(message,
          style:
              TextStyle(color: fg, fontWeight: FontWeight.w700, height: 1.25)),
      icon: Icon(
        switch (variant) {
          _Variant.info => Icons.notifications_active_outlined,
          _Variant.promo => Icons.local_offer_outlined,
          _Variant.success => Icons.check_circle_outline,
          _Variant.error => Icons.error_outline,
        },
        color: fg,
      ),
    );
  }

  void _refreshRelated(Map<String, dynamic> event) {
    final type = (event['type'] ?? '').toString();
    if (type.isEmpty) return;

    // Simple throttle: don't spam refreshes if multiple events arrive quickly.
    final now = DateTime.now();
    final last = _lastRefreshAt[type];
    if (last != null && now.difference(last).inMilliseconds < 1200) return;
    _lastRefreshAt[type] = now;

    final role = Get.isRegistered<LocalStorageService>()
        ? (Get.find<LocalStorageService>().userRole ?? '')
        : '';

    // Offer created -> user offers list should refresh.
    if (type == 'offer_created') {
      if (role != 'company' && Get.isRegistered<OffersController>()) {
        Get.find<OffersController>().load();
      }
      return;
    }

    // Request created -> company available requests should refresh.
    if (type == 'request_created') {
      if (role == 'company' && Get.isRegistered<RequestsController>()) {
        Get.find<RequestsController>().loadAvailable();
      }
      return;
    }
  }
}

enum _Variant { info, promo, success, error }
