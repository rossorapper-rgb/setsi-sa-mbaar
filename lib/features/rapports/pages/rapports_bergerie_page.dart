import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/config/current_bergerie_config.dart';
import '../../../core/session/current_user_service.dart';
import '../../../core/session/local_business_cache_service.dart';

class RapportsBergeriePage extends StatefulWidget {
  const RapportsBergeriePage({super.key});

  @override
  State<RapportsBergeriePage> createState() => _RapportsBergeriePageState();
}

class _RapportsBergeriePageState extends State<RapportsBergeriePage> {
  final _firestore = FirebaseFirestore.instance;
  final _cache = LocalBusinessCacheService.instance;
  final _money = NumberFormat('#,##0', 'fr_FR');
  final _dateFormat = DateFormat('MMMM yyyy', 'fr_FR');

  DateTime _mois = DateTime(DateTime.now().year, DateTime.now().month);
  bool _loading = true;
  String? _error;

  int _moutons = 0;
  int _gestations = 0;
  int _naissances = 0;
  int _soins = 0;
  int _interventions = 0;
  double _alimentation = 0;
  double _ventes = 0;
  double _depenses = 0;

  String? get _bergerieId {
    final id = CurrentUserService.instance.bergerieId?.trim();
    return id == null || id.isEmpty ? null : id;
  }

  @override
  void initState() {
    super.initState();
    _charger();
  }

  String _reportCacheKey(String bergerieId) =>
      'rapport_${bergerieId}_$_mois.year_$_mois.month';

