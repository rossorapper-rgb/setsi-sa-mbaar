import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/config/current_bergerie_config.dart';
import '../../../core/session/current_user_service.dart';

class RapportsBergeriePage extends StatefulWidget {
  const RapportsBergeriePage({super.key});

  @override
  State<RapportsBergeriePage> createState() => _RapportsBergeriePageState();
}

class _RapportsBergeriePageState extends State<RapportsBergeriePage> {
  final _firestore = FirebaseFirestore.instance;
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
        _firestore.collection('moutons').where('bergerieId', isEqualTo: bergerieId).where('actif', isEqualTo: true).get(),
        _firestore.collection('gestations').where('bergerieId', isEqualTo: bergerieId).get(),
        _firestore.collection('carnet_sante').where('bergerieId', isEqualTo: bergerieId).get(),
        _firestore.collection('alimentations').where('bergerieId', isEqualTo: bergerieId).get(),
        _firestore.collection('interventions').where('bergerieId', isEqualTo: bergerieId).get(),
        _firestore.collection('finance_entries').where('bergerieId', isEqualTo: bergerieId).get(),
      ]);

      final gestations = results[1].docs;
      final soins = results[2].docs;
      final alimentations = results[3].docs;
      final interventions = results[4].docs;
      final finances = results[5].docs;

      int naissances = 0;
      int gestationsEnCours = 0;
      for (final doc in gestations) {
        final data = doc.data();
        if (data['statut']?.toString() == 'Gestante') {
          gestationsEnCours++;
        }
        final rawDate = data['dateMiseBas'];
        DateTime? date;
        if (rawDate is Timestamp) {
          date = rawDate.toDate();
        } else if (rawDate is int) {
          date = DateTime.fromMillisecondsSinceEpoch(rawDate);
        } else if (rawDate != null) {
          date = DateTime.tryParse(rawDate.toString());
        }
        if (date != null && !date.isBefore(debut) && date.isBefore(fin)) {
          naissances++;
        }
      }

      double alimentation = 0;
      for (final doc in alimentations) {
        final data = doc.data();
        final date = _dateFrom(data['date']);
        if (date != null && !date.isBefore(debut) && date.isBefore(fin)) {
          alimentation += (data['prix'] as num?)?.toDouble() ?? 0;
        }
      }

      double ventes = 0;
      double depenses = alimentation;
      for (final doc in finances) {
        final data = doc.data();
        final date = _dateFrom(data['date']);
        if (date == null || date.isBefore(debut) || !date.isBefore(fin)) continue;
        final montant = (data['montant'] as num?)?.toDouble() ?? 0;
        if (data['type']?.toString() == 'vente') {
          ventes += montant;
        } else {
          depenses += montant;
        }
      }

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
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        backgroundColor: config.couleurPrimaire,
        foregroundColor: Colors.white,
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
