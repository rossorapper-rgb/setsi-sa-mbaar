import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/session/current_user_service.dart';
import '../models/alimentation_model.dart';
import '../repository/firebase_alimentation_repository.dart';
import '../../stock/models/stock_produit_model.dart';
import '../../stock/repository/firebase_stock_repository.dart';

class AlimentationPage extends StatefulWidget {
  const AlimentationPage({super.key});

  @override
  State<AlimentationPage> createState() => _AlimentationPageState();
}

class _AlimentationPageState extends State<AlimentationPage> {
  final _repository = FirebaseAlimentationRepository();
  final _uuid = const Uuid();
  final _stockRepository = FirebaseStockRepository();

  bool _loading = true;
  String? _erreur;
  String _bergerieId = '';
  List<AlimentationModel> _alimentations = [];
  String _recherche = '';

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() {
      _loading = true;
      _erreur = null;
    });

    try {
      final user = CurrentUserService.instance.currentUser;
      final bergerieId = user?.bergerieId?.trim() ?? '';

      if (user == null) {
        throw Exception('Utilisateur connecté introuvable.');
      }
      if (bergerieId.isEmpty) {
        throw Exception('Aucune bergerie n’est associée à ce compte.');
      }

      final canView = CurrentUserService.instance.hasPermission('alimentation.view');
        final alimentations = canView ? await _repository.getParBergerie(bergerieId) : <AlimentationModel>[];

      if (!mounted) return;
      setState(() {
        _bergerieId = bergerieId;
        _alimentations = alimentations;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _erreur = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<AlimentationModel> get _filtered {
    final recherche = _recherche.trim().toLowerCase();
    if (recherche.isEmpty) return _alimentations;

    return _alimentations.where((item) {
      final texte = '${item.aliment} ${item.unite} ${item.observation}'.toLowerCase();
      return texte.contains(recherche);
    }).toList();
  }

  double get _totalDepenses =>
      _alimentations.fold(0, (total, item) => total + item.prix);

  Future<void> _ouvrirFormulaire({AlimentationModel? alimentation}) async {
    if (_bergerieId.isEmpty) return;

    final resultat = await showDialog<bool>(
      context: context,
      builder: (_) => _AlimentationFormDialog(
        bergerieId: _bergerieId,
        repository: _repository,
        uuid: _uuid,
        alimentation: alimentation,
      ),
    );

    if (resultat == true) await _charger();
  }

  bool get _canDeduirStock {
    final user = CurrentUserService.instance;
    return user.isAdmin || user.isResponsable || user.isTechnicien;
  }

  Future<void> _deduireDuStock(AlimentationModel alimentation) async {
    if (alimentation.stockDeduit) return;
    try {
      final produits = (await _stockRepository.getProduits()).where((p) => p.actif && p.quantite > 0).toList();
      if (!mounted) return;
      if (produits.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucun produit disponible dans le stock.')));
        return;
      }
      final choix = await showDialog<_StockDeductionChoice>(
        context: context,
        builder: (_) => _StockDeductionDialog(alimentation: alimentation, produits: produits),
      );
      if (choix == null) return;
      await _stockRepository.deduireDepuisAlimentation(alimentationId: alimentation.id, produitId: choix.produit.id, quantite: choix.quantite, motif: 'Consommation alimentation - ' + alimentation.aliment, date: alimentation.date);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stock déduit avec succès.')));
        await _charger();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible de déduire le stock : $e')));
    }
  }
  Future<void> _supprimer(AlimentationModel alimentation) async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer cet achat ?'),
        content: Text('Voulez-vous supprimer l’enregistrement « ${alimentation.aliment} » ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmer != true) return;

    try {
      await _repository.supprimer(alimentation.id);
      if (mounted) await _charger();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final compact = MediaQuery.of(context).size.width < 700;
    final canView = CurrentUserService.instance.hasPermission('alimentation.view');
    final canEdit = CurrentUserService.instance.hasPermission('alimentation.edit');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard/bergerie'),
        ),
        title: const Text('Alimentation'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _charger,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      floatingActionButton: !_loading && _erreur == null && _bergerieId.isNotEmpty && canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _ouvrirFormulaire(),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
            )
          : null,
      body: _buildBody(filtered, compact),
    );
  }

  Widget _buildBody(List<AlimentationModel> filtered, bool compact) {
    final canView = CurrentUserService.instance.hasPermission('alimentation.view');
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_erreur != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60),
              const SizedBox(height: 16),
              Text(_erreur!, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _charger,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _charger,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          const Text(
            'Alimentation',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enregistrez simplement les aliments achetés ou utilisés pour votre élevage.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 18),
          if (canView) _resumeCard(compact),
          if (canView) const SizedBox(height: 18),
          if (canView) TextField(
            onChanged: (value) => setState(() => _recherche = value),
            decoration: InputDecoration(
              hintText: 'Rechercher un aliment',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
          ),
          if (canView) const SizedBox(height: 20),
          if (!canView)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline),
                    SizedBox(width: 10),
                    Expanded(child: Text('Vous pouvez enregistrer une alimentation, mais les achats et montants enregistrés ne sont pas visibles avec votre niveau d’accès.')),
                  ],
                ),
              ),
            ),
          if (canView && filtered.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.grass_outlined, size: 64, color: Colors.grey.shade500),
                    const SizedBox(height: 16),
                    Text(
                      _alimentations.isEmpty ? 'Aucun aliment enregistré' : 'Aucun résultat',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _alimentations.isEmpty
                          ? 'Ajoutez votre premier achat ou apport alimentaire.'
                          : 'Essayez une autre recherche.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else if (canView)
            ...filtered.map(_buildCard),
        ],
      ),
    );
  }

  Widget _resumeCard(bool compact) {
    final montant = NumberFormat('#,##0', 'fr_FR').format(_totalDepenses);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: .07),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              child: const Icon(Icons.grass_rounded),
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .12),
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total enregistré', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(
                    '$montant FCFA',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            if (!compact)
              Text(
                '${_alimentations.length} entrée${_alimentations.length > 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(AlimentationModel item) {
    final prix = NumberFormat('#,##0', 'fr_FR').format(item.prix);
    final quantite = item.quantite % 1 == 0
        ? item.quantite.toInt().toString()
        : item.quantite.toStringAsFixed(2);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: const CircleAvatar(child: Icon(Icons.grass_rounded)),
        title: Text(item.aliment, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '$quantite ${item.unite} • $prix FCFA\n${DateFormat('dd/MM/yyyy').format(item.date)}'
            '${item.observation.trim().isNotEmpty ? '\n${item.observation}' : ''}',
          ),
        ),
        isThreeLine: item.observation.trim().isNotEmpty,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'stock') _deduireDuStock(item);
            if (value == 'edit') _ouvrirFormulaire(alimentation: item);
            if (value == 'delete') _supprimer(item);
          },
          itemBuilder: (_) => [
            if (_canDeduirStock && !item.stockDeduit)
              const PopupMenuItem(value: 'stock', child: Text('Déduire du stock')),
            if (item.stockDeduit)
              const PopupMenuItem(enabled: false, value: 'stock_done', child: Text('Stock déjà déduit')),
            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
      ),
    );
  }
}

