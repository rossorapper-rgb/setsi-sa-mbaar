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
  State<AddVeterinairePage> createState() => _AddVeterinairePageState();
}

class _AddVeterinairePageState extends State<AddVeterinairePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();

  bool _loading = false;
  final FirebaseVeterinaireRepository _repository =
      FirebaseVeterinaireRepository();

  @override
  void initState() {
    super.initState();
    if (widget.isEdition) {
      final v = widget.veterinaire!;
      _nomController.text = v.nom;
      _telephoneController.text = v.telephone;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final id = widget.isEdition
          ? widget.veterinaire!.id
          : FirebaseFirestore.instance.collection('veterinaires').doc().id;

      final bergerieId = widget.isEdition
          ? widget.veterinaire!.bergerieId
          : '';

      final veterinaire = VeterinaireModel(
        id: id,
        bergerieId: bergerieId,
        nom: _nomController.text.trim(),
        telephone: _telephoneController.text.trim(),
      );

      if (widget.isEdition) {
        await _repository.updateVeterinaire(veterinaire);
      } else {
        await _repository.addVeterinaire(veterinaire);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdition
              ? 'Modifier le vétérinaire'
              : 'Ajouter un vétérinaire',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Champ obligatoire'
                      : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telephoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Champ obligatoire'
                      : null,
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _loading ? null : _enregistrer,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  widget.isEdition ? 'Mettre à jour' : 'Enregistrer',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
