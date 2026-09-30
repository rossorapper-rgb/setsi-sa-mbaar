import 'package:flutter/material.dart';
import '../../auth/login/login_page.dart';
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
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _chargerBergerie();
  }

  Future<void> _chargerBergerie() async {
    try {
      final bergerie =
          await _repository.getBergerieBySlug(widget.slug);

      if (!mounted) return;

      if (bergerie == null || !bergerie.active) {
        setState(() {
          _loading = false;
          _error = 'Bergerie introuvable ou inactive.';
        });
        return;
      }

      setState(() {
        _bergerieId = bergerie.id;
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

    return LoginPage(bergerieId: _bergerieId);
  }
}
