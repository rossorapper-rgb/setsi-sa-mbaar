import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/session/current_user_service.dart';
import '../../moutons/models/mouton_model.dart';
import '../../moutons/repository/firebase_mouton_repository.dart';
import '../../moutons/pages/add_mouton_page.dart';
import '../models/gestation_model.dart';
import '../../bergeries/models/bergerie_model.dart';
import '../../bergeries/repository/firebase_bergerie_repository.dart';
import '../repositories/firebase_gestation_repository.dart';
import '../widgets/femelle_info_card.dart';
import '../widgets/belier_info_card.dart';

enum TypeBelier { troupeau, exterieur }

class AddGestationPage extends StatefulWidget {
  final GestationModel? gestation;
  final BergerieModel? bergerie;

  const AddGestationPage({super.key, this.gestation, this.bergerie});

  bool get isEdition => gestation != null;

  @override
  State<AddGestationPage> createState() => _AddGestationPageState();
}

class _AddGestationPageState extends State<AddGestationPage> {
  final _formKey = GlobalKey<FormState>();
  final _repo = FirebaseGestationRepository();
  final _moutonRepo = FirebaseMoutonRepository();
  final _uuid = const Uuid();

  final _obsController = TextEditingController();
  final _nomBelierController = TextEditingController();
  final _proprietaireController = TextEditingController();

  List<MoutonModel> _brebis = [];
  List<MoutonModel> _beliers = [];
  MoutonModel? _brebisSelectionnee;
  MoutonModel? _belierSelectionne;

  TypeBelier _typeBelier = TypeBelier.troupeau;
  DateTime _dateSaillie = DateTime.now();
  bool _loading = true;
  bool _saving = false;

  CurrentUserService get _session => CurrentUserService.instance;

  String? get _bergerieIdSession {
    final id = _session.bergerieId?.trim();
    return (id == null || id.isEmpty) ? null : id;
  }

  String? get _bergerieIdEffectif {
    if (!_session.isAdmin) return _bergerieIdSession;
    return widget.bergerie?.id ?? widget.gestation?.bergerieId;
  }

  bool get _gestationEstTerminee {
    final gestation = widget.gestation;
    if (gestation == null) return false;
    return gestation.statut.toLowerCase() == 'terminée' ||
        gestation.dateMiseBas != null ||
        !gestation.active;
  }

