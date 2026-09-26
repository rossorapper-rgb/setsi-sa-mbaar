import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/session/current_user_service.dart';
import '../../moutons/models/mouton_model.dart';
import '../../moutons/repository/firebase_mouton_repository.dart';
import '../models/carnet_sante_model.dart';
import '../repository/firebase_carnet_sante_repository.dart';
import '../../stock/models/stock_produit_model.dart';
import '../../stock/repository/firebase_stock_repository.dart';

class CarnetSantePage extends StatefulWidget {
  const CarnetSantePage({super.key});

  @override
  State<CarnetSantePage> createState() => _CarnetSantePageState();
}

class _CarnetSantePageState extends State<CarnetSantePage> {
  final _repository = FirebaseCarnetSanteRepository();
  final _moutonRepository = FirebaseMoutonRepository();
  final _uuid = const Uuid();
  final _stockRepository = FirebaseStockRepository();

  bool _loading = true;
  String? _erreur;
  String _bergerieId = '';
  List<CarnetSanteModel> _soins = [];
  List<MoutonModel> _moutons = [];
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
      if (user == null) throw Exception('Utilisateur connecté introuvable.');
      if (bergerieId.isEmpty) {
        throw Exception('Aucune bergerie n’est associée à ce compte.');
      }

      final results = await Future.wait([
        _repository.getParBergerie(bergerieId),
        _moutonRepository.getMoutonsByBergerie(bergerieId),
      ]);

      if (!mounted) return;
      setState(() {
        _bergerieId = bergerieId;
        _soins = results[0] as List<CarnetSanteModel>;
        _moutons = results[1] as List<MoutonModel>;
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

  MoutonModel? _mouton(String id) {
    for (final mouton in _moutons) {
      if (mouton.id == id) return mouton;
    }
    return null;
  }

  Future<void> _ouvrirFormulaire({CarnetSanteModel? soin}) async {
    if (_bergerieId.isEmpty || _moutons.isEmpty) return;

    final resultat = await showDialog<bool>(
      context: context,
      builder: (_) => _CarnetSanteFormDialog(
        bergerieId: _bergerieId,
        moutons: _moutons,
        repository: _repository,
        uuid: _uuid,
        soin: soin,
      ),
    );

    if (resultat == true) await _charger();
  }

  bool get _canDeduirStock {
    final user = CurrentUserService.instance;
    return user.isAdmin || user.isResponsable || user.isTechnicien;
  }

  Future<void> _deduireDuStock(CarnetSanteModel soin) async {
    if (soin.stockDeduit) return;
    try {
      final produits = (await _stockRepository.getProduits()).where((p) => p.actif && p.quantite > 0).toList();
      if (!mounted) return;
      if (produits.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucun produit disponible dans le stock.')));
        return;
      }
      final choix = await showDialog<_StockSoinChoice>(context: context, builder: (_) => _StockSoinDialog(soin: soin, produits: produits));
      if (choix == null) return;
      await _stockRepository.deduireDepuisCarnetSante(soinId: soin.id, produitId: choix.produit.id, quantite: choix.quantite, motif: 'Soin - ${soin.problemeSoin}', date: soin.date);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stock déduit avec succès.'))); await _charger(); }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible de déduire le stock : $e')));
    }
  }
  Future<void> _supprimer(CarnetSanteModel soin) async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer le soin ?'),
        content: const Text('Cette entrée du carnet de santé sera supprimée.'),
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
    await _repository.supprimer(soin.id);
    if (mounted) await _charger();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _soins.where((soin) {
      final mouton = _mouton(soin.moutonId);
      final texte = '${mouton?.nom ?? ''} ${mouton?.numeroIdentification ?? ''} '
          '${soin.problemeSoin} ${soin.observation}'.toLowerCase();
      return texte.contains(_recherche.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard/bergerie'),
        ),
        title: const Text('Carnet de santé'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _charger,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      floatingActionButton: !_loading && _erreur == null && _moutons.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _ouvrirFormulaire(),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
            )
          : null,
      body: _buildBody(filtered),
    );
  }

  Widget _buildBody(List<CarnetSanteModel> filtered) {
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

    if (_moutons.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Ajoutez d’abord un mouton pour pouvoir enregistrer un soin.',
            textAlign: TextAlign.center,
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
            'Suivi de santé',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Conservez simplement l’historique des problèmes et des soins de vos moutons.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 18),
          TextField(
            onChanged: (value) => setState(() => _recherche = value),
            decoration: InputDecoration(
              hintText: 'Rechercher un mouton ou un soin',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
          ),
          const SizedBox(height: 20),
          if (filtered.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.health_and_safety_outlined, size: 64, color: Colors.grey.shade500),
                    const SizedBox(height: 16),
                    Text(
                      _soins.isEmpty ? 'Le carnet de santé est vide' : 'Aucun résultat',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _soins.isEmpty
                          ? 'Enregistrez le premier problème ou soin d’un mouton.'
                          : 'Essayez une autre recherche.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filtered.map(_buildCard),
        ],
      ),
    );
  }

  Widget _buildCard(CarnetSanteModel soin) {
    final mouton = _mouton(soin.moutonId);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: const CircleAvatar(child: Icon(Icons.health_and_safety_outlined)),
        title: Text(
          mouton?.nom.isNotEmpty == true ? mouton!.nom : 'Mouton',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${soin.problemeSoin}\n${DateFormat('dd/MM/yyyy').format(soin.date)}'
            '${soin.observation.trim().isNotEmpty ? '\n${soin.observation}' : ''}',
          ),
        ),
        isThreeLine: soin.observation.trim().isNotEmpty,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'stock') _deduireDuStock(soin);
            if (value == 'edit') _ouvrirFormulaire(soin: soin);
            if (value == 'delete') _supprimer(soin);
          },
          itemBuilder: (_) => [
            if (_canDeduirStock && !soin.stockDeduit)
              const PopupMenuItem(value: 'stock', child: Text('Déduire du stock')),
            if (soin.stockDeduit)
              const PopupMenuItem(enabled: false, value: 'stock_done', child: Text('Stock déjà déduit')),
            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
      ),
    );
  }
}

