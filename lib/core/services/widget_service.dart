import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../utils/date_calc.dart';
import '../../features/events/domain/event.dart';
import '../../features/events/presentation/widgets/poster_card.dart';

class WidgetService {
  static const String appGroupId = 'group.day_counter'; 
  static const String androidWidgetName = 'DayCounterWidget';

  Future<void> updateWidget(Event? event) async {
    // iOS App Group 설정
    await HomeWidget.setAppGroupId(appGroupId);

    if (event == null) {
      await HomeWidget.saveWidgetData<String>('widget_title', '이벤트를 추가하세요.');
      await HomeWidget.saveWidgetData<String>('widget_dday', '');
      await HomeWidget.saveWidgetData<String>('widget_date', '');
    } else {
      final diff = DateCalc.diffDays(
        base: DateTime.now(),
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

      // 테마 색상 추출 및 저장
      final theme = posterThemes[event.themeIndex % posterThemes.length];
      // 0xFF... -> #...
      String toHex(Color c) => '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}'; 
      
      await HomeWidget.saveWidgetData<String>('widget_title', event.title);
      await HomeWidget.saveWidgetData<String>('widget_dday', dText);
      await HomeWidget.saveWidgetData<String>('widget_date', DateFormat('yyyy.MM.dd').format(event.targetDate));
      await HomeWidget.saveWidgetData<String>('widget_bg_color', toHex(theme.bg));
      await HomeWidget.saveWidgetData<String>('widget_fg_color', toHex(theme.fg));
    }

    await HomeWidget.updateWidget(
      name: androidWidgetName,
      iOSName: 'DayCounterWidget', // Must match the Kind in iOS Widget
    );
  }
}
