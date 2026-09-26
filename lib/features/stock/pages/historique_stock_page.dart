import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/stock_mouvement_model.dart';
import '../repository/firebase_stock_repository.dart';

class HistoriqueStockPage extends StatefulWidget {
  const HistoriqueStockPage({super.key});
  @override State<HistoriqueStockPage> createState() => _HistoriqueStockPageState();
}
class _HistoriqueStockPageState extends State<HistoriqueStockPage> {
  final _repository = FirebaseStockRepository();
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');
  List<StockMouvementModel> _mouvements = [];
  bool _loading = true;
  String _filtre = 'tous';
  @override void initState() { super.initState(); _charger(); }
  Future<void> _charger() async {
    setState(() => _loading = true);
    final mouvements = await _repository.getMouvements();
    if (!mounted) return;
    setState(() { _mouvements = mouvements; _loading = false; });
  }
  @override Widget build(BuildContext context) {
    final filtered = _filtre == 'tous' ? _mouvements : _mouvements.where((m) => m.type == _filtre).toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()), title: const Text('Historique du stock'), actions: [IconButton(onPressed: _loading ? null : _charger, icon: const Icon(Icons.refresh_rounded))]),
      body: _loading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(
        onRefresh: _charger,
        child: ListView(padding: const EdgeInsets.fromLTRB(16,16,16,30), children: [
          SegmentedButton<String>(segments: const [ButtonSegment(value:'tous', label:Text('Tous')), ButtonSegment(value:'entree', label:Text('Entrées')), ButtonSegment(value:'sortie', label:Text('Sorties'))], selected: {_filtre}, onSelectionChanged: (s) => setState(() => _filtre = s.first)),
          const SizedBox(height: 16),
          if (filtered.isEmpty) const _Vide() else ...filtered.map((m) => _MouvementCard(mouvement: m, dateFormat: _dateFormat)),
        ]),
      ),
    );
  }
}
class _MouvementCard extends StatelessWidget {
  const _MouvementCard({required this.mouvement, required this.dateFormat});
  final StockMouvementModel mouvement; final DateFormat dateFormat;
  @override Widget build(BuildContext context) {
    final entree = mouvement.type == 'entree';
    final color = entree ? Colors.green : Colors.red;
    return Container(margin: const EdgeInsets.only(bottom:10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(15)), child: Row(children:[Container(width:44,height:44,decoration:BoxDecoration(color:color.withValues(alpha:.10),borderRadius:BorderRadius.circular(11)),child:Icon(entree?Icons.add_box_rounded:Icons.remove_circle_outline_rounded,color:color)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(entree?'Entrée':'Sortie',style:const TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:3),Text(mouvement.motif.isEmpty?'Sans motif':mouvement.motif),const SizedBox(height:3),Text(dateFormat.format(mouvement.date),style:const TextStyle(fontSize:12,color:Colors.black54)),if(entree&&mouvement.fournisseur.isNotEmpty) Text('Fournisseur : ${mouvement.fournisseur}',style:const TextStyle(fontSize:12,color:Colors.black54))])),Text(('${entree ? '+' : '-'} ${mouvement.quantite}'),style:TextStyle(fontWeight:FontWeight.w800,color:color))]));
  }
}
class _Vide extends StatelessWidget {
  const _Vide();
  @override Widget build(BuildContext context)=>const Padding(padding:EdgeInsets.symmetric(vertical:60),child:Column(children:[Icon(Icons.history_rounded,size:48,color:Colors.black38),SizedBox(height:12),Text('Aucun mouvement',style:TextStyle(fontWeight:FontWeight.w700)),SizedBox(height:5),Text('Les entrées et sorties apparaîtront ici.',textAlign:TextAlign.center,style:TextStyle(color:Colors.black54))]));
}