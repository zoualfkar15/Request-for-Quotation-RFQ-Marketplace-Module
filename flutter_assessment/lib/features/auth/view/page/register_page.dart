import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/ui/gradient.dart';
import '../../../../core/ui/section_header.dart';
import '../../../../core/ui/text_field_widget.dart';
import '../../../../core/validation/validation.dart';
import '../../controller/auth_controller.dart';
import 'login_page.dart';
import 'verify_account_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static const String route = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _companyName = TextEditingController();
  final _phone = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _role = 'user';

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _password.dispose();
    _companyName.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(
              title: 'Let’s get started',
              subtitle: 'Create your account in seconds.',
            ),
            GradientCard(
              gradient: AppGradients.warm,
              padding: const EdgeInsets.all(18),
              child: Row(
                children: const [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 40),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Users post requests. Companies send offers & quotations. Everything updates in real time.',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.25),
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
                      DropdownButtonFormField<String>(
                        value: _role,
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('User')),
                          DropdownMenuItem(value: 'company', child: Text('Company')),
                        ],
                        onChanged: (v) => setState(() => _role = v ?? 'user'),
                        decoration: const InputDecoration(
                          labelText: 'Account type',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                        controller: _username,
                        labelText: 'Username',
                        hintText: 'yourname',
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (v) => Validation.required(v, fieldName: 'Username'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      TextFieldWidget(
                        controller: _password,
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        obscureText: true,
                        validator: Validation.password,
                        textInputAction: _role == 'company' ? TextInputAction.next : TextInputAction.done,
                      ),
                      if (_role == 'company') ...[
                        const SizedBox(height: 12),
                        TextFieldWidget(
                          controller: _companyName,
                          labelText: 'Company name',
                          prefixIcon: const Icon(Icons.apartment_outlined),
                          validator: (v) => Validation.required(v, fieldName: 'Company name'),
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 12),
                        TextFieldWidget(
                          controller: _phone,
                          labelText: 'Phone number',
                          hintText: '+9665XXXXXXXX',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          validator: (v) =>
                              Validation.required(v, fieldName: 'Phone number'),
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Obx(() {
                        return FilledButton(
                          onPressed: c.isLoading.value
                              ? null
                              : () {
                                  if (!(_formKey.currentState?.validate() ?? false)) return;
                                  c.registerUser(
                                    email: _email.text.trim(),
                                    username: _username.text.trim(),
                                    password: _password.text,
                                    role: _role,
                                    companyName: _companyName.text.trim(),
                                    phone: _phone.text.trim(),
                                  );
                                },
                          child: c.isLoading.value
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Create account'),
                        );
                      }),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Get.toNamed(VerifyAccountPage.route, arguments: {'email': _email.text.trim()}),
                        child: const Text('Already have an OTP? Verify account'),
                      ),
                      OutlinedButton(
                        onPressed: () => Get.offAllNamed(LoginPage.route),
                        child: const Text('Back to sign in'),
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
