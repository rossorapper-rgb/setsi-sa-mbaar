import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reproduction_model.dart';
import '../repository/firebase_reproduction_repository.dart';

final reproductionRepositoryProvider =
Provider<FirebaseReproductionRepository>(
      (ref) => FirebaseReproductionRepository(),
);

final reproductionsProvider = FutureProvider.family<
    List<ReproductionModel>,
    String>((ref, moutonId) async {
  final repository = ref.watch(
    reproductionRepositoryProvider,
  );

  return repository.getReproductionsDuMouton(
    moutonId,
  );
});

final reproductionEnCoursProvider =
FutureProvider.family<
    ReproductionModel?,
    String>((ref, moutonId) async {
  final repository = ref.watch(
    reproductionRepositoryProvider,
  );

  return repository.getReproductionEnCours(
    moutonId,
  );
});
final toutesLesReproductionsProvider =
FutureProvider<List<ReproductionModel>>((ref) async {
  final repository = ref.watch(
    reproductionRepositoryProvider,
  );

  return repository.getToutesLesReproductions();
});