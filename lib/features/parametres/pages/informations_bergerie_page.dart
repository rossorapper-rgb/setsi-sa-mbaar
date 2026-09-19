import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/bergerie_config.dart';
import '../../../core/config/current_bergerie_config.dart';
import '../../../core/config/firebase_bergerie_config_repository.dart';
import '../../../core/session/current_user_service.dart';

class InformationsBergeriePage extends StatefulWidget {
  const InformationsBergeriePage({super.key});

  @override
  State<InformationsBergeriePage> createState() => _InformationsBergeriePageState();
}

class _InformationsBergeriePageState extends State<InformationsBergeriePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _adresseController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _saving = false;

  BergerieConfig get _config => CurrentBergerieConfig.instance.config;

  @override
  void initState() {
    super.initState();
    _nomController.text = _config.nomBergerie;
    _adresseController.text = _config.adresse ?? '';
    _telephoneController.text = _config.telephone ?? '';
    _emailController.text = _config.email ?? '';
  }

  @override
  void dispose() {
    _nomController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    super.dispose();
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
      nomBergerie: _nomController.text.trim(),
      telephone: _telephoneController.text.trim(),
      adresse: _adresseController.text.trim(),
      email: _emailController.text.trim(),
    );

    try {
      await FirebaseBergerieConfigRepository().save(updated);
      CurrentBergerieConfig.instance.setConfig(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informations enregistrées avec succès.')),
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

  @override
  Widget build(BuildContext context) {
    final config = _config;
    final primary = config.couleurPrimaire;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations de la bergerie'),
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
                  _Header(
                    config: config,
                    primary: primary,
                  ),
                  const SizedBox(height: 24),
                  _field(
                    controller: _nomController,
                    label: 'Nom de la bergerie',
                    icon: Icons.home_work_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le nom de la bergerie est obligatoire.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _field(
                    controller: _adresseController,
                    label: 'Adresse',
                    icon: Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 16),
                  _field(
                    controller: _telephoneController,
                    label: 'Téléphone',
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _field(
                    controller: _emailController,
                    label: 'E-mail',
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _field(
                    controller: TextEditingController(
                      text: CurrentUserService.instance.currentUser?.nomComplet.trim().isNotEmpty == true
                          ? CurrentUserService.instance.currentUser!.nomComplet.trim()
                          : 'Responsable',
                    ),
                    label: 'Responsable',
                    icon: Icons.person_rounded,
                    enabled: false,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _enregistrer,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(_saving ? 'Enregistrement…' : 'Enregistrer'),
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.config,
    required this.primary,
  });

  final BergerieConfig config;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: config.logo != null
                ? Image.asset(
                    config.logo!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.home_work_rounded,
                      color: primary,
                      size: 32,
                    ),
                  )
                : Icon(
                    Icons.home_work_rounded,
                    color: primary,
                    size: 32,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Les informations générales de votre bergerie.',
              style: TextStyle(
                color: primary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
