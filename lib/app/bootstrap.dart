import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sembast/sembast.dart';
import '../core/storage/database_service.dart';
import '../core/storage/database_provider.dart';
import '../core/storage/shared_prefs_provider.dart';
import 'app.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _isInitialized = false;
  SharedPreferences? _sharedPreferences;
  Database? _database;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Give a larger breathing room for the Flutter engine and native launch screen to settle
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      print('AppBootstrap: Starting initialization...');
      
      // Initialize sequentially to isolate potential errors
      print('AppBootstrap: Init SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      
      print('AppBootstrap: Init Database...');
      final db = await DatabaseService().database;
      
      print('AppBootstrap: Initialization successful.');

      if (mounted) {
        setState(() {
          _sharedPreferences = prefs;
          _database = db;
          _isInitialized = true;
        });
      }
    } catch (e, stack) {
      print('AppBootstrap Error: $e\n$stack');
      if (mounted) {
        setState(() {
          _error = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If not initialized, show a simple splash/loading screen within a single MaterialApp
    if (!_isInitialized && _error == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Initialization Failed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('$_error', textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _isInitialized = false;
                      });
                      _init();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // IMPORTANT: Return ProviderScope wrapping the actual App only when ready
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(_sharedPreferences!),
        databaseProvider.overrideWithValue(_database!),
      ],
      child: const App(),
    );
  }
}
