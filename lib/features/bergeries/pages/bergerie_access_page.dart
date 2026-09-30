import 'package:flutter/material.dart';
import '../../auth/login/login_page.dart';
import '../../../core/config/bergerie_config.dart';
import '../../../core/config/public_bergerie_config.dart';
import '../repository/firebase_bergerie_repository.dart';

class BergerieAccessPage extends StatefulWidget {
  const BergerieAccessPage({
    super.key,
    required this.slug,
  });

  final String slug;

  @override
  State<BergerieAccessPage> createState() => _BergerieAccessPageState();
}

class _BergerieAccessPageState extends State<BergerieAccessPage> {
  final FirebaseBergerieRepository _repository =
      FirebaseBergerieRepository();

  String? _bergerieId;
  BergerieConfig? _branding;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _chargerBergerie();
  }

  Future<void> _chargerBergerie() async {
    try {
      // L'accès public se fait avant authentification.
      // On résout donc d'abord l'ID via la configuration publique.
      final publicBergerieId =
          await _repository.getBergerieIdByPublicSlug(widget.slug);

      if (!mounted) return;

      if (publicBergerieId == null || publicBergerieId.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'Bergerie introuvable ou inactive.';
        });
        return;
      }

      final publicConfig =
          await PublicBergerieConfigService.instance.load(
        publicBergerieId,
      );

      final branding = BergerieConfig(
        bergerieId: publicConfig.bergerieId,
        nomBergerie: publicConfig.nomBergerie,
        nomApplication: publicConfig.nomApplication,
        logo: publicConfig.logo,
        imageAccueil: publicConfig.imageAccueil,
        couleurPrimaire: publicConfig.couleurPrimaire,
        couleurSecondaire: publicConfig.couleurSecondaire,
        couleurFond: publicConfig.couleurFond,
        slogan: publicConfig.slogan,
        active: publicConfig.active,
      );

      setState(() {
        _bergerieId = publicBergerieId;
        _branding = branding;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Impossible de charger cette bergerie.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_bergerieId == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _error ?? 'Bergerie introuvable.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return LoginPage(
      bergerieId: _bergerieId,
      initialBranding: _branding,
    );
  }
}
