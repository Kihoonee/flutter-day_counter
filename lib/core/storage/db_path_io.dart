import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getDatabasePath(String dbName) async {
  Directory dir;
  if (Platform.isIOS) {
    dir = await getLibraryDirectory();
  } else {
    dir = await getApplicationDocumentsDirectory();
  }
  await dir.create(recursive: true);
  return join(dir.path, dbName);
}
