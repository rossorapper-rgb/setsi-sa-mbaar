import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/current_bergerie_config.dart';
import '../../../../core/session/current_user_service.dart';

class DrawerFooter extends StatelessWidget {
  const DrawerFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(
              'Déconnexion',
            ),
            onTap: () async {
              CurrentUserService.instance.clear();
              CurrentBergerieConfig.instance.clear();
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;
              context.replace('/login');
            },
          ),

          const Padding(
            padding: EdgeInsets.only(
              bottom: 16,
              top: 8,
            ),
            child: Text(
              "SET'SI SA MBAAR v2.0",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}