enum FinanceEntryType {
  depense,
  vente,
}

class FinanceEntryModel {
  final String id;
  final String bergerieId;
  final FinanceEntryType type;
  final String libelle;
  final double montant;
  final DateTime date;
  final String observation;

  const FinanceEntryModel({
    required this.id,
    required this.bergerieId,
    required this.type,
    required this.libelle,
    required this.montant,
    required this.date,
    this.observation = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'bergerieId': bergerieId,
        'type': type.name,
        'libelle': libelle,
        'montant': montant,
        'date': date.millisecondsSinceEpoch,
        'observation': observation,
      };

  factory FinanceEntryModel.fromMap(Map<String, dynamic> map) {
    final rawDate = map['date'];
    final date = rawDate is int
        ? DateTime.fromMillisecondsSinceEpoch(rawDate)
        : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now();

    return FinanceEntryModel(
      id: map['id']?.toString() ?? '',
      bergerieId: map['bergerieId']?.toString() ?? '',
      type: map['type'] == FinanceEntryType.vente.name
          ? FinanceEntryType.vente
          : FinanceEntryType.depense,
      libelle: map['libelle']?.toString() ?? '',
      montant: (map['montant'] as num?)?.toDouble() ?? 0,
      date: date,
      observation: map['observation']?.toString() ?? '',
    );
  }

  FinanceEntryModel copyWith({
    String? id,
    String? bergerieId,
    FinanceEntryType? type,
    String? libelle,
    double? montant,
    DateTime? date,
    String? observation,
  }) {
    return FinanceEntryModel(
      id: id ?? this.id,
      bergerieId: bergerieId ?? this.bergerieId,
      type: type ?? this.type,
      libelle: libelle ?? this.libelle,
      montant: montant ?? this.montant,
      date: date ?? this.date,
      observation: observation ?? this.observation,
    );
  }
}
