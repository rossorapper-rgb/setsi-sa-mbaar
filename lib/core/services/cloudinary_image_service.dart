import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/cloudinary_config.dart';

class CloudinaryImageService {
  const CloudinaryImageService();

  Future<String> _upload({
    required Uint8List bytes,
    required String folder,
    required String publicId,
    required String filename,
  }) async {
    if (!CloudinaryConfig.isConfigured) {
      throw Exception('Cloudinary n’est pas encore configuré.');
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..fields['folder'] = folder
      ..fields['public_id'] = publicId;

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Échec de l’envoi de la photo.';
      try {
        final data = jsonDecode(responseBody);
        final error = data['error'];
        if (error is Map && error['message'] != null) {
          message = error['message'].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }

    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final secureUrl = data['secure_url']?.toString() ?? '';
    if (secureUrl.isEmpty) {
      throw Exception('Cloudinary n’a pas retourné l’URL de la photo.');
    }
    return secureUrl;
  }

  Future<String> uploadMoutonPhoto({
    required Uint8List bytes,
    required String bergerieId,
    required String moutonId,
  }) {
    return _upload(
      bytes: bytes,
      folder: 'bergeries/$bergerieId/moutons',
      publicId: 'mouton_$moutonId',
      filename: 'mouton_$moutonId.jpg',
    );
  }

  Future<String> uploadBergerieLogo({
    required Uint8List bytes,
    required String bergerieId,
  }) {
    return _upload(
      bytes: bytes,
      folder: 'bergeries/$bergerieId/config',
      // Un identifiant unique évite le cache Cloudinary et permet
      // de remplacer le logo autant de fois que nécessaire.
      publicId: 'logo_${DateTime.now().millisecondsSinceEpoch}',
      filename: 'logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  Future<String> uploadNaissancePhoto({
    required Uint8List bytes,
    required String bergerieId,
    required String naissanceId,
  }) {
    return _upload(
      bytes: bytes,
      folder: 'bergeries/$bergerieId/naissances',
      publicId: 'naissance_$naissanceId',
      filename: 'naissance_$naissanceId.jpg',
    );
  }
}
