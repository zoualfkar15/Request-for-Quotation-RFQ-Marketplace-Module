import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/ui/gradient.dart';
import '../../../../core/ui/section_header.dart';
import '../../../auth/controller/auth_controller.dart';

class UserProfileTab extends StatelessWidget {
  const UserProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final u = auth.user.value;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        SectionHeader(
          title: u == null ? 'Account' : u.username,
          subtitle: u == null ? 'RFQ Marketplace' : u.email,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GradientCard(
            gradient: AppGradients.primary,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: const [
                Icon(Icons.verified_user_outlined, color: Colors.white, size: 34),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You are signed in as an end-user. Browse offers and manage your requests.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, height: 1.25),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w900)),
            subtitle: const Text('Sign out from this device'),
            onTap: () => auth.logout(),
          ),
        ),
      ],
    );
  }
}


