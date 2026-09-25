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

  factory StockMouvementModel.fromMap(Map<String, dynamic> map) {
    final rawDate = map['date'];
    DateTime date;
    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is DateTime) {
      date = rawDate;
    } else {
      date = DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now();
    }

    return StockMouvementModel(
      id: map['id']?.toString() ?? '',
      bergerieId: map['bergerieId']?.toString() ?? '',
      produitId: map['produitId']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      quantite: (map['quantite'] as num?)?.toDouble() ?? 0,
      date: date,
      motif: map['motif']?.toString() ?? '',
      prix: (map['prix'] as num?)?.toDouble() ?? 0,
      fournisseur: map['fournisseur']?.toString() ?? '',
      note: map['note']?.toString() ?? '',
    );
  }

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
