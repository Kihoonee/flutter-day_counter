import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day_counter/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:day_counter/core/storage/shared_prefs_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
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
        await tester.pumpAndSettle();
    
        // Verify that our app shows the 'DayCounter' title.
        expect(find.text('DayCounter'), findsOneWidget);
        
        // Verify that we have a view agenda button (Events).
        expect(find.byIcon(Icons.view_agenda_rounded), findsOneWidget);
      });
    }
    