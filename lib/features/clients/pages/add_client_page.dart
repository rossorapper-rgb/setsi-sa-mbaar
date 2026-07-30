import 'package:flutter/material.dart';

class AddClientPage extends StatefulWidget {
  const AddClientPage({super.key});

  @override
  State<AddClientPage> createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _quartierController = TextEditingController();
  final _adresseController = TextEditingController();
  final _troupeauxController = TextEditingController();
  final _moutonsController = TextEditingController();

  String _abonnement = "Essentiel";
  bool _actif = true;

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    _quartierController.dispose();
    _adresseController.dispose();
    _troupeauxController.dispose();
    _moutonsController.dispose();
    super.dispose();
  }

  void _enregistrer() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Client enregistré (fonction en préparation)"),
        ),
      );
    }
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouveau client"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              "Informations générales",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            TextFormField(
              controller: _nomController,
              decoration: _decoration(
                "Nom complet",
                Icons.person,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Veuillez saisir le nom";
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _telephoneController,
              keyboardType: TextInputType.phone,
              decoration: _decoration(
                "Téléphone",
                Icons.phone,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Veuillez saisir le téléphone";
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _quartierController,
              decoration: _decoration(
                "Quartier",
                Icons.location_on,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Veuillez saisir le quartier";
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _adresseController,
              maxLines: 2,
              decoration: _decoration(
                "Adresse",
                Icons.home,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _troupeauxController,
                    keyboardType: TextInputType.number,
                    decoration: _decoration(
                      "Troupeaux",
                      Icons.home_work,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _moutonsController,
                    keyboardType: TextInputType.number,
                    decoration: _decoration(
                      "Moutons",
                      Icons.pets,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _abonnement,
              decoration: _decoration(
                "Abonnement",
                Icons.workspace_premium,
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
                  _abonnement = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            SwitchListTile(
              value: _actif,
              title: const Text("Client actif"),
              secondary: const Icon(Icons.verified_user),
              onChanged: (value) {
                setState(() {
                  _actif = value;
                });
              },
            ),

            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: _enregistrer,
              icon: const Icon(Icons.save),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  "Enregistrer",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text("Annuler"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}