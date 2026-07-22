import 'package:flutter/material.dart';

import '../models/intervention_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/intervention_provider.dart';

class EditInterventionPage extends ConsumerStatefulWidget {
  final InterventionModel intervention;

  const EditInterventionPage({
    super.key,
    required this.intervention,
  });

  @override
  ConsumerState<EditInterventionPage> createState() =>
      _EditInterventionPageState();
}

class _EditInterventionPageState
    extends ConsumerState<EditInterventionPage> {

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _clientController;
  late final TextEditingController _nombreController;
  late final TextEditingController _agentController;
  late final TextEditingController _vehiculeController;
  late final TextEditingController _observationController;

  late DateTime _date;

  late bool _lavage;
  late bool _nettoyage;
  late bool _desinfection;

  @override
  void initState() {
    super.initState();

    _clientController =
        TextEditingController(text: widget.intervention.clientNom);

    _nombreController =
        TextEditingController(
          text: widget.intervention.nombreMoutons.toString(),
        );

    _agentController =
        TextEditingController(text: widget.intervention.agent);

    _vehiculeController =
        TextEditingController(text: widget.intervention.vehicule);

    _observationController =
        TextEditingController(
          text: widget.intervention.observations,
        );

    _date = widget.intervention.dateIntervention;

    _lavage = widget.intervention.lavage;
    _nettoyage = widget.intervention.nettoyageBergerie;
    _desinfection = widget.intervention.desinfection;
  }

  @override
  void dispose() {
    _clientController.dispose();
    _nombreController.dispose();
    _agentController.dispose();
    _vehiculeController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier l'intervention"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [

            TextFormField(
              controller: _clientController,
              decoration: const InputDecoration(
                labelText: "Client",
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _nombreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Nombre de moutons",
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _agentController,
              decoration: const InputDecoration(
                labelText: "Agent",
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _vehiculeController,
              decoration: const InputDecoration(
                labelText: "Véhicule",
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _observationController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Observations",
              ),
            ),

            const SizedBox(height: 24),

            SwitchListTile(
              value: _lavage,
              title: const Text("Lavage"),
              onChanged: (v) {
                setState(() => _lavage = v);
              },
            ),

            SwitchListTile(
              value: _nettoyage,
              title: const Text("Nettoyage bergerie"),
              onChanged: (v) {
                setState(() => _nettoyage = v);
              },
            ),

            SwitchListTile(
              value: _desinfection,
              title: const Text("Désinfection"),
              onChanged: (v) {
                setState(() => _desinfection = v);
              },
            ),

            const SizedBox(height: 30),

            FilledButton.icon(
                onPressed: () {
                  final interventionModifiee = widget.intervention.copyWith(
                    clientNom: _clientController.text.trim(),
                    nombreMoutons: int.tryParse(_nombreController.text) ?? 0,
                    agent: _agentController.text.trim(),
                    vehicule: _vehiculeController.text.trim(),
                    observations: _observationController.text.trim(),
                    dateIntervention: _date,
                    lavage: _lavage,
                    nettoyageBergerie: _nettoyage,
                    desinfection: _desinfection,
                  );

                  ref
                      .read(interventionProvider.notifier)
                      .updateIntervention(interventionModifiee);

                  Navigator.pop(context);
                },
              icon: const Icon(Icons.save),
              label: const Text("Enregistrer les modifications"),
            ),
          ],
        ),
      ),
    );
  }
}