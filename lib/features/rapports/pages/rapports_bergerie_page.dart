import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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

  String _cacheKey(String collection, String bergerieId) =>
      'rapport_$collection_$bergerieId';

  Future<List<Map<String, dynamic>>> _chargerCollection({
    required String collection,
    required String bergerieId,
    bool actifsSeulement = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(collection)
          .where('bergerieId', isEqualTo: bergerieId);

      if (actifsSeulement) {
        query = query.where('actif', isEqualTo: true);
      }

      final snapshot =
          await query.get(const GetOptions(source: Source.server));

      final data = snapshot.docs
          .map((doc) => <String, dynamic>{
                ...doc.data(),
                'id': doc.id,
              })
          .toList();

      await _cache.saveList(_cacheKey(collection, bergerieId), data);
      return data;
    } catch (_) {
      final cached =
          await _cache.loadList(_cacheKey(collection, bergerieId));
      return cached ?? <Map<String, dynamic>>[];
    }
  }

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
        _chargerCollection(
          collection: 'moutons',
          bergerieId: bergerieId,
          actifsSeulement: true,
        ),
        _chargerCollection(
          collection: 'gestations',
          bergerieId: bergerieId,
        ),
        _chargerCollection(
          collection: 'carnet_sante',
          bergerieId: bergerieId,
        ),
        _chargerCollection(
          collection: 'alimentations',
          bergerieId: bergerieId,
        ),
        _chargerCollection(
          collection: 'interventions',
          bergerieId: bergerieId,
        ),
        _chargerCollection(
          collection: 'finance_entries',
          bergerieId: bergerieId,
        ),
      ]);

      final moutons = results[0];
      final gestations = results[1];
      final soins = results[2];
      final alimentations = results[3];
      final interventions = results[4];
      final finances = results[5];

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
        if (date == null || date.isBefore(debut) || !date.isBefore(fin)) {
          continue;
        }
        final montant = (data['montant'] as num?)?.toDouble() ?? 0;
        if (data['type']?.toString() == 'vente') {
          ventes += montant;
        } else {
          depenses += montant;
        }
      }

      setState(() {
        _moutons = moutons.length;
        _gestations = gestationsEnCours;
        _naissances = naissances;
        _soins = soins.where((data) {
          final date = _dateFrom(data['date']);
          return date != null &&
              !date.isBefore(debut) &&
              date.isBefore(fin);
        }).length;
        _interventions = interventions.where((data) {
          final date = _dateFrom(data['date']);
          return date != null &&
              !date.isBefore(debut) &&
              date.isBefore(fin);
        }).length;
        _alimentation = alimentation;
        _ventes = ventes;
        _depenses = depenses;
        _loading = false;
      });
      if (!mounted) return;
      setState(() {
        _moutons = results[0].docs.length;
        _gestations = gestationsEnCours;
        _naissances = naissances;
        _soins = soins.where((d) {
          final date = _dateFrom(d.data()['date']);
          return date != null && !date.isBefore(debut) && date.isBefore(fin);
        }).length;
        _interventions = interventions.where((d) {
          final date = _dateFrom(d.data()['date']);
          return date != null && !date.isBefore(debut) && date.isBefore(fin);
        }).length;
        _alimentation = alimentation;
        _ventes = ventes;
        _depenses = depenses;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Impossible de charger le rapport.';
      });
    }
  }

  DateTime? _dateFrom(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    if (raw is DateTime) return raw;
    return DateTime.tryParse(raw?.toString() ?? '');
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: config.couleurPrimaire,
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: 'Retour',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard/bergerie'),
        ),
        title: Text('Rapports - ${config.nomBergerie}'),
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
                      _financeCard('Ventes', _ventes, Icons.trending_up, config.couleurPrimaire),
                      const SizedBox(height: 10),
                      _financeCard('Dépenses', _depenses, Icons.trending_down, config.couleurSecondaire),
                      const SizedBox(height: 10),
                      _financeCard('Dont alimentation', _alimentation, Icons.restaurant, config.couleurSecondaire),
                      const SizedBox(height: 10),
                      _financeCard('Solde', solde, Icons.account_balance_wallet, solde >= 0 ? config.couleurPrimaire : config.couleurSecondaire),
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
