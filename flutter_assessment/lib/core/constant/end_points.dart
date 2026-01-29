class Endpoints {
  /// Backend base URL (Yii2).
  ///
  /// - iOS simulator: http://127.0.0.1:8000/
  /// - Android emulator: http://10.0.2.2:8000/
  /// - Real device: use your LAN IP (e.g. http://192.168.x.x:8000/)
  static const String baseUrl = 'http://10.0.2.2:8000/';

  /// Centrifugo websocket URL (example).
  /// You will update this once Centrifugo is running.
  // Local dev uses ws:// (no TLS). Android emulator reaches host via 10.0.2.2.
  static const String centrifugoWsUrl =
      'ws://10.0.2.2:8001/connection/websocket';
  static const String centrifugoToken = 'api/ws/token';

  // Auth
  static const String register = 'api/auth/register';
  static const String login = 'api/auth/login';
  static const String me = 'api/auth/me';
  static const String refresh = 'api/auth/refresh';
  static const String logout = 'api/auth/logout';
  static const String otpSend = 'api/auth/otp/send';
  static const String otpVerify = 'api/auth/otp/verify';
  static const String passwordReset = 'api/auth/password/reset';

  // Categories + subscriptions
  static const String categories = 'api/categories';
  static const String subscriptions = 'api/subscriptions';
  static const String subscriptionsToggle = 'api/subscriptions/toggle';

  // Requests
  static const String requests = 'api/requests';
  static const String myRequests = 'api/requests/my';
  static const String availableRequests = 'api/requests/available';
  static const String requestsHistory = 'api/requests/history';

  // Quotations
  static const String quotations = 'api/quotations';
  static String quotationsByRequest(int requestId) =>
      'api/quotations/by-request/$requestId';

  // Offers
  static const String offers = 'api/offers';
  static const String myOffers = 'api/offers/my';
  static const String availableOffers = 'api/offers/available';

  // Notifications
  static const String notifications = 'api/notifications';
  static String notificationRead(int id) => 'api/notifications/$id/read';
}
