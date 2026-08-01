import 'package:flutter/material.dart';

import '../../../../core/session/current_user.dart';
import '../../../../core/roles/user_role.dart';

class DrawerHeaderWidget extends StatelessWidget {
  const DrawerHeaderWidget({
    super.key,
  });

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.responsable:
        return 'Responsable';
      case UserRole.agent:
        return 'Agent';
      case UserRole.client:
        return 'Client';
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = CurrentUser.role;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 38,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.pets,
              size: 42,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "SET'SI SA MBAAR",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _roleLabel(role),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 6),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: Colors.greenAccent,
              ),
              SizedBox(width: 6),
              Text(
                "En ligne",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}