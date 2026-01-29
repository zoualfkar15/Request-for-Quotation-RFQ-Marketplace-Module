import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../auth/controller/auth_controller.dart';
import '../../../../core/service/notifications/in_app_notification_service.dart';
import '../../../../core/service/socket/centrifugo_handler.dart';
import 'company_main_page.dart';
import 'user_main_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String route = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final CentrifugoHandler _ws;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ws = Get.find<CentrifugoHandler>();
    _ws.connect();
    // Global in-app banners for realtime events
    Get.find<InAppNotificationService>().start(_ws);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Android often drops sockets while app is backgrounded.
      _ws.connect(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final role = auth.storage.userRole ?? 'user';
    return role == 'company' ? const CompanyMainPage() : const UserMainPage();
  }
}
