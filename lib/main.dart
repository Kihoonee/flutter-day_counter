import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'core/storage/shared_prefs_provider.dart';

import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 세로 모드 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  print('MAIN: Starting initialization...');
  
  // 1. 필수 로컬 설정만 먼저 초기화
  await initializeDateFormatting();
  final prefs = await SharedPreferences.getInstance();
  print('MAIN: Local prefs loaded.');

  // 2. UI 바로 실행
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const App(),
    ),
  );
  
  // 3. 무거운 서비스는 화면이 뜬 후 백그라운드에서 초기화
  print('MAIN: App rendering started. Initializing external services in background...');
  
  Future.delayed(const Duration(milliseconds: 500), () async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('MAIN: Firebase initialized (Background).');
    } catch (e) {
      print('MAIN: Firebase Initial Error: $e');
    }

    try {
      await MobileAds.instance.initialize();
      print('MAIN: AdMob initialized (Background).');
    } catch (e) {
      print('MAIN: AdMob Initial Error: $e');
    }
  });
}