import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PlanningView {
  day,
  week,
  month,
}

final planningViewProvider =
StateProvider<PlanningView>((ref) => PlanningView.day);

final selectedPlanningDateProvider =
StateProvider<DateTime>((ref) => DateTime.now());

class PlanningController extends StateNotifier<DateTime> {
  PlanningController() : super(DateTime.now());

  void selectDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }

  void nextDay() {
    state = state.add(const Duration(days: 1));
  }

  void previousDay() {
    state = state.subtract(const Duration(days: 1));
  }

  void today() {
    final now = DateTime.now();
    state = DateTime(now.year, now.month, now.day);
  }
}

final planningControllerProvider =
StateNotifierProvider<PlanningController, DateTime>(
      (ref) => PlanningController(),
);