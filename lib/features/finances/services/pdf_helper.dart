

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfHelper {
PdfHelper._();

static const String entreprise =
"SET'SI SA MBAAR";

static const String slogan =
"Le partenaire de votre élevage";

static const String telephone =
"71 053 06 06";

static const String adresse =
"Grand Yoff Taïba 4 - Dakar";

static const String email =
"setsisambaar@gmail.com";

static const PdfColor primaryColor =
PdfColor.fromInt(0xFF0B6E4F);

static const PdfColor secondaryColor =
PdfColor.fromInt(0xFFC9A227);

static const PdfColor lightColor =
PdfColor.fromInt(0xFFF5F7F5);

static const PdfColor darkColor =
PdfColor.fromInt(0xFF2D3748);

static Future<pw.MemoryImage> logo() async {
final data = await rootBundle.load(
"assets/images/app_icon.png",
);

return pw.MemoryImage(
data.buffer.asUint8List(),
);
}

static String formatMontant(
double montant,
) {
final format =
NumberFormat.decimalPattern(
"fr_FR",
);

return "${format.format(montant)} FCFA";
}

static String formatDate(
DateTime date,
) {
return DateFormat(
"dd/MM/yyyy",
"fr_FR",
).format(date);
}

static pw.TextStyle titreStyle() {
return pw.TextStyle(
fontSize: 22,
fontWeight: pw.FontWeight.bold,
color: primaryColor,
);
}

static pw.TextStyle sousTitreStyle() {
return pw.TextStyle(
fontSize: 14,
fontWeight: pw.FontWeight.bold,
color: darkColor,
);
}

static pw.TextStyle normalStyle() {
return const pw.TextStyle(
fontSize: 11,
);
}

static Future<pw.Widget> buildHeader() async {
final img = await logo();

return pw.Container(
padding:
const pw.EdgeInsets.only(
bottom: 10,
),
decoration: const pw.BoxDecoration(
border: pw.Border(
bottom: pw.BorderSide(
color: primaryColor,
width: 2,
),
),
),
child: pw.Row(
crossAxisAlignment:
pw.CrossAxisAlignment.start,
children: [
pw.Container(
width: 70,
height: 70,
child: pw.Image(img),
),

pw.SizedBox(width: 15),

pw.Expanded(
child: pw.Column(
crossAxisAlignment:
pw.CrossAxisAlignment.start,
children: [
pw.Text(
entreprise,
style: titreStyle(),
),

pw.SizedBox(height: 4),

pw.Text(
slogan,
style:
sousTitreStyle(),
),

pw.SizedBox(height: 8),

pw.Text(
"📍 $adresse",
style:
normalStyle(),
),

pw.Text(
"☎ $telephone",
style:
normalStyle(),
),

pw.Text(
"✉ $email",
style:
normalStyle(),
),
],
),
),
],
),
);
}
static Future<pw.Widget> buildFooter() async {
  return pw.Container(
    margin: const pw.EdgeInsets.only(
      top: 25,
    ),
    padding: const pw.EdgeInsets.only(
      top: 10,
    ),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        top: pw.BorderSide(
          color: primaryColor,
          width: 1,
        ),
      ),
    ),
    child: pw.Column(
      children: [

        pw.Text(
          entreprise,
          style: sousTitreStyle(),
        ),

        pw.SizedBox(height: 4),

        pw.Text(
          slogan,
          style: normalStyle(),
        ),

        pw.SizedBox(height: 6),

        pw.Text(
          adresse,
          style: normalStyle(),
        ),

        pw.Text(
          "Tél. : $telephone",
          style: normalStyle(),
        ),

        pw.Text(
          email,
          style: normalStyle(),
        ),

        pw.SizedBox(height: 10),

        pw.Text(
          "Document généré automatiquement par SET'SI SA MBAAR",
          style: pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey700,
          ),
          textAlign: pw.TextAlign.center,
        ),

      ],
    ),
  );
}

static pw.Widget infoRow({
  required String label,
  required String valeur,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(
      vertical: 4,
    ),
    child: pw.Row(
      children: [

        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight:
              pw.FontWeight.bold,
            ),
          ),
        ),

        pw.Expanded(
          child: pw.Text(
            valeur,
          ),
        ),

      ],
    ),
  );
}

static pw.Widget montantRow({
  required String label,
  required double montant,
  bool gras = false,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(
      vertical: 3,
    ),
    child: pw.Row(
      mainAxisAlignment:
      pw.MainAxisAlignment.spaceBetween,
      children: [

        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: gras
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
          ),
        ),

        pw.Text(
          formatMontant(montant),
          style: pw.TextStyle(
            fontWeight: gras
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
          ),
        ),

      ],
    ),
  );
}

static pw.Widget separation() {
  return pw.Container(
    margin: const pw.EdgeInsets.symmetric(
      vertical: 10,
    ),
    height: 1,
    color: PdfColors.grey400,
  );
}

static pw.Widget titreSection(
    String titre,
    ) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(8),
    color: lightColor,
    child: pw.Text(
      titre,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: primaryColor,
        fontSize: 13,
      ),
    ),
  );
}

static Future<pw.Document>
createDocument() async {
  return pw.Document(
    title: entreprise,
    author: entreprise,
    creator: entreprise,
    subject: slogan,
  );
}
}