import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/client_provider.dart';
import '../widgets/client_actions_bar.dart';
import '../widgets/client_card.dart';
import '../widgets/client_search_bar.dart';
import '../widgets/client_stats.dart';
import 'client_details_page.dart';
import 'edit_client_page.dart';

class ClientsPage extends ConsumerWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientProvider);

    final totalClients = clients.length;

    final totalMoutons = clients.fold<int>(
      0,
          (total, client) => total + client.nombreMoutons,
    );

    final totalTroupeaux = clients.fold<int>(
      0,
          (total, client) => total + client.nombreTroupeaux,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //====================================================
              // HEADER
              //====================================================

              const Row(
                children: [
                  Icon(
                    Icons.people_alt_rounded,
                    size: 34,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Gestion des clients",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              //====================================================
              // STATISTIQUES
              //====================================================

              ClientStats(
                totalClients: totalClients,
                totalMoutons: totalMoutons,
                totalTroupeaux: totalTroupeaux,
              ),

              const SizedBox(height: 24),

              //====================================================
              // BARRE D'ACTIONS
              //====================================================

              ClientActionsBar(
                totalClients: totalClients,

                onAdd: () {
                  context.push('/clients/add');
                },

                onRefresh: () {
                  // À connecter plus tard
                },

                onExportPdf: () {
                  // À connecter plus tard
                },

                onExportExcel: () {
                  // À connecter plus tard
                },
              ),

              const SizedBox(height: 24),

              //====================================================
              // RECHERCHE
              //====================================================

              ClientSearchBar(
                hintText: "Rechercher un client...",
                onChanged: (value) {
                  // Recherche à implémenter
                },
              ),

              const SizedBox(height: 24),

              //====================================================
              // LISTE DES CLIENTS
              //====================================================

              Expanded(
                child: ListView.builder(
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    return ClientCard(
                      client: clients[index],

                      onView: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClientDetailsPage(
                              client: clients[index],
                            ),
                          ),
                        );
                      },

                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditClientPage(
                              client: clients[index],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}