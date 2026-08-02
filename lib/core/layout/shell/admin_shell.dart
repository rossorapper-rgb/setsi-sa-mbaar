import 'package:flutter/material.dart';

import '../../navigation/app_menu_key.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.currentMenu,
    required this.body,
    this.drawer,
    this.appBar,
    this.floatingActionButton,
    this.backgroundColor = const Color(0xFFF5F7FA),
  });

  final AppMenuKey currentMenu;

  final Widget body;

  final Widget? drawer;

  final PreferredSizeWidget? appBar;

  final Widget? floatingActionButton;

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: body,
      ),
    );
  }
}