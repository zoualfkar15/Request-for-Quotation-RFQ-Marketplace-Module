import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/controller/auth_controller.dart';
import 'injection.dart';
import 'core/network/request/api_client.dart';
import 'core/service/storage/local_storage_service.dart';
import 'features/splash/view/page/splash_page.dart';
import 'features/requests/controller/requests_controller.dart';
import 'features/quotations/controller/quotations_controller.dart';
import 'features/subscriptions/controller/subscriptions_controller.dart';
import 'features/offers/controller/offers_controller.dart';
import 'features/notifications/controller/notifications_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  initDependencies();

  Get.put<AuthController>(
    AuthController(
        api: Get.find<ApiClient>(), storage: Get.find<LocalStorageService>()),
    permanent: true,
  );
  Get.put<RequestsController>(RequestsController(api: Get.find<ApiClient>()),
      permanent: true);
  Get.put<QuotationsController>(
      QuotationsController(api: Get.find<ApiClient>()),
      permanent: true);
  Get.put<SubscriptionsController>(
      SubscriptionsController(api: Get.find<ApiClient>()),
      permanent: true);
  Get.put<OffersController>(OffersController(api: Get.find<ApiClient>()),
      permanent: true);
  Get.put<NotificationsController>(
      NotificationsController(api: Get.find<ApiClient>()),
      permanent: true);

  runApp(const RfqApp());
}

class RfqApp extends StatelessWidget {
  const RfqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RFQ Marketplace',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      initialRoute: SplashPage.route,
      getPages: AppRoutes.pages,
    );
  }
}
