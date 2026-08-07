import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/utilisateur_model.dart';
import '../repository/firebase_utilisateur_repository.dart';

final utilisateurRepositoryProvider =
Provider<FirebaseUtilisateurRepository>((ref) {
  return FirebaseUtilisateurRepository();
});

final utilisateursProvider =
FutureProvider<List<UtilisateurModel>>((ref) async {
  return ref.read(utilisateurRepositoryProvider).getUtilisateurs();
});

final tousLesUtilisateursProvider =
FutureProvider<List<UtilisateurModel>>((ref) async {
  return ref
      .read(utilisateurRepositoryProvider)
      .getTousLesUtilisateurs();
});

final nombreUtilisateursProvider =
FutureProvider<int>((ref) async {
  return ref
      .read(utilisateurRepositoryProvider)
      .getNombreUtilisateurs();
});

final utilisateurProvider =
FutureProvider.family<UtilisateurModel?, String>(
      (ref, id) async {
    return ref
        .read(utilisateurRepositoryProvider)
        .getUtilisateurById(id);
  },
);

final utilisateurTelephoneProvider =
FutureProvider.family<UtilisateurModel?, String>(
      (ref, telephone) async {
    return ref
        .read(utilisateurRepositoryProvider)
        .getUtilisateurByTelephone(telephone);
  },
);

final utilisateursByRoleProvider =
FutureProvider.family<List<UtilisateurModel>, String>(
      (ref, role) async {
    return ref
        .read(utilisateurRepositoryProvider)
        .getUtilisateursByRole(role);
  },
);

final utilisateursByBergerieProvider =
FutureProvider.family<List<UtilisateurModel>, String>(
      (ref, bergerieId) async {
    return ref
        .read(utilisateurRepositoryProvider)
        .getUtilisateursByBergerie(bergerieId);
  },
);

final utilisateursStreamProvider =
StreamProvider<List<UtilisateurModel>>((ref) {
  return ref
      .read(utilisateurRepositoryProvider)
      .streamUtilisateurs();
});

final utilisateurStreamProvider =
StreamProvider.family<UtilisateurModel?, String>(
      (ref, id) {
    return ref
        .read(utilisateurRepositoryProvider)
        .streamUtilisateur(id);
  },
);