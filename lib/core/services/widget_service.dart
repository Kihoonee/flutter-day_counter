import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../../features/events/domain/event.dart';
import '../../features/events/presentation/widgets/poster_card.dart'; // To access posterThemes
import '../utils/date_calc.dart';

class WidgetService {
  static const String appGroupId = 'group.com.handroom.daysplus'; 
  static const String androidWidgetName = 'DaysPlusWidget';

  String _colorToHex(dynamic color) {
    if (color is! Color) return 'FFFFFF';
    return color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
  }

  /// Save events list as JSON for native widget configuration
  Future<void> saveEventsList(List<Event> events) async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      
      final eventsJson = events.map((e) {
        final diff = DateCalc.diffDays(
          base: DateTime.now(),
          target: e.targetDate,
          includeToday: e.includeToday,
          excludeWeekends: e.excludeWeekends,
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
        };
      }).toList();
      
      await HomeWidget.saveWidgetData('widget_events_list', jsonEncode(eventsJson));
      print('WIDGET_SERVICE: Saved ${events.length} events for widget selection');
    } catch (e) {
      print('WIDGET_SERVICE: Error saving events list: $e');
    }
  }

  Future<void> updateWidget(Event? event) async {
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
        await HomeWidget.updateWidget(
            name: androidWidgetName, androidName: androidWidgetName, iOSName: androidWidgetName);
        return;
      }

      // Calculate D-Day relative to "Today"
      final now = DateTime.now();
      final diff = DateCalc.diffDays(
        base: now,
        target: event.targetDate,
        includeToday: event.includeToday,
        excludeWeekends: event.excludeWeekends,
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
      
      await HomeWidget.updateWidget(
          name: androidWidgetName, androidName: androidWidgetName, iOSName: androidWidgetName);
      
      print('WIDGET_SERVICE: Update Success: ${event.title}, $dText, $bgColorHex');

    } catch (e) {
      print('WIDGET_SERVICE: Widget update error: $e');
    }
  }
}
