import 'bergerie_config.dart';
import 'firebase_bergerie_config_repository.dart';

class CurrentBergerieConfig {
  CurrentBergerieConfig._();

  static final CurrentBergerieConfig instance = CurrentBergerieConfig._();

  final FirebaseBergerieConfigRepository _repository = FirebaseBergerieConfigRepository();
  BergerieConfig _config = BergerieConfig.defaut();

  BergerieConfig get config => _config;

  Future<void> load(String? bergerieId) async {
    if (bergerieId == null || bergerieId.trim().isEmpty) {
      _config = BergerieConfig.defaut();
      return;
    }

    try {
      final configuration = await _repository.getByBergerieId(bergerieId);
      if (configuration != null && configuration.active) {
        _config = configuration;
        return;
      }
    } catch (_) {}

    // Configuration locale de référence pour la bergerie Baraka de test.
    if (bergerieId == BergerieConfig.baraka().bergerieId) {
      _config = BergerieConfig.baraka();
      return;
    }

    _config = BergerieConfig.defaut().copyWith(bergerieId: bergerieId);
  }

  void setConfig(BergerieConfig config) => _config = config;

  void clear() => _config = BergerieConfig.defaut();
}
