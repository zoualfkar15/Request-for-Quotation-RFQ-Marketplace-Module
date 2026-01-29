import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/ui/gradient.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../../home/view/page/home_page.dart';
import '../../../auth/view/page/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const String route = '/';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // Small delay so splash is visible (and for any future init work).
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final auth = Get.find<AuthController>();
    if (auth.isLoggedIn) {
      Get.offAllNamed(HomePage.route);
    } else {
      Get.offAllNamed(LoginPage.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.primary),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.request_quote, size: 70, color: Colors.white),
              const SizedBox(height: 14),
              const Text(
                'RFQ Marketplace',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(.22)),
                ),
                child: Text(
                  isDark ? 'Preparing dark mode…' : 'Getting things ready…',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 18),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                    strokeWidth: 3, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
