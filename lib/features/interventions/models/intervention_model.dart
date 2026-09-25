class InterventionModel {
  final String id;
  final String bergerieId;
  final String type;
  final DateTime date;
  final String? moutonId;
  final String? moutonNom;
  final String observation;
  final bool stockDeduit;
  final String stockMouvementId;

  const InterventionModel({
    required this.id,
    required this.bergerieId,
    required this.type,
    required this.date,
    this.moutonId,
    this.moutonNom,
    this.observation = '',
    this.stockDeduit = false,
    this.stockMouvementId = '',
  });

  // Compatibilite avec les anciens composants du dashboard admin.
  DateTime get dateIntervention => date;
  String get agent => '';
  String get statut => '';
  bool get lavage => type.toLowerCase().contains('lavage');
  bool get nettoyageBergerie => type.toLowerCase().contains('nettoyage');
  bool get desinfection => type.toLowerCase().contains('désinfection') || type.toLowerCase().contains('desinfection');
  String get bergerieNom => '';

  InterventionModel copyWith({
    String? id,
    String? bergerieId,
    String? type,
    DateTime? date,
    String? moutonId,
    String? moutonNom,
    String? observation,
    bool? stockDeduit,
    String? stockMouvementId,
  }) {
    return InterventionModel(
      id: id ?? this.id,
      bergerieId: bergerieId ?? this.bergerieId,
      type: type ?? this.type,
      date: date ?? this.date,
      moutonId: moutonId ?? this.moutonId,
      moutonNom: moutonNom ?? this.moutonNom,
      observation: observation ?? this.observation,
      stockDeduit: stockDeduit ?? this.stockDeduit,
      stockMouvementId: stockMouvementId ?? this.stockMouvementId,
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
      'stockDeduit': stockDeduit,
      'stockMouvementId': stockMouvementId,
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
      stockDeduit: map['stockDeduit'] == true,
      stockMouvementId: map['stockMouvementId']?.toString() ?? '',
    );
  }
}
