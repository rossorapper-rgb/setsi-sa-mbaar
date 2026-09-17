import 'dart:html' as html;

Future<bool> downloadImage(String url, String filename) async {
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..target = '_blank';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  return true;
}
