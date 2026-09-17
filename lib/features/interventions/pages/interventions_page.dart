import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/intervention_model.dart';
import '../providers/intervention_provider.dart';
import 'add_intervention_page.dart';

class InterventionsPage extends ConsumerWidget {
  const InterventionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interventionsAsync = ref.watch(interventionProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/dashboard/bergerie'),
        ),
        title: const Text('Interventions'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddInterventionPage()),
          );
          if (result == true && context.mounted) {
            await ref.read(interventionProvider.notifier).rafraichir();
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Enregistrer'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(interventionProvider.notifier).rafraichir(),
        child: interventionsAsync.when(
          loading: () => const ListView(
            children: [
              SizedBox(height: 260),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (error, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 120),
              Icon(Icons.error_outline_rounded, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Impossible de charger les interventions.\n$error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => ref.read(interventionProvider.notifier).rafraichir(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réessayer'),
                ),
              ),
            ],
          ),
          data: (interventions) {
            if (interventions.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 100),
                  Icon(Icons.assignment_rounded, size: 72, color: primary.withValues(alpha: .45)),
                  const SizedBox(height: 18),
                  const Text(
                    'Aucune intervention enregistrée',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enregistrez ici les actions réalisées dans votre bergerie.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: interventions.length,
              itemBuilder: (context, index) {
                final intervention = interventions[index];
                return _InterventionCard(
                  intervention: intervention,
                  primary: primary,
                  onEdit: () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => AddInterventionPage(intervention: intervention),
                      ),
                    );
                    if (result == true && context.mounted) {
                      await ref.read(interventionProvider.notifier).rafraichir();
                    }
                  },
                  onDelete: () => _supprimer(context, ref, intervention),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _supprimer(
    BuildContext context,
    WidgetRef ref,
    InterventionModel intervention,
  ) async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer l’intervention ?'),
        content: const Text('Cette intervention sera supprimée définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmer != true || !context.mounted) return;

    try {
      await ref.read(interventionProvider.notifier).supprimerIntervention(intervention.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intervention supprimée.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }
}

class _InterventionCard extends StatelessWidget {
  const _InterventionCard({
    required this.intervention,
    required this.primary,
    required this.onEdit,
    required this.onDelete,
  });

  final InterventionModel intervention;
  final Color primary;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy').format(intervention.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: primary.withValues(alpha: .10),
              child: Icon(Icons.assignment_rounded, color: primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    intervention.type,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  const SizedBox(height: 5),
                  Text('📅 $date', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                  if (intervention.moutonNom != null && intervention.moutonNom!.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      '🐑 ${intervention.moutonNom}',
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ] else ...[
                    const SizedBox(height: 3),
                    const Text(
                      '🐑 Toute la bergerie',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                  if (intervention.observation.trim().isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      intervention.observation,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Modifier')),
                PopupMenuItem(value: 'delete', child: Text('Supprimer')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
