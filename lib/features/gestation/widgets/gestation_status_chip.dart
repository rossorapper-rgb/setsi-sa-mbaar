import 'package:flutter/material.dart';

class GestationStatusChip extends StatelessWidget {
  final String statut;

  const GestationStatusChip({
    super.key,
    required this.statut,
  });

  Color get _backgroundColor {
    switch (statut) {
      case 'Gestante':
        return Colors.green;
      case 'Mise bas proche':
        return Colors.orange;
      case 'Mise bas effectuée':
        return Colors.blue;
      case 'Interrompue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get _icon {
    switch (statut) {
      case 'Gestante':
        return Icons.favorite;
      case 'Mise bas proche':
        return Icons.schedule;
      case 'Mise bas effectuée':
        return Icons.check_circle;
      case 'Interrompue':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        _icon,
        color: Colors.white,
        size: 18,
      ),
      label: Text(
        statut,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: _backgroundColor,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
    );
  }
}
