import 'package:flutter/material.dart';

import '../../clients/models/client_model.dart';

class InterventionClientSection extends StatelessWidget {
  final List<ClientModel> clients;
  final ClientModel? clientSelectionne;
  final ValueChanged<ClientModel?> onClientChanged;

  const InterventionClientSection({
    super.key,
    required this.clients,
    required this.clientSelectionne,
    required this.onClientChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ControlledDropdown<ClientModel>(
          value: clientSelectionne,
          decoration: const InputDecoration(
            labelText: "Client",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          items: clients
              .map(
                (client) => DropdownMenuItem<ClientModel>(
              value: client,
              child: Text(client.nom),
            ),
          )
              .toList(),
          onChanged: onClientChanged,
          validator: (value) {
            if (value == null) {
              return "Veuillez sélectionner un client";
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        if (clientSelectionne != null)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    clientSelectionne!.nom,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _InfoRow(
                    icon: Icons.phone,
                    label: "Téléphone",
                    value: clientSelectionne!.telephone,
                  ),

                  _InfoRow(
                    icon: Icons.location_on,
                    label: "Quartier",
                    value: clientSelectionne!.quartier,
                  ),

                  _InfoRow(
                    icon: Icons.pets,
                    label: "Nombre de moutons",
                    value: clientSelectionne!
                        .nombreMoutons
                        .toString(),
                  ),

                  _InfoRow(
                    icon: Icons.workspace_premium,
                    label: "Abonnement",
                    value: clientSelectionne!.abonnement,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            "$label : ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class _ControlledDropdown<T> extends StatelessWidget {
  final T? value;
  final bool isExpanded;
  final InputDecoration decoration;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  const _ControlledDropdown({
    required this.value,
    this.isExpanded = false,
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
      decoration: decoration,
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
