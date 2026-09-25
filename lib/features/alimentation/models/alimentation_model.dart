class AlimentationModel {
  final String id;
  final String bergerieId;
  final String aliment;
  final double quantite;
  final String unite;
  final double prix;
  final DateTime date;
  final String observation;
  final bool stockDeduit;
  final String stockMouvementId;

  const AlimentationModel({
    required this.id,
    required this.bergerieId,
    required this.aliment,
    required this.quantite,
    required this.unite,
    required this.prix,
    required this.date,
    this.observation = '',
    this.stockDeduit = false,
    this.stockMouvementId = '',
  });

  AlimentationModel copyWith({
    String? id,
    String? bergerieId,
    String? aliment,
    double? quantite,
    String? unite,
    double? prix,
    DateTime? date,
    String? observation,
    bool? stockDeduit,
    String? stockMouvementId,
  }) {
    return AlimentationModel(
      id: id ?? this.id,
      bergerieId: bergerieId ?? this.bergerieId,
      aliment: aliment ?? this.aliment,
      quantite: quantite ?? this.quantite,
      unite: unite ?? this.unite,
      prix: prix ?? this.prix,
      date: date ?? this.date,
      observation: observation ?? this.observation,
      stockDeduit: stockDeduit ?? this.stockDeduit,
      stockMouvementId: stockMouvementId ?? this.stockMouvementId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bergerieId': bergerieId,
      'aliment': aliment,
      'quantite': quantite,
      'unite': unite,
      'prix': prix,
      'date': date.millisecondsSinceEpoch,
      'observation': observation,
      'stockDeduit': stockDeduit,
      'stockMouvementId': stockMouvementId,
    };
  }

  factory AlimentationModel.fromMap(Map<String, dynamic> map) {
    final rawDate = map['date'];
    final date = rawDate is int
        ? DateTime.fromMillisecondsSinceEpoch(rawDate)
        : DateTime.now();

    return AlimentationModel(
      id: map['id']?.toString() ?? '',
      bergerieId: map['bergerieId']?.toString() ?? '',
      aliment: map['aliment']?.toString() ?? '',
      quantite: (map['quantite'] as num?)?.toDouble() ?? 0,
      unite: map['unite']?.toString() ?? 'kg',
      prix: (map['prix'] as num?)?.toDouble() ?? 0,
      date: date,
      observation: map['observation']?.toString() ?? '',
      stockDeduit: map['stockDeduit'] == true,
      stockMouvementId: map['stockMouvementId']?.toString() ?? '',
    );
  }
}
