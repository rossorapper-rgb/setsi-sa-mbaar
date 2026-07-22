import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Date actuellement sélectionnée dans le calendrier.
final selectedDateProvider =
StateProvider<DateTime>((ref) => DateTime.now());

/// Change la date sélectionnée.
final calendarControllerProvider =
Provider<CalendarController>((ref) {
  return CalendarController(ref);
});

class CalendarController {
  final Ref ref;

  CalendarController(this.ref);

  void selectDate(DateTime date) {
    ref.read(selectedDateProvider.notifier).state = DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  DateTime get selectedDate =>
      ref.read(selectedDateProvider);

  bool isSelected(DateTime date) {
    final selected = selectedDate;

    return selected.year == date.year &&
        selected.month == date.month &&
        selected.day == date.day;
  }
}