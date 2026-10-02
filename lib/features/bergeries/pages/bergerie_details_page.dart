import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_back_bar.dart';
import '../../clients/models/client_model.dart';
import '../../clients/repositories/firebase_client_repository.dart';
import '../models/bergerie_model.dart';
import 'add_bergerie_page.dart';

class BergerieDetailsPage extends StatefulWidget {
  final BergerieModel bergerie;

  const BergerieDetailsPage({
    super.key,
    required this.bergerie,
  });

  @override
  State<BergerieDetailsPage> createState() => _BergerieDetailsPageState();
}

class _BergerieDetailsPageState extends State<BergerieDetailsPage> {
  final FirebaseClientRepository _clientRepository =
      FirebaseClientRepository();

  ClientModel? _client;

  @override
  void initState() {
    super.initState();
    _chargerClient();
  }

  Future<void> _chargerClient() async {
    final client = await _clientRepository.getClientById(
      widget.bergerie.clientId,
    );

    if (!mounted) return;

    setState(() {
      _client = client;
    });
  }

  Future<void> _modifier() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddBergeriePage(
          isEdition: true,
          bergerie: widget.bergerie,
        ),
      ),
    );

    if (result is BergerieModel && context.mounted) {
      Navigator.pop(context, result);
    }
  }

  void _ouvrirApplication() {
    context.push('/bergerie/' + widget.bergerie.slugEffectif);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBackBar(
        title: 'Détails de la bergerie',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier',
            onPressed: _modifier,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      child: Icon(
                        Icons.home_work,
                        size: 35,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.bergerie.nom,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          _infoTile(
                            icon: Icons.person,
                            title: 'Client',
                            value: _client?.nom ?? 'Chargement...',
                          ),
                          _infoTile(
                            icon: Icons.badge,
                            title: 'Responsable',
                            value: widget.bergerie.responsable,
                          ),
                          _infoTile(
                            icon: Icons.phone,
                            title: 'Téléphone',
                            value: widget.bergerie.telephone,
                          ),
                          _infoTile(
                            icon: Icons.location_on,
                            title: 'Adresse',
                            value: widget.bergerie.adresse,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.login,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: const Text(
                  'Accéder à l’application Bergerie',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Ouvrir l’espace de connexion de cette bergerie',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _ouvrirApplication,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final displayValue = value.trim().isEmpty ? '-' : value;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(displayValue),
    );
  }
}
