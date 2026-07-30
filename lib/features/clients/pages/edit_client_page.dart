import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/client_model.dart';
import '../providers/client_provider.dart';

class EditClientPage extends ConsumerStatefulWidget {
  final ClientModel client;

  const EditClientPage({
    super.key,
    required this.client,
  });

  @override
  ConsumerState<EditClientPage> createState() =>
      _EditClientPageState();
}

class _EditClientPageState
    extends ConsumerState<EditClientPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomController;
  late final TextEditingController _telephoneController;
  late final TextEditingController _quartierController;
  late final TextEditingController _adresseController;
  late final TextEditingController _troupeauxController;
  late final TextEditingController _moutonsController;

  late String _abonnement;
  late bool _actif;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nomController =
        TextEditingController(text: widget.client.nom);

    _telephoneController =
        TextEditingController(
          text: widget.client.telephone,
        );

    _quartierController =
        TextEditingController(
          text: widget.client.quartier,
        );

    _adresseController =
        TextEditingController(
          text: widget.client.adresse,
        );

    _troupeauxController =
        TextEditingController(
          text: widget.client.nombreTroupeaux.toString(),
        );

    _moutonsController =
        TextEditingController(
          text: widget.client.nombreMoutons.toString(),
        );

    _abonnement = widget.client.abonnement;
    _actif = widget.client.actif;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    _quartierController.dispose();
    _adresseController.dispose();
    _troupeauxController.dispose();
    _moutonsController.dispose();
    super.dispose();
  }

  Future<void> _modifierClient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final client = widget.client.copyWith(
        nom: _nomController.text.trim(),
        telephone: _telephoneController.text.trim(),
        quartier: _quartierController.text.trim(),
        adresse: _adresseController.text.trim(),
        nombreTroupeaux:
        int.tryParse(_troupeauxController.text) ?? 0,
        nombreMoutons:
        int.tryParse(_moutonsController.text) ?? 0,
        abonnement: _abonnement,
        actif: _actif,
      );

      await ref
          .read(clientNotifierProvider.notifier)
          .modifierClient(client);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Client modifié avec succès",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Erreur : $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration(
      String label,
      IconData icon,
      ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le client"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nomController,
              decoration: _inputDecoration(
                "Nom complet",
                Icons.person,
              ),
              validator: (value) =>
              value!.isEmpty ? "Champ obligatoire" : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _telephoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(
                "Téléphone",
                Icons.phone,
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _quartierController,
              decoration: _inputDecoration(
                "Quartier",
                Icons.location_on,
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _adresseController,
              decoration: _inputDecoration(
                "Adresse",
                Icons.home,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _troupeauxController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      "Troupeaux",
                      Icons.home_work,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: TextFormField(
                    controller: _moutonsController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      "Moutons",
                      Icons.pets,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _abonnement,
              decoration: _inputDecoration(
                "Abonnement",
                Icons.workspace_premium,
              ),
              items: const [
                DropdownMenuItem(
                  value: "Essentiel",
                  child: Text("Essentiel"),
                ),
                DropdownMenuItem(
                  value: "Confort",
                  child: Text("Confort"),
                ),
                DropdownMenuItem(
                  value: "Prestige",
                  child: Text("Prestige"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _abonnement = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              value: _actif,
              title: const Text("Client actif"),
              onChanged: (value) {
                setState(() {
                  _actif = value;
                });
              },
            ),

            const SizedBox(height: 30),

            FilledButton.icon(
              onPressed: _isSaving ? null : _modifierClient,
              icon: _isSaving
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.save),
              label: Text(
                _isSaving
                    ? "Enregistrement..."
                    : "Enregistrer les modifications",
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Retour"),
            ),
          ],
        ),
      ),
    );
  }
}