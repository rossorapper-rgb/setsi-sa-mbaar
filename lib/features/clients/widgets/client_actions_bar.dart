import 'package:flutter/material.dart';

class ClientActionsBar extends StatelessWidget {
  final int totalClients;
  final VoidCallback onAdd;
  final VoidCallback? onRefresh;
  final VoidCallback? onExportPdf;
  final VoidCallback? onExportExcel;

  const ClientActionsBar({
    super.key,
    required this.totalClients,
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
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text("Nouveau client"),
      ),
    ];

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$totalClients client(s)",
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
          "$totalClients client(s)",
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