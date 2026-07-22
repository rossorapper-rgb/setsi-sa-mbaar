import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/planning_filter_provider.dart';

class PlanningFilters extends ConsumerWidget {
  const PlanningFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(planningStatusFilterProvider);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.filter_alt),
            const SizedBox(width: 10),

            const Text(
              "Statut :",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: DropdownButton<PlanningStatusFilter>(
                isExpanded: true,
                value: selectedFilter,
                items: PlanningStatusFilter.values.map((filter) {
                  return DropdownMenuItem(
                    value: filter,
                    child: Text(filter.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(planningStatusFilterProvider.notifier)
                        .state = value;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}