class _AlimentationFormDialog extends StatefulWidget {
  const _AlimentationFormDialog({
    required this.bergerieId,
    required this.repository,
    required this.uuid,
    this.alimentation,
  });

  final String bergerieId;
  final FirebaseAlimentationRepository repository;
  final Uuid uuid;
  final AlimentationModel? alimentation;

  @override
  State<_AlimentationFormDialog> createState() => _AlimentationFormDialogState();
}

class _AlimentationFormDialogState extends State<_AlimentationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _alimentController;
  late TextEditingController _quantiteController;
  late TextEditingController _prixController;
  late TextEditingController _observationController;
  late String _unite;
  late DateTime _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.alimentation;
    _alimentController = TextEditingController(text: item?.aliment ?? '');
    _quantiteController = TextEditingController(
      text: item == null ? '' : item.quantite.toString(),
    );
    _prixController = TextEditingController(
      text: item == null ? '' : item.prix.toStringAsFixed(0),
    );
    _observationController = TextEditingController(text: item?.observation ?? '');
    _unite = item?.unite ?? 'kg';
    _date = item?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _alimentController.dispose();
    _quantiteController.dispose();
    _prixController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  double? _parseNombre(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = AlimentationModel(
      id: widget.alimentation?.id ?? widget.uuid.v4(),
      bergerieId: widget.bergerieId,
      aliment: _alimentController.text.trim(),
      quantite: _parseNombre(_quantiteController.text)!,
      unite: _unite,
      prix: _parseNombre(_prixController.text)!,
      date: _date,
      observation: _observationController.text.trim(),
    );

    try {
      if (widget.alimentation == null) {
        await widget.repository.ajouter(item);
      } else {
        await widget.repository.modifier(item);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.alimentation == null ? 'Ajouter un aliment' : 'Modifier l’aliment'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _alimentController,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Aliment *',
                    hintText: 'Ex. Maïs',
                    prefixIcon: Icon(Icons.grass_rounded),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ce champ est obligatoire.'
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantiteController,
                        enabled: !_saving,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Quantité *',
                          hintText: 'Ex. 5',
                          prefixIcon: Icon(Icons.scale_outlined),
                        ),
                        validator: (value) {
                          final number = value == null ? null : _parseNombre(value);
                          if (number == null || number <= 0) return 'Quantité invalide';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _unite,
                        decoration: const InputDecoration(labelText: 'Unité'),
                        items: const [
                          DropdownMenuItem(value: 'kg', child: Text('kg')),
                          DropdownMenuItem(value: 'sac', child: Text('sac')),
                          DropdownMenuItem(value: 'litre', child: Text('litre')),
                          DropdownMenuItem(value: 'unité', child: Text('unité')),
                        ],
                        onChanged: _saving ? null : (value) {
                          if (value != null) setState(() => _unite = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _prixController,
                  enabled: !_saving,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Prix *',
                    hintText: 'Ex. 1500',
                    suffixText: 'FCFA',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (value) {
                    final number = value == null ? null : _parseNombre(value);
                    if (number == null || number < 0) return 'Prix invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(_date)),
                  onTap: _saving ? null : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
                TextFormField(
                  controller: _observationController,
                  enabled: !_saving,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observation (facultatif)',
                    hintText: 'Ajoutez une précision si nécessaire.',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _enregistrer,
          icon: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save),
          label: Text(_saving ? 'Enregistrement…' : 'Enregistrer'),
        ),
      ],
    );
  }
}

class _StockDeductionChoice {
  const _StockDeductionChoice({required this.produit, required this.quantite});
  final StockProduitModel produit;
  final double quantite;
}

class _StockDeductionDialog extends StatefulWidget {
  const _StockDeductionDialog({required this.alimentation, required this.produits});
  final AlimentationModel alimentation;
  final List<StockProduitModel> produits;
  @override State<_StockDeductionDialog> createState() => _StockDeductionDialogState();
}

class _StockDeductionDialogState extends State<_StockDeductionDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _produitId;
  late TextEditingController _quantiteController;
  @override void initState() { super.initState(); _produitId = widget.produits.first.id; _quantiteController = TextEditingController(text: widget.alimentation.quantite.toString()); }
  @override void dispose() { _quantiteController.dispose(); super.dispose(); }
  double? _parse(String value) => double.tryParse(value.trim().replaceAll(',', '.'));
  @override Widget build(BuildContext context) {
    final produit = widget.produits.where((p) => p.id == _produitId).first;
    return AlertDialog(
      title: const Text('Déduire du stock'),
      content: SizedBox(width: 500, child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Alimentation : ' + widget.alimentation.aliment),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(initialValue: _produitId, decoration: const InputDecoration(labelText: 'Produit stock', prefixIcon: Icon(Icons.inventory_2_rounded)), items: widget.produits.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nom + ' — ' + p.quantite.toString() + ' ' + p.unite))).toList(), onChanged: (value) { if (value != null) setState(() => _produitId = value); }),
        const SizedBox(height: 14),
        TextFormField(controller: _quantiteController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Quantité à déduire', suffixText: produit.unite), validator: (value) { final n = _parse(value ?? ''); if (n == null || n <= 0) return 'Quantité invalide.'; if (n > produit.quantite) return 'La quantité dépasse le stock disponible.'; return null; }),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton.icon(onPressed: () { if (!_formKey.currentState!.validate()) return; Navigator.pop(context, _StockDeductionChoice(produit: produit, quantite: _parse(_quantiteController.text)!)); }, icon: const Icon(Icons.remove_circle_outline_rounded), label: const Text('Déduire')),
      ],
    );
  }
}