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

class _GestationDetailsPageState extends State<GestationDetailsPage> {
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }

  bool get _miseBasEffectuee =>
      _gestation.dateMiseBas != null || _gestation.terminee;

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
                    _info('Date saillie', _formatDate(_gestation.dateSaillie)),
                    _info(
                      'Mise bas prévue',
                      _formatDate(_gestation.dateProbableMiseBas),
                    ),
                    if (!_miseBasEffectuee) ...[
                      _info('Jours écoulés', '${_gestation.joursGestation}'),
                      _info('Jours restants', '${_gestation.joursRestants}'),
                    ],
                    if (_gestation.observations.isNotEmpty)
                      _info('Observations', _gestation.observations),
                  ],
                ),
              ),
            ),
            if (_gestation.dateMiseBas != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Résultat de la mise bas',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _info(
                        'Date de mise bas',
                        _formatDate(_gestation.dateMiseBas!),
                      ),
                      _info(
                        'Nombre d\'agneaux',
                        '${_gestation.nombreAgneaux}',
                      ),
                      _info('Mâles', '${_gestation.nombreMales}'),
                      _info('Femelles', '${_gestation.nombreFemelles}'),
                      _info('Mort-nés', '${_gestation.nombreMortNes}'),
                    ],
                  ),
                ),
              ),
            ],
            if (!_miseBasEffectuee) ...[
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
          ],
        ),
      ),
    );
  }
}
