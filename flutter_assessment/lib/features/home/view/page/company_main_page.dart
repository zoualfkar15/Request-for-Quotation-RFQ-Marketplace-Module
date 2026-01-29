import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../offers/controller/offers_controller.dart';
import '../../../quotations/controller/quotations_controller.dart';
import '../../../requests/controller/requests_controller.dart';
import '../../../offers/view/page/create_offer_page.dart';
import '../../../requests/view/tab/company_requests_tab.dart';
import '../../../offers/view/tab/company_offers_tab.dart';
import '../../../quotations/view/tab/company_quotations_tab.dart';
import '../../../notifications/view/page/notifications_page.dart';
import '../tab/company_profile_tab.dart';

class CompanyMainPage extends StatefulWidget {
  const CompanyMainPage({super.key});

  @override
  State<CompanyMainPage> createState() => _CompanyMainPageState();
}

class _CompanyMainPageState extends State<CompanyMainPage> {
  int _index = 0;
  late final List<_LazyTab> _tabs;
  late final List<Widget?> _built;

  @override
  Widget build(BuildContext context) {
    _built[_index] ??= _tabs[_index].builder();
    final tab = _tabs[_index];

    return Scaffold(
      appBar: AppBar(
        title: Text(tab.title),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(NotificationsPage.route),
            icon: const Icon(Icons.notifications_rounded),
            tooltip: 'Notifications',
          ),
        ],
      ),
      floatingActionButton: tab.fab,
      body: IndexedStack(
        index: _index,
        children: List.generate(
          _tabs.length,
          (i) => _built[i] ?? const SizedBox.shrink(),
          growable: false,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.selectedIcon),
              label: t.label,
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabs = <_LazyTab>[
      _LazyTab(
        label: 'Home',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        title: 'Available requests',
        builder: () => const CompanyRequestsTab(),
        onRefresh: () => Get.find<RequestsController>().loadAvailable(),
      ),
      _LazyTab(
        label: 'Offers',
        icon: Icons.local_offer_outlined,
        selectedIcon: Icons.local_offer_rounded,
        title: 'My offers',
        builder: () => const CompanyOffersTab(),
        onRefresh: () => Get.find<OffersController>().load(),
        fab: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(CreateOfferPage.route),
          icon: const Icon(Icons.add),
          label: const Text('New offer'),
        ),
      ),
      _LazyTab(
        label: 'Quotations',
        icon: Icons.price_change_outlined,
        selectedIcon: Icons.price_change_rounded,
        title: 'My quotations',
        builder: () => const CompanyQuotationsTab(),
        onRefresh: () => Get.find<QuotationsController>().loadMy(),
      ),
      _LazyTab(
        label: 'Profile',
        icon: Icons.person_outline,
        selectedIcon: Icons.person_rounded,
        title: 'Profile',
        builder: () => const CompanyProfileTab(),
      ),
    ];
    _built = List<Widget?>.filled(_tabs.length, null, growable: false);
  }
}

class _LazyTab {
  _LazyTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.title,
    required this.builder,
    this.onRefresh,
    this.fab,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String title;
  final Widget Function() builder;
  final VoidCallback? onRefresh;
  final Widget? fab;
}
