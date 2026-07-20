import 'package:flutter/material.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text("Gestion des clients"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B6E4F),
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0B6E4F),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          "Ajouter",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          // Navigation vers AddClientPage
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Rechercher un client...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
                itemCount: 10,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF0B6E4F),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),

                      title: Text(
                        "Client ${index + 1}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: const Text(
                        "Grand-Yoff • Pack Prestige",
                      ),

                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                            // Modifier
                              break;

                            case 'delete':
                            // Supprimer
                              break;
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text("Modifier"),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text("Supprimer"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}