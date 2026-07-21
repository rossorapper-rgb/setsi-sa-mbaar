// add_intervention_page.dart
//
// VERSION DE BASE PRETE POUR L'INTEGRATION RIVERPOD
//
// Ce fichier est fourni comme base de remplacement.
// Il devra être adapté avec les imports exacts de ton projet
// (InterventionService et interventionProvider).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddInterventionPage extends ConsumerStatefulWidget {
  const AddInterventionPage({super.key});

  @override
  ConsumerState<AddInterventionPage> createState() =>
      _AddInterventionPageState();
}

class _AddInterventionPageState
    extends ConsumerState<AddInterventionPage> {

  final _formKey = GlobalKey<FormState>();

  final _clientController = TextEditingController();
  final _nombreController = TextEditingController();
  final _agentController = TextEditingController();
  final _vehiculeController = TextEditingController();
  final _observationController = TextEditingController();

  DateTime? _date;

  bool _lavage = true;
  bool _nettoyage = false;
  bool _desinfection = false;

  @override
  void dispose() {
    _clientController.dispose();
    _nombreController.dispose();
    _agentController.dispose();
    _vehiculeController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (d != null) {
      setState(() => _date = d);
    }
  }

  void _enregistrer() {
    if (!_formKey.currentState!.validate()) return;

    // Ici viendront :
    //
    // final intervention =
    //     InterventionService.creerIntervention(...);
    //
    // ref.read(interventionProvider.notifier)
    //    .addIntervention(intervention);
    //
    // Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La logique Riverpod sera branchée à cette étape.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle intervention'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _clientController,
                decoration: const InputDecoration(
                  labelText: 'Client',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Client obligatoire' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nombre de moutons',
                  prefixIcon: Icon(Icons.pets),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month),
                title: Text(
                  _date == null
                      ? 'Choisir une date'
                      : '${_date!.day}/${_date!.month}/${_date!.year}',
                ),
                trailing: FilledButton(
                  onPressed: _choisirDate,
                  child: const Text('Date'),
                ),
              ),
              const Divider(height: 32),
              SwitchListTile(
                value: _lavage,
                title: const Text('Lavage'),
                onChanged: (v) => setState(() => _lavage = v),
              ),
              SwitchListTile(
                value: _nettoyage,
                title: const Text('Nettoyage bergerie'),
                onChanged: (v) => setState(() => _nettoyage = v),
              ),
              SwitchListTile(
                value: _desinfection,
                title: const Text('Désinfection'),
                onChanged: (v) => setState(() => _desinfection = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _agentController,
                decoration: const InputDecoration(
                  labelText: 'Agent',
                  prefixIcon: Icon(Icons.groups),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehiculeController,
                decoration: const InputDecoration(
                  labelText: 'Véhicule',
                  prefixIcon: Icon(Icons.local_shipping),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observationController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Observations',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _enregistrer,
                  icon: const Icon(Icons.save),
                  label: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
