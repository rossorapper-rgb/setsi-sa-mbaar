import 'package:flutter/material.dart';

class ParametresBergeriePage extends StatelessWidget {
  const ParametresBergeriePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          _SectionCard(
            icon: Icons.home_work_rounded,
            title: 'Informations de la bergerie',
            subtitle: 'Nom, adresse, téléphone et responsable',
          ),
          _SectionCard(
            icon: Icons.palette_rounded,
            title: 'Personnalisation',
            subtitle: 'Logo, couleurs et slogan de votre bergerie',
          ),
          _SectionCard(
            icon: Icons.people_alt_rounded,
            title: 'Utilisateurs',
            subtitle: 'Gérer les utilisateurs de la bergerie',
          ),
          _SectionCard(
            icon: Icons.pets_rounded,
            title: 'Paramètres d’élevage',
            subtitle: 'Règles et paramètres utilisés pour l’élevage',
          ),
          _SectionCard(
            icon: Icons.notifications_active_rounded,
            title: 'Rappels',
            subtitle: 'Gérer les rappels de la bergerie',
          ),
          _SectionCard(
            icon: Icons.lock_rounded,
            title: 'Compte et sécurité',
            subtitle: 'Compte, sécurité et déconnexion',
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
