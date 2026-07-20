import 'package:flutter/material.dart';

import 'widgets/dashboard_drawer.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_stats.dart';
import 'widgets/recent_activity.dart';

class DashboardAdminPage extends StatelessWidget {
  const DashboardAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      drawer: isDesktop
          ? null
          : const DashboardDrawer(selectedIndex: 0),

      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop)
              const SizedBox(
                width: 260,
                child: DashboardDrawer(selectedIndex: 0),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    DashboardHeader(),

                    SizedBox(height: 30),

                    DashboardStats(),

                    SizedBox(height: 30),

                    RecentActivity(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}