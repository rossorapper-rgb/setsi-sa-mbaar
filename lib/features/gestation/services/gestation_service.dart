import '../models/gestation_model.dart';
import '../repositories/firebase_gestation_repository.dart';

class GestationService {
  GestationService({
    FirebaseGestationRepository? repository,
  }) : _repository =
      repository ?? FirebaseGestationRepository();

  final FirebaseGestationRepository _repository;

  /// Vérifie si une brebis possède déjà une gestation active.
  Future<GestationModel?> verifierGestationActive(
      String brebisId,
      ) async {
    return await _repository.getGestationActiveByBrebis(
      brebisId,
    );
  }

  /// Calcule automatiquement la date probable de mise bas.
  DateTime calculerDateMiseBas(
      DateTime dateSaillie,
      ) {
    return dateSaillie.add(
      const Duration(days: 150),
    );
  }

  /// Vérifie si la femelle peut recevoir une nouvelle gestation.
  Future<bool> femelleDisponible(
      String brebisId,
      ) async {
    final gestation =
    await verifierGestationActive(
      brebisId,
    );

    return gestation == null;
  }
}