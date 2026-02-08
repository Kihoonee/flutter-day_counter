import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/events/domain/event.dart';
import '../../features/events/presentation/widgets/poster_card.dart'; // To access posterThemes
import '../utils/date_calc.dart';
import 'widget_background_generator.dart';

class WidgetService {
  static const String appGroupId = 'group.com.handroom.daysplus'; 
  static const String androidWidgetName = 'DaysPlusWidget';
  static const String androidSimpleWidgetName = 'DaysPlusSimpleWidget';

  String _colorToHex(dynamic color) {
    if (color is! Color) return 'FFFFFF';
    return color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
  }
  /// Save events list as JSON for native widget configuration
  /// Android widgets read from this list and find their selected event by ID
  Future<void> saveEventsList(List<Event> events) async {
    if (kIsWeb) return;
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      
      final eventsJson = events.map((e) {
        final diff = DateCalc.diffDays(
          base: DateTime.now(),
          target: e.targetDate,
          includeToday: e.includeToday,
        );
        String dText;
        if (diff == 0) {
          dText = 'D-Day';
        } else if (diff > 0) {
          dText = 'D-$diff';
        } else {
          dText = 'D+${diff.abs()}';
        }
        
        final pTheme = posterThemes[e.themeIndex % posterThemes.length];
        return {
          'id': e.id,
          'title': e.title,
          'date': '${e.targetDate.year}.${e.targetDate.month.toString().padLeft(2, '0')}.${e.targetDate.day.toString().padLeft(2, '0')}',
          'dday': dText,
          'bgColor': _colorToHex(pTheme.bg),
          'fgColor': '4A4A4A',
          'layoutType': e.widgetLayoutType,
          'includeToday': e.includeToday,
          'themeIndex': e.themeIndex, // Native widgets use this to render gradient patterns
        };
      }).toList();
      
      await HomeWidget.saveWidgetData('widget_events_list', jsonEncode(eventsJson));
      
      // Force widget reload to reflect changes immediately
      await HomeWidget.updateWidget(
          name: androidWidgetName, androidName: androidWidgetName, iOSName: androidWidgetName);
      await HomeWidget.updateWidget(
          name: androidSimpleWidgetName, androidName: androidSimpleWidgetName, iOSName: androidWidgetName);
      
      print('WIDGET_SERVICE: Saved ${events.length} events');
    } catch (e) {
      print('WIDGET_SERVICE: Error saving events list: $e');
    }
  }

  Future<void> updateWidget(Event? event) async {
    if (kIsWeb) return;
    try {
      // iOS App Group Setting
      try {
        await HomeWidget.setAppGroupId(appGroupId);
      } catch (e) {
        print('WIDGET_SERVICE: Error setting AppGroupId (iOS only): $e');
      }

      if (event == null) {
        await HomeWidget.saveWidgetData('widget_title', '이벤트를 등록해주세요');
        await HomeWidget.saveWidgetData('widget_date', '');
        await HomeWidget.saveWidgetData('widget_dday', '');
        await HomeWidget.saveWidgetData('widget_bg_color', 'FFFFFF');
        await HomeWidget.saveWidgetData('widget_fg_color', '000000');
        await HomeWidget.saveWidgetData('widget_layout_type', 0);
        await HomeWidget.saveWidgetData('widget_include_today', false);
        await HomeWidget.updateWidget(
            name: androidWidgetName, androidName: androidWidgetName, iOSName: androidWidgetName);
        await HomeWidget.updateWidget(
            name: androidSimpleWidgetName, androidName: androidSimpleWidgetName, iOSName: androidWidgetName);
        return;
      }

      // Calculate D-Day relative to "Today"
      final now = DateTime.now();
      final diff = DateCalc.diffDays(
        base: now,
        target: event.targetDate,
        includeToday: event.includeToday,
      );

      String dText;
      if (diff == 0) {
        dText = 'D-Day';
      } else if (diff > 0) {
        dText = 'D-$diff';
      } else {
        dText = 'D+${diff.abs()}';
      }

      // Get Theme Colors
      final pTheme = posterThemes[event.themeIndex % posterThemes.length];
      final bgColorHex = _colorToHex(pTheme.bg);
      // UI Refinement v2/v3: Unified Softer Gray (4A4A4A) to match PosterCard
      const fgColorHex = '4A4A4A'; 

      // Save Data (Keys must match native implementation)
      await HomeWidget.saveWidgetData('widget_title', event.title);
      await HomeWidget.saveWidgetData('widget_date', '${event.targetDate.year}.${event.targetDate.month.toString().padLeft(2, '0')}.${event.targetDate.day.toString().padLeft(2, '0')}');
      await HomeWidget.saveWidgetData('widget_dday', dText);
      await HomeWidget.saveWidgetData('widget_bg_color', bgColorHex);
      await HomeWidget.saveWidgetData('widget_fg_color', fgColorHex);
      await HomeWidget.saveWidgetData('widget_layout_type', event.widgetLayoutType);
      await HomeWidget.saveWidgetData('widget_include_today', event.includeToday);
      
      // Generate background image (Phase 2: Image Background)
      final imagePath = await _generateAndSaveBackground(
        themeIndex: event.themeIndex,
        eventId: event.id,
      );
      if (imagePath != null) {
        await HomeWidget.saveWidgetData('widget_bg_image', imagePath);
      }
      
      await HomeWidget.updateWidget(
          name: androidWidgetName, androidName: androidWidgetName, iOSName: androidWidgetName);
      await HomeWidget.updateWidget(
          name: androidSimpleWidgetName, androidName: androidSimpleWidgetName, iOSName: androidWidgetName);
      
      print('WIDGET_SERVICE: Update Success: ${event.title}, $dText, $bgColorHex, image: $imagePath');

    } catch (e) {
      print('WIDGET_SERVICE: Widget update error: $e');
    }
  }

  /// Generates and saves a background image for a widget
  Future<String?> _generateAndSaveBackground({
    required int themeIndex,
    required String eventId,
  }) async {
    try {
      // Use the generator to create an image
      final imagePath = await WidgetBackgroundGenerator.generateBackground(
        themeIndex: themeIndex,
        size: const Size(400, 200), // Widget size (will be scaled)
        eventId: eventId,
      );
      return imagePath;
    } catch (e) {
      print('WIDGET_SERVICE: Error generating background: $e');
      return null;
    }
  }
}
