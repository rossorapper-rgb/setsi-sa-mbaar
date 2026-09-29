import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../alimentation/models/alimentation_model.dart';
import '../../alimentation/repository/firebase_alimentation_repository.dart';
import 'package:uuid/uuid.dart';
import '../models/finance_entry_model.dart';
import '../repository/firebase_finance_repository.dart';
import '../../../core/session/current_user_service.dart';

class FinancesBergeriePage extends StatefulWidget {
  const FinancesBergeriePage({super.key});

  @override
  State<FinancesBergeriePage> createState() => _FinancesBergeriePageState();
}

class _FinancesBergeriePageState extends State<FinancesBergeriePage> {
  static const List<String> _alimentsCourants = [
    'Super ladoum',
    'Khonte',
    'Mélange',
    'Foin "Ngogne"',
    'Maïs "Mbokou"',
    'Pain sec',
    'Gousses de kadd',
    'Pierre à lécher',
    'Concentré pour ruminants',
    'Niébé',
    'Son de mil',
    'Son de riz',
    'Son de blé',
    'Tourteau d’arachide',
    'Tourteau de coton',
    'Graine de coton',
    'Paille de riz',
    'Paille de brousse',
    'autre',
  ];
  final _repository = FirebaseFinanceRepository();
  final _alimentationRepository = FirebaseAlimentationRepository();
  final _uuid = const Uuid();
  final _money = NumberFormat('#,##0', 'fr_FR');
  final _dateFormat = DateFormat('dd/MM/yyyy');

  List<FinanceEntryModel> _entries = [];
  List<AlimentationModel> _alimentations = [];
  bool _loading = true;
  String? _error;

