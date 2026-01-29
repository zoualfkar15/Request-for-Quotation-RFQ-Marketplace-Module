import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'core/constant/end_points.dart';
import 'core/network/request/api_client.dart';
import 'core/network/request/curl_logger_interceptor.dart';
import 'core/service/notifications/in_app_notification_service.dart';
import 'core/service/storage/local_storage_service.dart';
import 'core/service/socket/centrifugo_handler.dart';

void initDependencies() {
  Get.put<LocalStorageService>(LocalStorageService(), permanent: true);

  Get.lazyPut<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    dio.interceptors.add(CurlLoggerInterceptor());
    return dio;
  }, fenix: true);

  Get.put<ApiClient>(ApiClient(dio: Get.find<Dio>(), storage: Get.find()),
      permanent: true);

  Get.put<CentrifugoHandler>(
    CentrifugoHandler(storage: Get.find(), api: Get.find()),
    permanent: true,
  );

  Get.put<InAppNotificationService>(InAppNotificationService(),
      permanent: true);
}
