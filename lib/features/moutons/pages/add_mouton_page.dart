import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../bergeries/models/bergerie_model.dart';
import '../models/mouton_model.dart';
import '../repository/firebase_mouton_repository.dart';

class AddMoutonPage extends StatefulWidget {
  final BergerieModel bergerie;
  final MoutonModel? mouton;

  const AddMoutonPage({
    super.key,
    required this.bergerie,
    this.mouton,
  });

  @override
  State<AddMoutonPage> createState() => _AddMoutonPageState();
}

class _AddMoutonPageState extends State<AddMoutonPage> {
  final _formKey = GlobalKey<FormState>();

  final FirebaseMoutonRepository _repository =
  FirebaseMoutonRepository();

  final Uuid _uuid = const Uuid();

  final TextEditingController _nomController =
  TextEditingController();

  final TextEditingController _numeroController =
  TextEditingController();

  final TextEditingController _poidsController =
  TextEditingController();

  final TextEditingController _couleurController =
  TextEditingController();

  DateTime? _dateNaissance;

  String _race = "Ladoum";
  String _sexe = "Mâle";

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.mouton != null) {
      _nomController.text = widget.mouton!.nom;
      _numeroController.text = widget.mouton!.numeroIdentification;
      _poidsController.text = widget.mouton!.poids.toString();
      _couleurController.text = widget.mouton!.couleur;
      _race = widget.mouton!.race;
      _sexe = widget.mouton!.sexe;
      _dateNaissance = widget.mouton!.dateNaissance;
    }
  }

@override
  void dispose() {
    _nomController.dispose();
    _numeroController.dispose();
    _poidsController.dispose();
    _couleurController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final mouton = MoutonModel(
        id: widget.mouton?.id ?? _uuid.v4(),
        bergerieId: widget.bergerie.id,
        nom: _nomController.text.trim(),
        numeroIdentification: _numeroController.text.trim(),
        race: _race,
        sexe: _sexe,
        dateNaissance: _dateNaissance,
        poids: double.tryParse(_poidsController.text) ?? 0,
        couleur: _couleurController.text.trim(),
        photoUrl: widget.mouton?.photoUrl ?? "",
        actif: widget.mouton?.actif ?? true,
        dateCreation: widget.mouton?.dateCreation ?? DateTime.now(),
      );

      if (widget.mouton == null) {
        await _repository.addMouton(mouton);
      } else {
        await _repository.updateMouton(mouton);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

Future<void> _choisirDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _dateNaissance = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mouton == null
              ? "Ajouter un mouton"
              : "Modifier le mouton",
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: "Nom",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Nom obligatoire";
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _numeroController,
              decoration: const InputDecoration(
                labelText: "Numéro d'identification",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Numéro obligatoire";
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _race,
              decoration: const InputDecoration(
                labelText: "Race",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Ladoum",
                  child: Text("Ladoum"),
                ),
                DropdownMenuItem(
                  value: "Bali-Bali",
                  child: Text("Bali-Bali"),
                ),
                DropdownMenuItem(
                  value: "Touabire",
                  child: Text("Touabire"),
                ),
                DropdownMenuItem(
                  value: "Waralé",
                  child: Text("Waralé"),
                ),
                DropdownMenuItem(
                  value: "Croisé",
                  child: Text("Croisé"),
                ),
                DropdownMenuItem(
                  value: "Autre",
                  child: Text("Autre"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _race = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _sexe,
              decoration: const InputDecoration(
                labelText: "Sexe",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Mâle",
                  child: Text("Mâle"),
                ),
                DropdownMenuItem(
                  value: "Femelle",
                  child: Text("Femelle"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _sexe = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _poidsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Poids (kg)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _couleurController,
              decoration: const InputDecoration(
                labelText: "Couleur",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: _choisirDate,
              icon: const Icon(Icons.calendar_month),
              label: Text(
                _dateNaissance == null
                    ? "Choisir la date de naissance"
                    : "${_dateNaissance!.day}/${_dateNaissance!.month}/${_dateNaissance!.year}",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _enregistrer,
                icon: const Icon(Icons.save),
                label: Text(
                  _loading
                      ? "Enregistrement..."
                      : (widget.mouton == null ? "Enregistrer" : "Mettre à jour"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}