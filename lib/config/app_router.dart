import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/session/current_user_service.dart';
import '../features/utilisateurs/models/user_role.dart';

import '../features/auth/login/login_page.dart';

import '../features/dashboard/admin/dashboard_admin_page.dart';

import '../features/clients/pages/clients_page.dart';
import '../features/clients/pages/add_client_page.dart';

import '../features/bergeries/pages/bergeries_page.dart';

import '../features/moutons/pages/mes_moutons_page.dart';

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
import '../features/moutons/pages/choisir_bergerie_page.dart';

import '../features/bergeries/models/bergerie_model.dart';
import '../features/moutons/pages/add_mouton_page.dart';
// ============================================================
// ADMIN UNIQUEMENT
// ============================================================

String? _adminOnlyRedirect() {
  final currentUser =
      CurrentUserService.instance.currentUser;

  if (currentUser == null) {
    return '/login';
  }

  if (CurrentUserService.instance.role != UserRole.admin) {
    return '/dashboard/admin';
  }

  return null;
}

// ============================================================
// ADMIN + RESPONSABLE
// ============================================================

String? _adminOrResponsableRedirect() {
  final currentUser =
      CurrentUserService.instance.currentUser;

  if (currentUser == null) {
    return '/login';
  }

  final role = CurrentUserService.instance.role;

  if (role != UserRole.admin &&
      role != UserRole.responsable) {
    return '/dashboard/admin';
  }

  return null;
}

// ============================================================
// ADMIN + RESPONSABLE + TECHNICIEN
// ============================================================

String? _adminResponsableTechnicienRedirect() {
  final currentUser =
      CurrentUserService.instance.currentUser;

  if (currentUser == null) {
    return '/login';
  }

  final role = CurrentUserService.instance.role;

  if (role != UserRole.admin &&
      role != UserRole.responsable &&
      role != UserRole.technicien) {
    return '/dashboard/admin';
  }

  return null;
}

// ============================================================
// CLIENT UNIQUEMENT
// ============================================================

String? _clientOnlyRedirect() {
  final currentUser =
      CurrentUserService.instance.currentUser;

  if (currentUser == null) {
    return '/login';
  }

  if (CurrentUserService.instance.role != UserRole.client) {
    return '/dashboard/admin';
  }

  return null;
}

// ============================================================
// INTERVENTIONS
// ADMIN + RESPONSABLE + TECHNICIEN + CLIENT
// ============================================================

String? _interventionRedirect() {
  final currentUser =
      CurrentUserService.instance.currentUser;

  if (currentUser == null) {
    return '/login';
  }

  final role = CurrentUserService.instance.role;

  if (role != UserRole.admin &&
      role != UserRole.responsable &&
      role != UserRole.technicien &&
      role != UserRole.client) {
    return '/dashboard/admin';
  }

  return null;
}

