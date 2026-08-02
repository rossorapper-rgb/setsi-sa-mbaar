import 'package:flutter/material.dart';

import 'dashboard_alerts.dart';
import 'dashboard_header.dart';
import 'dashboard_quick_actions.dart';
import 'dashboard_recent_activity.dart';
import 'dashboard_stats.dart';

class DashboardAdminBody extends StatelessWidget {
  const DashboardAdminBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [

          DashboardHeader(),

          SizedBox(height: 30),

          DashboardQuickActions(),

          SizedBox(height: 30),

          DashboardStats(),

          SizedBox(height: 30),

          DashboardAlerts(),

          SizedBox(height: 30),

          RecentActivity(),

        ],
      ),
    );
  }
}