import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/ui/gradient.dart';
import '../../../../core/ui/section_header.dart';
import '../../../../core/ui/text_field_widget.dart';
import '../../../../core/validation/validation.dart';
import '../../controller/auth_controller.dart';
import 'login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  static const String route = '/reset-password';

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _email = TextEditingController();
  final _code = TextEditingController(text: '123456');
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  int _retryIn = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final argEmail = (Get.arguments is Map) ? (Get.arguments['email'] as String?) : null;
    if (argEmail != null && argEmail.trim().isNotEmpty) {
      _email.text = argEmail.trim();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    _code.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _startCooldown([int seconds = 60]) {
    _timer?.cancel();
    setState(() => _retryIn = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_retryIn <= 1) {
        t.cancel();
        setState(() => _retryIn = 0);
      } else {
        setState(() => _retryIn -= 1);
      }
    });
  }

  int? _parseRetrySeconds(String message) {
    final m = RegExp(r'Retry in (\d+)s').firstMatch(message);
    if (m == null) return null;
    return int.tryParse(m.group(1) ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SectionHeader(
            title: 'Reset your password',
            subtitle: 'Request an OTP, then set a new password. (For this assessment the OTP is 123456)',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GradientCard(
              gradient: AppGradients.warm,
              padding: const EdgeInsets.all(18),
              child: Row(
                children: const [
                  Icon(Icons.lock_reset_outlined, color: Colors.white, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can request a new OTP once every minute.',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, height: 1.25),
                    ),
                  ),
                ],
              ),
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
                      controller: _email,
                      labelText: 'Email',
                      hintText: 'example@email.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.mail_outline),
                      validator: Validation.email,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _loading || _retryIn > 0
                                ? null
                                : () async {
                                    if (Validation.email(_email.text) != null) {
                                      _formKey.currentState?.validate();
                                      return;
                                    }
                                    setState(() => _loading = true);
                                    try {
                                      await c.sendOtp(email: _email.text.trim(), purpose: 'reset');
                                      _startCooldown(60);
                                      Get.snackbar('OTP sent', 'Use code 123456', snackPosition: SnackPosition.TOP);
                                    } catch (e) {
                                      final msg = e.toString();
                                      final retry = _parseRetrySeconds(msg);
                                      if (retry != null && retry > 0) _startCooldown(retry);
                                      Get.snackbar('Cannot send OTP', msg, snackPosition: SnackPosition.TOP);
                                    } finally {
                                      setState(() => _loading = false);
                                    }
                                  },
                            child: Text(_retryIn > 0 ? 'Send OTP ($_retryIn s)' : 'Send OTP'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _code,
                      labelText: 'OTP code',
                      hintText: '123456',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.password_outlined),
                      validator: (v) => Validation.required(v, fieldName: 'OTP code'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _newPassword,
                      labelText: 'New password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      obscureText: true,
                      validator: Validation.password,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _confirmPassword,
                      labelText: 'Confirm password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      obscureText: true,
                      validator: (v) => Validation.confirmPassword(v, _newPassword.text),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loading
                          ? null
                          : () async {
                              if (!(_formKey.currentState?.validate() ?? false)) return;

                              setState(() => _loading = true);
                              try {
                                await c.resetPassword(
                                  email: _email.text.trim(),
                                  code: _code.text.trim(),
                                  newPassword: _newPassword.text,
                                );
                                Get.offAllNamed(LoginPage.route);
                                Get.snackbar('Password updated', 'You can now sign in with your new password.', snackPosition: SnackPosition.TOP);
                              } catch (e) {
                                Get.snackbar('Reset failed', e.toString(), snackPosition: SnackPosition.TOP);
                              } finally {
                                setState(() => _loading = false);
                              }
                            },
                      child: _loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Reset password'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


