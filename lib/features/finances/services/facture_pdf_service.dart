import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/paiement_model.dart';
import 'pdf_helper.dart';

class FacturePdfService {
FacturePdfService._();

static Future<File> genererFacture(
PaiementModel paiement,
) async {
final pdf =
await PdfHelper.createDocument();
final header = await PdfHelper.buildHeader();
final footer = await PdfHelper.buildFooter();
pdf.addPage(
pw.MultiPage(
margin:
const pw.EdgeInsets.all(24),

build: (context) => [

  header,

pw.SizedBox(height: 20),

PdfHelper.titreSection(
"FACTURE",
),

pw.SizedBox(height: 12),

PdfHelper.infoRow(
label: "Facture",
valeur:
paiement.numeroFacture,
),

PdfHelper.infoRow(
label: "Date",
valeur:
PdfHelper.formatDate(
paiement.datePaiement,
),
),

PdfHelper.infoRow(
label: "Client",
valeur:
paiement.clientNom,
),

PdfHelper.infoRow(
label: "Bergerie",
valeur:
paiement.bergerieNom,
),

PdfHelper.separation(),

PdfHelper.titreSection(
"PRESTATION",
),

pw.SizedBox(height: 10),

PdfHelper.infoRow(
label: "Type",
valeur: paiement
.typePrestation.name,
),

PdfHelper.infoRow(
label: "Mode",
valeur: paiement
.modePaiement.name,
),

if (paiement
.reference.isNotEmpty)
PdfHelper.infoRow(
label: "Référence",
valeur:
paiement.reference,
),

PdfHelper.separation(),
PdfHelper.titreSection(
"MONTANTS",
),

pw.SizedBox(height: 10),

PdfHelper.montantRow(
label: "Montant conseillé",
montant:
paiement.montantConseille,
),

PdfHelper.montantRow(
label: "Montant facturé",
montant:
paiement.montantFacture,
),

if (paiement.motifRemise.isNotEmpty)
PdfHelper.infoRow(
label: "Motif remise",
valeur:
paiement.motifRemise,
),

PdfHelper.montantRow(
label: "Montant payé",
montant:
paiement.montantPaye,
),

PdfHelper.montantRow(
label: "Reste à payer",
montant:
paiement.resteAPayer,
gras: true,
),

PdfHelper.separation(),

if (paiement.observations.isNotEmpty) ...[

PdfHelper.titreSection(
"OBSERVATIONS",
),

pw.SizedBox(height: 10),

pw.Text(
paiement.observations,
style:
PdfHelper.normalStyle(),
),

PdfHelper.separation(),

],

pw.SizedBox(height: 25),

pw.Row(
mainAxisAlignment:
pw.MainAxisAlignment
.spaceBetween,
children: [

pw.Column(
crossAxisAlignment:
pw.CrossAxisAlignment
.center,
children: [

pw.Text(
"Signature Client",
style: PdfHelper
.normalStyle(),
),

pw.SizedBox(
height: 55,
),

pw.Container(
width: 140,
height: 1,
color: PdfHelper
.darkColor,
),

],
),

pw.Column(
crossAxisAlignment:
pw.CrossAxisAlignment
.center,
children: [

pw.Text(
"SET'SI SA MBAAR",
style: PdfHelper
.normalStyle(),
),

pw.SizedBox(
height: 55,
),

pw.Container(
width: 140,
height: 1,
color: PdfHelper
.darkColor,
),

],
),

],
),

pw.SizedBox(height: 25),

  footer,
],
),
);

final directory =
await getApplicationDocumentsDirectory();

final file = File(
  "${directory.path}/${paiement.numeroFacture}.pdf",
);

await file.writeAsBytes(
  await pdf.save(),
);

return file;
}

static Future<void> imprimerFacture(
    PaiementModel paiement,
    ) async {
  final pdf =
  await PdfHelper.createDocument();
  final header = await PdfHelper.buildHeader();
  final footer = await PdfHelper.buildFooter();
  pdf.addPage(
    pw.MultiPage(
      margin:
      const pw.EdgeInsets.all(24),
      build: (context) => [

        header,

        pw.SizedBox(height: 20),

        PdfHelper.titreSection(
          "FACTURE",
        ),

        pw.SizedBox(height: 12),

        PdfHelper.infoRow(
          label: "Facture",
          valeur:
          paiement.numeroFacture,
        ),

        PdfHelper.infoRow(
          label: "Date",
          valeur:
          PdfHelper.formatDate(
            paiement.datePaiement,
          ),
        ),

        PdfHelper.infoRow(
          label: "Client",
          valeur:
          paiement.clientNom,
        ),

        PdfHelper.infoRow(
          label: "Bergerie",
          valeur:
          paiement.bergerieNom,
        ),

        PdfHelper.separation(),

        PdfHelper.montantRow(
          label: "Montant facturé",
          montant:
          paiement.montantFacture,
        ),

        PdfHelper.montantRow(
          label: "Montant payé",
          montant:
          paiement.montantPaye,
        ),

        PdfHelper.montantRow(
          label: "Reste à payer",
          montant:
          paiement.resteAPayer,
          gras: true,
        ),

        pw.SizedBox(height: 25),

        footer,

      ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async =>
        pdf.save(),
  );
}
}
