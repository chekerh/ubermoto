import 'dart:io' show File;

Future<({List<int> bytes, String fileName})> readLocalDocumentPath(String path) async {
  final file = File(path);
  final bytes = await file.readAsBytes();
  final name =
      file.uri.pathSegments.isNotEmpty ? file.uri.pathSegments.last : 'document';
  return (bytes: bytes, fileName: name);
}
