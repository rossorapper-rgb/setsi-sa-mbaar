import 'package:cloud_firestore/cloud_firestore.dart';

class StockMouvementModel {
  final String id;
  final String bergerieId;
  final String produitId;
  final String type;
  final double quantite;
  final DateTime date;
  final String motif;
  final double prix;
  final String fournisseur;
  final String note;

  const StockMouvementModel({
    required this.id,
    required this.bergerieId,
    required this.produitId,
    required this.type,
    required this.quantite,
    required this.date,
    required this.motif,
    required this.prix,
    this.fournisseur = '',
    this.note = '',
  });

  Map<String, dynamic> toMap() => {
        'bergerieId': bergerieId,
        'produitId': produitId,
        'type': type,
        'quantite': quantite,
        'date': Timestamp.fromDate(date),
        'motif': motif,
        'prix': prix,
        'fournisseur': fournisseur,
        'note': note,
      };
}
