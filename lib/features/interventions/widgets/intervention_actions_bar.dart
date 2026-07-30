import 'package:flutter/material.dart';

class InterventionActionsBar extends StatelessWidget {
  final int totalInterventions;
  final VoidCallback onAdd;
  final VoidCallback? onRefresh;
  final VoidCallback? onExportPdf;
  final VoidCallback? onExportExcel;

  const InterventionActionsBar({
    super.key,
    required this.totalInterventions,
    required this.onAdd,
    this.onRefresh,
    this.onExportPdf,
    this.onExportExcel,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    final actions = [
      OutlinedButton.icon(
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh),
        label: const Text("Actualiser"),
      ),
      OutlinedButton.icon(
        onPressed: onExportPdf,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text("PDF"),
      ),
      OutlinedButton.icon(
        onPressed: onExportExcel,
        icon: const Icon(Icons.table_chart),
        label: const Text("Excel"),
      ),
      FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add_task),
        label: const Text("Nouvelle intervention"),
      ),
    ];

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$totalInterventions intervention(s)",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: actions,
          ),
        ],
      );
    }

    return Row(
      children: [
        Text(
          "$totalInterventions intervention(s)",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        ...actions.expand(
              (button) => [
            button,
            const SizedBox(width: 12),
          ],
        ),
      ],
    );
  }
}