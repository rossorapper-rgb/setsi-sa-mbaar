import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/bergerie_config.dart';
import '../../../core/config/current_bergerie_config.dart';
import '../../../core/config/firebase_bergerie_config_repository.dart';
import '../../../core/services/cloudinary_image_service.dart';
import '../../../core/session/current_user_service.dart';

class PersonnalisationBergeriePage extends StatefulWidget {
  const PersonnalisationBergeriePage({super.key});

  @override
  State<PersonnalisationBergeriePage> createState() =>
      _PersonnalisationBergeriePageState();
}

class _PersonnalisationBergeriePageState
    extends State<PersonnalisationBergeriePage> {
  final _formKey = GlobalKey<FormState>();
  final _sloganController = TextEditingController();
  final _picker = ImagePicker();
  final _cloudinary = const CloudinaryImageService();

  BergerieConfig get _config => CurrentBergerieConfig.instance.config;

  late Color _couleurPrimaire;
  late Color _couleurSecondaire;
  String? _logo;
  Uint8List? _logoPreview;
  String? _imageAccueil;
  Uint8List? _imageAccueilPreview;
  bool _saving = false;
  bool _uploadingLogo = false;

  static const _palettes = <Map<String, Color>>[
    {
      'Bleu': Color(0xFF1597B7),
    },
    {
      'Bleu foncé': Color(0xFF123B63),
    },
    {
      'Vert': Color(0xFF2E9E5B),
    },
    {
      'Orange': Color(0xFFF59A00),
    },
    {
      'Rouge': Color(0xFFC62828),
    },
    {
      'Violet': Color(0xFF6A4FB3),
    },
  ];

  @override
  void initState() {
    super.initState();
    _couleurPrimaire = _config.couleurPrimaire;
    _couleurSecondaire = _config.couleurSecondaire;
    _logo = _config.logo;
    _imageAccueil = _config.imageAccueil;
    _sloganController.text = _config.slogan ?? '';
  }

  @override
  void dispose() {
    _sloganController.dispose();
    super.dispose();
  }

  Future<void> _choisirLogo() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image == null) return;

    setState(() => _uploadingLogo = true);

    try {
      final bytes = await image.readAsBytes();
      final bergerieId = CurrentUserService.instance.bergerieId?.trim();

      if (bergerieId == null || bergerieId.isEmpty) {
        throw Exception('Bergerie introuvable pour cet utilisateur.');
      }

      final url = await _cloudinary.uploadBergerieLogo(
        bytes: bytes,
        bergerieId: bergerieId,
      );

      if (!mounted) return;
      setState(() {
        _logoPreview = bytes;
        _logo = url;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logo chargé avec succès.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de charger le logo : $e')),
      );
    } finally {
      if (mounted) setState(() => _uploadingLogo = false);
    }
  }

  Future<void> _choisirImageAccueil() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1600,
    );
    if (image == null) return;

    setState(() => _uploadingLogo = true);

    try {
      final bytes = await image.readAsBytes();
      final bergerieId = CurrentUserService.instance.bergerieId?.trim();

      if (bergerieId == null || bergerieId.isEmpty) {
        throw Exception('Bergerie introuvable pour cet utilisateur.');
      }

      final url = await _cloudinary.uploadBergerieImageAccueil(
        bytes: bytes,
        bergerieId: bergerieId,
      );

      if (!mounted) return;
      setState(() {
        _imageAccueilPreview = bytes;
        _imageAccueil = url;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image d’accueil chargée avec succès.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de charger l’image : $e')),
      );
    } finally {
      if (mounted) setState(() => _uploadingLogo = false);
    }
  }

  Future<void> _choisirCouleur({
    required String titre,
    required Color actuelle,
    required ValueChanged<Color> onSelected,
  }) async {
    final couleur = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titre),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _palettes.map((item) {
            final nom = item.keys.first;
            final couleur = item.values.first;
            final selected = couleur.value == actuelle.value;

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.pop(context, couleur),
              child: Container(
                width: 104,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? couleur : Colors.black12,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: couleur,
                      child: selected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      nom,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );

    if (couleur != null) {
      setState(() => onSelected(couleur));
    }
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    final bergerieId = CurrentUserService.instance.bergerieId?.trim();
    if (bergerieId == null || bergerieId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bergerie introuvable pour cet utilisateur.')),
      );
      return;
    }

    setState(() => _saving = true);

    final updated = _config.copyWith(
      bergerieId: bergerieId,
      logo: _logo,
      imageAccueil: _imageAccueil,
      couleurPrimaire: _couleurPrimaire,
      couleurSecondaire: _couleurSecondaire,
      slogan: _sloganController.text.trim(),
    );

    try {
      await FirebaseBergerieConfigRepository().save(updated);
      CurrentBergerieConfig.instance.setConfig(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personnalisation enregistrée avec succès.')),
      );
      context.go('/parametres');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l’enregistrement : $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _logoView() {
    if (_logoPreview != null) {
      return Image.memory(
        _logoPreview!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.broken_image_rounded, color: _couleurPrimaire, size: 42),
      );
    }

    final logo = _logo;
    if (logo == null || logo.isEmpty) {
      return Icon(
        Icons.home_work_rounded,
        color: _couleurPrimaire,
        size: 42,
      );
    }

    if (logo.startsWith('http://') || logo.startsWith('https://')) {
      return Image.network(
        logo,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.broken_image_rounded, color: _couleurPrimaire, size: 42),
      );
    }

    return Image.asset(
      logo,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.home_work_rounded, color: _couleurPrimaire, size: 42),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = _couleurPrimaire;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnalisation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/parametres'),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: _logoView(),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _config.nomBergerie,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Personnalisez l’apparence de votre bergerie.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: primary),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _uploadingLogo ? null : _choisirLogo,
                          icon: _uploadingLogo
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.upload_rounded),
                          label: Text(
                            _uploadingLogo
                                ? 'Chargement…'
                                : 'Choisir un logo',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Image d’accueil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 190,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: primary.withValues(alpha: .08),
                    ),
                    child: _imageAccueilPreview != null
                        ? Image.memory(_imageAccueilPreview!, fit: BoxFit.cover)
                        : (_imageAccueil != null && _imageAccueil!.isNotEmpty)
                            ? Image.network(
                                _imageAccueil!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 52,
                                    color: primary,
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 52,
                                  color: primary,
                                ),
                              ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _uploadingLogo ? null : _choisirImageAccueil,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Choisir l’image d’accueil'),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Slogan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _sloganController,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      labelText: 'Slogan de la bergerie',
                      hintText: 'Ex. Une meilleure gestion pour une meilleure bergerie',
                      prefixIcon: Icon(Icons.format_quote_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ColorCard(
                    title: 'Couleur principale',
                    description: 'Utilisée pour les menus et les éléments principaux.',
                    color: _couleurPrimaire,
                    onTap: () => _choisirCouleur(
                      titre: 'Couleur principale',
                      actuelle: _couleurPrimaire,
                      onSelected: (color) => _couleurPrimaire = color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ColorCard(
                    title: 'Couleur secondaire',
                    description: 'Utilisée pour les accents et actions importantes.',
                    color: _couleurSecondaire,
                    onTap: () => _choisirCouleur(
                      titre: 'Couleur secondaire',
                      actuelle: _couleurSecondaire,
                      onSelected: (color) => _couleurSecondaire = color,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _saving || _uploadingLogo ? null : _enregistrer,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        _saving ? 'Enregistrement…' : 'Enregistrer',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorCard extends StatelessWidget {
  const _ColorCard({
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(Icons.palette_rounded, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(description),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