  CurrentUserService get _session => CurrentUserService.instance;
  bool get _canViewDepenses => _session.hasPermission('depenses.view');
  bool get _canEditDepenses => _session.hasPermission('depenses.edit');
  bool get _canViewVentes => _session.hasPermission('ventes.view');
  bool get _canEditVentes => _session.hasPermission('ventes.edit');
  bool get _canViewFinance => _canViewDepenses || _canViewVentes;
  DateTime _mois = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _canViewFinance ? _repository.getEntries() : Future.value(<FinanceEntryModel>[]),
        _canViewFinance ? _repository.getAlimentations() : Future.value(<AlimentationModel>[]),
      ]);
      if (!mounted) return;
      setState(() {
        _entries = results[0] as List<FinanceEntryModel>;
        _alimentations = results[1] as List<AlimentationModel>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  bool _dansMois(DateTime date) =>
      date.year == _mois.year && date.month == _mois.month;

  double get _depensesManuelles => _entries
      .where((e) => e.type == FinanceEntryType.depense && _dansMois(e.date))
      .fold(0, (total, e) => total + e.montant);

  double get _alimentationMois => _alimentations
      .where((e) => _dansMois(e.date))
      .fold(0, (total, e) => total + e.prix);

  double get _ventes => _entries
      .where((e) => e.type == FinanceEntryType.vente && _dansMois(e.date))
      .fold(0, (total, e) => total + e.montant);

  double get _depenses => _depensesManuelles + _alimentationMois;

  Future<void> _changerMois() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _mois,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      helpText: 'Choisir le mois',
    );
    if (date == null || !mounted) return;
    setState(() => _mois = DateTime(date.year, date.month));
  }

  Future<void> _ajouter(FinanceEntryType type) async {
    final libelleController = TextEditingController();
    final montantController = TextEditingController();
    final observationController = TextEditingController();
    final alimentController = TextEditingController();
    final quantiteController = TextEditingController();
    String unite = 'kg';
    String categorie = type == FinanceEntryType.depense ? 'Alimentation' : 'Vente';
    DateTime date = DateTime.now();

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(type == FinanceEntryType.depense ? 'Ajouter une dépense' : 'Ajouter une vente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (type == FinanceEntryType.vente || (type == FinanceEntryType.depense && categorie == 'Autre')) ...[
                  TextField(
                    controller: libelleController,
                    decoration: InputDecoration(
                      labelText: type == FinanceEntryType.depense ? 'Libellé' : 'Produit / mouton vendu',
                      hintText: type == FinanceEntryType.depense ? 'Ex. Achat de matériel spécifique' : null,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (type == FinanceEntryType.depense) ...[
                  DropdownButtonFormField<String>(
                    initialValue: categorie,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Alimentation', child: Text('🌾 Alimentation')),
                      DropdownMenuItem(value: 'Sante', child: Text('💊 Santé / vétérinaire')),
                      DropdownMenuItem(value: 'Entretien', child: Text('🧹 Entretien / nettoyage')),
                      DropdownMenuItem(value: 'Transport', child: Text('🚚 Transport')),
                      DropdownMenuItem(value: 'Salaires', child: Text('👷 Salaires / main-d’œuvre')),
                      DropdownMenuItem(value: 'Materiel', child: Text('🔧 Matériel / équipement')),
                      DropdownMenuItem(value: 'EauElectricite', child: Text('💡 Électricité / eau')),
                      DropdownMenuItem(value: 'Autre', child: Text('📦 Autres')),
                    ],
                    onChanged: (value) {
                      if (value != null) setDialogState(() => categorie = value);
                    },
                  ),
                  if (categorie == 'Alimentation') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: alimentController,
                      decoration: InputDecoration(
                        labelText: 'Aliment',
                        hintText: 'Ex. Maïs, son, aliment bétail...',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: 'Choisir un aliment courant',
                          icon: const Icon(Icons.list_alt_rounded),
                          onPressed: () async {
                            final choix = await showDialog<String>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Aliments fréquemment utilisés'),
                                content: SizedBox(
                                  width: 520,
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: _alimentsCourants.length,
                                    separatorBuilder: (_, _) =>
                                        const Divider(height: 1),
                                    itemBuilder: (_, index) {
                                      final aliment = _alimentsCourants[index];
                                      return ListTile(
                                        leading: const Icon(Icons.grass_rounded),
                                        title: Text(aliment),
                                        onTap: () => Navigator.pop(
                                          dialogContext,
                                          aliment,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: const Text('Annuler'),
                                  ),
                                ],
                              ),
                            );
                            if (choix != null) {
                              alimentController.text =
                                  choix == 'autre' ? '' : choix;
                              alimentController.selection =
                                  TextSelection.collapsed(
                                offset: alimentController.text.length,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: quantiteController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Quantité',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: unite,
                            decoration: const InputDecoration(
                              labelText: 'Unité',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'kg', child: Text('kg')),
                              DropdownMenuItem(value: 'sac', child: Text('sac')),
                              DropdownMenuItem(value: 'litre', child: Text('litre')),
                              DropdownMenuItem(value: 'unité', child: Text('unité')),
                            ],
                            onChanged: (value) {
                              if (value != null) setDialogState(() => unite = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
                TextField(
                  controller: montantController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Montant (FCFA)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setDialogState(() => date = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_dateFormat.format(date)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: observationController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Observation (facultative)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final libelle = libelleController.text.trim();
                final montant = double.tryParse(
                  montantController.text.trim().replaceAll(',', '.'),
                );

                if (montant == null || montant <= 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Veuillez renseigner un montant valide.')),
                  );
                  return;
                }

                if (type == FinanceEntryType.vente || (type == FinanceEntryType.depense && categorie == 'Autre')) {
                  if (libelle.isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          type == FinanceEntryType.vente
                              ? 'Veuillez renseigner le produit ou le mouton vendu.'
                              : 'Veuillez renseigner le libellé de la dépense.',
                        ),
                      ),
                    );
                    return;
                  }
                }

                if (categorie == 'Alimentation') {
                  final quantite = double.tryParse(
                    quantiteController.text.trim().replaceAll(',', '.'),
                  );
                  if (alimentController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Veuillez renseigner l’aliment.')),
                    );
                    return;
                  }
                  if (quantite == null || quantite <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Veuillez renseigner une quantité valide.')),
                    );
                    return;
                  }
                }

                Navigator.pop(dialogContext, true);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) {
      libelleController.dispose();
      montantController.dispose();
      observationController.dispose();
      alimentController.dispose();
      quantiteController.dispose();
      return;
    }

    final libelle = libelleController.text.trim();
    final montant = double.tryParse(montantController.text.trim().replaceAll(',', '.'));
    if (categorie == 'Alimentation' && alimentController.text.trim().isEmpty) {
      alimentController.dispose();
      quantiteController.dispose();
      libelleController.dispose();
      montantController.dispose();
      observationController.dispose();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez renseigner l’aliment.')));
      return;
    }
    if (categorie == 'Alimentation' && (double.tryParse(quantiteController.text.trim().replaceAll(',', '.')) ?? 0) <= 0) {
      alimentController.dispose();
      quantiteController.dispose();
      libelleController.dispose();
      montantController.dispose();
      observationController.dispose();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez renseigner une quantité valide.')));
      return;
    }
    if (montant == null || montant <= 0) {
      libelleController.dispose();
      montantController.dispose();
      observationController.dispose();
      alimentController.dispose();
      quantiteController.dispose();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez renseigner un montant valide.')));
      return;
    }

    if (type == FinanceEntryType.vente || (type == FinanceEntryType.depense && categorie == 'Autre')) {
      if (libelle.isEmpty) {
        libelleController.dispose();
        montantController.dispose();
        observationController.dispose();
        alimentController.dispose();
        quantiteController.dispose();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                type == FinanceEntryType.vente
                    ? 'Veuillez renseigner le produit ou le mouton vendu.'
                    : 'Veuillez renseigner le libellé de la dépense.',
              ),
            ),
          );
        }
        return;
      }
    }

    try {
      if (type == FinanceEntryType.depense && categorie == 'Alimentation') {
        final quantite = double.parse(quantiteController.text.trim().replaceAll(',', '.'));
        final alimentation = AlimentationModel(
          id: _uuid.v4(),
          bergerieId: _session.bergerieId!.trim(),
          aliment: alimentController.text.trim(),
          quantite: quantite,
          unite: unite,
          prix: montant,
          date: date,
          observation: observationController.text.trim(),
        );
        await _alimentationRepository.ajouter(alimentation);
        if (mounted) {
          setState(() {
            _alimentations = [..._alimentations, alimentation]
              ..sort((a, b) => b.date.compareTo(a.date));
          });
        }
      } else {
        final entry = await _repository.ajouter(
          type: type,
          libelle: type == FinanceEntryType.depense ? _libelleCategorie(categorie, libelle) : libelle,
          categorie: type == FinanceEntryType.depense ? categorie : '',
          montant: montant,
          date: date,
          observation: observationController.text,
        );
        if (mounted) {
          setState(() {
            _entries = [entry, ..._entries];
            _entries.sort((a, b) => b.date.compareTo(a.date));
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(type == FinanceEntryType.depense ? 'Dépense enregistrée avec succès.' : 'Vente enregistrée avec succès.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      libelleController.dispose();
      montantController.dispose();
      observationController.dispose();
      alimentController.dispose();
      quantiteController.dispose();
    }
  }

  String _libelleCategorie(String categorie, String libelle) {
    if (libelle.isNotEmpty) return libelle;
    switch (categorie) {
      case 'Sante':
        return 'Santé / vétérinaire';
      case 'Entretien':
        return 'Entretien / nettoyage';
      case 'Transport':
        return 'Transport';
      case 'Salaires':
        return 'Salaires / main-d’œuvre';
      case 'Materiel':
        return 'Matériel / équipement';
      case 'EauElectricite':
        return 'Électricité / eau';
      case 'Autre':
        return 'Autres';
      default:
        return categorie;
    }
  }

  Future<void> _modifier(FinanceEntryModel entry) async {
    final libelleController = TextEditingController(text: entry.libelle);
    final montantController = TextEditingController(text: entry.montant.toStringAsFixed(0));
    final observationController = TextEditingController(text: entry.observation);
    String categorie = entry.categorie.trim().isNotEmpty
        ? entry.categorie
        : (entry.type == FinanceEntryType.vente ? 'Vente' : 'Autre');
    DateTime date = entry.date;

    final result = await showDialog<FinanceEntryModel?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(entry.type == FinanceEntryType.depense ? 'Modifier la dépense' : 'Modifier la vente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (entry.type == FinanceEntryType.depense)
                  DropdownButtonFormField<String>(
                    initialValue: categorie,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Alimentation', child: Text('🌾 Alimentation')),
                      DropdownMenuItem(value: 'Sante', child: Text('💊 Santé / vétérinaire')),
                      DropdownMenuItem(value: 'Entretien', child: Text('🧹 Entretien / nettoyage')),
                      DropdownMenuItem(value: 'Transport', child: Text('🚚 Transport')),
                      DropdownMenuItem(value: 'Salaires', child: Text('👷 Salaires / main-d’œuvre')),
                      DropdownMenuItem(value: 'Materiel', child: Text('🔧 Matériel / équipement')),
                      DropdownMenuItem(value: 'EauElectricite', child: Text('💡 Électricité / eau')),
                      DropdownMenuItem(value: 'Autre', child: Text('📦 Autres')),
                    ],
                    onChanged: (value) {
                      if (value != null) setDialogState(() => categorie = value);
                    },
                  ),
                if (entry.type == FinanceEntryType.depense) const SizedBox(height: 12),
                TextField(
                  controller: libelleController,
                  decoration: InputDecoration(
                    labelText: entry.type == FinanceEntryType.vente ? 'Produit / mouton vendu' : 'Libellé',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: montantController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Montant (FCFA)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setDialogState(() => date = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_dateFormat.format(date)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: observationController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Observation (facultative)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final libelle = libelleController.text.trim();
                final montant = double.tryParse(
                  montantController.text.trim().replaceAll(',', '.'),
                );
                if (montant == null || montant <= 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Veuillez renseigner un montant valide.')),
                  );
                  return;
                }
                if (libelle.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Veuillez renseigner le libellé.')),
                  );
                  return;
                }
                Navigator.pop(
                  dialogContext,
                  entry.copyWith(
                    libelle: libelle,
                    categorie: entry.type == FinanceEntryType.depense ? categorie : '',
                    montant: montant,
                    date: date,
                    observation: observationController.text.trim(),
                  ),
                );
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );

    libelleController.dispose();
    montantController.dispose();
    observationController.dispose();

    if (result == null) return;

    try {
      await _repository.modifier(result);
      if (mounted) {
        setState(() {
          _entries = _entries.map((item) => item.id == result.id ? result : item).toList()
            ..sort((a, b) => b.date.compareTo(a.date));
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opération modifiée avec succès.')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  Future<void> _supprimer(FinanceEntryModel entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text('Supprimer « ${entry.libelle.isEmpty ? entry.categorie : entry.libelle} » ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repository.supprimer(entry.id);
      if (mounted) {
        setState(() {
          _entries = _entries.where((item) => item.id != entry.id).toList();
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final moisLabel = DateFormat('MMMM yyyy', 'fr_FR').format(_mois);
    final solde = _ventes - _depenses;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/dashboard/bergerie'),
        ),
        title: const Text('Finances'),
        actions: [IconButton(onPressed: _charger, icon: const Icon(Icons.refresh_rounded))],
      ),
      floatingActionButton: _loading || (!_canEditDepenses && !_canEditVentes)
          ? null
          : FloatingActionButton.extended(onPressed: () => _choisirAction(), icon: const Icon(Icons.add_rounded), label: const Text('Ajouter')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Impossible de charger les finances.\n$_error', textAlign: TextAlign.center)))
              : RefreshIndicator(
                  onRefresh: _charger,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      InkWell(
                        onTap: _changerMois,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                          child: Row(children: [const Icon(Icons.calendar_month_rounded), const SizedBox(width: 10), Expanded(child: Text(moisLabel[0].toUpperCase() + moisLabel.substring(1), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))), const Icon(Icons.keyboard_arrow_down_rounded)]),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (!_canViewFinance)
                        const Card(child: Padding(padding: EdgeInsets.all(18), child: Row(children: [Icon(Icons.lock_outline), SizedBox(width: 10), Expanded(child: Text('Vous pouvez enregistrer des opérations autorisées, mais les montants financiers ne sont pas visibles avec votre niveau d’accès.'))])))
                      else ...[
                        if (_canViewVentes) _SummaryCard(title: 'Ventes', value: '${_money.format(_ventes)} FCFA', icon: Icons.trending_up_rounded, color: Colors.green),
                        if (_canViewDepenses) ...[
                          const SizedBox(height: 10),
                          _SummaryCard(title: 'Dépenses', value: '${_money.format(_depenses)} FCFA', subtitle: 'Alimentation : ${_money.format(_alimentationMois)} FCFA', icon: Icons.trending_down_rounded, color: Colors.red),
                        ],
                        if (_canViewVentes && _canViewDepenses) ...[
                          const SizedBox(height: 10),
                          _SummaryCard(title: 'Solde', value: '${_money.format(solde)} FCFA', icon: Icons.account_balance_wallet_rounded, color: solde >= 0 ? Colors.green : Colors.red),
                        ],
                      ],
                      const SizedBox(height: 22),
                      const Text('Historique', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      if (_entries.where((e) => _dansMois(e.date)).isEmpty && _alimentations.where((e) => _dansMois(e.date)).isEmpty)
                        const Card(child: Padding(padding: EdgeInsets.all(22), child: Text('Aucune opération enregistrée pour ce mois.')))
                      else ...[
                        ..._alimentations.where((e) => _dansMois(e.date)).map((e) => _AlimentationFinanceTile(alimentation: e, dateFormat: _dateFormat)),
                        ..._entries.where((e) => _dansMois(e.date)).map((e) => _FinanceTile(
                          entry: e,
                          dateFormat: _dateFormat,
                          money: _money,
                          onEdit: (_canEditDepenses && e.type == FinanceEntryType.depense) ||
                                  (_canEditVentes && e.type == FinanceEntryType.vente)
                              ? () => _modifier(e)
                              : null,
                          onDelete: (_canEditDepenses && e.type == FinanceEntryType.depense) ||
                                  (_canEditVentes && e.type == FinanceEntryType.vente)
                              ? () => _supprimer(e)
                              : null,
                        )),
                      ],
                    ],
                  ),
                ),
    );
  }

  Future<void> _choisirAction() async {
    final type = await showModalBottomSheet<FinanceEntryType>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            if (_canEditDepenses) ListTile(leading: const Icon(Icons.trending_down_rounded, color: Colors.red), title: const Text('Ajouter une dépense'), onTap: () => Navigator.pop(context, FinanceEntryType.depense)),
            if (_canEditVentes) ListTile(leading: const Icon(Icons.trending_up_rounded, color: Colors.green), title: const Text('Ajouter une vente'), onTap: () => Navigator.pop(context, FinanceEntryType.vente)),
          ],
        ),
      ),
    );
    if (type != null) await _ajouter(type);
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color, this.subtitle});
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [CircleAvatar(backgroundColor: color.withValues(alpha: .12), child: Icon(icon, color: color)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.black54)), const SizedBox(height: 3), Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)), if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: const TextStyle(fontSize: 11, color: Colors.black54))]]))])));
}

