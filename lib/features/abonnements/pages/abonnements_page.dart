import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/abonnement_provider.dart';
import '../widgets/abonnement_actions_bar.dart';
import '../widgets/abonnement_stats.dart';
import '../widgets/abonnement_card.dart';
import 'add_abonnement_page.dart';

class AbonnementsPage extends ConsumerWidget {
  const AbonnementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final abonnements = ref.watch(abonnementProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Gestion des abonnements'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddAbonnementPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Nouvel abonnement"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AbonnementActionsBar(total: abonnements.length),
            const SizedBox(height: 20),
            AbonnementStats(abonnements: abonnements),
            const SizedBox(height: 20),
            Expanded(
              child: abonnements.isEmpty
                  ? const Center(
                      child: Text("Aucun abonnement enregistré."),
                    )
                  : ListView.builder(
                      itemCount: abonnements.length,
                      itemBuilder: (_, index) => AbonnementCard(
                        abonnement: abonnements[index],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
