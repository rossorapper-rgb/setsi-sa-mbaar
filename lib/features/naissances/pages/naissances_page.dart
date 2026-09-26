import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:go_router/go_router.dart';

import '../../../core/config/current_bergerie_config.dart';
import '../../../core/utils/jpeg_exporter.dart';
import '../../gestation/models/gestation_model.dart';
import '../../gestation/repositories/firebase_gestation_repository.dart';
import '../../moutons/pages/add_mouton_page.dart';
import '../../moutons/models/mouton_model.dart';

class NaissancesPage extends StatefulWidget {
  const NaissancesPage({super.key});

  @override
  State<NaissancesPage> createState() => _NaissancesPageState();
}

class _NaissancesPageState extends State<NaissancesPage> {
  final _repository = FirebaseGestationRepository();
  final _searchController = TextEditingController();

  List<GestationModel> _naissances = [];
  bool _loading = true;
  String _recherche = '';

  Color get _primary => CurrentBergerieConfig.instance.config.couleurPrimaire;
  Color get _orange => CurrentBergerieConfig.instance.config.couleurSecondaire;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(() {
      if (mounted) {
        setState(() => _recherche = _searchController.text.trim().toLowerCase());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final all = await _repository.getGestations();
      final result = all.where((g) => g.miseBasEffectuee || g.statut == 'Terminée').toList();
      if (mounted) setState(() => _naissances = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de charger les naissances : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<GestationModel> get _filtered {
    if (_recherche.isEmpty) return _naissances;
    return _naissances.where((g) {
      return g.nomFemelle.toLowerCase().contains(_recherche) ||
          g.belierNom.toLowerCase().contains(_recherche) ||
          g.observations.toLowerCase().contains(_recherche);
    }).toList();
  }

  Future<void> _openBirth(GestationModel naissance) async {
    final result = await showDialog<_NaissanceDialogResult>(
      context: context,
      builder: (_) => _NaissanceDetailsDialog(
        naissance: naissance,
        primary: _primary,
        orange: _orange,
      ),
    );

    if (!mounted) return;

    if (result is GestationModel) {
      setState(() {
        _naissances = _naissances
            .map((item) => item.id == result.id ? result : item)
            .toList();
      });
    } else if (result == _NaissanceDialogResult.deleted ||
        result == _NaissanceDialogResult.completed) {
      setState(() {
        _naissances = _naissances
            .where((item) => item.id != naissance.id)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = CurrentBergerieConfig.instance.config;
    final compact = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: Text('Naissances — ${config.nomBergerie}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/dashboard/bergerie'),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.all(compact ? 14 : 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _primary.withValues(alpha: .12)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: _orange.withValues(alpha: .12),
                    child: Icon(Icons.child_friendly_rounded, color: _orange, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Naissances enregistrées', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('${_naissances.length} mise(s) bas dans votre élevage', style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une mère, un géniteur ou une observation…',
                prefixIcon: Icon(Icons.search_rounded, color: _primary),
                suffixIcon: _recherche.isEmpty
                    ? null
                    : IconButton(icon: const Icon(Icons.clear), onPressed: _searchController.clear),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 14),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filtered.isEmpty)
              _EmptyState(primary: _primary)
            else
              ..._filtered.map((naissance) => _NaissanceCard(
                    naissance: naissance,
                    primary: _primary,
                    orange: _orange,
                    onTap: () => _openBirth(naissance),
                  )),
          ],
        ),
      ),
    );
  }
}

class _NaissanceCard extends StatelessWidget {
  const _NaissanceCard({
    required this.naissance,
    required this.primary,
    required this.orange,
    required this.onTap,
  });

  final GestationModel naissance;
  final Color primary;
  final Color orange;
  final VoidCallback onTap;

  String _date(DateTime? date) {
    if (date == null) return 'Date inconnue';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final photo = naissance.photoUrl;
    final mere = naissance.nomFemelle.isEmpty ? 'Mère sans nom' : naissance.nomFemelle;
    final geniteur = naissance.belierNom.isEmpty ? 'Géniteur non renseigné' : naissance.belierNom;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 68,
                  height: 68,
                  color: primary.withValues(alpha: .08),
                  child: photo == null || photo.isEmpty
                      ? Icon(Icons.photo_camera_back_rounded, color: primary, size: 30)
                      : Image.network(photo, fit: BoxFit.cover, errorBuilder: (_, _, _) => Icon(Icons.broken_image_rounded, color: primary)),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mere, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text('Géniteur : $geniteur', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 3),
                    Text(_date(naissance.dateMiseBas), style: TextStyle(color: primary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text('${naissance.nombreAgneaux} agneau(x) • ${naissance.nombreMales} mâle(s) • ${naissance.nombreFemelles} femelle(s) • ${naissance.nombreMortNes} mort(s)-né(s)', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: orange),
            ],
          ),
        ),
      ),
    );
  }
}

enum _NaissanceDialogResult { deleted, completed }

