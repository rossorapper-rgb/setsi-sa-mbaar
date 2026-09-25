import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/stock_produit_model.dart';

import '../repository/firebase_stock_repository.dart';

class AjouterProduitPage extends StatefulWidget {
  const AjouterProduitPage({super.key, this.produit});

  final StockProduitModel? produit;

  @override
  State<AjouterProduitPage> createState() => _AjouterProduitPageState();
}

class _AjouterProduitPageState extends State<AjouterProduitPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = FirebaseStockRepository();
  final _nomController = TextEditingController();
  final _categorieController = TextEditingController();
  final _quantiteController = TextEditingController(text: '0');
  final _seuilController = TextEditingController(text: '0');
  final _prixController = TextEditingController(text: '0');

  String _unite = 'unité';
  bool _actif = true;
  bool _saving = false;

  bool get _isEditing => widget.produit != null;

  static const _unites = ['unité', 'kg', 'litre', 'sac', 'flacon', 'boîte'];

  @override
  void initState() {
    super.initState();
    final produit = widget.produit;
    if (produit != null) {
      _nomController.text = produit.nom;
      _categorieController.text = produit.categorie;
      _quantiteController.text = produit.quantite.toString();
      _seuilController.text = produit.seuilMinimum.toString();
      _prixController.text = produit.prixUnitaire.toString();
      _unite = produit.unite;
      _actif = produit.actif;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _categorieController.dispose();
    _quantiteController.dispose();
    _seuilController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  double? _nombre(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label est obligatoire.';
    }
    return null;
  }

  String? _positifOuZero(String? value, String label) {
    final number = _nombre(value ?? '');
    if (number == null || number < 0) {
      return '$label doit être un nombre positif ou nul.';
    }
    return null;
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      if (_isEditing) {
        final produit = widget.produit!;
        await _repository.modifierProduit(
          produit.copyWith(
            nom: _nomController.text.trim(),
            categorie: _categorieController.text.trim(),
            unite: _unite,
            seuilMinimum: _nombre(_seuilController.text)!,
            prixUnitaire: _nombre(_prixController.text)!,
            actif: _actif,
          ),
        );
      } else {
        await _repository.ajouterProduit(
          nom: _nomController.text.trim(),
          categorie: _categorieController.text.trim(),
          unite: _unite,
          quantite: _nombre(_quantiteController.text)!,
          seuilMinimum: _nombre(_seuilController.text)!,
          prixUnitaire: _nombre(_prixController.text)!,
          actif: _actif,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Produit modifié avec succès.' : 'Produit ajouté avec succès.')),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d’ajouter le produit : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _saving ? null : () => context.pop(),
        ),
        title: Text(_isEditing ? 'Modifier le produit' : 'Ajouter un produit'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          children: [
            _Section(
              title: 'Informations du produit',
              child: Column(
                children: [
                  TextFormField(
                    controller: _nomController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nom du produit',
                      hintText: 'Ex. Aliment bétail, désinfectant...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory_2_rounded),
                    ),
                    validator: (v) => _required(v, 'Le nom'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _categorieController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      hintText: 'Ex. Alimentation, Santé, Entretien...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    validator: (v) => _required(v, 'La catégorie'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _unite,
                    decoration: const InputDecoration(
                      labelText: 'Unité',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.straighten_rounded),
                    ),
                    items: _unites
                        .map(
                          (unite) => DropdownMenuItem(
                            value: unite,
                            child: Text(unite),
                          ),
                        )
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _unite = value);
                            }
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Section(
              title: 'Stock initial',
              child: Column(
                children: [
                  TextFormField(
                    controller: _quantiteController,
                    enabled: !_isEditing,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: _isEditing ? 'Quantité actuelle' : 'Quantité initiale',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers_rounded),
                    ),
                    validator: (v) => _positifOuZero(v, 'La quantité'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _seuilController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Seuil minimum',
                      hintText: 'Déclenche une alerte lorsque le stock atteint ce niveau',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.warning_amber_rounded),
                    ),
                    validator: (v) => _positifOuZero(v, 'Le seuil minimum'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _prixController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Prix unitaire (FCFA)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.payments_rounded),
                    ),
                    validator: (v) => _positifOuZero(v, 'Le prix unitaire'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Card(
              margin: EdgeInsets.zero,
              child: SwitchListTile(
                value: _actif,
                onChanged: _saving ? null : (value) => setState(() => _actif = value),
                title: const Text('Produit actif'),
                subtitle: const Text('Un produit inactif ne déclenche pas d’alerte de stock.'),
                secondary: const Icon(Icons.toggle_on_rounded),
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _saving ? null : _enregistrer,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_saving ? 'Enregistrement...' : (_isEditing ? 'Enregistrer les modifications' : 'Enregistrer le produit')),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
