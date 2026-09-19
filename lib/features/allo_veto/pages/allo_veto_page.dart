import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../core/session/current_user_service.dart';
import '../models/veterinaire_model.dart';
import '../repository/firebase_veterinaire_repository.dart';
import '../widgets/veterinaire_card.dart';

class AlloVetoPage extends StatefulWidget {
  const AlloVetoPage({super.key});

  @override
  State<AlloVetoPage> createState() => _AlloVetoPageState();
}

class _AlloVetoPageState extends State<AlloVetoPage> {
  final FirebaseVeterinaireRepository _repository =
      FirebaseVeterinaireRepository();
  final TextEditingController _searchController = TextEditingController();
  final Uuid _uuid = const Uuid();

  bool _loading = true;
  String? _bergerieId;
  List<VeterinaireModel> _veterinaires = [];
  List<VeterinaireModel> _resultat = [];

  @override
  void initState() {
    super.initState();
    _bergerieId = CurrentUserService.instance.bergerieId;
    _charger();
    _searchController.addListener(_filtrerVeterinaires);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtrerVeterinaires);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    final bergerieId = _bergerieId;

    if (bergerieId == null || bergerieId.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _veterinaires = [];
          _resultat = [];
        });
      }
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final veterinaires =
          await _repository.getVeterinairesParBergerie(bergerieId);

      if (!mounted) return;

      setState(() {
        _veterinaires = veterinaires;
        _resultat = List.from(veterinaires);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de charger le carnet véto : $e'),
        ),
      );
    }
  }

  void _filtrerVeterinaires() {
    final recherche = _searchController.text.trim().toLowerCase();

    setState(() {
      if (recherche.isEmpty) {
        _resultat = List.from(_veterinaires);
        return;
      }

      _resultat = _veterinaires.where((v) {
        return v.nom.toLowerCase().contains(recherche) ||
            v.telephone.toLowerCase().contains(recherche);
      }).toList();
    });
  }

  Future<void> _appeler(VeterinaireModel veterinaire) async {
    final telephone = veterinaire.telephone.trim();
    final uri = Uri(scheme: 'tel', path: telephone);

    try {
      final launched = await launchUrl(uri);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'appeler ${veterinaire.nom}.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Numéro : ${veterinaire.telephone}'),
        ),
      );
    }
  }

  Future<void> _ajouterVeterinaire() async {
    final nomController = TextEditingController();
    final telephoneController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un vétérinaire'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nom du vétérinaire *',
                  hintText: 'Ex. Dr Amadou Diop',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: telephoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone *',
                  hintText: 'Ex. 77 123 45 67',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                final nom = nomController.text.trim();
                final telephone = telephoneController.text.trim();
                final bergerieId = _bergerieId;

                if (nom.isEmpty || telephone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Le nom et le numéro sont obligatoires.'),
                    ),
                  );
                  return;
                }

                if (bergerieId == null || bergerieId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Aucune bergerie associée à ce compte.'),
                    ),
                  );
                  return;
                }

                try {
                  final veterinaire = VeterinaireModel(
                    id: _uuid.v4(),
                    bergerieId: bergerieId,
                    nom: nom,
                    telephone: telephone,
                  );

                  await _repository.addVeterinaire(veterinaire);

                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur lors de l\'ajout : $e')),
                  );
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );

    nomController.dispose();
    telephoneController.dispose();

    if (result == true) {
      await _charger();
    }
  }

  Future<void> _modifierVeterinaire(VeterinaireModel veterinaire) async {
    final nomController = TextEditingController(text: veterinaire.nom);
    final telephoneController =
        TextEditingController(text: veterinaire.telephone);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier le vétérinaire'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nom du vétérinaire *',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: telephoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone *',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                final nom = nomController.text.trim();
                final telephone = telephoneController.text.trim();

                if (nom.isEmpty || telephone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Le nom et le numéro sont obligatoires.'),
                    ),
                  );
                  return;
                }

                try {
                  await _repository.updateVeterinaire(
                    veterinaire.copyWith(
                      nom: nom,
                      telephone: telephone,
                    ),
                  );

                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur lors de la modification : $e')),
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    nomController.dispose();
    telephoneController.dispose();

    if (result == true) {
      await _charger();
    }
  }

  Future<void> _supprimerVeterinaire(VeterinaireModel veterinaire) async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le contact ?'),
        content: Text(
          'Voulez-vous supprimer ${veterinaire.nom} de votre carnet véto ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmer != true) return;

    try {
      await _repository.deleteVeterinaire(veterinaire.id);
      await _charger();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bergerieId = _bergerieId;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/dashboard/bergerie'),
        ),
        title: const Text('🩺 Mon Carnet Véto'),
        centerTitle: true,
      ),
      floatingActionButton: bergerieId != null && bergerieId.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _ajouterVeterinaire,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _charger,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.medical_services_rounded, size: 30),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Enregistrez ici les vétérinaires que vous souhaitez contacter.',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_veterinaires.isNotEmpty)
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Rechercher un vétérinaire',
                      ),
                    ),
                  if (_veterinaires.isNotEmpty)
                    const SizedBox(height: 20),
                  if (bergerieId == null || bergerieId.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          'Aucune bergerie associée à ce compte.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else if (_resultat.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          'Votre carnet véto est vide.\n\nAjoutez votre premier contact.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ..._resultat.map(
                      (veterinaire) => VeterinaireCard(
                        veterinaire: veterinaire,
                        onCall: () => _appeler(veterinaire),
                        onEdit: () => _modifierVeterinaire(veterinaire),
                        onDelete: () => _supprimerVeterinaire(veterinaire),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}