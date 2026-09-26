import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/stock_produit_model.dart';
import '../repository/firebase_stock_repository.dart';

class EntreeStockPage extends StatefulWidget {
  const EntreeStockPage({super.key});
  @override State<EntreeStockPage> createState() => _EntreeStockPageState();
}

class _EntreeStockPageState extends State<EntreeStockPage> {
  final _repository = FirebaseStockRepository();
  List<StockProduitModel> _produits = [];
  bool _loading = true;
  String? _loadError;
  final _formKey = GlobalKey<FormState>();
  final _quantiteController = TextEditingController();
  final _prixController = TextEditingController();
  final _motifController = TextEditingController();
  final _fournisseurController = TextEditingController();
  final _noteController = TextEditingController();
  String? _produitId;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override void initState() { super.initState(); _chargerProduits(); }

  Future<void> _chargerProduits() async {
    try {
      final produits = await _repository.getProduits();
      if (!mounted) return;
      setState(() { _produits = produits; _loading = false; if (_produits.isNotEmpty) _produitId = _produits.first.id; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _loadError = e.toString(); });
    }
  }
  @override void dispose() { _quantiteController.dispose(); _prixController.dispose(); _motifController.dispose(); _fournisseurController.dispose(); _noteController.dispose(); super.dispose(); }
  double? _nombre(String value) => double.tryParse(value.trim().replaceAll(',', '.'));

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate() || _produitId == null) return;
    setState(() => _saving = true);
    try {
      await _repository.enregistrerEntree(produitId: _produitId!, quantite: _nombre(_quantiteController.text)!, motif: _motifController.text.trim(), date: _date, prix: _nombre(_prixController.text)!, fournisseur: _fournisseurController.text.trim(), note: _noteController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entrée de stock enregistrée avec succès.')));
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible d’enregistrer l’entrée : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _produits.where((p) => p.id == _produitId).firstOrNull;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: _saving ? null : () => context.pop()), title: const Text('Entrée de stock')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _loadError != null ? Center(child: Text('Impossible de charger les produits.\n$_loadError!', textAlign: TextAlign.center)) : _produits.isEmpty ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Aucun produit disponible. Ajoutez d’abord un produit au stock.', textAlign: TextAlign.center))) : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          children: [
            _Section(title: 'Produit', child: Column(children: [
              DropdownButtonFormField<String>(initialValue: _produitId, decoration: const InputDecoration(labelText: 'Produit', border: OutlineInputBorder(), prefixIcon: Icon(Icons.inventory_2_rounded)), items: _produits.where((p) => p.actif).map((p) => DropdownMenuItem(value: p.id, child: Text('${p.nom} (${p.unite})'))).toList(), onChanged: _saving ? null : (value) => setState(() => _produitId = value), validator: (v) => v == null ? 'Sélectionnez un produit.' : null),
              if (selected != null) ...[const SizedBox(height: 10), Align(alignment: Alignment.centerLeft, child: Text('Stock actuel : ${_formatQuantity(selected.quantite)} ${selected.unite}', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)))],
            ])),
            const SizedBox(height: 14),
            _Section(title: 'Détails de l’entrée', child: Column(children: [
              TextFormField(controller: _quantiteController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Quantité ajoutée', border: OutlineInputBorder(), prefixIcon: Icon(Icons.add_box_rounded)), validator: (v) { final n = _nombre(v ?? ''); return n == null || n <= 0 ? 'Entrez une quantité supérieure à zéro.' : null; }),
              const SizedBox(height: 14),
              TextFormField(controller: _prixController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Prix d’achat unitaire (FCFA)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.payments_rounded)), validator: (v) { final n = _nombre(v ?? ''); return n == null || n < 0 ? 'Entrez un prix valide.' : null; }),
              const SizedBox(height: 14),
              InkWell(onTap: _saving ? null : () async { final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2024), lastDate: DateTime(2100)); if (picked != null) setState(() => _date = picked); }, child: InputDecorator(decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_month_rounded)), child: Text(DateFormat('dd/MM/yyyy').format(_date)))),
              const SizedBox(height: 14),
              TextFormField(controller: _motifController, decoration: const InputDecoration(labelText: 'Motif', hintText: 'Ex. Achat, livraison, don...', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description_rounded)), validator: (v) => v == null || v.trim().isEmpty ? 'Le motif est obligatoire.' : null),
            ])),
            const SizedBox(height: 14),
            _Section(title: 'Informations complémentaires', child: Column(children: [
              TextFormField(controller: _fournisseurController, decoration: const InputDecoration(labelText: 'Fournisseur (facultatif)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.store_rounded))),
              const SizedBox(height: 14),
              TextFormField(controller: _noteController, maxLines: 2, decoration: const InputDecoration(labelText: 'Note (facultative)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.notes_rounded))),
            ])),
            const SizedBox(height: 22),
            FilledButton.icon(onPressed: _saving ? null : _enregistrer, icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_rounded), label: Text(_saving ? 'Enregistrement...' : 'Enregistrer l’entrée'), style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52))),
          ],
        ),
      ),
    );
  }

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title; final Widget child;
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), const SizedBox(height: 14), child]));
}