import 'package:flutter/material.dart';

class GestationActionButtons extends StatelessWidget {
  final bool saving;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  const GestationActionButtons({
    super.key,
    required this.saving,
    required this.onSave,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: saving
                ? null
                : (onCancel ??
                    () => Navigator.pop(context)),
            child: const Text("Annuler"),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ElevatedButton.icon(
            onPressed: saving ? null : onSave,
            icon: const Icon(Icons.save),
            label: Text(
              saving
                  ? "Enregistrement..."
                  : "Enregistrer",
            ),
          ),
        ),
      ],
    );
  }
}