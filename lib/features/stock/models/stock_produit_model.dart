class StockProduitModel {
  final String id;
  final String bergerieId;
  final String nom;
  final String categorie;
  final String unite;
  final double quantite;
  final double seuilMinimum;
  final double prixUnitaire;
  final bool actif;

  const StockProduitModel({
    required this.id,
    required this.bergerieId,
    required this.nom,
    required this.categorie,
    required this.unite,
    required this.quantite,
    required this.seuilMinimum,
    required this.prixUnitaire,
    this.actif = true,
  });

  /// Indique si le stock est actuellement sous le seuil minimum.
  bool get estEnAlerte => quantite <= seuilMinimum;

  /// Valeur totale actuelle du stock pour ce produit.
  double get valeurStock => quantite * prixUnitaire;

  Map<String, dynamic> toMap() {
    return {
      'bergerieId': bergerieId,
      'nom': nom,
      'categorie': categorie,
      'unite': unite,
      'quantite': quantite,
      'seuilMinimum': seuilMinimum,
      'prixUnitaire': prixUnitaire,
      'actif': actif,
    };
  }

  factory StockProduitModel.fromMap(Map<String, dynamic> map) {
    return StockProduitModel(
      id: map['id']?.toString() ?? '',
      bergerieId: map['bergerieId']?.toString() ?? '',
      nom: map['nom']?.toString() ?? '',
      categorie: map['categorie']?.toString() ?? '',
      unite: map['unite']?.toString() ?? 'unité',
      quantite: (map['quantite'] as num?)?.toDouble() ?? 0,
      seuilMinimum: (map['seuilMinimum'] as num?)?.toDouble() ?? 0,
      prixUnitaire: (map['prixUnitaire'] as num?)?.toDouble() ?? 0,
      actif: map['actif'] is bool ? map['actif'] as bool : true,
    );
  }

  StockProduitModel copyWith({
    String? id,
    String? bergerieId,
    String? nom,
    String? categorie,
    String? unite,
    double? quantite,
    double? seuilMinimum,
    double? prixUnitaire,
    bool? actif,
  }) {
    return StockProduitModel(
      id: id ?? this.id,
      bergerieId: bergerieId ?? this.bergerieId,
      nom: nom ?? this.nom,
      categorie: categorie ?? this.categorie,
      unite: unite ?? this.unite,
      quantite: quantite ?? this.quantite,
      seuilMinimum: seuilMinimum ?? this.seuilMinimum,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      actif: actif ?? this.actif,
    );
  }
}
