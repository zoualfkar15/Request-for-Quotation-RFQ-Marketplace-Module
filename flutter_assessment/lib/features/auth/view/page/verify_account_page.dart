import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/ui/gradient.dart';
import '../../../../core/ui/section_header.dart';
import '../../../../core/ui/text_field_widget.dart';
import '../../../../core/validation/validation.dart';
import '../../controller/auth_controller.dart';

class VerifyAccountPage extends StatefulWidget {
  const VerifyAccountPage({super.key});

  static const String route = '/verify';

  @override
  State<VerifyAccountPage> createState() => _VerifyAccountPageState();
}

class _VerifyAccountPageState extends State<VerifyAccountPage> {
  final _email = TextEditingController();
  final _code = TextEditingController(text: '123456');
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  int _retryIn = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final argEmail = (Get.arguments is Map) ? (Get.arguments['email'] as String?) : null;
    final argRetryIn = (Get.arguments is Map) ? (Get.arguments['retryIn'] as int?) : null;
    if (argEmail != null && argEmail.trim().isNotEmpty) {
      _email.text = argEmail.trim();
    }
    // OTP is already sent before opening this page (signup/login flow),
    // so start the resend cooldown immediately.
    _startCooldown(argRetryIn != null && argRetryIn > 0 ? argRetryIn : 60);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    _code.dispose();
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
      appBar: AppBar(title: const Text('Verify account')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SectionHeader(
            title: 'Verify your account',
            subtitle: 'Enter the OTP code we sent you. (For this assessment the OTP is 123456)',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GradientCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: const [
                  Icon(Icons.verified_outlined, color: Colors.white, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Verification unlocks login. You can resend OTP after 1 minute.',
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
                    TextFieldWidget(
                      controller: _code,
                      labelText: 'OTP code',
                      hintText: '123456',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.password_outlined),
                      validator: (v) => Validation.required(v, fieldName: 'OTP code'),
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
                                await c.verifyOtp(
                                  email: _email.text.trim(),
                                  purpose: 'verify',
                                  code: _code.text.trim(),
                                );
                                Get.snackbar(
                                  'Verified',
                                  'Your account is verified.',
                                  snackPosition: SnackPosition.TOP,
                                );
                              } catch (e) {
                                Get.snackbar('Verification failed', e.toString(), snackPosition: SnackPosition.TOP);
                              } finally {
                                setState(() => _loading = false);
                              }
                            },
                      child: _loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Verify'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _loading || _retryIn > 0
                          ? null
                          : () async {
                              // Validate email only
                              if (Validation.email(_email.text) != null) {
                                _formKey.currentState?.validate();
                                return;
                              }
                              setState(() => _loading = true);
                              try {
                                await c.sendOtp(email: _email.text.trim(), purpose: 'verify');
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
                      child: Text(_retryIn > 0 ? 'Resend OTP ($_retryIn s)' : 'Resend OTP'),
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