class _NaissanceDetailsDialog extends StatefulWidget {
  const _NaissanceDetailsDialog({required this.naissance, required this.primary, required this.orange});

  final GestationModel naissance;
  final Color primary;
  final Color orange;

  @override
  State<_NaissanceDetailsDialog> createState() => _NaissanceDetailsDialogState();
}

class _NaissanceDetailsDialogState extends State<_NaissanceDetailsDialog> {
  @override
  void initState() {
    super.initState();
    _naissance = widget.naissance;
  }

  final GlobalKey _ficheKey = GlobalKey();
  bool _saving = false;
  bool _deleting = false;
  late GestationModel _naissance;

  GestationModel get naissance => _naissance;
  Color get primary => widget.primary;
  Color get orange => widget.orange;

  Future<void> _supprimerNaissance() async {
    if (_deleting) return;

    final confirmer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer la naissance ?'),
        content: const Text(
          'Cette action supprimera définitivement la fiche de naissance de cet élevage. '
          'Elle ne supprimera pas automatiquement le mouton ni les agneaux déjà créés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmer != true || !mounted) return;
    setState(() => _deleting = true);

    try {
      await FirebaseGestationRepository().deleteGestation(naissance.id);
      if (!mounted) return;
      Navigator.pop(context, _NaissanceDialogResult.deleted);
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de supprimer la naissance : $e')),
      );
    }
  }

  Future<void> _ajouterDansMoutons() async {
    if (_deleting) return;
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (_) => _AjouterAgneauxPage(naissance: naissance),
      ),
    );
    if (!mounted) return;
    if (result is GestationModel) {
      setState(() => _naissance = result);
      if (result.agneauMoutonIds.length >=
          (result.nombreAgneaux - result.nombreMortNes).clamp(0, result.nombreAgneaux).toInt()) {
        Navigator.pop(context, _NaissanceDialogResult.completed);
      }
    } else if (result == _NaissanceDialogResult.completed) {
      Navigator.pop(context, result);
    }
  }

  Future<void> _saveAsJpeg() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final boundary = _ficheKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('La fiche n’est pas prête.');

      final uiImage = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      uiImage.dispose();
      if (byteData == null) throw StateError('Impossible de créer l’image.');

      final pngBytes = byteData.buffer.asUint8List();
      final decoded = img.decodeImage(pngBytes);
      if (decoded == null) throw StateError('Impossible de convertir la fiche en JPEG.');

      final jpegBytes = Uint8List.fromList(img.encodeJpg(decoded, quality: 92));
      final safeName = (naissance.nomFemelle.trim().isEmpty ? 'naissance' : naissance.nomFemelle.trim())
          .replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
      await saveJpegBytes(jpegBytes, 'fiche_naissance_${safeName}.jpg');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fiche de naissance enregistrée en JPEG.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d’enregistrer la fiche : $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _date(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final mere = naissance.nomFemelle.isEmpty ? 'Mère sans nom' : naissance.nomFemelle;
    final geniteur = naissance.belierNom.isEmpty ? 'Non renseigné' : naissance.belierNom;

    return Dialog(
      child: RepaintBoundary(
        key: _ficheKey,
        child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Fiche de naissance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: primary))),
                  IconButton(onPressed: () => Navigator.pop(context, naissance), icon: const Icon(Icons.close)),
                ],
              ),
              if (naissance.photoUrl != null && naissance.photoUrl!.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(naissance.photoUrl!, width: double.infinity, height: 260, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 16),
              _Info('Mère', mere),
              if (geniteur != 'Non renseigné') _Info('Géniteur', geniteur),
              if (naissance.dateMiseBas != null)
                _Info('Date de mise bas', _date(naissance.dateMiseBas)),
              if (naissance.nombreAgneaux > 0)
                _Info('Total agneaux', '${naissance.nombreAgneaux}'),
              if (naissance.nombreMales > 0)
                _Info('Mâles', '${naissance.nombreMales}'),
              if (naissance.nombreFemelles > 0)
                _Info('Femelles', '${naissance.nombreFemelles}'),
              if (naissance.nombreMortNes > 0)
                _Info('Mort-nés', '${naissance.nombreMortNes}'),
              if (naissance.observations.trim().isNotEmpty)
                _Info('Observations', naissance.observations.trim()),
              if (naissance.belierExterieur &&
                  (naissance.proprietaireBelier?.trim().isNotEmpty ?? false))
                _Info('Propriétaire du géniteur', naissance.proprietaireBelier!.trim()),
              const SizedBox(height: 8),
              if (!_saving && !_deleting) ...[
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _saveAsJpeg,
                      icon: const Icon(Icons.image_rounded),
                      label: const Text('Enregistrer JPEG'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _ajouterDansMoutons,
                      icon: const Icon(Icons.pets_rounded),
                      label: const Text('Ajouter dans Moutons'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: _supprimerNaissance,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Supprimer'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: orange),
                      onPressed: () => Navigator.pop(context, naissance),
                      child: const Text('Fermer'),
                    ),
                  ],
                ),
              ],
              if (_saving || _deleting)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _AjouterAgneauxPage extends StatefulWidget {
  const _AjouterAgneauxPage({required this.naissance});

  final GestationModel naissance;

  @override
  State<_AjouterAgneauxPage> createState() => _AjouterAgneauxPageState();
}

