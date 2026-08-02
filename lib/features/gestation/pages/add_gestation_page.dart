import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../moutons/models/mouton_model.dart';
import '../../moutons/repository/firebase_mouton_repository.dart';
import '../models/gestation_model.dart';
import '../../bergeries/models/bergerie_model.dart';
import '../repositories/firebase_gestation_repository.dart';
import '../widgets/femelle_info_card.dart';
import '../widgets/belier_info_card.dart';

enum TypeBelier {
  troupeau,
  exterieur,
}

class AddGestationPage extends StatefulWidget {
  final GestationModel? gestation;
  final BergerieModel? bergerie;

  const AddGestationPage({
    super.key,
    this.gestation,
    this.bergerie,
  });

  bool get isEdition => gestation != null;

  @override
  State<AddGestationPage> createState() =>
      _AddGestationPageState();
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

  @override
  void initState() {
    super.initState();

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

    final gestation =
    await _repo.getGestationActiveByBrebis(
      _brebisSelectionnee!.id,
    );

    if (!mounted) return;

    if (gestation != null &&
        (!widget.isEdition ||
            gestation.id != widget.gestation?.id)) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(
            "Gestation déjà en cours",
          ),
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

      setState(() {
        _brebisSelectionnee = null;
      });
    }
  }

  Future<void> _charger() async {
    final brebis = widget.bergerie == null
        ? await _moutonRepo.getBrebis()
        : await _moutonRepo.getBrebisByBergerie(
      widget.bergerie!.id,
    );

    final beliers = widget.bergerie == null
        ? await _moutonRepo.getBeliers()
        : await _moutonRepo.getBeliersByBergerie(
      widget.bergerie!.id,
    );

    brebis.sort(
          (a, b) =>
          a.nom.toLowerCase().compareTo(
            b.nom.toLowerCase(),
          ),
    );

    beliers.sort(
          (a, b) =>
          a.nom.toLowerCase().compareTo(
            b.nom.toLowerCase(),
          ),
    );

    if (!mounted) return;

    setState(() {
      _brebis = brebis;
      _beliers = beliers;

      if (widget.gestation == null) {
        _brebisSelectionnee = null;
        _belierSelectionne = null;
      } else {
        _brebisSelectionnee = brebis.firstWhere(
              (e) => e.id == widget.gestation!.brebisId,
          orElse: () => brebis.first,
        );

        if (!widget.gestation!.belierExterieur) {
          _belierSelectionne = beliers.firstWhere(
                (e) => e.id == widget.gestation!.belierId,
            orElse: () => beliers.first,
          );
        }
      }

      _loading = false;
    });
  }
  Future<void> _choisirDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dateSaillie,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (d != null) {
      setState(() {
        _dateSaillie = d;
      });
    }
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_brebisSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez sélectionner une femelle.",
          ),
        ),
      );
      return;
    }

    if (_typeBelier == TypeBelier.troupeau &&
        _belierSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez sélectionner un bélier.",
          ),
        ),
      );
      return;
    }

    // Sécurité supplémentaire
    await _verifierGestationActive();

    if (_brebisSelectionnee == null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final gestation = GestationModel(
      id: widget.gestation?.id ?? _uuid.v4(),

      brebisId: _brebisSelectionnee!.id,
      nomFemelle: _brebisSelectionnee!.nom,

      bergerieId: _brebisSelectionnee!.bergerieId,

      typeSaillie: _typeBelier == TypeBelier.troupeau
          ? "Interne"
          : "Externe",

      belierId: _typeBelier == TypeBelier.troupeau
          ? _belierSelectionne!.id
          : "",

      belierNom: _typeBelier == TypeBelier.troupeau
          ? _belierSelectionne!.nom
          : _nomBelierController.text.trim(),

      belierExterieur:
      _typeBelier == TypeBelier.exterieur,

      proprietaireBelier:
      _proprietaireController.text.trim(),

      dateSaillie: _dateSaillie,

      dateProbableMiseBas:
      _dateSaillie.add(
        const Duration(days: 150),
      ),

      dateMiseBas:
      widget.gestation?.dateMiseBas,

      statut:
      widget.gestation?.statut ??
          "Gestante",

      nombreAgneaux:
      widget.gestation?.nombreAgneaux ?? 0,

      nombreMales:
      widget.gestation?.nombreMales ?? 0,

      nombreFemelles:
      widget.gestation?.nombreFemelles ?? 0,

      nombreMortNes:
      widget.gestation?.nombreMortNes ?? 0,

      observations:
      _obsController.text.trim(),

      dateCreation:
      widget.gestation?.dateCreation ??
          DateTime.now(),
    );

    try {
      if (widget.isEdition) {
        await _repo.updateGestation(
          gestation,
        );
      } else {
        await _repo.addGestation(
          gestation,
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur : $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }
  Widget _infoFemelle() {
    if (_brebisSelectionnee == null) {
      return const SizedBox();
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.pets,
                  color: Colors.green,
                ),
                SizedBox(width: 8),
                Text(
                  "Femelle sélectionnée",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.badge),
              title: const Text("Nom"),
              subtitle: Text(_brebisSelectionnee!.nom),
            ),

            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.qr_code),
              title: const Text("Identification"),
              subtitle: Text(
                _brebisSelectionnee!.numeroIdentification,
              ),
            ),

            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.category),
              title: const Text("Race"),
              subtitle: Text(
                _brebisSelectionnee!.race,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBelier() {
    if (_typeBelier == TypeBelier.exterieur) {
      return const SizedBox();
    }

    if (_belierSelectionne == null) {
      return const SizedBox();
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.pets,
                  color: Colors.blue,
                ),
                SizedBox(width: 8),
                Text(
                  "Bélier sélectionné",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.badge),
              title: const Text("Nom"),
              subtitle: Text(_belierSelectionne!.nom),
            ),

            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.qr_code),
              title: const Text("Identification"),
              subtitle: Text(
                _belierSelectionne!.numeroIdentification,
              ),
            ),

            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.category),
              title: const Text("Race"),
              subtitle: Text(
                _belierSelectionne!.race,
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdition
              ? "Modifier la gestation"
              : "Nouvelle gestation",
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            /// ==========================
            /// FEMELLE
            /// ==========================
            const Text(
              "Femelle gestante",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                  child: Text(
                    "${e.nom} • ${e.numeroIdentification}",
                  ),
                );
              }).toList(),

              onChanged: (value) async {
                setState(() {
                  _brebisSelectionnee = value;
                });

                await _verifierGestationActive();
              },

              validator: (value) {
                if (value == null) {
                  return "Veuillez sélectionner une femelle";
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            FemelleInfoCard(
              femelle: _brebisSelectionnee,
            ),

            const SizedBox(height: 24),

            /// ==========================
            /// BELIER
            /// ==========================
            const Text(
              "Bélier reproducteur",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            RadioListTile<TypeBelier>(
              value: TypeBelier.troupeau,
              groupValue: _typeBelier,
              title: const Text(
                "Bélier du troupeau",
              ),
              onChanged: (value) {
                setState(() {
                  _typeBelier = value!;
                });
              },
            ),

            RadioListTile<TypeBelier>(
              value: TypeBelier.exterieur,
              groupValue: _typeBelier,
              title: const Text(
                "Bélier extérieur",
              ),
              onChanged: (value) {
                setState(() {
                  _typeBelier = value!;
                });
              },
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
                    child: Text(
                      "${e.nom} • ${e.numeroIdentification}",
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _belierSelectionne = value;
                  });
                },
                validator: (value) {
                  if (_typeBelier ==
                      TypeBelier.troupeau &&
                      value == null) {
                    return "Veuillez sélectionner un bélier";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              BelierInfoCard(
                belier: _belierSelectionne,
              ),
            ],

            if (_typeBelier == TypeBelier.exterieur) ...[
              TextFormField(
                controller: _nomBelierController,
                decoration: const InputDecoration(
                  labelText: "Nom du bélier",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_typeBelier ==
                      TypeBelier.exterieur &&
                      (value == null ||
                          value.trim().isEmpty)) {
                    return "Nom obligatoire";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                _proprietaireController,
                decoration:
                const InputDecoration(
                  labelText:
                  "Propriétaire (facultatif)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 24),

            /// ==========================
            /// DATE DE SAILLIE
            /// ==========================
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
                leading: const Icon(
                  Icons.event_available,
                  color: Colors.green,
                ),
                title: const Text(
                  "Date probable de mise bas",
                ),
                subtitle: Text(
                  "${_dateSaillie.add(const Duration(days: 150)).day}/"
                      "${_dateSaillie.add(const Duration(days: 150)).month}/"
                      "${_dateSaillie.add(const Duration(days: 150)).year}",
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ==========================
            /// OBSERVATIONS
            /// ==========================
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
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