class _CarnetSanteFormDialog extends StatefulWidget {
  final String bergerieId;
  final List<MoutonModel> moutons;
  final FirebaseCarnetSanteRepository repository;
  final Uuid uuid;
  final CarnetSanteModel? soin;

  const _CarnetSanteFormDialog({
    required this.bergerieId,
    required this.moutons,
    required this.repository,
    required this.uuid,
    this.soin,
  });

  @override
  State<_CarnetSanteFormDialog> createState() => _CarnetSanteFormDialogState();
}

class _CarnetSanteFormDialogState extends State<_CarnetSanteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String? _moutonId;
  late DateTime _date;
  late TextEditingController _problemeController;
  late TextEditingController _observationController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _moutonId = widget.soin?.moutonId ?? widget.moutons.first.id;
    _date = widget.soin?.date ?? DateTime.now();
    _problemeController = TextEditingController(text: widget.soin?.problemeSoin ?? '');
    _observationController = TextEditingController(text: widget.soin?.observation ?? '');
  }

  @override
  void dispose() {
    _problemeController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate() || _moutonId == null) return;
    setState(() => _saving = true);

    final soin = CarnetSanteModel(
      id: widget.soin?.id ?? widget.uuid.v4(),
      bergerieId: widget.bergerieId,
      moutonId: _moutonId!,
      problemeSoin: _problemeController.text.trim(),
      date: _date,
      observation: _observationController.text.trim(),
    );

    try {
      if (widget.soin == null) {
        await widget.repository.ajouter(soin);
      } else {
        await widget.repository.modifier(soin);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.soin == null ? 'Nouveau soin' : 'Modifier le soin'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _moutonId,
                  decoration: const InputDecoration(
                    labelText: 'Mouton',
                    prefixIcon: Icon(Icons.pets),
                  ),
                  items: widget.moutons.map((mouton) {
                    final label = mouton.numeroIdentification.trim().isEmpty
                        ? mouton.nom
                        : '${mouton.nom} • ${mouton.numeroIdentification}';
                    return DropdownMenuItem(value: mouton.id, child: Text(label));
                  }).toList(),
                  onChanged: _saving ? null : (value) => setState(() => _moutonId = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _problemeController,
                  enabled: !_saving,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Problème / soin',
                    hintText: 'Ex. Boiterie, traitement, blessure…',
                    prefixIcon: Icon(Icons.medical_services_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ce champ est obligatoire.'
                      : null,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(_date)),
                  onTap: _saving
                      ? null
                      : () async {
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

class _StockSoinChoice {
  const _StockSoinChoice({required this.produit, required this.quantite});
  final StockProduitModel produit;
  final double quantite;
}

class _StockSoinDialog extends StatefulWidget {
  const _StockSoinDialog({required this.soin, required this.produits});
  final CarnetSanteModel soin;
  final List<StockProduitModel> produits;
  @override State<_StockSoinDialog> createState() => _StockSoinDialogState();
}

class _StockSoinDialogState extends State<_StockSoinDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _produitId;
  late TextEditingController _quantiteController;
  @override void initState() {
    super.initState();
    _produitId = widget.produits.first.id;
    _quantiteController = TextEditingController(text: '1');
  }
  @override void dispose() { _quantiteController.dispose(); super.dispose(); }
  double? _parse(String value) => double.tryParse(value.trim().replaceAll(',', '.'));
  @override Widget build(BuildContext context) {
    final produit = widget.produits.where((p) => p.id == _produitId).first;
    return AlertDialog(
      title: const Text('Déduire du stock'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Soin : ${widget.soin.problemeSoin}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _produitId,
              decoration: const InputDecoration(labelText: 'Produit stock', prefixIcon: Icon(Icons.inventory_2_rounded)),
              items: widget.produits.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.nom} — ${p.quantite} ${p.unite}'))).toList(),
              onChanged: (value) { if (value != null) setState(() => _produitId = value); },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _quantiteController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Quantité à déduire', suffixText: produit.unite),
              validator: (value) {
                final n = _parse(value ?? '');
                if (n == null || n <= 0) return 'Quantité invalide.';
                if (n > produit.quantite) return 'La quantité dépasse le stock disponible.';
                return null;
              },
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton.icon(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, _StockSoinChoice(produit: produit, quantite: _parse(_quantiteController.text)!));
          },
          icon: const Icon(Icons.remove_circle_outline_rounded),
          label: const Text('Déduire'),
        ),
      ],
    );
  }
}
