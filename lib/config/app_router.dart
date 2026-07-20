import 'package:go_router/go_router.dart';

import '../features/auth/login/login_page.dart';
import '../features/dashboard/admin/dashboard_admin_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',

  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

    GoRoute(
      path: '/dashboard/admin',
      builder: (context, state) => const DashboardAdminPage(),
    ),
  ],
);