  Future<void> _charger() async {
    final bergerieId = _bergerieId;
    if (bergerieId == null) {
      setState(() {
        _loading = false;
        _error = 'Aucune bergerie associée à ce compte.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final debut = DateTime(_mois.year, _mois.month);
      final fin = DateTime(_mois.year, _mois.month + 1);

      final results = await Future.wait([
        _firestore.collection('moutons').where('bergerieId', isEqualTo: bergerieId).where('actif', isEqualTo: true).get(const GetOptions(source: Source.server)),
        _firestore.collection('gestations').where('bergerieId', isEqualTo: bergerieId).get(const GetOptions(source: Source.server)),
        _firestore.collection('carnet_sante').where('bergerieId', isEqualTo: bergerieId).get(const GetOptions(source: Source.server)),
        _firestore.collection('alimentations').where('bergerieId', isEqualTo: bergerieId).get(const GetOptions(source: Source.server)),
        _firestore.collection('interventions').where('bergerieId', isEqualTo: bergerieId).get(const GetOptions(source: Source.server)),
        _firestore.collection('finance_entries').where('bergerieId', isEqualTo: bergerieId).get(const GetOptions(source: Source.server)),
      ]);

      final report = _calculerRapport(
        debut: debut,
        fin: fin,
        moutons: results[0].docs.map((d) => {...d.data(), 'id': d.id}).toList(),
        gestations: results[1].docs.map((d) => {...d.data(), 'id': d.id}).toList(),
        soins: results[2].docs.map((d) => {...d.data(), 'id': d.id}).toList(),
        alimentations: results[3].docs.map((d) => {...d.data(), 'id': d.id}).toList(),
        interventions: results[4].docs.map((d) => {...d.data(), 'id': d.id}).toList(),
        finances: results[5].docs.map((d) => {...d.data(), 'id': d.id}).toList(),
      );

      await _cache.saveList(_reportCacheKey(bergerieId), [report]);
      _appliquerRapport(report);
    } catch (_) {
      try {
        final local = await Future.wait([
          _cache.loadList('moutons_${bergerieId}'),
          _cache.loadList('gestations_${bergerieId}'),
          _cache.loadList('carnet_sante_${bergerieId}'),
          _cache.loadList('alimentations_${bergerieId}'),
          _cache.loadList('interventions_${bergerieId.trim()}'),
          _cache.loadList('finances_${bergerieId}'),
        ]);

        final hasLocalData = local.any((items) => items != null);
        if (hasLocalData) {
          final report = _calculerRapport(
            debut: DateTime(_mois.year, _mois.month),
            fin: DateTime(_mois.year, _mois.month + 1),
            moutons: local[0] ?? const [],
            gestations: local[1] ?? const [],
            soins: local[2] ?? const [],
            alimentations: local[3] ?? const [],
            interventions: local[4] ?? const [],
            finances: local[5] ?? const [],
          );
          await _cache.saveList(_reportCacheKey(bergerieId), [report]);
          _appliquerRapport(report);
          return;
        }
      } catch (_) {}

      final cached = await _cache.loadList(_reportCacheKey(bergerieId));
      if (cached != null && cached.isNotEmpty) {
        _appliquerRapport(cached.first);
        return;
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Impossible de charger le rapport.';
      });
    }
  }

  Map<String, dynamic> _calculerRapport({
    required DateTime debut,
    required DateTime fin,
    required List<Map<String, dynamic>> moutons,
    required List<Map<String, dynamic>> gestations,
    required List<Map<String, dynamic>> soins,
    required List<Map<String, dynamic>> alimentations,
    required List<Map<String, dynamic>> interventions,
    required List<Map<String, dynamic>> finances,
  }) {
    int naissances = 0;
    int gestationsEnCours = 0;

    for (final data in gestations) {
      if (data['statut']?.toString() == 'Gestante') {
        gestationsEnCours++;
      }
      final date = _dateFrom(data['dateMiseBas']);
      if (date != null && !date.isBefore(debut) && date.isBefore(fin)) {
        naissances++;
      }
    }

    double alimentation = 0;
    for (final data in alimentations) {
      final date = _dateFrom(data['date']);
      if (date != null && !date.isBefore(debut) && date.isBefore(fin)) {
        alimentation += (data['prix'] as num?)?.toDouble() ?? 0;
      }
    }

    double ventes = 0;
    double depenses = alimentation;
    for (final data in finances) {
      final date = _dateFrom(data['date']);
      if (date == null || date.isBefore(debut) || !date.isBefore(fin)) continue;
      final montant = (data['montant'] as num?)?.toDouble() ?? 0;
      if (data['type']?.toString() == 'vente') {
        ventes += montant;
      } else {
        depenses += montant;
      }
    }

    final soinsMois = soins.where((data) {
      final date = _dateFrom(data['date']);
      return date != null && !date.isBefore(debut) && date.isBefore(fin);
    }).length;

    final interventionsMois = interventions.where((data) {
      final date = _dateFrom(data['date']);
      return date != null && !date.isBefore(debut) && date.isBefore(fin);
    }).length;

    return {
      'moutons': moutons.where((data) => data['actif'] != false).length,
      'gestations': gestationsEnCours,
      'naissances': naissances,
      'soins': soinsMois,
      'interventions': interventionsMois,
      'alimentation': alimentation,
      'ventes': ventes,
      'depenses': depenses,
    };
  }

  void _appliquerRapport(Map<String, dynamic> report) {
    if (!mounted) return;
    setState(() {
      _moutons = (report['moutons'] as num?)?.toInt() ?? 0;
      _gestations = (report['gestations'] as num?)?.toInt() ?? 0;
      _naissances = (report['naissances'] as num?)?.toInt() ?? 0;
      _soins = (report['soins'] as num?)?.toInt() ?? 0;
      _interventions = (report['interventions'] as num?)?.toInt() ?? 0;
      _alimentation = (report['alimentation'] as num?)?.toDouble() ?? 0;
      _ventes = (report['ventes'] as num?)?.toDouble() ?? 0;
      _depenses = (report['depenses'] as num?)?.toDouble() ?? 0;
      _loading = false;
      _error = null;
    });
  }

  DateTime? _dateFrom(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    if (raw is DateTime) return raw;
    return DateTime.tryParse(raw?.toString() ?? '');
  }

  Future<void> _exporterPdf({bool partager = false}) async {
    final config = CurrentBergerieConfig.instance.config;
    final solde = _ventes - _depenses;
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(28),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Rapport de bergerie',
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 6),
                pw.Text(config.nomBergerie),
                pw.Text(_dateFormat.format(_mois)),
                pw.SizedBox(height: 24),
                pw.Text(
                  'Vue d’ensemble',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  headers: const ['Indicateur', 'Valeur'],
                  data: [
                    ['Moutons', _moutons.toString()],
                    ['Gestations en cours', _gestations.toString()],
                    ['Naissances', _naissances.toString()],
                    ['Soins', _soins.toString()],
                    ['Interventions', _interventions.toString()],
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Text(
                  'Finances du mois',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: const ['Indicateur', 'Montant'],
                  data: [
                    ['Ventes', '$_money.format(_ventes) FCFA'],
                    ['Dépenses', '${_money.format(_depenses)} FCFA'],
                    ['Dont alimentation', '${_money.format(_alimentation)} FCFA'],
                    ['Solde', '${_money.format(solde)} FCFA'],
                  ],
                ),
                pw.Spacer(),
                pw.Text("Généré depuis SET'S I SA MBAAR", style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final nomFichier = 'rapport_${config.nomBergerie}_${_mois.year}_${_mois.month}.pdf';

    if (partager) {
      await Printing.sharePdf(bytes: bytes, filename: nomFichier);
      return;
    }

    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }
  void _moisPrecedent() {
    setState(() => _mois = DateTime(_mois.year, _mois.month - 1));
    _charger();
  }

  void _moisSuivant() {
    setState(() => _mois = DateTime(_mois.year, _mois.month + 1));
    _charger();
  }

  @override
  Widget build(BuildContext context) {
    final config = CurrentBergerieConfig.instance.config;
    final solde = _ventes - _depenses;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        backgroundColor: config.couleurPrimaire,
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: 'Retour',
          onPressed: () => context.go('/dashboard/bergerie'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text('Rapports - ${config.nomBergerie}'),
        actions: [
          IconButton(
            tooltip: 'Exporter / imprimer le rapport',
            onPressed: _loading ? null : _exporterPdf,
            icon: const Icon(Icons.picture_as_pdf),
          ),
          IconButton(
            tooltip: 'Enregistrer / partager le PDF',
            onPressed: _loading ? null : () => _exporterPdf(partager: true),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _charger,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _periode(config),
                      const SizedBox(height: 20),
                      const Text('Vue d’ensemble', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _grid([
                        _stat('Moutons', _moutons.toString(), Icons.pets, config.couleurPrimaire),
                        _stat('Gestations en cours', _gestations.toString(), Icons.pregnant_woman, config.couleurSecondaire),
                        _stat('Naissances', _naissances.toString(), Icons.child_friendly, config.couleurPrimaire),
                        _stat('Soins', _soins.toString(), Icons.medical_services, config.couleurSecondaire),
                        _stat('Interventions', _interventions.toString(), Icons.build, config.couleurPrimaire),
                      ]),
                      const SizedBox(height: 24),
                      const Text('Finances du mois', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _financeCard('Ventes', _ventes, Icons.trending_up, Colors.green),
                      const SizedBox(height: 10),
                      _financeCard('Dépenses', _depenses, Icons.trending_down, Colors.red),
                      const SizedBox(height: 10),
                      _financeCard('Dont alimentation', _alimentation, Icons.restaurant, config.couleurSecondaire),
                      const SizedBox(height: 10),
                      _financeCard('Solde', solde, Icons.account_balance_wallet, solde >= 0 ? Colors.green : Colors.red),
                    ],
                  ),
                ),
    );
  }

  Widget _periode(dynamic config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(onPressed: _moisPrecedent, icon: const Icon(Icons.chevron_left)),
            Expanded(child: Center(child: Text(_dateFormat.format(_mois), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)))),
            IconButton(onPressed: _moisSuivant, icon: const Icon(Icons.chevron_right)),
          ],
        ),
      ),
    );
  }

  Widget _grid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 650;
        return Wrap(spacing: 12, runSpacing: 12, children: children.map((child) => SizedBox(width: twoColumns ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth, child: child)).toList());
      },
    );
  }

  Widget _stat(String title, String value, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: .12), child: Icon(icon, color: color)),
        title: Text(title),
        subtitle: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _financeCard(String title, double value, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: .12), child: Icon(icon, color: color)),
        title: Text(title),
        trailing: Text('${_money.format(value)} FCFA', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
