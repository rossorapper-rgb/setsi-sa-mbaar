import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/current_user_service.dart';

class SecuriteComptePage extends StatefulWidget {
  const SecuriteComptePage({super.key});

  @override
  State<SecuriteComptePage> createState() => _SecuriteComptePageState();
}

class _SecuriteComptePageState extends State<SecuriteComptePage> {
  final _formKey = GlobalKey<FormState>();
  final _ancienMotDePasseController = TextEditingController();
  final _nouveauMotDePasseController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _obscureAncien = true;
  bool _obscureNouveau = true;
  bool _obscureConfirmation = true;
  bool _loading = false;

  @override
  void dispose() {
    _ancienMotDePasseController.dispose();
    _nouveauMotDePasseController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _changerMotDePasse() async {
    if (!_formKey.currentState!.validate()) return;

    final utilisateur = CurrentUserService.instance.currentUser;
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (utilisateur == null || firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Votre session a expiré. Veuillez vous reconnecter.'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: utilisateur.emailTechnique,
        password: _ancienMotDePasseController.text.trim(),
      );

      await firebaseUser.reauthenticateWithCredential(credential);
      await firebaseUser.updatePassword(
        _nouveauMotDePasseController.text.trim(),
      );

      if (!mounted) return;

      _ancienMotDePasseController.clear();
      _nouveauMotDePasseController.clear();
      _confirmationController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Mot de passe modifié avec succès.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Votre ancien mot de passe est incorrect.';
          break;
        case 'weak-password':
          message = 'Le nouveau mot de passe doit contenir au moins 6 caractères.';
          break;
        case 'requires-recent-login':
          message = 'Veuillez vous reconnecter avant de modifier votre mot de passe.';
          break;
        default:
          message = e.message ?? 'Impossible de modifier le mot de passe.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Erreur : $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _decoration(
    String label,
    IconData icon,
    bool obscure,
    VoidCallback onToggle,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
        onPressed: onToggle,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF123B63);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text('Compte et sécurité'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/parametres'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lock_rounded, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Changer mon mot de passe',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Utilisez votre mot de passe actuel pour définir un nouveau mot de passe.',
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _ancienMotDePasseController,
                      obscureText: _obscureAncien,
                      decoration: _decoration(
                        'Mot de passe actuel',
                        Icons.lock_outline,
                        _obscureAncien,
                        () => setState(() => _obscureAncien = !_obscureAncien),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez saisir votre mot de passe actuel.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _nouveauMotDePasseController,
                      obscureText: _obscureNouveau,
                      decoration: _decoration(
                        'Nouveau mot de passe',
                        Icons.lock_reset_rounded,
                        _obscureNouveau,
                        () => setState(() => _obscureNouveau = !_obscureNouveau),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Minimum 6 caractères.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _confirmationController,
                      obscureText: _obscureConfirmation,
                      decoration: _decoration(
                        'Confirmer le nouveau mot de passe',
                        Icons.verified_user_outlined,
                        _obscureConfirmation,
                        () => setState(
                          () => _obscureConfirmation = !_obscureConfirmation,
                        ),
                      ),
                      validator: (value) {
                        if (value != _nouveauMotDePasseController.text) {
                          return 'Les mots de passe ne correspondent pas.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _changerMotDePasse,
                        icon: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(
                          _loading ? 'Modification...' : 'Changer le mot de passe',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
