import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/widgets/app_action_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_text_field.dart';

import '../../bergeries/models/bergerie_model.dart';
import '../../bergeries/repository/firebase_bergerie_repository.dart';

import '../models/user_role.dart';
import '../models/utilisateur_model.dart';
import '../providers/utilisateur_provider.dart';

class AddUtilisateurPage extends ConsumerStatefulWidget {
  final UtilisateurModel? utilisateur;

  const AddUtilisateurPage({
    super.key,
    this.utilisateur,
  });

  @override
  ConsumerState<AddUtilisateurPage> createState() =>
      _AddUtilisateurPageState();
}

class _AddUtilisateurPageState
    extends ConsumerState<AddUtilisateurPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _motDePasseController = TextEditingController();

  final Uuid _uuid = const Uuid();

  final FirebaseBergerieRepository _bergerieRepository =
  FirebaseBergerieRepository();

  late Future<List<BergerieModel>> _futureBergeries;

  UserRole _role = UserRole.client;

  String? _bergerieId;

  bool _actif = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _futureBergeries = _chargerBergeries();

    if (widget.utilisateur != null) {
      final u = widget.utilisateur!;

      _nomController.text = u.nom;
      _prenomController.text = u.prenom;
      _telephoneController.text = u.telephone;

      _role = u.role;
      _bergerieId = u.bergerieId;
      _actif = u.actif;
    }
  }

  Future<List<BergerieModel>> _chargerBergeries() async {
    final bergeries =
    await _bergerieRepository.getAllBergeries();

    bergeries.removeWhere(
          (bergerie) => !bergerie.active,
    );

    bergeries.sort(
          (a, b) => a.nom
          .toLowerCase()
          .compareTo(
        b.nom.toLowerCase(),
      ),
    );

    return bergeries;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _motDePasseController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.utilisateur == null
              ? "Nouvel utilisateur"
              : "Modifier utilisateur",
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Column(
                children: [
                  AppTextField(
                    controller: _prenomController,
                    label: "Prénom",
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 18),

                  AppTextField(
                    controller: _nomController,
                    label: "Nom",
                    icon: Icons.person,
                  ),

                  const SizedBox(height: 18),

                  AppTextField(
                    controller: _telephoneController,
                    label: "Téléphone",
                    icon: Icons.phone,
                  ),

                  const SizedBox(height: 18),

                  AppTextField(
                    controller: _motDePasseController,
                    label: "Mot de passe initial",
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),

                  const SizedBox(height: 18),

                  AppDropdown<UserRole>(
                    label: "Rôle",
                    icon: Icons.badge,
                    value: _role,
                    items: UserRole.values
                        .map(
                          (role) =>
                          DropdownMenuItem<UserRole>(
                            value: role,
                            child: Text(role.label),
                          ),
                    )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _role = value;

                        if (_role != UserRole.client) {
                          _bergerieId = null;
                        }
                      });
                    },
                  ),

                  if (_role == UserRole.client) ...[
                    const SizedBox(height: 18),

                    FutureBuilder<List<BergerieModel>>(
                      future: _futureBergeries,
                      builder:
                          (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding:
                            EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                  CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Chargement des bergeries...",
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Container(
                            width: double.infinity,
                            padding:
                            const EdgeInsets.all(14),
                            decoration:
                            BoxDecoration(
                              color:
                              Colors.red.shade50,
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                              border: Border.all(
                                color:
                                Colors.red.shade200,
                              ),
                            ),
                            child: Text(
                              "Impossible de charger les "
                                  "bergeries : ${snapshot.error}",
                              style: TextStyle(
                                color:
                                Colors.red.shade800,
                              ),
                            ),
                          );
                        }

                        final bergeries =
                            snapshot.data ?? [];

                        if (bergeries.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding:
                            const EdgeInsets.all(14),
                            decoration:
                            BoxDecoration(
                              color:
                              Colors.orange.shade50,
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                              border: Border.all(
                                color: Colors
                                    .orange.shade200,
                              ),
                            ),
                            child: const Text(
                              "Aucune bergerie active n'est "
                                  "disponible. Créez d'abord "
                                  "la bergerie du client.",
                            ),
                          );
                        }

                        final selectedStillExists =
                        bergeries.any(
                              (bergerie) =>
                          bergerie.id ==
                              _bergerieId,
                        );

                        return DropdownButtonFormField<
                            String>(
                          value: selectedStillExists
                              ? _bergerieId
                              : null,
                          isExpanded: true,
                          decoration:
                          InputDecoration(
                            labelText:
                            "Bergerie associée",
                            prefixIcon:
                            const Icon(
                              Icons
                                  .home_work_outlined,
                            ),
                            border:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          items: bergeries.map(
                                (bergerie) {
                              return DropdownMenuItem<
                                  String>(
                                value: bergerie.id,
                                child: Text(
                                  bergerie.nom,
                                  overflow:
                                  TextOverflow
                                      .ellipsis,
                                ),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            setState(() {
                              _bergerieId = value;
                            });
                          },
                          validator: (value) {
                            if (_role ==
                                UserRole.client &&
                                (value == null ||
                                    value.isEmpty)) {
                              return "Veuillez associer une "
                                  "bergerie à ce compte client.";
                            }

                            return null;
                          },
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 20),

                  SwitchListTile(
                    value: _actif,
                    title:
                    const Text("Utilisateur actif"),
                    onChanged: (value) {
                      setState(() {
                        _actif = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            AppActionButton(
              label: widget.utilisateur == null
                  ? "Enregistrer"
                  : "Mettre à jour",
              icon: Icons.save,
              isLoading: _loading,
              onPressed:
              _loading ? null : _enregistrer,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_role == UserRole.client &&
        (_bergerieId == null ||
            _bergerieId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            "Veuillez associer une bergerie "
                "à ce compte client.",
          ),
        ),
      );

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final repository =
      ref.read(utilisateurRepositoryProvider);

      final emailTechnique =
      repository.genererEmailTechnique(
        _telephoneController.text.trim(),
      );

      final utilisateur = UtilisateurModel(
        id: widget.utilisateur?.id ??
            _uuid.v4(),

        nom: _nomController.text.trim(),

        prenom:
        _prenomController.text.trim(),

        telephone:
        _telephoneController.text.trim(),

        emailTechnique:
        emailTechnique,

        role: _role,

        bergerieId:
        _role == UserRole.client
            ? _bergerieId
            : null,

        actif: _actif,

        dateCreation:
        widget.utilisateur?.dateCreation ??
            DateTime.now(),

        derniereConnexion:
        widget.utilisateur
            ?.derniereConnexion,

        creePar: "Administrateur",

        photoUrl:
        widget.utilisateur?.photoUrl,

        permissions:
        widget.utilisateur
            ?.permissions ??
            {},
      );

      if (widget.utilisateur == null) {
        await repository.addUtilisateur(
          utilisateur,
        );
      } else {
        await repository.updateUtilisateur(
          utilisateur,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            widget.utilisateur == null
                ? "Utilisateur ajouté avec succès."
                : "Utilisateur mis à jour avec succès.",
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Erreur : $e",
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }
}