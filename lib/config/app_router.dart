import 'package:firebase_auth/firebase_auth.dart';
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
import '../features/sante/pages/carnet_sante_page.dart';
import '../features/alimentation/pages/alimentation_page.dart';
import '../features/finances/pages/finances_bergerie_page.dart';
import '../features/naissances/pages/naissances_page.dart';
import '../features/rapports/pages/rapports_bergerie_page.dart';
import '../features/parametres/pages/parametres_bergerie_page.dart';
import '../features/parametres/pages/informations_bergerie_page.dart';
import '../features/parametres/pages/personnalisation_bergerie_page.dart';
import '../features/parametres/pages/securite_compte_page.dart';
import '../features/abonnements/pages/abonnements_page.dart';
import '../features/finances/pages/finances_home_page.dart';
import '../features/finances/pages/paiements_page.dart';
import '../features/finances/pages/creances_page.dart';
import '../features/finances/pages/dashboard_financier_page.dart';
import '../features/finances/pages/rapports_financiers_page.dart';
import '../features/stock/pages/stock_bergerie_page.dart';
import '../features/stock/pages/ajouter_produit_page.dart';
import '../features/utilisateurs/pages/utilisateurs_page.dart';
import '../features/utilisateurs/pages/add_utilisateur_page.dart';
import '../features/utilisateurs/pages/utilisateur_details_page.dart';
import '../features/utilisateurs/repository/firebase_utilisateur_repository.dart';

String? _sessionRedirect() {
  if (!CurrentUserService.instance.isLoggedIn) return '/login';
  return null;
}

String? _loginBergerieId(GoRouterState state) {
  final fromRoute = state.uri.queryParameters['bergerie']?.trim();
  if (fromRoute != null && fromRoute.isNotEmpty) {
    return fromRoute;
  }

  final fragment = Uri.base.fragment;
  if (fragment.isNotEmpty) {
    final fragmentUri = Uri.tryParse(fragment);
    final fromFragment = fragmentUri?.queryParameters['bergerie']?.trim();
    if (fromFragment != null && fromFragment.isNotEmpty) {
      return fromFragment;
    }
  }

  // Certains navigateurs/extensions peuvent placer des paramètres avant
  // le fragment Flutter (#). On vérifie également l'URL complète.
  final fullUri = Uri.base;
  final fromFullUri = fullUri.queryParameters['bergerie']?.trim();
  if (fromFullUri != null && fromFullUri.isNotEmpty) {
    return fromFullUri;
  }

  return null;
}

String? _permissionRedirect(String permission) {
  final session = CurrentUserService.instance;
  if (!session.isLoggedIn) return '/login';
  if (session.hasPermission(permission)) return null;
  return '/dashboard/bergerie';
}

String? _responsableParametresRedirect() {
  final session = CurrentUserService.instance;
  if (!session.isLoggedIn) return '/login';
  if (session.role != UserRole.responsable && session.role != UserRole.admin) {
    return '/dashboard/bergerie';
  }
  return null;
}

String? _securiteParametresRedirect() {
  final session = CurrentUserService.instance;
  if (!session.isLoggedIn) return '/login';
  return null;
}

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
  final permission = _permissionRedirect('moutons.view');
  if (permission != null) return permission;
  final currentUser = CurrentUserService.instance.currentUser;
  if (currentUser == null) return '/login';
  final role = CurrentUserService.instance.role;
  if (role != UserRole.admin && role != UserRole.responsable && role != UserRole.technicien && role != UserRole.client) return '/dashboard/bergerie';
  if (role != UserRole.admin && (currentUser.bergerieId == null || currentUser.bergerieId!.trim().isEmpty)) return '/dashboard/bergerie';
  return null;
}

String? _interventionRedirect() {
  final permission = _permissionRedirect('interventions.view');
  if (permission != null) return permission;
  final currentUser = CurrentUserService.instance.currentUser;
  if (currentUser == null) return '/login';
  final role = CurrentUserService.instance.role;
  if (role != UserRole.admin && role != UserRole.responsable && role != UserRole.technicien && role != UserRole.client) return '/dashboard/bergerie';
  return null;
}

