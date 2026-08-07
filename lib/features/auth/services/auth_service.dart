import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/session/current_user_service.dart';
import '../../utilisateurs/models/utilisateur_model.dart';
import '../../utilisateurs/repository/firebase_utilisateur_repository.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseUtilisateurRepository _repository =
  FirebaseUtilisateurRepository();

  Future<UtilisateurModel> login({
    required String email,
    required String password,
  }) async {
    final credential =
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;

    final utilisateur =
    await _repository.getCurrentUtilisateur(uid);

    if (utilisateur == null) {
      throw FirebaseAuthException(
        code: 'profil-introuvable',
        message:
        'Le profil utilisateur est introuvable.',
      );
    }

    CurrentUserService.instance
        .setCurrentUser(utilisateur);

    await _repository.updateDerniereConnexion(
      uid,
      DateTime.now(),
    );

    return utilisateur;
  }

  Future<void> logout() async {
    CurrentUserService.instance.clear();

    await _auth.signOut();
  }

  UtilisateurModel? get currentUser =>
      CurrentUserService.instance.currentUser;

  bool get isLogged =>
      CurrentUserService.instance.isLoggedIn;

  bool get isAdmin =>
      CurrentUserService.instance.isAdmin;

  bool get isResponsable =>
      CurrentUserService.instance.isResponsable;

  bool get isTechnicien =>
      CurrentUserService.instance.isTechnicien;

  bool get isClient =>
      CurrentUserService.instance.isClient;
}