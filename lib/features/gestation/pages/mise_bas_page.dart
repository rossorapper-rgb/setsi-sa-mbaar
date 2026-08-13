import 'package:flutter/material.dart';

import '../models/gestation_model.dart';
import '../repositories/firebase_gestation_repository.dart';

class MiseBasPage extends StatefulWidget {
  final GestationModel gestation;

  const MiseBasPage({
    super.key,
    required this.gestation,
  });

  @override
  State<MiseBasPage> createState() => _MiseBasPageState();
}

class _MiseBasPageState extends State<MiseBasPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = FirebaseGestationRepository();

  late DateTime _dateMiseBas;

  final _totalCtrl = TextEditingController(text: "1");
  final _obsCtrl = TextEditingController();

  bool _saving = false;

  bool get _miseBasDejaEnregistree {
    return widget.gestation.statut.toLowerCase() == 'terminée' ||
        widget.gestation.dateMiseBas != null ||
        !widget.gestation.active;
  }

  @override
  void initState() {
    super.initState();

    if (_miseBasDejaEnregistree) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "La mise bas de cette gestation a déjà été enregistrée.",
            ),
          ),
        );

        Navigator.pop(context);
      });
      return;
    }

    _dateMiseBas = DateTime.now();
    _obsCtrl.text = widget.gestation.observations;
  }

  @override
  void dispose() {
    _totalCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_miseBasDejaEnregistree) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "La mise bas de cette gestation a déjà été enregistrée.",
            ),
          ),
        );
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final nombreAgneaux = int.tryParse(_totalCtrl.text.trim());
    if (nombreAgneaux == null || nombreAgneaux <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Le nombre total d'agneaux doit être supérieur à zéro.",
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await _repository.enregistrerMiseBas(
        gestationId: widget.gestation.id,
        dateMiseBas: _dateMiseBas,
        nombreAgneaux: nombreAgneaux,
        nombreMales: 0,
        nombreFemelles: 0,
        nombreMortNes: 0,
        observations: _obsCtrl.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Impossible d'enregistrer la mise bas : $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dateMiseBas,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (d != null) {
      setState(() => _dateMiseBas = d);
    }
  }

  Widget _numberField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Champ obligatoire';
        if (int.tryParse(v) == null) return 'Valeur invalide';
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enregistrer la mise bas')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date de mise bas'),
              subtitle: Text(
                  '${_dateMiseBas.day}/${_dateMiseBas.month}/${_dateMiseBas.year}'),
              trailing: const Icon(Icons.calendar_month),
              onTap: _pickDate,
            ),
            _numberField('Nombre total d\'agneaux', _totalCtrl),
            TextFormField(
              controller: _obsCtrl,
              decoration: const InputDecoration(labelText: 'Observations'),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
