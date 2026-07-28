import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mouton_model.dart';
import '../repository/firebase_mouton_repository.dart';

/// Repository des moutons
final moutonRepositoryProvider =
Provider<FirebaseMoutonRepository>(
      (ref) => FirebaseMoutonRepository(),
);

/// Tous les moutons
final moutonsProvider =
FutureProvider<List<MoutonModel>>((ref) async {
  final repository = ref.watch(
    moutonRepositoryProvider,
  );

  return repository.getMoutons();
});

/// Un seul mouton
final moutonProvider =
FutureProvider.family<MoutonModel?, String>(
      (ref, id) async {
    final repository = ref.watch(
      moutonRepositoryProvider,
    );

    return repository.getMoutonById(id);
  },
);

/// Tous les béliers
final beliersProvider =
FutureProvider<List<MoutonModel>>((ref) async {
  final repository = ref.watch(
    moutonRepositoryProvider,
  );

  return repository.getBeliers();
});

/// Toutes les brebis
final brebisProvider =
FutureProvider<List<MoutonModel>>((ref) async {
  final repository = ref.watch(
    moutonRepositoryProvider,
  );

  return repository.getBrebis();
});

/// Moutons d'une bergerie
final moutonsBergerieProvider =
FutureProvider.family<List<MoutonModel>, String>(
      (ref, bergerieId) async {
    final repository = ref.watch(
      moutonRepositoryProvider,
    );

    return repository.getMoutonsByBergerie(
      bergerieId,
    );
  },
);

/// Nombre de moutons d'une bergerie
final nombreMoutonsProvider =
FutureProvider.family<int, String>(
      (ref, bergerieId) async {
    final repository = ref.watch(
      moutonRepositoryProvider,
    );

    return repository.getNombreMoutons(
      bergerieId,
    );
  },
);