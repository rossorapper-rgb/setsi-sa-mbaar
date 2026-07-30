import 'dart:math';

class CodeGeneratorService {
  static Future<String> generate({
    required String prefix,
  }) async {
    final now = DateTime.now();

    final random = Random().nextInt(9000) + 1000;

    return "$prefix${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}$random";
  }
}