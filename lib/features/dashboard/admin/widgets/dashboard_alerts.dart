import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/session/current_user_service.dart';
import '../../../gestation/models/gestation_model.dart';
import '../../../gestation/repositories/firebase_gestation_repository.dart';
import '../../../interventions/models/intervention_model.dart';
import '../../../interventions/providers/intervention_provider.dart';
import '../../../utilisateurs/models/user_role.dart';

class DashboardAlerts extends ConsumerWidget {
  const DashboardAlerts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = CurrentUserService.instance;
    final role = session.role;

    switch (role) {
      case UserRole.admin:
        return _AdminAlerts(
          interventionState: ref.watch(interventionProvider),
        );

      case UserRole.client:
      case UserRole.responsable:
        return _BergerieAlerts(
          bergerieId: session.bergerieId,
          interventionState: ref.watch(interventionProvider),
        );

      case UserRole.technicien:
        return _TechnicienAlerts(
          nomTechnicien: session.nomComplet,
          bergerieId: session.bergerieId,
          interventionState: ref.watch(interventionProvider),
        );

      default:
        return const _AlertsCard(
          alerts: [],
          emptyMessage:
          'Aucune alerte prioritaire à signaler pour le moment.',
        );
    }
  }
}

class _AdminAlerts extends StatelessWidget {
  final AsyncValue<List<InterventionModel>> interventionState;

  const _AdminAlerts({
    required this.interventionState,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_GestationAlertData>(
      future: _loadGestationAlerts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AlertsLoading();
        }

        final data = snapshot.data ??
            const _GestationAlertData(
              misesBasProchaines: 0,
              gestationsEnRetard: 0,
            );

        final interventions = interventionState.maybeWhen(
          data: (items) => items,
          orElse: () => const <InterventionModel>[],
        );

        final today = DateTime.now();

        final interventionsAujourdhui = interventions.where((item) {
          final date = item.dateIntervention;

          return date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
        }).length;

        final alerts = <_Alert>[];

        if (data.misesBasProchaines > 0) {
          alerts.add(
            _Alert(
              icon: Icons.favorite_rounded,
              color: Colors.pink,
              title: '${data.misesBasProchaines} mise(s) bas prévue(s)',
              subtitle:
              'Une mise bas est prévue dans les 15 prochains jours.',
            ),
          );
        }

        if (data.gestationsEnRetard > 0) {
          alerts.add(
            _Alert(
              icon: Icons.warning_amber_rounded,
              color: Colors.red,
              title: '${data.gestationsEnRetard} gestation(s) en retard',
              subtitle: 'Vérifiez les gestations concernées.',
            ),
          );
        }

        if (interventionsAujourdhui > 0) {
          alerts.add(
            _Alert(
              icon: Icons.medical_services_rounded,
              color: Theme.of(context).colorScheme.secondary,
              title:
              '$interventionsAujourdhui intervention(s) aujourd\'hui',
              subtitle:
              'Des interventions sont programmées aujourd\'hui.',
            ),
          );
        }

        return _AlertsCard(
          alerts: alerts,
          emptyMessage:
          'Aucune alerte prioritaire à signaler pour le moment.',
        );
      },
    );
  }

  Future<_GestationAlertData> _loadGestationAlerts() async {
    final repository = FirebaseGestationRepository();

    final results = await Future.wait<int>([
      repository.getNombreMisesBasProchaines(),
      repository.getNombreGestationsEnRetard(),
    ]);

    return _GestationAlertData(
      misesBasProchaines: results[0],
      gestationsEnRetard: results[1],
    );
  }
}

class _BergerieAlerts extends StatelessWidget {
  final String? bergerieId;
  final AsyncValue<List<InterventionModel>> interventionState;

  const _BergerieAlerts({
    required this.bergerieId,
    required this.interventionState,
  });

