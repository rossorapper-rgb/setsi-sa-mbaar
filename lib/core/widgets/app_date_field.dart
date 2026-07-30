import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final String? Function(DateTime?)? validator;
  final IconData icon;

  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.validator,
    this.icon = Icons.calendar_today,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: value,
      validator: validator,
      builder: (state) {
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
              border: const OutlineInputBorder(),
              errorText: state.errorText,
            ),
            child: Text(
              value == null
                  ? "Sélectionner une date"
                  : DateFormat("dd/MM/yyyy").format(value!),
              style: TextStyle(
                color: value == null
                    ? Colors.grey.shade600
                    : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}