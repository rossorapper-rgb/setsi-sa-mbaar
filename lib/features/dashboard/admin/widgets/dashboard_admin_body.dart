import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_alerts.dart';
import 'dashboard_header.dart';
import 'dashboard_quick_actions.dart';
import 'dashboard_recent_activity.dart';
import 'dashboard_stats.dart';

import '../../../../providers/dashboard_provider.dart';

class DashboardAdminBody extends ConsumerWidget {
  const DashboardAdminBody({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(dashboardProvider);

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