  @override
  Widget build(BuildContext context) {
    if (bergerieId == null || bergerieId!.isEmpty) {
      return const _AlertsCard(
        alerts: [],
        emptyMessage:
        'Aucune alerte disponible : aucune bergerie n\'est associée au compte.',
      );
    }

    return FutureBuilder<List<GestationModel>>(
      future: FirebaseGestationRepository().getGestationsParBergerie(
        bergerieId!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AlertsLoading();
        }

        final gestations =
            snapshot.data ?? const <GestationModel>[];

        final actives = gestations.where(
              (gestation) => gestation.statut == 'Gestante',
        );

        final misesBas = actives.where(
              (gestation) =>
          gestation.joursRestants >= 0 &&
              gestation.joursRestants <= 15,
        ).length;

        final retards = actives.where(
              (gestation) => gestation.estEnRetard,
        ).length;

        final interventions = interventionState.maybeWhen(
          data: (items) => items
              .where(
                (item) => item.bergerieId == bergerieId,
          )
              .length,
          orElse: () => 0,
        );

        final alerts = <_Alert>[];

        if (misesBas > 0) {
          alerts.add(
            _Alert(
              icon: Icons.favorite_rounded,
              color: Colors.pink,
              title: '$misesBas mise(s) bas prévue(s)',
              subtitle:
              'Une mise bas est prévue dans les 15 prochains jours.',
            ),
          );
        }

        if (retards > 0) {
          alerts.add(
            _Alert(
              icon: Icons.warning_amber_rounded,
              color: Colors.red,
              title: '$retards gestation(s) en retard',
              subtitle: 'Vérifiez les gestations concernées.',
            ),
          );
        }

        if (interventions > 0) {
          alerts.add(
            _Alert(
              icon: Icons.medical_services_rounded,
              color: Theme.of(context).colorScheme.secondary,
              title: '$interventions intervention(s) enregistrée(s)',
              subtitle:
              'Consultez le module Interventions pour le suivi.',
            ),
          );
        }

        return _AlertsCard(
          alerts: alerts,
          emptyMessage:
          'Aucune alerte prioritaire pour votre espace.',
        );
      },
    );
  }
}

class _TechnicienAlerts extends StatelessWidget {
  final String nomTechnicien;
  final String? bergerieId;
  final AsyncValue<List<InterventionModel>> interventionState;

  const _TechnicienAlerts({
    required this.nomTechnicien,
    required this.bergerieId,
    required this.interventionState,
  });

  @override
  Widget build(BuildContext context) {
    final nomRecherche =
    nomTechnicien.trim().toLowerCase();

    final bergerieRecherche =
        bergerieId?.trim() ?? '';

    final interventions = interventionState.maybeWhen(
      data: (items) {
        return items.where((item) {
          final agent =
          item.agent.trim().toLowerCase();

          final memeTechnicien =
              agent == nomRecherche;

          if (!memeTechnicien) {
            return false;
          }

          if (bergerieRecherche.isEmpty) {
            return true;
          }

          return item.bergerieId == bergerieRecherche;
        }).toList();
      },
      orElse: () => const <InterventionModel>[],
    );

    final today = DateTime.now();

    final aujourdHui = interventions.where((item) {
      final date = item.dateIntervention;

      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).length;

    final enCours = interventions.where(
          (item) => item.statut.trim().toLowerCase() == 'en cours',
    ).length;

    final alerts = <_Alert>[];

    if (aujourdHui > 0) {
      alerts.add(
        _Alert(
          icon: Icons.today_rounded,
          color: Theme.of(context).colorScheme.secondary,
          title: '$aujourdHui intervention(s) aujourd\'hui',
          subtitle:
          'Consultez vos interventions programmées.',
        ),
      );
    }

    if (enCours > 0) {
      alerts.add(
        _Alert(
          icon: Icons.pending_actions_rounded,
          color: Theme.of(context).colorScheme.primary,
          title: '$enCours intervention(s) en cours',
          subtitle:
          'Des interventions nécessitent encore votre suivi.',
        ),
      );
    }

    return _AlertsCard(
      alerts: alerts,
      emptyMessage:
      'Aucune alerte concernant vos interventions.',
    );
  }
}

class _AlertsCard extends StatelessWidget {
  final List<_Alert> alerts;
  final String emptyMessage;

  const _AlertsCard({
    required this.alerts,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.notifications_active_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 10),
              Text(
                'Alertes & Priorités',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (alerts.isEmpty)
            _EmptyAlert(message: emptyMessage)
          else
            ...alerts.map(
                  (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _AlertTile(alert: alert),
              ),
            ),
        ],
      ),
    );
  }
}

class _AlertsLoading extends StatelessWidget {
  const _AlertsLoading();

  @override
  Widget build(BuildContext context) {
    return const _AlertsCard(
      alerts: [],
      emptyMessage: 'Chargement des alertes...',
    );
  }
}

class _EmptyAlert extends StatelessWidget {
  final String message;

  const _EmptyAlert({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final _Alert alert;

  const _AlertTile({
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alert.color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
            alert.color.withValues(alpha: .15),
            child: Icon(
              alert.icon,
              color: alert.color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
            color: alert.color,
          ),
        ],
      ),
    );
  }
}

class _Alert {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _Alert({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

class _GestationAlertData {
  final int misesBasProchaines;
  final int gestationsEnRetard;

  const _GestationAlertData({
    required this.misesBasProchaines,
    required this.gestationsEnRetard,
  });
}