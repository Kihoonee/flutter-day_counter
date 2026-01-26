import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'core/storage/shared_prefs_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('MAIN: Starting initialization...');
  
  // 로케일 초기화
  await initializeDateFormatting();

  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('MAIN: Firebase initialized.');
  } catch (e) {
    print('MAIN: Firebase Initial Error: $e');
  }

  // AdMob 초기화
  try {
    await MobileAds.instance.initialize();
    print('MAIN: AdMob initialized.');
  } catch (e) {
    print('MAIN: AdMob Initial Error: $e');
  }

  // 설정값 로드
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const App(),
    ),
  );
  
  print('MAIN: App Launched with Services.');
}