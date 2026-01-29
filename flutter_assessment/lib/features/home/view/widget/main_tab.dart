import 'package:flutter/material.dart';

class MainTab {
  MainTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.title,
    required this.body,
    this.onRefresh,
    this.fab,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String title;
  final Widget body;
  final VoidCallback? onRefresh;
  final Widget? fab;
}
