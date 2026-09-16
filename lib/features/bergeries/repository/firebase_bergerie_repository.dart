import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/session/current_user_service.dart';
import '../models/bergerie_model.dart';
import 'bergerie_repository.dart';

class FirebaseBergerieRepository implements BergerieRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final String _collection = 'bergeries';

  @override
  Future<void> addBergerie(
      BergerieModel bergerie,
      ) async {
    await _firestore
        .collection(_collection)
        .doc(bergerie.id)
        .set(bergerie.toMap());
  }

  @override
  Future<void> updateBergerie(
      BergerieModel bergerie,
      ) async {
    await _firestore
        .collection(_collection)
        .doc(bergerie.id)
        .update(bergerie.toMap());
  }

  @override
  Future<void> archiveBergerie(
      String id,
      ) async {
    await _firestore
        .collection(_collection)
        .doc(id)
        .update({
      'active': false,
      'dateModification':
      DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<BergerieModel>> getAllBergeries() async {
    final currentUser =
        CurrentUserService.instance;

    // L'administrateur central peut consulter toutes les bergeries.
    if (currentUser.isAdmin) {
      final snapshot =
          await _firestore
              .collection(_collection)
              .get();

      return snapshot.docs
          .map(
            (doc) => BergerieModel.fromMap({
          ...doc.data(),
          'id': doc.id,
        }),
      )
          .toList();
    }

    // Un responsable ou un technicien ne consulte que sa bergerie.
    final bergerieId = currentUser.bergerieId;

    if ((currentUser.isResponsable || currentUser.isTechnicien) &&
        bergerieId != null &&
        bergerieId.isNotEmpty) {
      final doc = await _firestore
          .collection(_collection)
          .doc(bergerieId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return [];
      }

      return [
        BergerieModel.fromMap({
          ...doc.data()!,
          'id': doc.id,
        }),
      ];
    }

    // Les autres profils ne doivent pas accéder à la liste générale.
    return [];
  }

  @override
  Future<BergerieModel?> getBergerieById(
      String id,
      ) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(id)
        .get();

    if (!doc.exists) {
      return null;
    }

    return BergerieModel.fromMap({
      ...doc.data()!,
      'id': doc.id,
    });
  }

  // ====================================================
  // BERGERIES D'UN CLIENT
  // ====================================================

  Future<List<BergerieModel>> getBergeriesByClient(
      String clientId,
      ) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where(
      'clientId',
      isEqualTo: clientId,
    )
        .get();

    final liste = snapshot.docs
        .map(
          (doc) => BergerieModel.fromMap({
        ...doc.data(),
        'id': doc.id,
      }),
    )
        .toList();

    liste.sort(
          (a, b) => a.nom.compareTo(b.nom),
    );

    return liste;
  }
}