class _FinanceTile extends StatelessWidget {
  const _FinanceTile({
    required this.entry,
    required this.dateFormat,
    required this.money,
    this.onEdit,
    this.onDelete,
  });
  final FinanceEntryModel entry;
  final DateFormat dateFormat;
  final NumberFormat money;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final vente = entry.type == FinanceEntryType.vente;
    final titre = entry.libelle.trim().isNotEmpty
        ? entry.libelle.trim()
        : (entry.categorie.trim().isNotEmpty ? entry.categorie.trim() : (vente ? 'Vente' : 'Dépense'));
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          vente ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          color: vente ? Colors.green : Colors.red,
        ),
        title: Text(titre, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${dateFormat.format(entry.date)}${entry.observation.isEmpty ? '' : '\n${entry.observation}'}',
        ),
        isThreeLine: entry.observation.isNotEmpty,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${money.format(entry.montant)} FCFA',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: vente ? Colors.green : Colors.red,
              ),
            ),
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit?.call();
                  } else if (value == 'delete') {
                    onDelete?.call();
                  }
                },
                itemBuilder: (_) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Modifier'),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Supprimer'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AlimentationFinanceTile extends StatelessWidget {
  const _AlimentationFinanceTile({required this.alimentation, required this.dateFormat});
  final AlimentationModel alimentation;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: const Icon(Icons.grass_rounded, color: Colors.orange), title: Text('Alimentation · ${alimentation.aliment}', style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('${dateFormat.format(alimentation.date)} · ${alimentation.quantite} ${alimentation.unite}'), trailing: Text('${alimentation.prix.toStringAsFixed(0)} FCFA', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.orange))));
}
