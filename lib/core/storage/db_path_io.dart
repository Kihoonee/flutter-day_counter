import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getDatabasePath(String dbName) async {
  final appDir = await getApplicationDocumentsDirectory();
  await appDir.create(recursive: true);
  return join(appDir.path, dbName);
}
