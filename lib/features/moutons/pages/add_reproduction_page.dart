import 'package:flutter/material.dart';

import '../models/mouton_model.dart';
import '../widgets/reproduction_form.dart';

class AddReproductionPage extends StatelessWidget {
  final MoutonModel mouton;

  const AddReproductionPage({
    super.key,
    required this.mouton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nouvelle reproduction",
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ReproductionForm(
          mouton: mouton,
        ),
      ),
    );
  }
}