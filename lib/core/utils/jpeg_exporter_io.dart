import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<void> saveJpegBytes(Uint8List bytes, String fileName) async {
  final directory = await getDownloadsDirectory() ??
      await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
}
