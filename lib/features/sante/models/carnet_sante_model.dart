class CarnetSanteModel {
  final String id;
  final String bergerieId;
  final String moutonId;
  final String problemeSoin;
  final DateTime date;
  final String observation;
  final bool stockDeduit;
  final String stockMouvementId;

  const CarnetSanteModel({
    required this.id,
    required this.bergerieId,
    required this.moutonId,
    required this.problemeSoin,
    required this.date,
    this.observation = '',
    this.stockDeduit = false,
    this.stockMouvementId = '',
  });

  CarnetSanteModel copyWith({
    String? id,
    String? bergerieId,
    String? moutonId,
    String? problemeSoin,
    DateTime? date,
    String? observation,
    bool? stockDeduit,
    String? stockMouvementId,
  }) {
    return CarnetSanteModel(
      id: id ?? this.id,
      bergerieId: bergerieId ?? this.bergerieId,
      moutonId: moutonId ?? this.moutonId,
      problemeSoin: problemeSoin ?? this.problemeSoin,
      date: date ?? this.date,
      observation: observation ?? this.observation,
      stockDeduit: stockDeduit ?? this.stockDeduit,
      stockMouvementId: stockMouvementId ?? this.stockMouvementId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bergerieId': bergerieId,
      'moutonId': moutonId,
      'problemeSoin': problemeSoin,
      'date': date.millisecondsSinceEpoch,
      'observation': observation,
      'stockDeduit': stockDeduit,
      'stockMouvementId': stockMouvementId,
    };
  }

  factory CarnetSanteModel.fromMap(Map<String, dynamic> map) {
    final rawDate = map['date'];
    DateTime date;
    if (rawDate is int) {
      date = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else {
      date = DateTime.now();
    }

    return CarnetSanteModel(
      id: map['id'] ?? '',
      bergerieId: map['bergerieId'] ?? '',
      moutonId: map['moutonId'] ?? '',
      problemeSoin: map['problemeSoin'] ?? '',
      date: date,
      observation: map['observation'] ?? '',
      stockDeduit: map['stockDeduit'] == true,
      stockMouvementId: map['stockMouvementId']?.toString() ?? '',
    );
  }
}
