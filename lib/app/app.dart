// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';
import 'theme_provider.dart';
import 'locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:days_plus/l10n/app_localizations.dart';
import '../core/ads/ad_manager.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // 첫 실행 시 광고 로드 시도
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdManager.instance.showAppOpenAdIfAvailable(isColdStart: true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('App: [LIFECYCLE] Changed to: $state');
    // 백그라운드에서 복귀할 때 앱 오픈 광고 실행
    if (state == AppLifecycleState.resumed) {
      debugPrint('App: [LIFECYCLE] Resumed - requesting AppOpenAd');
      // UI 렌더링이 전환된 직후 바로 광고 요청 (안정성을 위해 500ms 지연)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          AdManager.instance.showAppOpenAdIfAvailable();
        }
      });
    } else if (state == AppLifecycleState.paused) {
      debugPrint('App: [LIFECYCLE] Paused - app in background');
    } else if (state == AppLifecycleState.inactive) {
      debugPrint('App: [LIFECYCLE] Inactive - transitioning');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
