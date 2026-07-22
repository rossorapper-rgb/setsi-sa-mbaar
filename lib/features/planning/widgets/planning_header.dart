import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/planning_provider.dart';

class PlanningHeader extends ConsumerWidget {
  const PlanningHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(planningControllerProvider);
    final currentView = ref.watch(planningViewProvider);

    final controller =
    ref.read(planningControllerProvider.notifier);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 32,
                ),
                SizedBox(width: 12),
                Text(
                  "Planning des interventions",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                IconButton(
                  onPressed: controller.previousDay,
                  icon: const Icon(Icons.chevron_left),
                ),

                Expanded(
                  child: Center(
                    child: Text(
                      DateFormat(
                        "EEEE dd MMMM yyyy",
                        "fr_FR",
                      ).format(selectedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: controller.nextDay,
                  icon: const Icon(Icons.chevron_right),
                ),

                const SizedBox(width: 10),

                FilledButton.icon(
                  onPressed: controller.today,
                  icon: const Icon(Icons.today),
                  label: const Text("Aujourd'hui"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SegmentedButton<PlanningView>(
              segments: const [
                ButtonSegment(
                  value: PlanningView.day,
                  label: Text("Jour"),
                  icon: Icon(Icons.today),
                ),
                ButtonSegment(
                  value: PlanningView.week,
                  label: Text("Semaine"),
                  icon: Icon(Icons.view_week),
                ),
                ButtonSegment(
                  value: PlanningView.month,
                  label: Text("Mois"),
                  icon: Icon(Icons.calendar_view_month),
                ),
              ],
              selected: {currentView},
              onSelectionChanged: (selection) {
                ref.read(planningViewProvider.notifier).state =
                    selection.first;
              },
            ),
          ],
        ),
      ),
    );
  }
}