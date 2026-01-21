import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

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
      
      // iOS: Documents 대신 Library 디렉토리 사용 (안전성 향상)
      Directory dir;
      if (Platform.isIOS) {
        dir = await getLibraryDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
      
      await dir.create(recursive: true);
      final dbPath = join(dir.path, 'day_counter_v2.db'); // 새 파일명 사용
      
      print('DatabaseService: Opening database at path: $dbPath');

      // IO Factory 명시적 사용
      final factory = databaseFactoryIo;
      
      final db = await factory.openDatabase(dbPath);
      print('DatabaseService: Database opened successfully.');
      return db;
    } catch (e, st) {
      print('DatabaseService: Failed to open database: $e\n$st');
      rethrow;
    }
  }
}