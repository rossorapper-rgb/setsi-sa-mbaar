import 'package:go_router/go_router.dart';

import '../features/auth/login/login_page.dart';
import '../features/dashboard/admin/dashboard_admin_page.dart';
import '../features/clients/pages/clients_page.dart';
import '../features/clients/pages/add_client_page.dart';
import '../features/interventions/pages/interventions_page.dart';
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

    GoRoute(
      path: '/interventions',
      builder: (context, state) => const InterventionsPage(),
    ),

    GoRoute(
      path: '/clients',
      builder: (context, state) => const ClientsPage(),
    ),

    GoRoute(
      path: '/clients/add',
      builder: (context, state) => const AddClientPage(),
    ),
  ],
);