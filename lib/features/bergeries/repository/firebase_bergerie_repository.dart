import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/session/current_user_service.dart';
import '../../auth/services/auth_service.dart';
import '../../clients/repositories/firebase_client_repository.dart';
import '../models/bergerie_model.dart';
import 'bergerie_repository.dart';

class FirebaseBergerieRepository implements BergerieRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _collection = 'bergeries';

  @override
  Future<void> addBergerie(BergerieModel bergerie) async {
    await _firestore
        .collection(_collection)
        .doc(bergerie.id)
        .set(bergerie.toMap());
  }

  @override
  Future<void> updateBergerie(BergerieModel bergerie) async {
    await _firestore
        .collection(_collection)
        .doc(bergerie.id)
        .update(bergerie.toMap());
  }

  @override
  Future<void> archiveBergerie(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'active': false,
      'dateModification': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<BergerieModel>> getAllBergeries() async {
    if (AuthService.instance.isAdmin ||
        AuthService.instance.isResponsable) {
      final snapshot =
      await _firestore.collection(_collection).get();

      return snapshot.docs
          .map(
            (doc) => BergerieModel.fromMap({
          ...doc.data(),
          'id': doc.id,
        }),
      )
          .toList();
    }

    final utilisateur = CurrentUserService.instance.currentUser;

    if (utilisateur == null) {
      return [];
    }

    final client =
    await FirebaseClientRepository().getClients();

    final clientCourant = client.firstWhere(
          (c) => c.telephone == utilisateur.telephone,
      orElse: () => throw Exception('Client introuvable'),
    );

    return getBergeriesByClient(clientCourant.id);
  }

  @override
  Future<BergerieModel?> getBergerieById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();

    if (!doc.exists) return null;

    return BergerieModel.fromMap({
      ...doc.data()!,
      'id': doc.id,
    });
  }
  //====================================================
// BERGERIES D'UN CLIENT
//====================================================

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