String? _gestationRedirect() {
  final permission = _permissionRedirect('gestations.view');
  if (permission != null) return permission;
  final currentUser = CurrentUserService.instance.currentUser;
  if (currentUser == null) return '/login';
  final role = CurrentUserService.instance.role;
  if (role != UserRole.admin && role != UserRole.responsable && role != UserRole.technicien && role != UserRole.client) return '/dashboard/bergerie';
  if (role != UserRole.admin && (currentUser.bergerieId == null || currentUser.bergerieId!.trim().isEmpty)) return '/dashboard/bergerie';
  return null;
}

String? _santeRedirect() {
  final permission = _permissionRedirect('sante.view');
  if (permission != null) return permission;
  final currentUser = CurrentUserService.instance.currentUser;
  if (currentUser == null) return '/login';
  final role = CurrentUserService.instance.role;
  if (role != UserRole.admin && role != UserRole.responsable && role != UserRole.technicien && role != UserRole.client) return '/dashboard/bergerie';
  if (role != UserRole.admin && (currentUser.bergerieId == null || currentUser.bergerieId!.trim().isEmpty)) return '/dashboard/bergerie';
  return null;
}

String? _alimentationRedirect() {
  final session = CurrentUserService.instance;
  if (!session.isLoggedIn) return '/login';
  final currentUser = session.currentUser;
  if (currentUser == null) return '/login';
  final role = session.role;
  final canAccess = session.isAdmin ||
      role == UserRole.responsable ||
      session.hasPermission('alimentation.view') ||
      session.hasPermission('alimentation.edit');
  if (!canAccess) return '/dashboard/bergerie';
  if (role != UserRole.admin && role != UserRole.responsable && role != UserRole.technicien && role != UserRole.client) return '/dashboard/bergerie';
  if (role != UserRole.admin && (currentUser.bergerieId == null || currentUser.bergerieId!.trim().isEmpty)) return '/dashboard/bergerie';
  return null;
}

String? _financeBergerieRedirect() {
  final session = CurrentUserService.instance;
  if (!session.isLoggedIn) return '/login';
  if (!session.isAdmin &&
      !session.hasPermission('depenses.view') &&
      !session.hasPermission('depenses.edit') &&
      !session.hasPermission('ventes.view') &&
      !session.hasPermission('ventes.edit')) {
    return '/dashboard/bergerie';
  }
  if (!session.isAdmin &&
      (session.bergerieId == null || session.bergerieId!.trim().isEmpty)) {
    return '/dashboard/bergerie';
  }
  return null;
}

String? _naissanceRedirect() => _permissionRedirect('naissances.view');
String? _rapportBergerieRedirect() => _permissionRedirect('rapports_financiers.view');

