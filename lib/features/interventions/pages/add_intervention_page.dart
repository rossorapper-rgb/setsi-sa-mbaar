import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../moutons/models/mouton_model.dart';
import '../../moutons/repository/firebase_mouton_repository.dart';
import '../models/intervention_model.dart';
import '../providers/intervention_provider.dart';

class AddInterventionPage extends ConsumerStatefulWidget {
  const AddInterventionPage({super.key, this.intervention});

  final InterventionModel? intervention;

  @override
  ConsumerState<AddInterventionPage> createState() => _AddInterventionPageState();
}

class _AddInterventionPageState extends ConsumerState<AddInterventionPage> {
  final _formKey = GlobalKey<FormState>();
  final _observationController = TextEditingController();
  final _moutonRepository = FirebaseMoutonRepository();

  static const _types = [
    'Nettoyage de la bergerie',
    'Vaccination',
    'Soin d’un mouton',
    'Désinfection',
    'Vermifugation',
    'Autre',
  ];

  String _type = 'Nettoyage de la bergerie';
  DateTime _date = DateTime.now();
  String? _moutonId;
  String? _moutonNom;
  List<MoutonModel> _moutons = [];
  bool _chargementMoutons = true;
  bool _enregistrement = false;

  bool get _edition => widget.intervention != null;

  @override
  void initState() {
    super.initState();
    final intervention = widget.intervention;
    if (intervention != null) {
      _type = intervention.type;
      _date = intervention.date;
      _moutonId = intervention.moutonId;
      _moutonNom = intervention.moutonNom;
      _observationController.text = intervention.observation;
    }
    _chargerMoutons();
  }

  Future<void> _chargerMoutons() async {
    try {
      final moutons = await _moutonRepository.getMoutons();
      if (!mounted) return;
      setState(() {
        _moutons = moutons;
        _chargementMoutons = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _chargementMoutons = false);
    }
  }

  @override
  void dispose() {
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
    );
    if (date != null && mounted) setState(() => _date = date);
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enregistrement = true);
    try {
      final notifier = ref.read(interventionProvider.notifier);

      if (_edition) {
        await notifier.modifierIntervention(
          widget.intervention!.copyWith(
            type: _type,
            date: _date,
            moutonId: _moutonId,
            moutonNom: _moutonNom,
            observation: _observationController.text.trim(),
          ),
        );
      } else {
        await notifier.ajouterIntervention(
          type: _type,
          date: _date,
          moutonId: _moutonId,
          moutonNom: _moutonNom,
          observation: _observationController.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _enregistrement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(_edition ? 'Modifier une intervention' : 'Nouvelle intervention'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Enregistrez simplement ce qui a été fait dans votre bergerie.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 22),
            DropdownButtonFormField<String>(
              initialValue: _types.contains(_type) ? _type : 'Autre',
              decoration: const InputDecoration(
                labelText: 'Type d’intervention *',
                prefixIcon: Icon(Icons.assignment_rounded),
                border: OutlineInputBorder(),
              ),
              items: _types
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(text: DateFormat('dd/MM/yyyy').format(_date)),
              decoration: InputDecoration(
                labelText: 'Date *',
                prefixIcon: const Icon(Icons.calendar_today_rounded),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit_calendar_rounded),
                  onPressed: _choisirDate,
                ),
              ),
              onTap: _choisirDate,
            ),
            const SizedBox(height: 16),
            if (_chargementMoutons)
              const LinearProgressIndicator()
            else
              DropdownButtonFormField<String?>(
                initialValue: _moutonId,
                decoration: const InputDecoration(
                  labelText: 'Mouton concerné (facultatif)',
                  prefixIcon: Icon(Icons.pets_rounded),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('Toute la bergerie / aucun mouton précis')),
                  ..._moutons.map(
                    (mouton) => DropdownMenuItem<String?>(
                      value: mouton.id,
                      child: Text(mouton.nom),
                    ),
                  ),
                ],
                onChanged: (value) {
                  final mouton = value == null
                      ? null
                      : _moutons.where((m) => m.id == value).firstOrNull;
                  setState(() {
                    _moutonId = value;
                    _moutonNom = mouton?.nom;
                  });
                },
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observationController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Observation (facultative)',
                hintText: 'Ex. Vaccin effectué, nettoyage complet…',
                prefixIcon: Icon(Icons.notes_rounded),
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _enregistrement ? null : _enregistrer,
                icon: _enregistrement
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_enregistrement ? 'Enregistrement…' : 'Enregistrer'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _enregistrement ? null : () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Les interventions sont automatiquement rattachées à votre bergerie.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: primary.withValues(alpha: .7)),
            ),
          ],
        ),
      ),
    );
  }
}
