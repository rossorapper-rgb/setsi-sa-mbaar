import 'package:flutter/material.dart';

class ClientSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final VoidCallback? onFilterPressed;

  const ClientSearchBar({
    super.key,
    this.hintText = "Rechercher...",
    this.onChanged,
    this.controller,
    this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,

          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.primary,
          ),

          suffixIcon: IconButton(
            tooltip: "Filtres",
            onPressed: onFilterPressed,
            icon: const Icon(Icons.tune_rounded),
          ),

          filled: true,
          fillColor: Colors.white,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2,
            ),
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}