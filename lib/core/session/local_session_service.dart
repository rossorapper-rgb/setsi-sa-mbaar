import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/utilisateurs/models/utilisateur_model.dart';
import '../config/bergerie_config.dart';

class LocalSessionService {
  LocalSessionService._();

  static final LocalSessionService instance = LocalSessionService._();

  static const _userKey = 'setsi_local_user';
  static const _bergerieConfigKey = 'setsi_local_bergerie_config';

  Future<void> saveUtilisateur(UtilisateurModel utilisateur) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _userKey,
      jsonEncode(utilisateur.toMap()..['id'] = utilisateur.id),
    );
  }

  Future<UtilisateurModel?> loadUtilisateur() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_userKey);

    if (raw == null || raw.isEmpty) return null;

    try {
      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final id = map.remove('id')?.toString();

      if (id == null || id.isEmpty) return null;

      return UtilisateurModel.fromMap(map, id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveBergerieConfig(BergerieConfig config) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _bergerieConfigKey,
      jsonEncode(config.toMap()),
    );
  }

  Future<BergerieConfig?> loadBergerieConfig() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_bergerieConfigKey);

    if (raw == null || raw.isEmpty) return null;

    try {
      return BergerieConfig.fromMap(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_userKey);
    await preferences.remove(_bergerieConfigKey);
  }
}
