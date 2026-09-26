import 'package:web/web.dart' as web;

Future<bool> downloadImage(String url, String filename) async {
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename
    ..target = '_blank';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  return true;
}
