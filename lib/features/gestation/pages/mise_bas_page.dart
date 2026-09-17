import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/cloudinary_config.dart';
import '../../../core/config/current_bergerie_config.dart';
import '../../../core/services/cloudinary_image_service.dart';
import '../../../core/session/current_user_service.dart';
import '../models/gestation_model.dart';
import '../repositories/firebase_gestation_repository.dart';

class MiseBasPage extends StatefulWidget {
  final GestationModel gestation;

  const MiseBasPage({super.key, required this.gestation});

  @override
  State<MiseBasPage> createState() => _MiseBasPageState();
}

class _MiseBasPageState extends State<MiseBasPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = FirebaseGestationRepository();
  final _picker = ImagePicker();
  final _cloudinary = const CloudinaryImageService();

  late DateTime _dateMiseBas;
  final _totalCtrl = TextEditingController(text: '1');
  final _malesCtrl = TextEditingController(text: '0');
  final _femellesCtrl = TextEditingController(text: '0');
  final _mortNesCtrl = TextEditingController(text: '0');
  final _obsCtrl = TextEditingController();

  Uint8List? _photoBytes;
  bool _saving = false;
  bool _uploadingPhoto = false;

  Color get _primary => CurrentBergerieConfig.instance.config.couleurPrimaire;
  Color get _orange => CurrentBergerieConfig.instance.config.couleurSecondaire;

  bool get _miseBasDejaEnregistree =>
      widget.gestation.statut.toLowerCase() == 'terminée' ||
      widget.gestation.dateMiseBas != null ||
      !widget.gestation.active;

  @override
  void initState() {
    super.initState();
    if (_miseBasDejaEnregistree) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La mise bas de cette gestation a déjà été enregistrée.')));
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
    _malesCtrl.dispose();
    _femellesCtrl.dispose();
    _mortNesCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      setState(() => _uploadingPhoto = true);
      final image = await _picker.pickImage(source: source, imageQuality: 82, maxWidth: 1600, maxHeight: 1600);
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (mounted) setState(() => _photoBytes = bytes);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible de sélectionner la photo : $e')));
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _showPhotoOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera_rounded, color: _primary),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: _orange),
              title: const Text('Choisir dans la galerie'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_miseBasDejaEnregistree || !_formKey.currentState!.validate()) return;

    final total = int.tryParse(_totalCtrl.text.trim()) ?? 0;
    final males = int.tryParse(_malesCtrl.text.trim()) ?? 0;
    final femelles = int.tryParse(_femellesCtrl.text.trim()) ?? 0;
    final mortNes = int.tryParse(_mortNesCtrl.text.trim()) ?? 0;

    if (total <= 0 || males < 0 || femelles < 0 || mortNes < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vérifiez les nombres saisis.')));
      return;
    }
    if (males + femelles + mortNes > total) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mâles + femelles + mort-nés ne peut pas dépasser le total.')));
      return;
    }

    final bergerieId = CurrentUserService.instance.bergerieId?.trim();
    if (bergerieId == null || bergerieId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bergerie introuvable pour cet utilisateur.')));
      return;
    }

    setState(() => _saving = true);

    try {
      String? photoUrl;
      if (_photoBytes != null) {
        if (!CloudinaryConfig.isConfigured) {
          throw Exception('Cloudinary n’est pas configuré.');
        }
        photoUrl = await _cloudinary.uploadNaissancePhoto(
          bytes: _photoBytes!,
          bergerieId: bergerieId,
          naissanceId: widget.gestation.id,
        );
      }

      await _repository.enregistrerMiseBas(
        gestationId: widget.gestation.id,
        dateMiseBas: _dateMiseBas,
        nombreAgneaux: total,
        nombreMales: males,
        nombreFemelles: femelles,
        nombreMortNes: mortNes,
        observations: _obsCtrl.text.trim(),
        photoUrl: photoUrl,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible d’enregistrer la naissance : $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _dateMiseBas, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (d != null) setState(() => _dateMiseBas = d);
  }

  Widget _numberField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Champ obligatoire';
        final value = int.tryParse(v.trim());
        if (value == null || value < 0) return 'Valeur invalide';
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: const Text('Enregistrer une naissance'),
      ),
      backgroundColor: const Color(0xFFF5F8FC),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mère : ${widget.gestation.nomFemelle}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _primary)),
                  const SizedBox(height: 4),
                  const Text('Enregistrez la mise bas et, si possible, prenez une photo des agneaux.'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _saving || _uploadingPhoto ? null : _showPhotoOptions,
              child: Container(
                height: 220,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _primary.withValues(alpha: .18))),
                clipBehavior: Clip.antiAlias,
                child: _photoBytes == null
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.photo_camera_rounded, size: 48, color: _primary), const SizedBox(height: 10), const Text('Ajouter une photo', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 4), const Text('Appareil photo ou galerie', style: TextStyle(color: Colors.black54))])
                    : Stack(fit: StackFit.expand, children: [Image.memory(_photoBytes!, fit: BoxFit.cover), Positioned(right: 10, top: 10, child: CircleAvatar(backgroundColor: Colors.black54, child: IconButton(onPressed: _showPhotoOptions, icon: const Icon(Icons.edit, color: Colors.white))))]),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date de mise bas', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${_dateMiseBas.day.toString().padLeft(2, '0')}/${_dateMiseBas.month.toString().padLeft(2, '0')}/${_dateMiseBas.year}'),
              trailing: Icon(Icons.calendar_month_rounded, color: _primary),
              onTap: _pickDate,
            ),
            _numberField("Nombre total d'agneaux", _totalCtrl),
            Row(children: [Expanded(child: _numberField('Mâles', _malesCtrl)), const SizedBox(width: 12), Expanded(child: _numberField('Femelles', _femellesCtrl))]),
            _numberField('Mort-nés', _mortNesCtrl),
            TextFormField(controller: _obsCtrl, decoration: const InputDecoration(labelText: 'Observations'), maxLines: 4),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save_rounded),
              label: Text(_saving ? 'Enregistrement...' : 'Enregistrer la naissance'),
            ),
          ],
        ),
      ),
    );
  }
}
