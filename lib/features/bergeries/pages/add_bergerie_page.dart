import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/widgets/app_back_bar.dart';
import '../../../core/config/bergerie_config.dart';
import '../../../core/config/public_bergerie_config.dart';

import '../../clients/models/client_model.dart';
import '../../clients/repositories/firebase_client_repository.dart';
import '../../utilisateurs/models/user_permissions.dart';
import '../../utilisateurs/models/user_role.dart';
import '../../utilisateurs/models/utilisateur_model.dart';
import '../../utilisateurs/repository/firebase_utilisateur_repository.dart';

import '../models/bergerie_model.dart';
import '../repository/firebase_bergerie_repository.dart';

class AddBergeriePage extends StatefulWidget {
  final bool isEdition;
  final BergerieModel? bergerie;
  final ClientModel? clientPreselectionne;

  const AddBergeriePage({
    super.key,
    this.isEdition = false,
    this.bergerie,
    this.clientPreselectionne,
  });

  @override
  State<AddBergeriePage> createState() =>
      _AddBergeriePageState();
}

class _AddBergeriePageState
    extends State<AddBergeriePage> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _adresseController = TextEditingController();
  final _telephoneController =
  TextEditingController();
  final _responsableController =
  TextEditingController();
  final _responsableTelephoneController = TextEditingController();
  final _responsableMotDePasseController = TextEditingController();
  final _observationsController =
  TextEditingController();

  final FirebaseBergerieRepository _repository =
  FirebaseBergerieRepository();

  final FirebaseClientRepository _clientRepository =
  FirebaseClientRepository();

  final FirebaseUtilisateurRepository _utilisateurRepository =
      FirebaseUtilisateurRepository();

  final Uuid _uuid = const Uuid();

  List<ClientModel> _clients = [];

  ClientModel? _clientSelectionne;

  bool _isSaving = false;
  bool _isLoadingClients = true;
  bool _connexionTelephoneModifieManuellement = false;
  @override
  void initState() {
    super.initState();

    if (widget.isEdition && widget.bergerie != null) {
      _nomController.text = widget.bergerie!.nom;
      _adresseController.text = widget.bergerie!.adresse;
      _telephoneController.text = widget.bergerie!.telephone;
      _responsableController.text =
          widget.bergerie!.responsable;
      _observationsController.text =
          widget.bergerie!.observations;
    }

    _chargerClients();
  }

  Future<void> _chargerClients() async {
    try {
      final clients = await _clientRepository.getClients();

      if (!mounted) return;

      ClientModel? clientSelectionne =
          widget.clientPreselectionne;

      if (clientSelectionne == null &&
          widget.isEdition &&
          widget.bergerie != null &&
          widget.bergerie!.clientId.isNotEmpty) {
        try {
          clientSelectionne = clients.firstWhere(
                (c) => c.id == widget.bergerie!.clientId,
          );
        } catch (_) {
          clientSelectionne = null;
        }
      }

      setState(() {
        _clients = clients;
        _clientSelectionne = clientSelectionne;
        _isLoadingClients = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingClients = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible de charger les clients.\n$e",
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _responsableController.dispose();
    _responsableTelephoneController.dispose();
    _responsableMotDePasseController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _saveBergerie() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_clientSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez sélectionner un client.",
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final bergerie = BergerieModel(
        id: widget.isEdition
            ? widget.bergerie!.id
            : _uuid.v4(),

        clientId: _clientSelectionne!.id,
        slug: widget.isEdition
            ? widget.bergerie!.slugEffectif
            : BergerieModel.slugifier(_nomController.text),

        nom: _nomController.text.trim(),
        adresse: _adresseController.text.trim(),
        telephone: _telephoneController.text.trim(),
        responsable:
        _responsableController.text.trim(),
        observations:
        _observationsController.text.trim(),

        latitude: widget.isEdition
            ? widget.bergerie!.latitude
            : null,

        longitude: widget.isEdition
            ? widget.bergerie!.longitude
            : null,

        active: widget.isEdition
            ? widget.bergerie!.active
            : true,

        dateCreation: widget.isEdition
            ? widget.bergerie!.dateCreation
            : DateTime.now(),

        dateModification: DateTime.now(),
      );

      if (widget.isEdition) {
        await _repository.updateBergerie(bergerie);

        // La configuration publique doit toujours rester synchronisée
        // avec les informations essentielles de la bergerie.
        // On conserve les personnalisations existantes (logo, couleurs,
        // image d'accueil, slogan...) et on met seulement à jour
        // l'identité de la bergerie et son statut.
        final publicConfig =
            await PublicBergerieConfigService.instance.load(bergerie.id);

        final updatedPublicConfig = BergerieConfig(
          bergerieId: bergerie.id,
          nomBergerie: bergerie.nom,
          nomApplication: publicConfig.nomApplication.trim().isEmpty
              ? bergerie.nom
              : publicConfig.nomApplication,
          logo: publicConfig.logo,
          imageAccueil: publicConfig.imageAccueil,
          couleurPrimaire: publicConfig.couleurPrimaire,
          couleurSecondaire: publicConfig.couleurSecondaire,
          couleurFond: publicConfig.couleurFond,
          slogan: publicConfig.slogan,
          active: bergerie.active,
        );

        await PublicBergerieConfigService.instance.save(updatedPublicConfig);
      } else {
        await _repository.addBergerie(bergerie);

        // Crée immédiatement une identité publique minimale pour que
        // l'URL /bergerie/<slug> soit disponible dès la création.
        final branding = BergerieConfig(
          bergerieId: bergerie.id,
          nomBergerie: bergerie.nom,
          nomApplication: bergerie.nom,
          couleurPrimaire: const Color(0xFF1597B7),
          couleurSecondaire: const Color(0xFFF59A00),
          couleurFond: Colors.white,
          slogan: 'Une meilleure gestion pour une meilleure bergerie',
          active: bergerie.active,
        );

        await PublicBergerieConfigService.instance.save(branding);

        // Une nouvelle bergerie doit disposer immédiatement de son
        // compte Responsable principal. Les autres sous-comptes
        // seront ensuite créés depuis les paramètres de la bergerie.
        final responsableNomComplet =
            _responsableController.text.trim();

        final morceauxNom = responsableNomComplet
            .split(RegExp(r'\s+'))
            .where((element) => element.isNotEmpty)
            .toList();

        final prenom = morceauxNom.isNotEmpty
            ? morceauxNom.first
            : '';
        final nom = morceauxNom.length > 1
            ? morceauxNom.sublist(1).join(' ')
            : '';

        final responsableTelephone =
            _responsableTelephoneController.text.trim();

        final responsableUtilisateur = UtilisateurModel(
          id: '',
          nom: nom,
          prenom: prenom,
          telephone: responsableTelephone,
          emailTechnique:
              _utilisateurRepository.genererEmailTechnique(
            responsableTelephone,
          ),
          role: UserRole.responsable,
          bergerieId: bergerie.id,
          actif: true,
          dateCreation: DateTime.now(),
          derniereConnexion: null,
          creePar: 'Administrateur',
          photoUrl: null,
          permissions: createDefaultPermissions(),
        );

        await _utilisateurRepository.createUtilisateurAvecCompte(
          responsableUtilisateur,
          _responsableMotDePasseController.text.trim(),
        );
      }

      if (!mounted) return;

      // Retourne la bergerie créée/modifiée pour permettre à la liste
      // de se mettre à jour immédiatement, sans rechargement.
      Navigator.pop(context, bergerie);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Erreur : $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBackBar(
        title: widget.isEdition
            ? "Modifier la bergerie"
            : "Nouvelle bergerie",
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                "Informations générales",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              if (widget.clientPreselectionne != null)
                const InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Client",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    "Client connecté",
                  ),
                )
              else if (_isLoadingClients)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 20,
                    ),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                DropdownButtonFormField<ClientModel>(
                  initialValue: _clientSelectionne,
                  decoration:
                  const InputDecoration(
                    labelText: "Client *",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  items: _clients.map((client) {
                    return DropdownMenuItem<ClientModel>(
                      value: client,
                      child: Text(client.nom),
                    );
                  }).toList(),
                  onChanged: (client) {
                    setState(() {
                      _clientSelectionne = client;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Veuillez sélectionner un client";
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _nomController,
                decoration:
                const InputDecoration(
                  labelText:
                  "Nom de la bergerie",
                  prefixIcon:
                  Icon(Icons.home_work),
                  border:
                  OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return "Veuillez saisir le nom";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _adresseController,
                decoration:
                const InputDecoration(
                  labelText: "Adresse",
                  prefixIcon:
                  Icon(Icons.location_on),
                  border:
                  OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _telephoneController,
                keyboardType:
                TextInputType.phone,
                onChanged: (value) {
                  if (!widget.isEdition &&
                      !_connexionTelephoneModifieManuellement) {
                    _responsableTelephoneController.value =
                        _responsableTelephoneController.value.copyWith(
                      text: value,
                      selection: TextSelection.collapsed(
                        offset: value.length,
                      ),
                    );
                  }
                },
                decoration:
                const InputDecoration(
                  labelText: "Téléphone",
                  prefixIcon:
                  Icon(Icons.phone),
                  border:
                  OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return "Veuillez saisir le téléphone";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                _responsableController,
                decoration:
                const InputDecoration(
                  labelText: "Responsable principal *",
                  prefixIcon:
                  Icon(Icons.badge),
                  border:
                  OutlineInputBorder(),
                  helperText:
                      "Ce responsable sera le premier compte de connexion de la bergerie.",
                ),
                validator: widget.isEdition
                    ? null
                    : (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Veuillez saisir le responsable principal";
                        }
                        return null;
                      },
              ),

              if (!widget.isEdition) ...[
                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      _responsableTelephoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    _connexionTelephoneModifieManuellement = true;
                  },
                  decoration: const InputDecoration(
                    labelText: "Téléphone de connexion *",
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                    helperText:
                        "Ce numéro sera utilisé pour se connecter à la bergerie.",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Veuillez saisir le téléphone du responsable";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      _responsableMotDePasseController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Mot de passe initial *",
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                    helperText: "Minimum 6 caractères.",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 6) {
                      return "Minimum 6 caractères.";
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 16),

              TextFormField(
                controller:
                _observationsController,
                maxLines: 4,
                decoration:
                const InputDecoration(
                  labelText: "Observations",
                  alignLabelWithHint: true,
                  border:
                  OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveBergerie,
                  icon: _isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Icon(
                    widget.isEdition
                        ? Icons.edit
                        : Icons.save,
                  ),
                  label: Text(
                    _isSaving
                        ? (widget.isEdition
                        ? "Modification..."
                        : "Enregistrement...")
                        : (widget.isEdition
                        ? "Modifier la bergerie"
                        : "Enregistrer la bergerie"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}