// ============================================================
// ROUTEUR
// ============================================================

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',

  routes: [
    // ========================================================
    // LOGIN
    // ========================================================

    GoRoute(
      path: '/login',
      builder: (context, state) =>
      const LoginPage(),
    ),

    // ========================================================
    // DASHBOARD
    // ========================================================

    GoRoute(
      path: '/dashboard/admin',
      builder: (context, state) =>
      const DashboardAdminPage(),
    ),

    // ========================================================
    // CLIENTS
    // ADMIN + RESPONSABLE
    // ========================================================

    GoRoute(
      path: '/clients',
      redirect: (context, state) {
        return _adminOrResponsableRedirect();
      },
      builder: (context, state) =>
      const ClientsPage(),
    ),

    GoRoute(
      path: '/clients/add',
      redirect: (context, state) {
        return _adminOrResponsableRedirect();
      },
      builder: (context, state) =>
      const AddClientPage(),
    ),

    // ========================================================
    // BERGERIES
    // ADMIN + RESPONSABLE + TECHNICIEN
    // ========================================================

    GoRoute(
      path: '/bergeries',
      redirect: (context, state) {
        return _adminResponsableTechnicienRedirect();
      },
      builder: (context, state) =>
      const BergeriesPage(),
    ),
    GoRoute(
      path: '/moutons/choisir-bergerie',
      redirect: (context, state) {
        return _clientOnlyRedirect();
      },
      builder: (context, state) =>
      const ChoisirBergeriePage(),
    ),
    // ========================================================
    // MES MOUTONS
    // CLIENT UNIQUEMENT
    // ========================================================

    // ========================================================
// MOUTONS
// CLIENT
// ========================================================

    GoRoute(
      path: '/moutons',
      redirect: (context, state) {
        return _clientOnlyRedirect();
      },
      builder: (context, state) =>
      const MesMoutonsPage(),
    ),

    GoRoute(
      path: '/moutons/add',
      redirect: (context, state) {
        return _clientOnlyRedirect();
      },
      builder: (context, state) {
        final extra = state.extra;

        if (extra is! BergerieModel) {
          return const Scaffold(
            body: Center(
              child: Text(
                "Bergerie non sélectionnée.",
              ),
            ),
          );
        }

        return AddMoutonPage(
          bergerie: extra,
        );
      },
    ),

    // ========================================================
    // INTERVENTIONS
    // ADMIN + RESPONSABLE + TECHNICIEN + CLIENT
    // ========================================================

    GoRoute(
      path: '/interventions',
      redirect: (context, state) {
        return _interventionRedirect();
      },
      builder: (context, state) =>
      const InterventionsPage(),
    ),

    // ========================================================
    // MES GESTATIONS
    // CLIENT UNIQUEMENT
    // ========================================================

    GoRoute(
      path: '/gestations',
      redirect: (context, state) {
        return _clientOnlyRedirect();
      },
      builder: (context, state) =>
      const GestationsPage(),
    ),

    // ========================================================
    // ALLO VETO
    // ========================================================

    GoRoute(
      path: '/allo-veto',
      builder: (context, state) =>
      const AlloVetoPage(),
    ),

    // ========================================================
    // ABONNEMENTS
    // ADMIN UNIQUEMENT
    // ========================================================

    GoRoute(
      path: '/abonnements',
      redirect: (context, state) {
        return _adminOnlyRedirect();
      },
      builder: (context, state) =>
      const AbonnementsPage(),
    ),

    // ========================================================
    // FINANCES
    // ADMIN UNIQUEMENT
    // ========================================================

    GoRoute(
      path: '/finances',
      redirect: (context, state) {
        return _adminOnlyRedirect();
      },
      builder: (context, state) =>
      const FinancesHomePage(),
    ),

    GoRoute(
      path: '/paiements',
      redirect: (context, state) {
        return _adminOnlyRedirect();
      },
      builder: (context, state) =>
      const PaiementsPage(),
    ),

    GoRoute(
      path: '/creances',
      redirect: (context, state) {
        return _adminOnlyRedirect();
      },
      builder: (context, state) =>
      const CreancesPage(),
    ),

    GoRoute(
      path: '/dashboard-financier',
      redirect: (context, state) {
        return _adminOnlyRedirect();
      },
      builder: (context, state) =>
      const DashboardFinancierPage(),
    ),

    // ========================================================
    // RAPPORTS FINANCIERS
    // ADMIN + RESPONSABLE
    // ========================================================

    GoRoute(
      path: '/rapports-financiers',
      redirect: (context, state) {
        return _adminOrResponsableRedirect();
      },
      builder: (context, state) =>
      const RapportsFinanciersPage(),
    ),

    // ========================================================
    // UTILISATEURS
    // ADMIN UNIQUEMENT
    // ========================================================

    GoRoute(
      path: '/utilisateurs',
      redirect: (context, state) {
        return _adminOnlyRedirect();
      },
      builder: (context, state) =>
      const UtilisateursPage(),
    ),

    // ========================================================
    // AJOUT UTILISATEUR
    // ADMIN UNIQUEMENT
    // ========================================================

    GoRoute(
      path: '/utilisateurs/add',
      redirect: (context, state) {
        return _adminOnlyRedirect();
      },
      builder: (context, state) =>
      const AddUtilisateurPage(),
    ),

    // ========================================================
    // DETAILS UTILISATEUR
    // ADMIN UNIQUEMENT
    // ========================================================

    GoRoute(
      path: '/utilisateurs/details/:id',
      redirect: (context, state) {
        return _adminOnlyRedirect();
      },
      builder: (context, state) {
        final utilisateurId = state.pathParameters['id'];

        if (utilisateurId == null || utilisateurId.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text(
                "Utilisateur introuvable.",
              ),
            ),
          );
        }

        return UtilisateurDetailsPage(
          utilisateurId: utilisateurId,
        );
      },
    ),

    // ========================================================
    // MODIFIER UTILISATEUR
    // ADMIN UNIQUEMENT
    // ========================================================

    GoRoute(
      path: '/utilisateurs/edit/:id',
      redirect: (context, state) {
        return _adminOnlyRedirect();
      },
      builder: (context, state) {
        final utilisateurId = state.pathParameters['id'];

        if (utilisateurId == null || utilisateurId.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text(
                "Utilisateur introuvable.",
              ),
            ),
          );
        }

        return FutureBuilder(
          future: FirebaseUtilisateurRepository()
              .getUtilisateurById(utilisateurId),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text(
                    "Modifier utilisateur",
                  ),
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      "Erreur : ${snapshot.error}",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            final utilisateur = snapshot.data;

            if (utilisateur == null) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    "Utilisateur introuvable.",
                  ),
                ),
              );
            }

            return AddUtilisateurPage(
              utilisateur: utilisateur,
            );
          },
        );
      },
    ),
  ],
);