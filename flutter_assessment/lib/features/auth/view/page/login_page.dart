import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/ui/gradient.dart';
import '../../../../core/ui/section_header.dart';
import '../../../../core/ui/text_field_widget.dart';
import '../../../../core/validation/validation.dart';
import '../../controller/auth_controller.dart';
import 'register_page.dart';
import 'reset_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String route = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _login = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(
              title: 'Welcome back',
              subtitle: 'Sign in to continue to RFQ Marketplace.',
            ),
            GradientCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: const [
                  Icon(Icons.request_quote, color: Colors.white, size: 40),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Compare quotations, accept the best deal, and get real-time updates.',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, height: 1.25),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFieldWidget(
                        controller: _login,
                        labelText: 'Email or username',
                        hintText: 'example@email.com',
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (v) => Validation.required(v, fieldName: 'Login'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      TextFieldWidget(
                        controller: _password,
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        obscureText: true,
                        validator: (v) => Validation.required(v, fieldName: 'Password'),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          if (_formKey.currentState?.validate() ?? false) {
                            c.login(login: _login.text.trim(), password: _password.text);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        return FilledButton(
                          onPressed: c.isLoading.value
                              ? null
                              : () {
                                  if (!(_formKey.currentState?.validate() ?? false)) return;
                                  c.login(login: _login.text.trim(), password: _password.text);
                                },
                          child: c.isLoading.value
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Sign in'),
                        );
                      }),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => Get.toNamed(
                            ResetPasswordPage.route,
                            arguments: {'email': _login.text.trim()},
                          ),
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => Get.toNamed(RegisterPage.route),
                        child: const Text('Create account'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
