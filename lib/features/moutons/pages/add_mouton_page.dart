import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/widgets/app_action_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_date_field.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../core/session/current_user_service.dart';
import '../../../core/services/cloudinary_image_service.dart';
import '../../bergeries/models/bergerie_model.dart';
import '../../bergeries/repository/firebase_bergerie_repository.dart';
import '../models/mouton_model.dart';
import '../repository/firebase_mouton_repository.dart';

class AddMoutonPage extends StatefulWidget {
  final BergerieModel? bergerie;
  final MoutonModel? mouton;

  const AddMoutonPage({
    super.key,
    this.bergerie,
    this.mouton,
  });

  @override
  State<AddMoutonPage> createState() => _AddMoutonPageState();
}

class _AddMoutonPageState extends State<AddMoutonPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseMoutonRepository _repository = FirebaseMoutonRepository();
  final FirebaseBergerieRepository _bergerieRepository =
      FirebaseBergerieRepository();
  final CloudinaryImageService _cloudinaryImageService =
      const CloudinaryImageService();
  final ImagePicker _imagePicker = ImagePicker();
  final Uuid _uuid = const Uuid();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _poidsController = TextEditingController();
  final TextEditingController _couleurController = TextEditingController();

  DateTime? _dateNaissance;
  String _race = 'Ladoum';
  String _sexe = 'Mâle';
  bool _loading = false;
  bool _chargementPhoto = false;

  Uint8List? _photoBytes;
  String _photoUrl = '';
  bool _photoSupprimee = false;

  static const List<DropdownMenuItem<String>> races = [
    DropdownMenuItem(value: 'Ladoum', child: Text('Ladoum')),
    DropdownMenuItem(value: 'Bali-Bali', child: Text('Bali-Bali')),
    DropdownMenuItem(value: 'Touabire', child: Text('Touabire')),
    DropdownMenuItem(value: 'Waralé', child: Text('Waralé')),
    DropdownMenuItem(value: 'Croisé', child: Text('Croisé')),
    DropdownMenuItem(value: 'Autre', child: Text('Autre')),
  ];

  static const List<DropdownMenuItem<String>> sexes = [
    DropdownMenuItem(value: 'Mâle', child: Text('Mâle')),
    DropdownMenuItem(value: 'Femelle', child: Text('Femelle')),
  ];

  @override
  void initState() {
    super.initState();

    if (widget.mouton != null) {
      _chargerMouton();
    } else {
      _numeroController.text = _genererNumeroIdentification();
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

  void _chargerMouton() {
    final mouton = widget.mouton!;

    _nomController.text = mouton.nom;
    _numeroController.text = mouton.numeroIdentification;
    _poidsController.text = mouton.poids.toString();
    _couleurController.text = mouton.couleur;
    _race = mouton.race;
    _sexe = mouton.sexe;
    _dateNaissance = mouton.dateNaissance;
    _photoUrl = mouton.photoUrl;
  }

  String _genererNumeroIdentification() {
    final now = DateTime.now();
    final numero = now.millisecondsSinceEpoch.toString().substring(7);
    return 'MTN-${now.year}-$numero';
  }

  int? get _ageEnMois {
    if (_dateNaissance == null) return null;

    final now = DateTime.now();
    int mois =
        ((now.year - _dateNaissance!.year) * 12) +
        (now.month - _dateNaissance!.month);

    if (now.day < _dateNaissance!.day) {
      mois--;
    }

    return mois < 0 ? 0 : mois;
  }

  String get _texteAge {
    final age = _ageEnMois;

    if (age == null) return 'Non renseigné';
    if (age < 12) return '$age mois';

    final ans = age ~/ 12;
    final mois = age % 12;

    if (mois == 0) return '$ans an${ans > 1 ? 's' : ''}';
    return '$ans an${ans > 1 ? 's' : ''} $mois mois';
  }

  Future<void> _choisirDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateNaissance ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );

    if (date == null) return;
    setState(() => _dateNaissance = date);
  }

  Future<void> _choisirPhoto(ImageSource source) async {
    try {
      setState(() => _chargementPhoto = true);

      final photo = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      if (photo == null) return;

      final bytes = await photo.readAsBytes();

      if (!mounted) return;

      setState(() {
        _photoBytes = bytes;
        _photoSupprimee = false;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Impossible de sélectionner la photo : $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _chargementPhoto = false);
      }
    }
  }

  Future<void> _gererPhoto() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(context);
                  _choisirPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir une photo'),
                onTap: () {
                  Navigator.pop(context);
                  _choisirPhoto(ImageSource.gallery);
                },
              ),
              if (_photoBytes != null || _photoUrl.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Retirer la photo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _photoBytes = null;
                      _photoUrl = '';
                      _photoSupprimee = true;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoPreview() {
    if (_photoBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          _photoBytes!,
          width: double.infinity,
          height: 240,
          fit: BoxFit.cover,
        ),
      );
    }

    if (_photoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          _photoUrl,
          width: double.infinity,
          height: 240,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPhotoPlaceholder(),
        ),
      );
    }

    return _buildPhotoPlaceholder();
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Aucune photo',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            'Ajoutez une photo du mouton',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<String> _televerserPhoto({
    required String bergerieId,
    required String moutonId,
  }) async {
    if (_photoBytes == null) {
      if (_photoSupprimee) return '';
      return _photoUrl;
    }

    return _cloudinaryImageService.uploadMoutonPhoto(
      bytes: _photoBytes!,
      bergerieId: bergerieId,
      moutonId: moutonId,
    );
  }

  Future<String> _resoudreBergerieId() async {
    final utilisateur = CurrentUserService.instance.currentUser;
    final compteBergerieId = utilisateur?.bergerieId?.trim() ?? '';
    final bergerieFournieId = widget.bergerie?.id.trim() ?? '';
    final bergerieId = compteBergerieId.isNotEmpty
        ? compteBergerieId
        : bergerieFournieId;

    if (bergerieId.isEmpty) {
      throw Exception('Aucune bergerie n’est associée à ce compte.');
    }

    if (compteBergerieId.isNotEmpty &&
        bergerieFournieId.isNotEmpty &&
        compteBergerieId != bergerieFournieId) {
      throw Exception(
        'La bergerie sélectionnée ne correspond pas à votre compte.',
      );
    }

    if (widget.mouton != null &&
        widget.mouton!.bergerieId.trim().isNotEmpty &&
        widget.mouton!.bergerieId.trim() != bergerieId) {
      throw Exception('Ce mouton n’appartient pas à votre bergerie.');
    }

    final bergeries = await _bergerieRepository.getAllBergeries();
    final existe = bergeries.any((item) => item.id == bergerieId);

    if (!existe) {
      throw Exception('Bergerie introuvable pour ce compte.');
    }

    return bergerieId;
  }

  Future<String> _resoudreClientId(String bergerieId) async {
    if (widget.mouton != null && widget.mouton!.clientId.trim().isNotEmpty) {
      return widget.mouton!.clientId;
    }

    if (widget.bergerie != null &&
        widget.bergerie!.id == bergerieId &&
        widget.bergerie!.clientId.trim().isNotEmpty) {
      return widget.bergerie!.clientId;
    }

    final bergeries = await _bergerieRepository.getAllBergeries();
    final correspondante = bergeries.where((item) => item.id == bergerieId);

    if (correspondante.isEmpty ||
        correspondante.first.clientId.trim().isEmpty) {
      throw Exception('Client propriétaire de la bergerie introuvable.');
    }

    return correspondante.first.clientId;
  }

  Future<void> _enregistrer() async {
    if (_nomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir le nom du mouton.')),
      );
      return;
    }

    if (_numeroController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez saisir le numéro d'identification."),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final bergerieId = await _resoudreBergerieId();
      final clientId = await _resoudreClientId(bergerieId);
      final moutonId = widget.mouton?.id ?? _uuid.v4();
      final photoUrl = await _televerserPhoto(
        bergerieId: bergerieId,
        moutonId: moutonId,
      );

      final mouton = MoutonModel(
        id: moutonId,
        clientId: clientId,
        bergerieId: bergerieId,
        nom: _nomController.text.trim(),
        numeroIdentification: _numeroController.text.trim(),
        race: _race,
        sexe: _sexe,
        dateNaissance: _dateNaissance,
        poids: _poidsController.text.trim().isEmpty
            ? 0
            : double.tryParse(_poidsController.text.replaceAll(',', '.')) ?? 0,
        couleur: _couleurController.text.trim(),
        photoUrl: photoUrl,
        actif: widget.mouton?.actif ?? true,
        dateCreation: widget.mouton?.dateCreation ?? DateTime.now(),
      );

      if (widget.mouton == null) {
        await _repository.addMouton(mouton);
      } else {
        await _repository.updateMouton(mouton);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            widget.mouton == null
                ? 'Le mouton a été ajouté avec succès.'
                : 'Le mouton a été mis à jour avec succès.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Une erreur est survenue : $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePage(
      title: widget.mouton == null ? 'Ajouter un mouton' : 'Modifier le mouton',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Photo du mouton',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Facultative, mais recommandée pour reconnaître rapidement l’animal.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  _buildPhotoPreview(),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _chargementPhoto ? null : _gererPhoto,
                      icon: _chargementPhoto
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_a_photo_outlined),
                      label: Text(
                        _photoBytes != null || _photoUrl.isNotEmpty
                            ? 'Changer la photo'
                            : 'Ajouter une photo',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Identification',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: _nomController,
                    label: 'Nom du mouton',
                    icon: Icons.pets,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    controller: _numeroController,
                    label: "Numéro d'identification",
                    icon: Icons.qr_code,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Caractéristiques',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppDropdown<String>(
                    label: 'Race',
                    value: _race,
                    icon: Icons.category,
                    items: races,
                    onChanged: (value) {
                      if (value != null) setState(() => _race = value);
                    },
                  ),
                  const SizedBox(height: 18),
                  AppDropdown<String>(
                    label: 'Sexe',
                    value: _sexe,
                    icon: Icons.male,
                    items: sexes,
                    onChanged: (value) {
                      if (value != null) setState(() => _sexe = value);
                    },
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    controller: _poidsController,
                    label: 'Poids (Kg)',
                    icon: Icons.monitor_weight_outlined,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    controller: _couleurController,
                    label: 'Couleur',
                    icon: Icons.palette,
                  ),
                  const SizedBox(height: 18),
                  AppDateField(
                    label: 'Date de naissance',
                    value: _dateNaissance,
                    onTap: _choisirDate,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cake,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Âge : $_texteAge',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            AppActionButton(
              label: widget.mouton == null ? 'Enregistrer' : 'Mettre à jour',
              icon: Icons.save,
              isLoading: _loading,
              onPressed: _loading ? null : _enregistrer,
            ),
          ],
        ),
      ),
    );
  }
}
