import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/paiement_model.dart';
import 'pdf_helper.dart';

class RecuPdfService {
RecuPdfService._();

static Future<File> genererRecu(
PaiementModel paiement,
) async {
final pdf =
await PdfHelper.createDocument();

final header =
await PdfHelper.buildHeader();

final footer =
await PdfHelper.buildFooter();

pdf.addPage(
pw.MultiPage(
margin:
const pw.EdgeInsets.all(24),

build: (context) => [

header,

pw.SizedBox(height: 20),

PdfHelper.titreSection(
"REÇU DE PAIEMENT",
),

pw.SizedBox(height: 12),

PdfHelper.infoRow(
label: "N° Facture",
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
label: "Montant payé",
montant:
paiement.montantPaye,
gras: true,
),

PdfHelper.montantRow(
label: "Reste à payer",
montant:
paiement.resteAPayer,
),

PdfHelper.infoRow(
label: "Mode",
valeur:
paiement.modePaiement.name,
),

if (paiement
.reference.isNotEmpty)
PdfHelper.infoRow(
label: "Référence",
valeur:
paiement.reference,
),

PdfHelper.separation(),
  pw.Row(
    mainAxisAlignment:
    pw.MainAxisAlignment.spaceBetween,
    children: [

      pw.Column(
        children: [

          pw.Text(
            "Client",
            style:
            PdfHelper.normalStyle(),
          ),

          pw.SizedBox(
            height: 55,
          ),

          pw.Container(
            width: 140,
            height: 1,
            color:
            PdfHelper.darkColor,
          ),

        ],
      ),

      pw.Column(
        children: [

          pw.Text(
            "SET'SI SA MBAAR",
            style:
            PdfHelper.normalStyle(),
          ),

          pw.SizedBox(
            height: 55,
          ),

          pw.Container(
            width: 140,
            height: 1,
            color:
            PdfHelper.darkColor,
          ),

        ],
      ),

    ],
  ),

  pw.SizedBox(height: 20),

  footer,

],
),
);

final directory =
await getApplicationDocumentsDirectory();

final file = File(
  "${directory.path}/REC-${paiement.numeroFacture}.pdf",
);

await file.writeAsBytes(
  await pdf.save(),
);

return file;
}

static Future<void> imprimerRecu(
    PaiementModel paiement,
    ) async {
  final pdf =
  await PdfHelper.createDocument();

  final header =
  await PdfHelper.buildHeader();

  final footer =
  await PdfHelper.buildFooter();

  pdf.addPage(
    pw.MultiPage(
      margin:
      const pw.EdgeInsets.all(24),
      build: (context) => [

        header,

        pw.SizedBox(height: 20),

        PdfHelper.titreSection(
          "REÇU DE PAIEMENT",
        ),

        pw.SizedBox(height: 12),

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

        PdfHelper.montantRow(
          label: "Montant payé",
          montant:
          paiement.montantPaye,
          gras: true,
        ),

        PdfHelper.montantRow(
          label: "Reste",
          montant:
          paiement.resteAPayer,
        ),

        pw.SizedBox(height: 20),

        footer,

      ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (_) async =>
        pdf.save(),
  );
}
}