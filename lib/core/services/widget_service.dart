import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../../features/events/domain/event.dart';
import '../../features/events/presentation/widgets/poster_card.dart'; // To access posterThemes
import '../utils/date_calc.dart';

class WidgetService {
  static const String appGroupId = 'group.com.kihoonee.daycounterv2'; 
  static const String androidWidgetName = 'DayCounterWidget';

  String _colorToHex(dynamic color) {
    if (color is! Color) return 'FFFFFF';
    return color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
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
      
      await HomeWidget.updateWidget(
          name: androidWidgetName, androidName: androidWidgetName, iOSName: androidWidgetName);
      
      print('WIDGET_SERVICE: Update Success: ${event.title}, $dText, $bgColorHex');

    } catch (e) {
      print('WIDGET_SERVICE: Widget update error: $e');
    }
  }
}
