import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalBusinessCacheService {
  LocalBusinessCacheService._();

  static final LocalBusinessCacheService instance =
      LocalBusinessCacheService._();

  static const _prefix = 'setsi_business_cache_';

  Future<void> saveList(
    String key,
    List<Map<String, dynamic>> items,
  ) async {
    final preferences = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      items.map(_encodeValue).toList(),
    );

    await preferences.setString('$_prefix$key', encoded);
  }

  Future<List<Map<String, dynamic>>?> loadList(String key) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString('$_prefix$key');

    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        return null;
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(
              _decodeValue(item) as Map,
            ),
          )
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> clear(String key) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('$_prefix$key');
  }

  dynamic _encodeValue(dynamic value) {
    if (value is Timestamp) {
      return {
        '__type': 'timestamp',
        'value': value.millisecondsSinceEpoch,
      };
    }

    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(
          key.toString(),
          _encodeValue(item),
        ),
      );
    }

    if (value is List) {
      return value.map(_encodeValue).toList();
    }

    return value;
  }

  dynamic _decodeValue(dynamic value) {
    if (value is Map) {
      if (value['__type'] == 'timestamp') {
        return Timestamp.fromMillisecondsSinceEpoch(
          (value['value'] as num).toInt(),
        );
      }

      return value.map(
        (key, item) => MapEntry(
          key.toString(),
          _decodeValue(item),
        ),
      );
    }

    if (value is List) {
      return value.map(_decodeValue).toList();
    }

    return value;
  }
}
