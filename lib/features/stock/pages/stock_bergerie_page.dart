import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/stock_produit_model.dart';
import '../repository/firebase_stock_repository.dart';

class StockBergeriePage extends StatefulWidget {
  const StockBergeriePage({super.key});
  @override
  State<StockBergeriePage> createState() => _StockBergeriePageState();
}

class _StockBergeriePageState extends State<StockBergeriePage> {
  final _repository = FirebaseStockRepository();
  final _money = NumberFormat('#,##0', 'fr_FR');
  List<StockProduitModel> _produits = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    setState(() { _loading = true; _error = null; });
    try {
      final produits = await _repository.getProduits();
      if (!mounted) return;
      setState(() { _produits = produits; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  double get _valeurStock => _produits.fold(0, (t, p) => t + p.valeurStock);
  int get _alertes => _produits.where((p) => p.actif && p.estEnAlerte).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.go('/dashboard/bergerie')),
        title: const Text('Stock'),
        actions: [
        IconButton(onPressed: _loading ? null : _charger, tooltip: 'Actualiser', icon: const Icon(Icons.refresh_rounded)),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(54),
        child: SizedBox(
          height: 54,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Colors.white,
                  ),
                  onPressed: _loading || _produits.isEmpty ? null : () async {
                    final saved = await context.push<bool>('/stock/entree');
                    if (saved == true && mounted) await _charger();
                  },
                  icon: const Icon(Icons.add_box_rounded, size: 19),
                  label: const Text('Entrée de stock'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Colors.white,
                  ),
                  onPressed: _loading || _produits.isEmpty ? null : () async {
                    final saved = await context.push<bool>('/stock/sortie');
                    if (saved == true && mounted) await _charger();
                  },
                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 19),
                  label: const Text('Sortie de stock'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Colors.white,
                  ),
                  onPressed: _loading ? null : () => context.push('/stock/historique'),
                  icon: const Icon(Icons.history_rounded, size: 19),
                  label: const Text('Historique'),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await context.push<bool>('/stock/ajouter');
          if (added == true && mounted) {
            await _charger();
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Produit'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Impossible de charger le stock.'), const SizedBox(height: 12), FilledButton(onPressed: _charger, child: const Text('Réessayer'))]))
              : RefreshIndicator(
                  onRefresh: _charger,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      Row(children: [
                        Expanded(child: _ResumeCard(icon: Icons.inventory_2_rounded, title: 'Produits', value: _produits.length.toString())),
                        const SizedBox(width: 10),
                        Expanded(child: _ResumeCard(icon: Icons.payments_rounded, title: 'Valeur', value: _money.format(_valeurStock) + ' F')),
                        const SizedBox(width: 10),
                        Expanded(child: _ResumeCard(icon: Icons.warning_amber_rounded, title: 'Alertes', value: _alertes.toString(), alert: _alertes > 0)),
                      ]),
                      if (_alertes > 0) ...[
                        _AlertesStock(produits: _produits.where((p) => p.actif && p.estEnAlerte).toList()),
                        const SizedBox(height: 20),
                      ],
                      const Text('Produits en stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      if (_produits.isEmpty)
                        const _StockVide()
                      else
                        ..._produits.map((p) => _ProduitCard(produit: p)),
                    ],
                  ),
                ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.icon, required this.title, required this.value, this.alert = false});
  final IconData icon; final String title; final String value; final bool alert;
  @override
  Widget build(BuildContext context) {
    final color = alert ? Colors.orange : Theme.of(context).colorScheme.primary;
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color), const SizedBox(height: 7), Text(title, style: const TextStyle(fontSize: 11, color: Colors.black54)), const SizedBox(height: 2), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800))]));
  }
}

class _ProduitCard extends StatelessWidget {
  const _ProduitCard({required this.produit});
  final StockProduitModel produit;
  @override
  Widget build(BuildContext context) {
    final alert = produit.actif && produit.estEnAlerte;
    final color = alert ? Colors.orange : Theme.of(context).colorScheme.primary;
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: alert ? Border.all(color: Colors.orange.withValues(alpha: .45)) : null), child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(11)), child: Icon(alert ? Icons.warning_amber_rounded : Icons.inventory_2_rounded, color: color)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(produit.nom.isEmpty ? 'Produit sans nom' : produit.nom, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(produit.categorie.isEmpty ? produit.unite : produit.categorie + ' • ' + produit.unite, style: const TextStyle(fontSize: 12, color: Colors.black54)), const SizedBox(height: 6), Text('Stock : ' + produit.quantite.toString() + ' ' + produit.unite, style: const TextStyle(fontWeight: FontWeight.w600)), if (alert) const Text('Stock sous le seuil minimum', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w700))])), const SizedBox(width: 8), Text(NumberFormat('#,##0', 'fr_FR').format(produit.valeurStock) + ' F', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))]));
  }
}

class _AlertesStock extends StatelessWidget {
  const _AlertesStock({required this.produits});
  final List<StockProduitModel> produits;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: .35)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.orange), SizedBox(width: 8), Text('Alertes de stock', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))]),
        const SizedBox(height: 10),
        ...produits.map((produit) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            const Icon(Icons.circle, color: Colors.orange, size: 8),
            const SizedBox(width: 8),
            Expanded(child: Text('${produit.nom} : ${produit.quantite} ${produit.unite} (seuil ${produit.seuilMinimum} ${produit.unite})', style: const TextStyle(fontWeight: FontWeight.w600))),
          ]),
        )),
      ]),
    );
  }
}

class _StockVide extends StatelessWidget {
  const _StockVide();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: const Column(children: [Icon(Icons.inventory_2_outlined, size: 48, color: Colors.black38), SizedBox(height: 12), Text('Aucun produit en stock', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height: 5), Text('Ajoutez vos premiers produits pour commencer la gestion du stock.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54))]));
}