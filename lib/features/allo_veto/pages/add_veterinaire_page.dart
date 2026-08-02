import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/veterinaire_model.dart';
import '../repository/firebase_veterinaire_repository.dart';

class AddVeterinairePage extends StatefulWidget {
  final VeterinaireModel? veterinaire;

  const AddVeterinairePage({
    super.key,
    this.veterinaire,
  });

  bool get isEdition => veterinaire != null;

  @override
  State<AddVeterinairePage> createState() =>
      _AddVeterinairePageState();
}

class _AddVeterinairePageState
    extends State<AddVeterinairePage> {
  final _formKey = GlobalKey<FormState>();

  final _nomController =
  TextEditingController();

  final _telephoneController =
  TextEditingController();

  final _regionController =
  TextEditingController();

  final _specialiteController =
  TextEditingController();

  bool _disponible = true;

  bool _loading = false;

  final FirebaseVeterinaireRepository
  _repository =
  FirebaseVeterinaireRepository();

  @override
  void initState() {
    super.initState();

    if (widget.isEdition) {
      final v = widget.veterinaire!;

      _nomController.text = v.nom;
      _telephoneController.text =
          v.telephone;
      _regionController.text = v.region;
      _specialiteController.text =
          v.specialite;

      _disponible = v.disponible;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    _regionController.dispose();
    _specialiteController.dispose();

    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    final id = widget.isEdition
        ? widget.veterinaire!.id
        : FirebaseFirestore.instance
        .collection("veterinaires")
        .doc()
        .id;

    final veterinaire = VeterinaireModel(
      id: id,
      nom: _nomController.text.trim(),
      telephone:
      _telephoneController.text.trim(),
      region:
      _regionController.text.trim(),
      specialite:
      _specialiteController.text.trim(),
      disponible: _disponible,
    );

    if (widget.isEdition) {
      await _repository
          .updateVeterinaire(veterinaire);
    } else {
      await _repository
          .addVeterinaire(veterinaire);
    }

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdition
              ? "Modifier un vétérinaire"
              : "Ajouter un vétérinaire",
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
          const EdgeInsets.all(20),
          children: [

            TextFormField(
              controller: _nomController,
              decoration:
              const InputDecoration(
                labelText: "Nom",
              ),
              validator: (value) =>
              value == null ||
                  value.isEmpty
                  ? "Champ obligatoire"
                  : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller:
              _telephoneController,
              keyboardType:
              TextInputType.phone,
              decoration:
              const InputDecoration(
                labelText: "Téléphone",
              ),
              validator: (value) =>
              value == null ||
                  value.isEmpty
                  ? "Champ obligatoire"
                  : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller:
              _regionController,
              decoration:
              const InputDecoration(
                labelText:
                "Zone d'intervention",
              ),
              validator: (value) =>
              value == null ||
                  value.isEmpty
                  ? "Champ obligatoire"
                  : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller:
              _specialiteController,
              decoration:
              const InputDecoration(
                labelText:
                "Spécialité",
              ),
            ),

            const SizedBox(height: 20),

            SwitchListTile(
              value: _disponible,
              title: const Text(
                "Disponible",
              ),
              onChanged: (value) {
                setState(() {
                  _disponible = value;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _loading
                    ? null
                    : _enregistrer,
                icon: _loading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.save,
                ),
                label: Text(
                  widget.isEdition
                      ? "Mettre à jour"
                      : "Enregistrer",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}