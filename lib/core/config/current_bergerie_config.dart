import 'package:flutter/foundation.dart';

import 'bergerie_config.dart';
import 'firebase_bergerie_config_repository.dart';

class CurrentBergerieConfig extends ChangeNotifier {
  CurrentBergerieConfig._();

  static final CurrentBergerieConfig instance = CurrentBergerieConfig._();

  final FirebaseBergerieConfigRepository _repository =
      FirebaseBergerieConfigRepository();

  BergerieConfig _config = BergerieConfig.defaut();

  BergerieConfig get config => _config;

  Future<void> load(String? bergerieId) async {
    if (bergerieId == null || bergerieId.trim().isEmpty) {
      _setConfig(BergerieConfig.defaut());
      return;
    }

    try {
      final configuration =
          await _repository.getByBergerieId(bergerieId);
      if (configuration != null && configuration.active) {
        _setConfig(configuration);
        return;
      }
    } catch (_) {}

    // Configuration locale de référence pour la bergerie Baraka de test.
    if (bergerieId == BergerieConfig.baraka().bergerieId) {
      _setConfig(BergerieConfig.baraka());
      return;
    }

    _setConfig(BergerieConfig.defaut().copyWith(bergerieId: bergerieId));
  }

  void setConfig(BergerieConfig config) {
    _setConfig(config);
  }

  void clear() {
    _setConfig(BergerieConfig.defaut());
  }

  void _setConfig(BergerieConfig config) {
    _config = config;
    notifyListeners();
  }
}
