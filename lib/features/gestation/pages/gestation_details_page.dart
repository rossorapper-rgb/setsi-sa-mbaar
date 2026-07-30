import 'package:flutter/material.dart';

import '../models/gestation_model.dart';
import '../repositories/firebase_gestation_repository.dart';
import 'add_gestation_page.dart';
import 'mise_bas_page.dart';

class GestationDetailsPage extends StatefulWidget {
  final GestationModel gestation;

  const GestationDetailsPage({
    super.key,
    required this.gestation,
  });

  @override
  State<GestationDetailsPage> createState() =>
      _GestationDetailsPageState();
}

class _GestationDetailsPageState
    extends State<GestationDetailsPage> {
  final FirebaseGestationRepository _repository =
      FirebaseGestationRepository();

  late GestationModel _gestation;

  @override
  void initState() {
    super.initState();
    _gestation = widget.gestation;
  }

  Future<void> _refresh() async {
    final g = await _repository.getGestationById(_gestation.id);
    if (g != null && mounted) {
      setState(() => _gestation = g);
    }
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold)),
          ),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails gestation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddGestationPage(
                    gestation: _gestation,
                  ),
                ),
              );
              _refresh();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _info('Statut', _gestation.statut),
                    _info(
                        'Date saillie',
                        '${_gestation.dateSaillie.day}/${_gestation.dateSaillie.month}/${_gestation.dateSaillie.year}'),
                    _info(
                        'Mise bas prévue',
                        '${_gestation.dateProbableMiseBas.day}/${_gestation.dateProbableMiseBas.month}/${_gestation.dateProbableMiseBas.year}'),
                    _info('Jours écoulés',
                        '${_gestation.joursGestation}'),
                    _info('Jours restants',
                        '${_gestation.joursRestants}'),
                    if (_gestation.observations.isNotEmpty)
                      _info('Observations',
                          _gestation.observations),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.pets),
              label: const Text('Enregistrer la mise bas'),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MiseBasPage(
                      gestation: _gestation,
                    ),
                  ),
                );
                _refresh();
              },
            ),
          ],
        ),
      ),
    );
  }
}
