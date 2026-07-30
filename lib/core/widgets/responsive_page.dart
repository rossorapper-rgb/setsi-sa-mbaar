import 'package:flutter/material.dart';

class ResponsivePage extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;
  final Widget? drawer;
  final bool center;

  const ResponsivePage({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.floatingActionButton,
    this.drawer,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    double maxWidth;

    if (width >= 1400) {
      maxWidth = 1300;
    } else if (width >= 1200) {
      maxWidth = 1100;
    } else if (width >= 900) {
      maxWidth = 900;
    } else {
      maxWidth = width;
    }

    return Scaffold(
      drawer: drawer,
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: center ? Center(child: child) : child,
            ),
          ),
        ),
      ),
    );
  }
}