import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'app/app.dart';
import 'core/storage/shared_prefs_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('MAIN: Starting initialization (MINIMAL MODE)...');
  
  await initializeDateFormatting();
  final prefs = await SharedPreferences.getInstance();
  print('MAIN: Local prefs loaded.');

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const App(),
    ),
  );
  
  print('MAIN: Minimal App Launched. External services REMOVED.');
}