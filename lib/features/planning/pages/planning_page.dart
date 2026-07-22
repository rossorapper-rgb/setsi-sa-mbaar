import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../interventions/providers/intervention_provider.dart';
import '../providers/planning_provider.dart';
import '../providers/planning_filter_provider.dart';

import '../widgets/planning_day_card.dart';
import '../widgets/planning_filters.dart';
import '../widgets/planning_header.dart';
import '../widgets/planning_stats.dart';

class PlanningPage extends ConsumerWidget {
const PlanningPage({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
final selectedDate = ref.watch(planningControllerProvider);
final interventions = ref.watch(interventionProvider);

final statusFilter = ref.watch(planningStatusFilterProvider);

final interventionsFiltrees = interventions.where((intervention) {
final memeJour =
intervention.dateIntervention.year == selectedDate.year &&
intervention.dateIntervention.month == selectedDate.month &&
intervention.dateIntervention.day == selectedDate.day;

if (!memeJour) return false;

final statut = statusFilter.statut;

if (statut == null) {
return true;
}

return intervention.statut == statut;
}).toList();

return Scaffold(
backgroundColor: const Color(0xFFF5F7FA),

  body: SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [

const PlanningHeader(),

const SizedBox(height: 20),

const PlanningStats(),

const SizedBox(height: 20),

const PlanningFilters(),

const SizedBox(height: 20),

Card(
elevation: 1,

child: Padding(
padding: const EdgeInsets.all(16),

child: TableCalendar(
firstDay: DateTime(2025, 1, 1),
lastDay: DateTime(2035, 12, 31),

focusedDay: selectedDate,

selectedDayPredicate: (day) {
return isSameDay(day, selectedDate);
},

onDaySelected: (selectedDay, focusedDay) {
ref
.read(planningControllerProvider.notifier)
.selectDate(selectedDay);
},

calendarFormat: CalendarFormat.month,

headerVisible: false,
  ),
 ),
),
  const SizedBox(height: 20),

  PlanningDayCard(
    selectedDate: selectedDate,
    interventions: interventionsFiltrees,
  ),
],
),
),
),
);
}
}