import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/session/current_user_service.dart';
import '../../../interventions/models/intervention_model.dart';
import '../../../interventions/providers/intervention_provider.dart';
import '../../../utilisateurs/models/user_role.dart';

class RecentActivity extends ConsumerWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = CurrentUserService.instance;
    final role = session.role;

    switch (role) {
      case UserRole.admin:
        return const _AdminRecentActivity();

      case UserRole.client:
      case UserRole.responsable:
        return _FilteredRecentActivity(
          role: role!,
          bergerieId: session.bergerieId,
          interventionState: ref.watch(interventionProvider),
        );

      case UserRole.technicien:
        return _FilteredRecentActivity(
          role: role!,
          bergerieId: session.bergerieId,
          nomTechnicien: session.nomComplet,
          interventionState: ref.watch(interventionProvider),
        );

      default:
        return const _RecentActivityCard(
          activities: [],
          emptyMessage:
          'Aucune activité récente disponible.',
        );
    }
  }
}

class _AdminRecentActivity extends StatelessWidget {
  const _AdminRecentActivity();

  @override
  Widget build(BuildContext context) {
    final activities = <_ActivityItem>[
      const _ActivityItem(
        icon: Icons.person_add_alt_1_rounded,
        color: Colors.blue,
        title: 'Nouveau client enregistré',
        subtitle: 'Mamadou Ndiaye',
        time: 'Il y a 10 min',
      ),
      const _ActivityItem(
        icon: Icons.pets_rounded,
        color: Colors.green,
        title: 'Nouveau mouton ajouté',
        subtitle: 'Bergerie de Grand-Yoff',
        time: '09:15',
      ),
      const _ActivityItem(
        icon: Icons.medical_services_rounded,
        color: Colors.orange,
        title: 'Intervention terminée',
        subtitle: 'Lavage et désinfection',
        time: '08:40',
      ),
      const _ActivityItem(
        icon: Icons.favorite_rounded,
        color: Colors.pink,
        title: 'Nouvelle gestation',
        subtitle: 'Femelle enregistrée',
        time: 'Hier',
      ),
      const _ActivityItem(
        icon: Icons.payments_rounded,
        color: Colors.red,
        title: 'Paiement reçu',
        subtitle: 'Abonnement Confort',
        time: 'Hier',
      ),
    ];

    return _RecentActivityCard(
      activities: activities,
      emptyMessage:
      'Aucune activité récente disponible.',
    );
  }
}

class _FilteredRecentActivity extends StatelessWidget {
  final UserRole role;
  final String? bergerieId;
  final String? nomTechnicien;
  final AsyncValue<List<InterventionModel>> interventionState;

  const _FilteredRecentActivity({
    required this.role,
    required this.bergerieId,
    required this.interventionState,
    this.nomTechnicien,
  });

  @override
  Widget build(BuildContext context) {
    if ((role == UserRole.client ||
        role == UserRole.responsable) &&
        (bergerieId == null || bergerieId!.isEmpty)) {
      return const _RecentActivityCard(
        activities: [],
        emptyMessage:
        'Aucune activité disponible : aucune bergerie n\'est associée au compte.',
      );
    }

    final interventions = interventionState.maybeWhen(
      data: (items) {
        return items.where((item) {
          if (bergerieId != null &&
              bergerieId!.isNotEmpty &&
              item.bergerieId != bergerieId) {
            return false;
          }

          if (role == UserRole.technicien) {
            final nom =
                nomTechnicien?.trim().toLowerCase() ?? '';

            final agent =
            item.agent.trim().toLowerCase();

            if (nom.isEmpty || agent != nom) {
              return false;
            }
          }

          return true;
        }).toList();
      },
      orElse: () => const <InterventionModel>[],
    );

    interventions.sort(
          (a, b) =>
          b.dateIntervention.compareTo(a.dateIntervention),
    );

    final activities = interventions
        .take(5)
        .map(_interventionToActivity)
        .toList();

    String emptyMessage;

    switch (role) {
      case UserRole.client:
        emptyMessage =
        'Aucune activité récente dans votre espace.';
        break;

      case UserRole.responsable:
        emptyMessage =
        'Aucune activité récente dans votre bergerie.';
        break;

      case UserRole.technicien:
        emptyMessage =
        'Aucune activité récente concernant vos interventions.';
        break;

      default:
        emptyMessage =
        'Aucune activité récente disponible.';
    }

    return _RecentActivityCard(
      activities: activities,
      emptyMessage: emptyMessage,
    );
  }

  _ActivityItem _interventionToActivity(
      InterventionModel intervention,
      ) {
    final statut =
    intervention.statut.trim().isEmpty
        ? 'Intervention enregistrée'
        : 'Intervention ${intervention.statut.toLowerCase()}';

    final prestations = <String>[];

    if (intervention.lavage) {
      prestations.add('Lavage');
    }

    if (intervention.nettoyageBergerie) {
      prestations.add('Nettoyage');
    }

    if (intervention.desinfection) {
      prestations.add('Désinfection');
    }

    final description = prestations.isEmpty
        ? intervention.bergerieNom
        : prestations.join(' et ');

    return _ActivityItem(
      icon: Icons.medical_services_rounded,
      color: Colors.orange,
      title: statut,
      subtitle: description.isEmpty
          ? 'Intervention'
          : description,
      time: _formatDate(intervention.dateIntervention),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final target = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final difference =
        today.difference(target).inDays;

    if (difference == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    }

    if (difference == 1) {
      return 'Hier';
    }

    if (difference > 1 && difference < 7) {
      return 'Il y a $difference jours';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _RecentActivityCard extends StatelessWidget {
  final List<_ActivityItem> activities;
  final String emptyMessage;

  const _RecentActivityCard({
    required this.activities,
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: Color(0xFF0B6E4F),
              ),
              SizedBox(width: 10),
              Text(
                'Activités récentes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (activities.isEmpty)
            _EmptyActivity(
              message: emptyMessage,
            )
          else
            ...List.generate(
              activities.length,
                  (index) {
                final activity =
                activities[index];

                return Column(
                  children: [
                    _ActivityTile(
                      activity: activity,
                    ),
                    if (index !=
                        activities.length - 1)
                      const Padding(
                        padding:
                        EdgeInsets.only(left: 26),
                        child: Divider(
                          height: 28,
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  final String message;

  const _EmptyActivity({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF0B6E4F),
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

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
  });

  final _ActivityItem activity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color:
            activity.color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            activity.icon,
            color: activity.color,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                activity.subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color:
            Colors.grey.withValues(alpha: 0.10),
            borderRadius:
            BorderRadius.circular(30),
          ),
          child: Text(
            activity.time,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}