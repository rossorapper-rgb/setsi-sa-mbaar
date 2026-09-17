class CarnetSanteModel {
  final String id;
  final String bergerieId;
  final String moutonId;
  final String problemeSoin;
  final DateTime date;
  final String observation;

  const CarnetSanteModel({
    required this.id,
    required this.bergerieId,
    required this.moutonId,
    required this.problemeSoin,
    required this.date,
    this.observation = '',
  });

  CarnetSanteModel copyWith({
    String? id,
    String? bergerieId,
    String? moutonId,
    String? problemeSoin,
    DateTime? date,
    String? observation,
  }) {
    return CarnetSanteModel(
      id: id ?? this.id,
      bergerieId: bergerieId ?? this.bergerieId,
      moutonId: moutonId ?? this.moutonId,
      problemeSoin: problemeSoin ?? this.problemeSoin,
      date: date ?? this.date,
      observation: observation ?? this.observation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bergerieId': bergerieId,
      'moutonId': moutonId,
      'problemeSoin': problemeSoin,
      'date': date.millisecondsSinceEpoch,
      'observation': observation,
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
    );
  }
}
