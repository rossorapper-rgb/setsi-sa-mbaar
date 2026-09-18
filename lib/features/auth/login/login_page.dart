import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/current_bergerie_config.dart';
import '../../../core/session/current_user_service.dart';
import '../../utilisateurs/models/user_role.dart';
import '../../utilisateurs/repository/firebase_utilisateur_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    telephoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (telephoneController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez saisir votre numéro de téléphone et votre mot de passe.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final telephone = telephoneController.text.trim();
      final emailTechnique = FirebaseUtilisateurRepository()
          .genererEmailTechnique(telephone);

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTechnique,
        password: passwordController.text.trim(),
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) throw Exception("Impossible de récupérer l'utilisateur connecté.");

      final utilisateur = await FirebaseUtilisateurRepository().getCurrentUtilisateur(firebaseUser.uid);
      if (utilisateur == null) {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Votre profil utilisateur SET'SI est introuvable.")));
        return;
      }

      if (!utilisateur.actif) {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Votre compte SET'SI est désactivé.")));
        return;
      }

      CurrentUserService.instance.setCurrentUser(utilisateur);

      await CurrentBergerieConfig.instance.load(utilisateur.bergerieId);

      if (!mounted) return;

      final role = CurrentUserService.instance.role;
      if (role == UserRole.admin) {
        context.replace('/dashboard/admin');
      } else {
        context.replace('/dashboard/bergerie');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found': message = 'Utilisateur introuvable.'; break;
        case 'wrong-password': message = 'Mot de passe incorrect.'; break;
        case 'invalid-email': message = 'Numéro de téléphone invalide.'; break;
        case 'invalid-credential': message = 'Numéro de téléphone ou mot de passe incorrect.'; break;
        case 'user-disabled': message = 'Ce compte utilisateur est désactivé.'; break;
        default: message = e.message ?? 'Erreur de connexion.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/app_icon.png', height: 180),
                const SizedBox(height: 20),
                const Text("SET'SI SA MBAAR", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0B6E4F))),
                const SizedBox(height: 8),
                const Text('Le premier service professionnel\nde lavage de moutons au Sénégal', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 15)),
                const SizedBox(height: 35),
                TextField(controller: telephoneController, keyboardType: TextInputType.phone, textInputAction: TextInputAction.next, onSubmitted: (_) => FocusScope.of(context).nextFocus(), decoration: InputDecoration(labelText: 'Numéro de téléphone', hintText: '77 123 45 67', prefixIcon: const Icon(Icons.phone_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) { if (!_isLoading) _login(); },
                  decoration: InputDecoration(labelText: 'Mot de passe', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                ),
                const SizedBox(height: 30),
                SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: _isLoading ? null : _login, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B6E4F), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : const Text('SE CONNECTER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
                const SizedBox(height: 15),
                TextButton(onPressed: () {}, child: const Text('Mot de passe oublié ?')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