final GoRouter appRouter = GoRouter(
  initialLocation: CurrentUserService.instance.isLoggedIn
      ? (CurrentUserService.instance.isAdmin
          ? '/dashboard/admin'
          : '/dashboard/bergerie')
      : '/login',
  redirect: (context, state) {
    final session = CurrentUserService.instance;
    final isLogin = state.matchedLocation == '/login';

    if (!session.isLoggedIn) {
      return isLogin ? null : '/login';
    }

    if (isLogin) {
      return session.isAdmin ? '/dashboard/admin' : '/dashboard/bergerie';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(
        bergerieId: _loginBergerieId(state),
      ),
    ),
    GoRoute(path: '/dashboard/admin', redirect: (context, state) => _sessionRedirect(), builder: (context, state) => const DashboardAdminPage()),
    GoRoute(path: '/dashboard/bergerie', redirect: (context, state) => _sessionRedirect(), builder: (context, state) => const BergerieDashboardPage()),
    GoRoute(path: '/clients', redirect: (context, state) => _adminOrResponsableRedirect(), builder: (context, state) => const ClientsPage()),
    GoRoute(path: '/clients/add', redirect: (context, state) => _adminOrResponsableRedirect(), builder: (context, state) => const AddClientPage()),
    GoRoute(path: '/bergeries', redirect: (context, state) => _adminResponsableTechnicienRedirect(), builder: (context, state) => const BergeriesPage()),
    GoRoute(path: '/moutons', redirect: (context, state) => _moutonsRedirect(), builder: (context, state) => const MesMoutonsPage()),
    GoRoute(path: '/moutons/add', redirect: (context, state) => _permissionRedirect('moutons.edit'), builder: (context, state) => const AddMoutonPage()),
    GoRoute(path: '/interventions', redirect: (context, state) => _interventionRedirect(), builder: (context, state) => const InterventionsPage()),
    GoRoute(path: '/gestations', redirect: (context, state) => _gestationRedirect(), builder: (context, state) => const GestationsPage()),
    GoRoute(path: '/naissances', redirect: (context, state) => _naissanceRedirect(), builder: (context, state) => const NaissancesPage()),
    GoRoute(path: '/rapports', redirect: (context, state) => _rapportBergerieRedirect(), builder: (context, state) => const RapportsBergeriePage()),
    GoRoute(path: '/parametres', redirect: (context, state) => _permissionRedirect('parametres.view'), builder: (context, state) => const ParametresBergeriePage()),
    GoRoute(path: '/parametres/informations', redirect: (context, state) => _responsableParametresRedirect(), builder: (context, state) => const InformationsBergeriePage()),
    GoRoute(path: '/parametres/personnalisation', redirect: (context, state) => _responsableParametresRedirect(), builder: (context, state) => const PersonnalisationBergeriePage()),
    GoRoute(path: '/parametres/securite', redirect: (context, state) => _securiteParametresRedirect(), builder: (context, state) => const SecuriteComptePage()),
    GoRoute(path: '/allo-veto', redirect: (context, state) => _permissionRedirect('veto.view'), builder: (context, state) => const AlloVetoPage()),
    GoRoute(path: '/carnet-sante', redirect: (context, state) => _santeRedirect(), builder: (context, state) => const CarnetSantePage()),
    GoRoute(path: '/alimentation', redirect: (context, state) => _alimentationRedirect(), builder: (context, state) => const AlimentationPage()),
    GoRoute(path: '/finances', redirect: (context, state) => _financeBergerieRedirect(), builder: (context, state) => const FinancesBergeriePage()),
    GoRoute(path: '/stock', redirect: (context, state) => _sessionRedirect(), builder: (context, state) => const StockBergeriePage()),
    GoRoute(path: '/stock/ajouter', redirect: (context, state) => _sessionRedirect(), builder: (context, state) => const AjouterProduitPage()),
    GoRoute(path: '/abonnements', redirect: (context, state) => _adminOnlyRedirect(), builder: (context, state) => const AbonnementsPage()),
    GoRoute(path: '/finances-admin', redirect: (context, state) => _adminOnlyRedirect(), builder: (context, state) => const FinancesHomePage()),
    GoRoute(path: '/paiements', redirect: (context, state) => _adminOnlyRedirect(), builder: (context, state) => const PaiementsPage()),
    GoRoute(path: '/creances', redirect: (context, state) => _adminOnlyRedirect(), builder: (context, state) => const CreancesPage()),
    GoRoute(path: '/dashboard-financier', redirect: (context, state) => _adminOnlyRedirect(), builder: (context, state) => const DashboardFinancierPage()),
    GoRoute(path: '/rapports-financiers', redirect: (context, state) => _adminOrResponsableRedirect(), builder: (context, state) => const RapportsFinanciersPage()),
    GoRoute(path: '/utilisateurs', redirect: (context, state) => _permissionRedirect('utilisateurs.view'), builder: (context, state) => const UtilisateursPage()),
    GoRoute(path: '/utilisateurs/add', redirect: (context, state) => _permissionRedirect('utilisateurs.manage'), builder: (context, state) => const AddUtilisateurPage()),
    GoRoute(path: '/utilisateurs/details/:id', redirect: (context, state) => _permissionRedirect('utilisateurs.view'), builder: (context, state) {
      final id = state.pathParameters['id'];
      if (id == null || id.isEmpty) return const Scaffold(body: Center(child: Text('Utilisateur introuvable.')));
      return UtilisateurDetailsPage(utilisateurId: id);
    }),
    GoRoute(path: '/utilisateurs/edit/:id', redirect: (context, state) => _permissionRedirect('utilisateurs.manage'), builder: (context, state) {
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
    }),
  ],
);
