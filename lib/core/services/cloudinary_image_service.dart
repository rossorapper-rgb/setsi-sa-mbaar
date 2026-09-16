import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/cloudinary_config.dart';

class CloudinaryImageService {
  const CloudinaryImageService();

  Future<String> uploadMoutonPhoto({
    required Uint8List bytes,
    required String bergerieId,
    required String moutonId,
  }) async {
    if (!CloudinaryConfig.isConfigured) {
      throw Exception(
        'Cloudinary n’est pas encore configuré. Renseignez le cloud name et le upload preset.',
      );
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..fields['folder'] = 'bergeries/$bergerieId/moutons'
      ..fields['public_id'] = 'mouton_$moutonId';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'mouton_$moutonId.jpg',
      ),
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
      } catch (_) {
        // On conserve le message générique si la réponse n'est pas JSON.
      }

      throw Exception(message);
    }

    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final secureUrl = data['secure_url']?.toString() ?? '';

    if (secureUrl.isEmpty) {
      throw Exception('Cloudinary n’a pas retourné l’URL de la photo.');
    }

    return secureUrl;
  }
}
