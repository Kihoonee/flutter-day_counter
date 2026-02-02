import 'package:sembast/sembast.dart';
import 'db_factory.dart';
import 'db_path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      print('DatabaseService: Initializing database...');
      
      final dbPath = await getDatabasePath('days_plus.db');
      print('DatabaseService: Opening database at path: $dbPath');

      final factory = await getDatabaseFactory();
      final db = await factory.openDatabase(dbPath);
      
      print('DatabaseService: Database opened successfully.');
      return db;
    } catch (e, st) {
      print('DatabaseService: Failed to open database: $e\n$st');
      rethrow;
    }
  }
}