import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/session/current_user_service.dart';
import '../features/utilisateurs/models/user_role.dart';
import '../features/auth/login/login_page.dart';
import '../features/dashboard/admin/dashboard_admin_page.dart';
import '../features/dashboard/bergerie/bergerie_dashboard_page.dart';
import '../features/clients/pages/clients_page.dart';
import '../features/clients/pages/add_client_page.dart';
import '../features/bergeries/pages/bergeries_page.dart';
import '../features/moutons/pages/mes_moutons_page.dart';
import '../features/moutons/pages/add_mouton_page.dart';
import '../features/interventions/pages/interventions_page.dart';
import '../features/gestation/pages/gestations_page.dart';
import '../features/allo_veto/pages/allo_veto_page.dart';
import '../features/abonnements/pages/abonnements_page.dart';
import '../features/finances/pages/finances_home_page.dart';
import '../features/finances/pages/paiements_page.dart';
import '../features/finances/pages/creances_page.dart';
import '../features/finances/pages/dashboard_financier_page.dart';
import '../features/finances/pages/rapports_financiers_page.dart';
import '../features/utilisateurs/pages/utilisateurs_page.dart';
import '../features/utilisateurs/pages/add_utilisateur_page.dart';
import '../features/utilisateurs/pages/utilisateur_details_page.dart';
import '../features/utilisateurs/repository/firebase_utilisateur_repository.dart';

String? _adminOnlyRedirect() {
  final currentUser = CurrentUserService.instance.currentUser;
  if (currentUser == null) return '/login';
  if (CurrentUserService.instance.role != UserRole.admin) return '/dashboard/bergerie';
  return null;
}

String? _adminOrResponsableRedirect() {
  final currentUser = CurrentUserService.instance.currentUser;
  if (currentUser == null) return '/login';
  final role = CurrentUserService.instance.role;
  if (role != UserRole.admin && role != UserRole.responsable) return '/dashboard/bergerie';
  return null;
}

String? _adminResponsableTechnicienRedirect() {
  final currentUser = CurrentUserService.instance.currentUser;
  if (currentUser == null) return '/login';
  final role = CurrentUserService.instance.role;
  if (role != UserRole.admin && role != UserRole.responsable && role != UserRole.technicien) return '/dashboard/bergerie';
  return null;
}

String? _moutonsRedirect() {
  final currentUser = CurrentUserService.instance.currentUser;
  if (currentUser == null) return '/login';
  final role = CurrentUserService.instance.role;
  if (role != UserRole.admin && role != UserRole.responsable && role != UserRole.technicien && role != UserRole.client) return '/dashboard/bergerie';
  if (role != UserRole.admin && (currentUser.bergerieId == null || currentUser.bergerieId!.trim().isEmpty)) return '/dashboard/bergerie';
  return null;
}

String? _interventionRedirect() {
  final currentUser = CurrentUserService.instance.currentUser;
  if (currentUser == null) return '/login';
  final role = CurrentUserService.instance.role;
  if (role != UserRole.admin && role != UserRole.responsable && role != UserRole.technicien && role != UserRole.client) return '/dashboard/bergerie';
  return null;
}

String? _gestationRedirect() {
  final currentUser = CurrentUserService.instance.currentUser;
  if (currentUser == null) return '/login';
  final role = CurrentUserService.instance.role;
  if (role != UserRole.admin && role != UserRole.responsable && role != UserRole.technicien && role != UserRole.client) return '/dashboard/bergerie';
  if (role != UserRole.admin && (currentUser.bergerieId == null || currentUser.bergerieId!.trim().isEmpty)) return '/dashboard/bergerie';
  return null;
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/dashboard/admin', builder: (context, state) => const DashboardAdminPage()),
    GoRoute(path: '/dashboard/bergerie', builder: (context, state) => const BergerieDashboardPage()),
    GoRoute(path: '/clients', redirect: (context, state) => _adminOrResponsableRedirect(), builder: (context, state) => const ClientsPage()),
    GoRoute(path: '/clients/add', redirect: (context, state) => _adminOrResponsableRedirect(), builder: (context, state) => const AddClientPage()),
    GoRoute(path: '/bergeries', redirect: (context, state) => _adminResponsableTechnicienRedirect(), builder: (context, state) => const BergeriesPage()),
    GoRoute(path: '/moutons', redirect: (context, state) => _moutonsRedirect(), builder: (context, state) => const MesMoutonsPage()),
    GoRoute(path: '/moutons/add', redirect: (context, state) => _moutonsRedirect(), builder: (context, state) => const AddMoutonPage()),
    GoRoute(path: '/interventions', redirect: (context, state) => _interventionRedirect(), builder: (context, state) => const InterventionsPage()),
    GoRoute(path: '/gestations', redirect: (context, state) => _gestationRedirect(), builder: (context, state) => const GestationsPage()),
    GoRoute(path: '/allo-veto', builder: (context, state) => const AlloVetoPage()),
    GoRoute(path: '/abonnements', redirect: (context, state) => _adminOnlyRedirect(), builder: (context, state) => const AbonnementsPage()),
    GoRoute(path: '/finances', redirect: (context, state) => _adminOnlyRedirect(), builder: (context, state) => const FinancesHomePage()),
    GoRoute(path: '/paiements', redirect: (context, state) => _adminOnlyRedirect(), builder: (context, state) => const PaiementsPage()),
    GoRoute(path: '/creances', redirect: (context, state) => _adminOnlyRedirect(), builder: (context, state) => const CreancesPage()),
    GoRoute(path: '/dashboard-financier', redirect: (context, state) => _adminOnlyRedirect(), builder: (context, state) => const DashboardFinancierPage()),
    GoRoute(path: '/rapports-financiers', redirect: (context, state) => _adminOrResponsableRedirect(), builder: (context, state) => const RapportsFinanciersPage()),
    GoRoute(path: '/utilisateurs', redirect: (context, state) => _adminOnlyRedirect(), builder: (context, state) => const UtilisateursPage()),
    GoRoute(path: '/utilisateurs/add', redirect: (context, state) => _adminOnlyRedirect(), builder: (context, state) => const AddUtilisateurPage()),
    GoRoute(
      path: '/utilisateurs/details/:id',
      redirect: (context, state) => _adminOnlyRedirect(),
      builder: (context, state) {
        final id = state.pathParameters['id'];
        if (id == null || id.isEmpty) return const Scaffold(body: Center(child: Text('Utilisateur introuvable.')));
        return UtilisateurDetailsPage(utilisateurId: id);
      },
    ),
    GoRoute(
      path: '/utilisateurs/edit/:id',
      redirect: (context, state) => _adminOnlyRedirect(),
      builder: (context, state) {
        final id = state.pathParameters['id'];
        if (id == null || id.isEmpty) return const Scaffold(body: Center(child: Text('Utilisateur introuvable.')));
        return FutureBuilder(
          future: FirebaseUtilisateurRepository().getUtilisateurById(id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
            if (snapshot.hasError) return Scaffold(body: Center(child: Text('Erreur : ${snapshot.error}')));
            final utilisateur = snapshot.data;
            if (utilisateur == null) return const Scaffold(body: Center(child: Text('Utilisateur introuvable.')));
            return AddUtilisateurPage(utilisateur: utilisateur);
          },
        );
      },
    ),
  ],
);
