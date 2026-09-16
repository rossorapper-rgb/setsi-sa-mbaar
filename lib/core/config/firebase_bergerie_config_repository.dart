import 'package:cloud_firestore/cloud_firestore.dart';

import 'bergerie_config.dart';

/// Repository Firestore des configurations personnalisées des bergeries.
///
/// Collection utilisée : `bergerie_config`.
class FirebaseBergerieConfigRepository {
  FirebaseBergerieConfigRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String collectionName = 'bergerie_config';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(collectionName);

  /// Récupère la configuration d'une bergerie à partir de son ID.
  Future<BergerieConfig?> getByBergerieId(String bergerieId) async {
    if (bergerieId.trim().isEmpty) return null;

    final document = await _collection.doc(bergerieId).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return BergerieConfig.fromMap(document.data()!);
  }

  /// Enregistre ou remplace la configuration d'une bergerie.
  Future<void> save(BergerieConfig config) async {
    await _collection.doc(config.bergerieId).set(
          config.toMap(),
          SetOptions(merge: true),
        );
  }

  /// Supprime la configuration d'une bergerie.
  Future<void> delete(String bergerieId) async {
    if (bergerieId.trim().isEmpty) return;
    await _collection.doc(bergerieId).delete();
  }
}
