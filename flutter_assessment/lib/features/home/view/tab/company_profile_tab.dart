import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/ui/gradient.dart';
import '../../../../core/ui/section_header.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../../requests/view/page/requests_history_page.dart';
import '../../../subscriptions/controller/subscriptions_controller.dart';
import '../../../subscriptions/view/page/subscriptions_page.dart';

class CompanyProfileTab extends StatelessWidget {
  const CompanyProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final u = auth.user.value;
    final subs = Get.find<SubscriptionsController>();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        SectionHeader(
          title: u == null ? 'Company' : (u.companyName ?? u.username),
          subtitle: u == null ? 'RFQ Marketplace' : u.email,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GradientCard(
            gradient: AppGradients.warm,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: const [
                Icon(Icons.apartment_outlined, color: Colors.white, size: 34),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You are signed in as a company. Subscribe to categories to receive requests instantly.',
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
            leading: const Icon(Icons.bookmark_add_outlined),
            title: const Text('Manage subscriptions', style: TextStyle(fontWeight: FontWeight.w900)),
            subtitle: const Text('Choose categories to receive matching requests'),
            onTap: () async {
              await subs.load();
              Get.toNamed(SubscriptionsPage.route);
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.history_rounded),
            title: const Text('Requests history',
                style: TextStyle(fontWeight: FontWeight.w900)),
            subtitle: const Text('Review requests you quoted (accepted/rejected/cancelled)'),
            onTap: () => Get.toNamed(RequestsHistoryPage.route),
          ),
        ),
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


