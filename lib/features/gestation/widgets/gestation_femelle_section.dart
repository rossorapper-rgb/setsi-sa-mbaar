import 'package:flutter/material.dart';

import '../../moutons/models/mouton_model.dart';
import 'femelle_info_card.dart';

class GestationFemelleSection extends StatelessWidget {
  final List<MoutonModel> brebis;
  final MoutonModel? femelleSelectionnee;
  final ValueChanged<MoutonModel?> onChanged;

  const GestationFemelleSection({
    super.key,
    required this.brebis,
    required this.femelleSelectionnee,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Femelle gestante",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        _ControlledDropdown<MoutonModel>(
          value: femelleSelectionnee,
          decoration: const InputDecoration(
            labelText: "Brebis",
            border: OutlineInputBorder(),
          ),
          hint: const Text("Sélectionner une femelle"),
          items: brebis.map((e) {
            return DropdownMenuItem<MoutonModel>(
              value: e,
              child: Text(
                "${e.nom} • ${e.numeroIdentification}",
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),

        const SizedBox(height: 12),

        FemelleInfoCard(
          femelle: femelleSelectionnee,
        ),
      ],
    );
  }
}

class _ControlledDropdown<T> extends StatelessWidget {
  final T? value;
  final bool isExpanded;
  final Widget? hint;
  final InputDecoration decoration;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  const _ControlledDropdown({
    required this.value,
    this.isExpanded = false,
    this.hint,
    required this.decoration,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: isExpanded,
      hint: hint,
      decoration: decoration,
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
