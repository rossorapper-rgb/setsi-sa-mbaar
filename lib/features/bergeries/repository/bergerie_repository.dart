import '../models/bergerie_model.dart';

abstract class BergerieRepository {
  /// Retourne toutes les bergeries
  Future<List<BergerieModel>> getAllBergeries();

  /// Retourne une bergerie par son identifiant
  Future<BergerieModel?> getBergerieById(String id);

  /// Ajoute une nouvelle bergerie
  Future<void> addBergerie(BergerieModel bergerie);

  /// Met à jour une bergerie
  Future<void> updateBergerie(BergerieModel bergerie);

  /// Archive une bergerie
  Future<void> archiveBergerie(String id);
}