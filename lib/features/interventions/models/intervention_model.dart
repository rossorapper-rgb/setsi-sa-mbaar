class InterventionModel {
  final String id;
  final String bergerieId;
  final String type;
  final DateTime date;
  final String? moutonId;
  final String? moutonNom;
  final String observation;

  const InterventionModel({
    required this.id,
    required this.bergerieId,
    required this.type,
    required this.date,
    this.moutonId,
    this.moutonNom,
    this.observation = '',
  });

  InterventionModel copyWith({
    String? id,
    String? bergerieId,
    String? type,
    DateTime? date,
    String? moutonId,
    String? moutonNom,
    String? observation,
  }) {
    return InterventionModel(
      id: id ?? this.id,
      bergerieId: bergerieId ?? this.bergerieId,
      type: type ?? this.type,
      date: date ?? this.date,
      moutonId: moutonId ?? this.moutonId,
      moutonNom: moutonNom ?? this.moutonNom,
      observation: observation ?? this.observation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bergerieId': bergerieId,
      'type': type,
      'date': date.millisecondsSinceEpoch,
      'moutonId': moutonId,
      'moutonNom': moutonNom,
      'observation': observation,
    };
  }

  factory InterventionModel.fromMap(Map<String, dynamic> map) {
    final rawDate = map['date'];
    final date = rawDate is int
        ? DateTime.fromMillisecondsSinceEpoch(rawDate)
        : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now();

    return InterventionModel(
      id: map['id']?.toString() ?? '',
      bergerieId: map['bergerieId']?.toString() ?? '',
      type: map['type']?.toString() ?? 'Autre',
      date: date,
      moutonId: map['moutonId']?.toString(),
      moutonNom: map['moutonNom']?.toString(),
      observation: map['observation']?.toString() ?? '',
    );
  }
}