class _AjouterAgneauxPageState extends State<_AjouterAgneauxPage> {
  final _repository = FirebaseGestationRepository();
  final List<MoutonModel> _created = [];
  bool _opening = false;

  GestationModel get naissance => widget.naissance;

  List<String> get _sexesRestants {
    final malesDeja = naissance.agneauSexes.where((s) => s == 'Mâle').length +
        _created.where((m) => m.sexe == 'Mâle').length;
    final femellesDeja = naissance.agneauSexes.where((s) => s == 'Femelle').length +
        _created.where((m) => m.sexe == 'Femelle').length;

    final sexes = <String>[
      ...List<String>.filled(
        (naissance.nombreMales - malesDeja).clamp(0, naissance.nombreMales).toInt(),
        'Mâle',
      ),
      ...List<String>.filled(
        (naissance.nombreFemelles - femellesDeja).clamp(0, naissance.nombreFemelles).toInt(),
        'Femelle',
      ),
    ];

    final totalVivant = (naissance.nombreAgneaux - naissance.nombreMortNes).clamp(
      0,
      naissance.nombreAgneaux,
    ).toInt();

    if (sexes.length < totalVivant - naissance.agneauMoutonIds.length - _created.length) {
      final reste = totalVivant - naissance.agneauMoutonIds.length - _created.length - sexes.length;
      sexes.addAll(List<String>.filled(reste > 0 ? reste : 0, 'Mâle'));
    }

    return sexes;
  }

  int get _totalVivant =>
      (naissance.nombreAgneaux - naissance.nombreMortNes).clamp(0, naissance.nombreAgneaux).toInt();

  int get _dejaAjoutes => naissance.agneauMoutonIds.length + _created.length;

  Future<void> _ajouterSuivant() async {
    if (_opening || _sexesRestants.isEmpty) {
      if (_sexesRestants.isEmpty && _dejaAjoutes >= _totalVivant && mounted) {
        Navigator.pop(context, _NaissanceDialogResult.completed);
      }
      return;
    }

    setState(() => _opening = true);
    final sexe = _sexesRestants.first;

    final result = await Navigator.push<MoutonModel>(
      context,
      MaterialPageRoute(
        builder: (_) => AddMoutonPage(
          initialSexe: sexe,
          initialDateNaissance: naissance.dateMiseBas,
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _opening = false);

    if (result == null) return;

    await _repository.enregistrerAgneauAjoute(
      gestationId: naissance.id,
      moutonId: result.id,
      sexe: result.sexe,
    );

    if (!mounted) return;
    setState(() => _created.add(result));

    if (_sexesRestants.isEmpty) {
      Navigator.pop(context, _NaissanceDialogResult.completed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalVivant;
    final deja = _dejaAjoutes;
    final restants = _sexesRestants;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter les agneaux'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  naissance.nomFemelle.isEmpty
                      ? 'Naissance'
                      : 'Naissance de ${naissance.nomFemelle}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  total == 0
                      ? 'Aucun agneau vivant à ajouter.'
                      : '$deja / $total agneau(x) déjà ajouté(s) dans Moutons.',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                if (total > 0)
                  LinearProgressIndicator(
                    value: total == 0 ? 0 : (deja / total).clamp(0, 1),
                  ),
                const SizedBox(height: 24),
                if (restants.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Tous les agneaux vivants de cette naissance sont déjà enregistrés dans Moutons.',
                      ),
                    ),
                  )
                else ...[
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${deja + 1}'),
                      ),
                      title: Text('Agneau ${deja + 1} sur $total'),
                      subtitle: Text('Sexe prérempli : ${restants.first}'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _opening ? null : _ajouterSuivant,
                      icon: const Icon(Icons.pets_rounded),
                      label: Text('Ajouter l’agneau ${deja + 1}'),
                    ),
                  ),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      final updated = naissance.copyWith(
                        agneauMoutonIds: [
                          ...naissance.agneauMoutonIds,
                          ..._created.map((m) => m.id),
                        ],
                        agneauSexes: [
                          ...naissance.agneauSexes,
                          ..._created.map((m) => m.sexe),
                        ],
                      );
                      Navigator.pop(context, updated);
                    },
                    child: Text(restants.isEmpty ? 'Terminer' : 'Plus tard'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(text: '$label : ', style: const TextStyle(fontWeight: FontWeight.w800)),
              TextSpan(text: value),
            ],
          ),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            Icon(Icons.child_friendly_rounded, size: 54, color: primary.withValues(alpha: .45)),
            const SizedBox(height: 12),
            const Text('Aucune naissance enregistrée', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Les mises bas enregistrées depuis Gestations apparaîtront ici.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
          ],
        ),
      );
}
