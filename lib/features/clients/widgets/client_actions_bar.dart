import 'package:flutter/material.dart';

class ClientActionsBar extends StatelessWidget {
  final int totalClients;
  final VoidCallback onAdd;
  final VoidCallback? onRefresh;
  final bool isRefreshing;

  const ClientActionsBar({
    super.key,
    required this.totalClients,
    required this.onAdd,
    required this.isRefreshing,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    final actions = [
      OutlinedButton.icon(
        onPressed: isRefreshing ? null : onRefresh,
        icon: isRefreshing
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        )
            : const Icon(Icons.refresh),
        label: Text(
          isRefreshing
              ? "Actualisation..."
              : "Actualiser",
        ),
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