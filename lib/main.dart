import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'core/storage/shared_prefs_provider.dart';
import 'core/ads/ad_manager.dart';

import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 세로 모드 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  debugPrint('MAIN: Starting initialization...');
  
  // 1. 필수 로컬 설정만 먼저 초기화
  await initializeDateFormatting();
  final prefs = await SharedPreferences.getInstance();
  debugPrint('MAIN: Local prefs loaded.');

  // 2. 필수 외부 서비스 초기화 (Firebase는 앱 실행 전 완료 권장)
  debugPrint('MAIN: Initializing Firebase...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('MAIN: Firebase initialized.');
  } catch (e) {
    debugPrint('MAIN: Firebase Initial Error: $e');
  }

  // 3. 광고 서비스 초기화 (비동기로 실행하여 runApp() 차단 방지)
  if (!kIsWeb) {
    debugPrint('MAIN: Initializing AdMob in background...');
    MobileAds.instance.initialize().then((_) async {
      debugPrint('MAIN: AdMob initialized in background.');
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: ['0D590785-B970-43D0-BE1F-368862470165', 'emulator-5554']),
      );
      AdManager.instance.loadAppOpenAd();
      AdManager.instance.loadInterstitialAd();
    }).catchError((e) {
      debugPrint('MAIN: AdMob Background Error: $e');
    });
  }

  // 4. UI 실행
  debugPrint('MAIN: Calling runApp()...');
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const App(),
    ),
  );
}