  @override
  void initState() {
    super.initState();

    if (_gestationEstTerminee) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Cette gestation est terminée et ne peut plus être modifiée.",
            ),
          ),
        );
        Navigator.pop(context);
      });
      return;
    }

    if (widget.gestation != null) {
      _dateSaillie = widget.gestation!.dateSaillie;
      _obsController.text = widget.gestation!.observations;
      _nomBelierController.text = widget.gestation!.belierNom;
      _proprietaireController.text =
          widget.gestation!.proprietaireBelier ?? "";
      _typeBelier = widget.gestation!.belierExterieur
          ? TypeBelier.exterieur
          : TypeBelier.troupeau;
    }

    _charger();
  }

  Future<void> _verifierGestationActive() async {
    if (_brebisSelectionnee == null) return;

    final gestation = await _repo.getGestationActiveByBrebis(
      _brebisSelectionnee!.id,
    );

    if (!mounted) return;

    if (gestation != null &&
        (!widget.isEdition || gestation.id != widget.gestation?.id)) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Gestation déjà en cours"),
          content: Text(
            "Cette femelle possède déjà une gestation active.\n\n"
            "Date de saillie : "
            "${gestation.dateSaillie.day}/${gestation.dateSaillie.month}/${gestation.dateSaillie.year}\n\n"
            "Veuillez enregistrer la mise bas avant de créer une nouvelle gestation.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );

      setState(() => _brebisSelectionnee = null);
    }
  }

  Future<BergerieModel?> _choisirBergeriePourAdmin() async {
    final bergeries = await FirebaseBergerieRepository().getAllBergeries();
    if (!mounted) return null;

    if (bergeries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Aucune bergerie n'est disponible. Veuillez d'abord créer une bergerie.",
          ),
        ),
      );
      return null;
    }

    if (bergeries.length == 1) return bergeries.first;

    return showDialog<BergerieModel>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Choisir la bergerie"),
        content: SizedBox(
          width: 420,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: bergeries.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (_, index) {
              final item = bergeries[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.home_work)),
                title: Text(item.nom),
                subtitle: Text(item.adresse.isEmpty ? "Bergerie" : item.adresse),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.pop(dialogContext, item),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _ajouterFemelle() async {
    BergerieModel? bergerie = widget.bergerie;

    if (!_session.isAdmin) {
      final sessionBergerieId = _bergerieIdSession;
      if (sessionBergerieId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Aucune bergerie n'est associée à votre compte."),
          ),
        );
        return;
      }

      if (bergerie == null || bergerie.id != sessionBergerieId) {
        try {
          final bergeries =
              await FirebaseBergerieRepository().getAllBergeries();
          for (final item in bergeries) {
            if (item.id == sessionBergerieId) {
              bergerie = item;
              break;
            }
          }
        } catch (_) {
          bergerie = null;
        }
      }

      if (bergerie == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Impossible de retrouver votre bergerie."),
          ),
        );
        return;
      }
    } else if (bergerie == null) {
      try {
        bergerie = await _choisirBergeriePourAdmin();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible de charger les bergeries : $e")),
        );
        return;
      }
      if (bergerie == null) return;
    }

    final navigator = Navigator.of(context);
    final resultat = await navigator.push<bool>(
      MaterialPageRoute(builder: (_) => AddMoutonPage(bergerie: bergerie!)),
    );

    if (resultat == true && mounted) await _charger();
  }

  Future<void> _charger() async {
    try {
      final bergerieId = _bergerieIdEffectif;
      final List<MoutonModel> brebis;
      final List<MoutonModel> beliers;

      if (bergerieId != null) {
        brebis = await _moutonRepo.getBrebisByBergerie(bergerieId);
        beliers = await _moutonRepo.getBeliersByBergerie(bergerieId);
      } else if (_session.isAdmin) {
        brebis = await _moutonRepo.getBrebis();
        beliers = await _moutonRepo.getBeliers();
      } else {
        throw Exception("Aucune bergerie n'est associée à ce compte.");
      }

      brebis.sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));
      beliers.sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));

      if (!mounted) return;

      MoutonModel? brebisSelectionnee;
      MoutonModel? belierSelectionne;

      if (widget.gestation != null) {
        for (final mouton in brebis) {
          if (mouton.id == widget.gestation!.brebisId) {
            brebisSelectionnee = mouton;
            break;
          }
        }

        if (!widget.gestation!.belierExterieur) {
          for (final mouton in beliers) {
            if (mouton.id == widget.gestation!.belierId) {
              belierSelectionne = mouton;
              break;
            }
          }
        }
      }

      setState(() {
        _brebis = brebis;
        _beliers = beliers;
        _brebisSelectionnee = brebisSelectionnee;
        _belierSelectionne = belierSelectionne;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible de charger les moutons : $e")),
      );
    }
  }

  Future<void> _choisirDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dateSaillie,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null && mounted) setState(() => _dateSaillie = d);
  }

  Future<void> _enregistrer() async {
    if (_gestationEstTerminee) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Cette gestation est terminée et ne peut plus être modifiée.",
          ),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_brebisSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner une femelle.")),
      );
      return;
    }

    if (_typeBelier == TypeBelier.troupeau && _belierSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner un bélier.")),
      );
      return;
    }

    final bergerieId = _bergerieIdEffectif ?? _brebisSelectionnee!.bergerieId;

    if (bergerieId.isEmpty || _brebisSelectionnee!.bergerieId != bergerieId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "La femelle sélectionnée n'appartient pas à cette bergerie.",
          ),
        ),
      );
      return;
    }

    if (_typeBelier == TypeBelier.troupeau &&
        _belierSelectionne!.bergerieId != bergerieId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Le bélier sélectionné n'appartient pas à cette bergerie.",
          ),
        ),
      );
      return;
    }

    await _verifierGestationActive();
    if (_brebisSelectionnee == null) return;

    setState(() => _saving = true);

    final gestation = GestationModel(
      id: widget.gestation?.id ?? _uuid.v4(),
      brebisId: _brebisSelectionnee!.id,
      nomFemelle: _brebisSelectionnee!.nom,
      bergerieId: bergerieId,
      typeSaillie:
          _typeBelier == TypeBelier.troupeau ? "Interne" : "Externe",
      belierId:
          _typeBelier == TypeBelier.troupeau ? _belierSelectionne!.id : "",
      belierNom: _typeBelier == TypeBelier.troupeau
          ? _belierSelectionne!.nom
          : _nomBelierController.text.trim(),
      belierExterieur: _typeBelier == TypeBelier.exterieur,
      proprietaireBelier: _proprietaireController.text.trim(),
      dateSaillie: _dateSaillie,
      dateProbableMiseBas: _dateSaillie.add(const Duration(days: 150)),
      dateMiseBas: widget.gestation?.dateMiseBas,
      statut: widget.gestation?.statut ?? "Gestante",
      nombreAgneaux: widget.gestation?.nombreAgneaux ?? 0,
      nombreMales: widget.gestation?.nombreMales ?? 0,
      nombreFemelles: widget.gestation?.nombreFemelles ?? 0,
      nombreMortNes: widget.gestation?.nombreMortNes ?? 0,
      observations: _obsController.text.trim(),
      dateCreation: widget.gestation?.dateCreation ?? DateTime.now(),
    );

    try {
      if (widget.isEdition) {
        await _repo.updateGestation(gestation);
      } else {
        await _repo.addGestation(gestation);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdition ? "Modifier la gestation" : "Nouvelle gestation",
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Femelle gestante",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MoutonModel>(
              value: _brebisSelectionnee,
              decoration: const InputDecoration(
                labelText: "Sélectionner une femelle",
                border: OutlineInputBorder(),
              ),
              items: _brebis.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text("${e.nom} • ${e.numeroIdentification}"),
                );
              }).toList(),
              onChanged: (value) async {
                setState(() => _brebisSelectionnee = value);
                await _verifierGestationActive();
              },
              validator: (value) =>
                  value == null ? "Veuillez sélectionner une femelle" : null,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _saving ? null : _ajouterFemelle,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text("Ajouter une femelle"),
              ),
            ),
            const SizedBox(height: 16),
            FemelleInfoCard(femelle: _brebisSelectionnee),
            const SizedBox(height: 24),
            const Text(
              "Bélier reproducteur",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            RadioGroup<TypeBelier>(
              groupValue: _typeBelier,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _typeBelier = value);
              },
              child: Column(
                children: [
                  RadioListTile<TypeBelier>(
                    value: TypeBelier.troupeau,
                    title: const Text("Bélier du troupeau"),
                  ),
                  RadioListTile<TypeBelier>(
                    value: TypeBelier.exterieur,
                    title: const Text("Bélier extérieur"),
                  ),
                ],
              ),
            ),
            if (_typeBelier == TypeBelier.troupeau) ...[
              DropdownButtonFormField<MoutonModel>(
                value: _belierSelectionne,
                decoration: const InputDecoration(
                  labelText: "Sélectionner un bélier",
                  border: OutlineInputBorder(),
                ),
                items: _beliers.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text("${e.nom} • ${e.numeroIdentification}"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _belierSelectionne = value);
                },
                validator: (value) =>
                    _typeBelier == TypeBelier.troupeau && value == null
                        ? "Veuillez sélectionner un bélier"
                        : null,
              ),
              const SizedBox(height: 16),
              BelierInfoCard(belier: _belierSelectionne),
            ],
            if (_typeBelier == TypeBelier.exterieur) ...[
              TextFormField(
                controller: _nomBelierController,
                decoration: const InputDecoration(
                  labelText: "Nom du bélier (facultatif)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _proprietaireController,
                decoration: const InputDecoration(
                  labelText: "Propriétaire (facultatif)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text("Date de saillie"),
              subtitle: Text(
                "${_dateSaillie.day}/${_dateSaillie.month}/${_dateSaillie.year}",
              ),
              trailing: const Icon(Icons.edit_calendar),
              onTap: _choisirDate,
            ),
            Card(
              elevation: 0,
              child: ListTile(
                leading: const Icon(Icons.event_available, color: Colors.green),
                title: const Text("Date probable de mise bas"),
                subtitle: Text(
                  "${_dateSaillie.add(const Duration(days: 150)).day}/"
                  "${_dateSaillie.add(const Duration(days: 150)).month}/"
                  "${_dateSaillie.add(const Duration(days: 150)).year}",
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _obsController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Observations",
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _enregistrer,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _saving
                      ? "Enregistrement..."
                      : widget.isEdition
                          ? "Mettre à jour"
                          : "Enregistrer",
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _obsController.dispose();
    _nomBelierController.dispose();
    _proprietaireController.dispose();
    super.dispose();
  }
}
