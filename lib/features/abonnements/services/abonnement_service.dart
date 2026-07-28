import '../models/abonnement_model.dart';

class AbonnementService {
  static int _compteur = 3;

  static AbonnementModel creerAbonnement({
    required String clientId,
    required String clientNom,
    required String bergerieId,
    required String bergerieNom,
    required String pack,
    required double montant,
    required DateTime dateDebut,
    required int dureeEnMois,
    String observations = '',
  }) {
    final numero = 'ABN-${_compteur.toString().padLeft(4, '0')}';
    _compteur++;

    final dateFin = DateTime(
      dateDebut.year,
      dateDebut.month + dureeEnMois,
      dateDebut.day,
    );

    return AbonnementModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      numero: numero,
      clientId: clientId,
      clientNom: clientNom,
      bergerieId: bergerieId,
      bergerieNom: bergerieNom,
      pack: pack,
      montant: montant,
      dateDebut: dateDebut,
      dateFin: dateFin,
      montantPaye: 0,
      resteAPayer: montant,
      statut: 'Actif',
      observations: observations,
      dateCreation: DateTime.now(),
    );
  }

  static double calculReste({
    required double montant,
    required double montantPaye,
  }) {
    final reste = montant - montantPaye;
    return reste < 0 ? 0 : reste;
  }

  static String determinerStatut({
    required DateTime dateFin,
    required double resteAPayer,
  }) {
    if (DateTime.now().isAfter(dateFin)) {
      return 'Expiré';
    }

    if (resteAPayer > 0) {
      return 'En attente';
    }

    return 'Actif';
  }
}
