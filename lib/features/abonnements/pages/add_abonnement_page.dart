import 'package:flutter/material.dart';

class AddAbonnementPage extends StatefulWidget {
  const AddAbonnementPage({super.key});

  @override
  State<AddAbonnementPage> createState() => _AddAbonnementPageState();
}

class _AddAbonnementPageState extends State<AddAbonnementPage> {
  final _formKey = GlobalKey<FormState>();

  final _clientController = TextEditingController();
  final _bergerieController = TextEditingController();
  final _montantController = TextEditingController();

  String _pack = 'Essentiel';

  @override
  void dispose() {
    _clientController.dispose();
    _bergerieController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  void _enregistrer() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Abonnement enregistré (version de démonstration)."),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouvel abonnement"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _clientController,
                decoration: const InputDecoration(
                  labelText: "Client",
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Champ obligatoire" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bergerieController,
                decoration: const InputDecoration(
                  labelText: "Bergerie",
                  prefixIcon: Icon(Icons.home_work),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Champ obligatoire" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _pack,
                decoration: const InputDecoration(
                  labelText: "Pack",
                  prefixIcon: Icon(Icons.workspace_premium),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Essentiel",
                    child: Text("Essentiel"),
                  ),
                  DropdownMenuItem(
                    value: "Confort",
                    child: Text("Confort"),
                  ),
                  DropdownMenuItem(
                    value: "Prestige",
                    child: Text("Prestige"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _pack = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Montant (FCFA)",
                  prefixIcon: Icon(Icons.payments),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Champ obligatoire" : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _enregistrer,
                  icon: const Icon(Icons.save),
                  label: const Text("Enregistrer"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
