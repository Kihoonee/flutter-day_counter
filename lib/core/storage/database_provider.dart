import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'database_service.dart';

final databaseProvider = FutureProvider<Database>((ref) async {
  return await DatabaseService().database;
});