import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:days_plus/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:days_plus/core/storage/shared_prefs_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Days+',
      packageName: 'com.example.days_plus',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const App(),
      ),
    );
    
    // Use pump instead of pumpAndSettle to avoid timeout from persistent animations (like ads)
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1)); // One more to ensure everything is resolved

    // Verify that our app shows the 'Days+' title.
    // It might find two: one in AppBar and one in BannerAdWidget placeholder.
    expect(find.text('Days+'), findsWidgets);
  });
}
    