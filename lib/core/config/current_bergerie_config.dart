import 'bergerie_config.dart';
import 'firebase_bergerie_config_repository.dart';

/// Gestionnaire de la configuration de la bergerie actuellement utilisée.
class CurrentBergerieConfig {
  CurrentBergerieConfig._();

  static final CurrentBergerieConfig instance =
      CurrentBergerieConfig._();

  final FirebaseBergerieConfigRepository _repository =
      FirebaseBergerieConfigRepository();

  BergerieConfig _config = BergerieConfig.defaut();

  BergerieConfig get config => _config;

  /// Charge la configuration depuis Firestore.
  ///
  /// Si aucune configuration n'est encore enregistrée, la configuration
  /// par défaut est conservée afin de ne pas bloquer le démarrage.
  Future<void> load(String? bergerieId) async {
    if (bergerieId == null || bergerieId.trim().isEmpty) {
      _config = BergerieConfig.defaut();
      return;
    }

    try {
      final configuration = await _repository.getByBergerieId(bergerieId);

      if (configuration != null && configuration.active) {
        _config = configuration;
      } else {
        _config = BergerieConfig.defaut().copyWith(
          bergerieId: bergerieId,
        );
      }
    } catch (_) {
      _config = BergerieConfig.defaut().copyWith(
        bergerieId: bergerieId,
      );
    }
  }

  /// Permet de définir temporairement une configuration en mémoire.
  void setConfig(BergerieConfig config) {
    _config = config;
  }

  /// Réinitialise la configuration par défaut.
  void clear() {
    _config = BergerieConfig.defaut();
  }
}
