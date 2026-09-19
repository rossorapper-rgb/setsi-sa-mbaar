import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/current_user_service.dart';
import '../../utilisateurs/repository/firebase_utilisateur_repository.dart';

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
  bool _photoLoading = false;

  @override
  void dispose() {
    _ancienMotDePasseController.dispose();
    _nouveauMotDePasseController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _choisirPhoto() async {
    final utilisateur = CurrentUserService.instance.currentUser;
    if (utilisateur == null) return;

    setState(() => _photoLoading = true);

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image == null) return;

      final Uint8List bytes = await image.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        throw Exception('La photo doit faire moins de 5 Mo.');
      }

      final extension = image.name.contains('.')
          ? image.name.split('.').last.toLowerCase()
          : 'jpg';
      final safeExtension = ['jpg', 'jpeg', 'png', 'webp'].contains(extension)
          ? extension
          : 'jpg';

      final reference = FirebaseStorage.instance
          .ref()
          .child('users/${utilisateur.id}/profile.$safeExtension');

      final metadata = SettableMetadata(
        contentType: 'image/$safeExtension'.replaceFirst('image/jpg', 'image/jpeg'),
      );

      await reference.putData(bytes, metadata);
      final photoUrl = await reference.getDownloadURL();

      await FirebaseUtilisateurRepository().updatePhotoUrl(
        utilisateur.id,
        photoUrl,
      );

      final updatedUser = utilisateur.copyWith(photoUrl: photoUrl);
      CurrentUserService.instance.setCurrentUser(updatedUser);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Photo de profil mise à jour avec succès.'),
        ),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Impossible de modifier la photo : $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _photoLoading = false);
    }
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

  Widget _buildPhotoSection(Color primary) {
    final utilisateur = CurrentUserService.instance.currentUser;
    final photoUrl = utilisateur?.photoUrl;

    return Column(
      children: [
        const Row(
          children: [
            Icon(Icons.account_circle_rounded, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ma photo de profil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 58,
              backgroundColor: primary.withValues(alpha: 0.12),
              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl == null || photoUrl.isEmpty
                  ? Icon(Icons.person_rounded, size: 62, color: primary)
                  : null,
            ),
            Material(
              color: primary,
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: _photoLoading ? null : _choisirPhoto,
                color: Colors.white,
                icon: _photoLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.camera_alt_rounded),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Cette photo appartient uniquement à votre compte.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _photoLoading ? null : _choisirPhoto,
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Choisir une photo'),
        ),
      ],
    );
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
    final primary = Theme.of(context).colorScheme.primary;

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
                child: _buildPhotoSection(primary),
              ),
            ),
            const SizedBox(height: 20),
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
