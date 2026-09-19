import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_action_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/session/current_user_service.dart';

import '../../bergeries/models/bergerie_model.dart';
import '../../bergeries/repository/firebase_bergerie_repository.dart';

import '../models/user_role.dart';
import '../models/utilisateur_model.dart';
import '../providers/utilisateur_provider.dart';
import '../models/user_permissions.dart';

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

  final FirebaseBergerieRepository _bergerieRepository =
      FirebaseBergerieRepository();

  late Future<List<BergerieModel>> _futureBergeries;

  UserRole _role = UserRole.client;

  String? _bergerieId;

  bool _actif = true;
  bool _loading = false;

  final Map<String, bool> _permissions = createDefaultPermissions();

  final CurrentUserService _session = CurrentUserService.instance;

  bool get _modeCreation => widget.utilisateur == null;

  bool get _responsableModifieSonPropreCompte =>
      !_modeCreation &&
      _session.isResponsable &&
      widget.utilisateur!.id == _session.uid;

  @override
  void initState() {
    super.initState();

    _futureBergeries = _chargerBergeries();

    if (!_session.isAdmin) {
      _bergerieId = _session.bergerieId;
    }

    if (widget.utilisateur != null) {
      final u = widget.utilisateur!;

      _nomController.text = u.nom;
      _prenomController.text = u.prenom;
      _telephoneController.text = u.telephone;

      _role = u.role;
      _bergerieId = u.bergerieId;
      _actif = u.actif;
      _permissions
        ..clear()
        ..addAll(normalizePermissions(u.permissions));
    }
  }

  Future<List<BergerieModel>> _chargerBergeries() async {
    if (!_session.isAdmin) return [];

    final bergeries = await _bergerieRepository.getAllBergeries();

    bergeries.removeWhere(
      (bergerie) => !bergerie.active,
    );

    bergeries.sort(
      (a, b) => a.nom
          .toLowerCase()
          .compareTo(b.nom.toLowerCase()),
    );

    return bergeries;
  }

  bool get _bergerieObligatoire => _role != UserRole.admin;

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
          _modeCreation
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

                  if (_modeCreation) ...[
                    const SizedBox(height: 18),

                    AppTextField(
                      controller: _motDePasseController,
                      label: "Mot de passe initial",
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),
                  ],

                  const SizedBox(height: 18),

                  AppDropdown<UserRole>(
                    label: "Rôle",
                    icon: Icons.badge,
                    value: _role,
                    items: (_session.isAdmin
                            ? UserRole.values
                            : UserRole.values.where((role) => role != UserRole.admin))
                        .map(
                          (role) => DropdownMenuItem<UserRole>(
                            value: role,
                            child: Text(role.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _role = value;

                        if (_role == UserRole.admin) {
                          _bergerieId = null;
                        }
                      });
                    },
                  ),

                  if (_bergerieObligatoire && _session.isAdmin) ...[
                    const SizedBox(height: 18),

                    FutureBuilder<List<BergerieModel>>(
                      future: _futureBergeries,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
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
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.shade200,
                              ),
                            ),
                            child: Text(
                              "Impossible de charger les bergeries : ${snapshot.error}",
                              style: TextStyle(
                                color: Colors.red.shade800,
                              ),
                            ),
                          );
                        }

                        final bergeries = snapshot.data ?? [];

                        if (bergeries.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.shade200,
                              ),
                            ),
                            child: const Text(
                              "Aucune bergerie active n'est disponible. Créez d'abord la bergerie du client.",
                            ),
                          );
                        }

                        final selectedStillExists = bergeries.any(
                          (bergerie) => bergerie.id == _bergerieId,
                        );

                        return DropdownButtonFormField<String>(
                          value: selectedStillExists ? _bergerieId : null,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: "Bergerie associée",
                            prefixIcon: const Icon(
                              Icons.home_work_outlined,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: bergeries.map((bergerie) {
                            return DropdownMenuItem<String>(
                              value: bergerie.id,
                              child: Text(
                                bergerie.nom,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _bergerieId = value;
                            });
                          },
                          validator: (value) {
                            if (_bergerieObligatoire &&
                                (value == null || value.isEmpty)) {
                              return "Veuillez associer une bergerie à ce compte.";
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
                    title: const Text("Utilisateur actif"),
                    onChanged: (value) {
                      setState(() {
                        _actif = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  if (_responsableModifieSonPropreCompte) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lock_outline, color: Colors.orange),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Vos permissions d'accès ne peuvent pas être modifiées depuis votre propre compte. Un administrateur peut les modifier si nécessaire.",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    _PermissionsSection(
                      permissions: _permissions,
                      onChanged: (key, value) {
                        setState(() {
                          _permissions[key] = value;
                        });
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            AppActionButton(
              label: _modeCreation
                  ? "Créer le compte"
                  : "Mettre à jour",
              icon: Icons.save,
              isLoading: _loading,
              onPressed: _loading ? null : _enregistrer,
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

    if (_modeCreation && _motDePasseController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            "Le mot de passe initial doit contenir au moins 6 caractères.",
          ),
        ),
      );

      return;
    }

    if (_bergerieObligatoire &&
        (_bergerieId == null || _bergerieId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            "Veuillez associer une bergerie à ce compte.",
          ),
        ),
      );

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final repository = ref.read(utilisateurRepositoryProvider);

      final telephone = _telephoneController.text.trim();
      final emailTechnique = repository.genererEmailTechnique(telephone);

      if (_modeCreation) {
        final utilisateur = UtilisateurModel(
          id: '',
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          telephone: telephone,
          emailTechnique: emailTechnique,
          role: _session.isAdmin ? _role : (_role == UserRole.admin ? UserRole.client : _role),
          bergerieId: _session.isAdmin ? (_bergerieObligatoire ? _bergerieId : null) : _session.bergerieId,
          actif: _actif,
          dateCreation: DateTime.now(),
          derniereConnexion: null,
          creePar: "Administrateur",
          photoUrl: null,
          permissions: _responsableModifieSonPropreCompte
              ? Map<String, bool>.from(ancienUtilisateur.permissions)
              : Map<String, bool>.from(_permissions),
        );

        await repository.createUtilisateurAvecCompte(
          utilisateur,
          _motDePasseController.text.trim(),
        );
      } else {
        final ancienUtilisateur = widget.utilisateur!;

        final utilisateur = ancienUtilisateur.copyWith(
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          telephone: telephone,
          emailTechnique: emailTechnique,
          role: _session.isAdmin ? _role : (_role == UserRole.admin ? UserRole.client : _role),
          bergerieId: _session.isAdmin ? (_bergerieObligatoire ? _bergerieId : null) : _session.bergerieId,
          actif: _actif,
          permissions: Map<String, bool>.from(_permissions),
        );

        await repository.updateUtilisateur(utilisateur);
      }

      // Invalide le cache du profil modifié afin que la fiche
      // Détails utilisateur affiche immédiatement les nouvelles données.
      if (!_modeCreation) {
        ref.invalidate(
          utilisateurProvider(widget.utilisateur!.id),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            _modeCreation
                ? "Compte utilisateur créé avec succès."
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
          content: Text("Erreur : $e"),
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


class _PermissionsSection extends StatelessWidget {
  const _PermissionsSection({
    required this.permissions,
    required this.onChanged,
  });

  final Map<String, bool> permissions;
  final void Function(String key, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.blue),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Permissions d'accès",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Choisissez ce que cet utilisateur peut consulter et modifier.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          ...permissionGroups.map(
            (group) => _PermissionGroup(
              group: group,
              permissions: permissions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionGroup extends StatelessWidget {
  const _PermissionGroup({
    required this.group,
    required this.permissions,
    required this.onChanged,
  });

  final PermissionGroup group;
  final Map<String, bool> permissions;
  final void Function(String key, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final hasEdit = group.editKey != null;
    final viewKey = group.viewKey;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SwitchListTile(
            dense: true,
            title: Text(
              group.label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text("Voir"),
            value: permissions[viewKey] ?? false,
            onChanged: (value) => onChanged(viewKey, value),
          ),
          if (hasEdit)
            SwitchListTile(
              dense: true,
              title: const Text("Ajouter / modifier"),
              value: permissions[group.editKey!] ?? false,
              onChanged: (value) {
                onChanged(group.editKey!, value);
                if (value && !(permissions[viewKey] ?? false)) {
                  onChanged(viewKey, true);
                }
              },
            ),
        ],
      ),
    );
  }
}
