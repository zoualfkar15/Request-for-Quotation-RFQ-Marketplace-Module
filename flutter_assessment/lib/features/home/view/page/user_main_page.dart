import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../offers/controller/offers_controller.dart';
import '../../../requests/controller/requests_controller.dart';
import '../../../subscriptions/controller/subscriptions_controller.dart';
import '../../../requests/view/page/create_request_page.dart';
import '../../../offers/view/tab/user_offers_tab.dart';
import '../../../requests/view/tab/user_requests_tab.dart';
import '../../../subscriptions/view/tab/subscriptions_tab.dart';
import '../../../notifications/view/page/notifications_page.dart';
import '../tab/user_profile_tab.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({super.key});

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  int _index = 0;
  late final List<_LazyTab> _tabs;
  late final List<Widget?> _built;

  @override
  Widget build(BuildContext context) {
    // Lazy init: create the widget only when the tab is opened the first time.
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
        title: 'Offers',
        builder: () => const UserOffersTab(),
        onRefresh: () => Get.find<OffersController>().load(),
      ),
      _LazyTab(
        label: 'Requests',
        icon: Icons.list_alt_outlined,
        selectedIcon: Icons.list_alt_rounded,
        title: 'My requests',
        builder: () => const UserRequestsTab(),
        onRefresh: () => Get.find<RequestsController>().loadMy(),
        fab: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(CreateRequestPage.route),
          icon: const Icon(Icons.add),
          label: const Text('New request'),
        ),
      ),
      _LazyTab(
        label: 'Subscriptions',
        icon: Icons.bookmark_add_outlined,
        selectedIcon: Icons.bookmark_added_rounded,
        title: 'Subscriptions',
        builder: () => const SubscriptionsTab(),
        onRefresh: () => Get.find<SubscriptionsController>().load(),
      ),
      _LazyTab(
        label: 'Profile',
        icon: Icons.person_outline,
        selectedIcon: Icons.person_rounded,
        title: 'Profile',
        builder: () => const UserProfileTab(),
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
