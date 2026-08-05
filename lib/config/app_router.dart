import 'package:go_router/go_router.dart';

import '../features/auth/login/login_page.dart';

import '../features/dashboard/admin/dashboard_admin_page.dart';

import '../features/clients/pages/clients_page.dart';
import '../features/clients/pages/add_client_page.dart';

import '../features/bergeries/pages/bergeries_page.dart';

import '../features/interventions/pages/interventions_page.dart';


import '../features/gestation/pages/gestations_page.dart';
import '../features/allo_veto/pages/allo_veto_page.dart';
import '../features/abonnements/pages/abonnements_page.dart';

// Décommente ces imports uniquement si les pages existent déjà.


// import '../features/paiements/pages/paiements_page.dart';
// import '../features/rapports/pages/rapports_page.dart';
// import '../features/parametres/pages/parametres_page.dart';

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
path: '/clients',
builder: (context, state) => const ClientsPage(),
),

GoRoute(
path: '/clients/add',
builder: (context, state) => const AddClientPage(),
),

GoRoute(
path: '/bergeries',
builder: (context, state) => const BergeriesPage(),
),

GoRoute(
path: '/interventions',
builder: (context, state) => const InterventionsPage(),
),

GoRoute(
path: '/gestations',
builder: (context, state) => const GestationsPage(),
),
      GoRoute(
        path: '/allo-veto',
        builder: (context, state) => const AlloVetoPage(),
      ),
// Décommente ces routes uniquement lorsque les pages existent.


    GoRoute(
      path: '/abonnements',
      builder: (context, state) => const AbonnementsPage(),
    ),
/*
    GoRoute(
      path: '/paiements',
      builder: (context, state) => const PaiementsPage(),
    ),

    GoRoute(
      path: '/rapports',
      builder: (context, state) => const RapportsPage(),
    ),

    GoRoute(
      path: '/parametres',
      builder: (context, state) => const ParametresPage(),
    ),
    */
    ],
);
