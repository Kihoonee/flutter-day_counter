import 'package:home_widget/home_widget.dart';
import '../../features/events/domain/event.dart';

class WidgetService {
  static const String appGroupId = 'group.day_counter'; 
  static const String androidWidgetName = 'DayCounterWidget';

  Future<void> updateWidget(Event? event) async {
    try {
      if (event == null) {
        await HomeWidget.saveWidgetData('event_title', '이벤트를 등록해주세요');
        await HomeWidget.saveWidgetData('event_date', '');
        await HomeWidget.saveWidgetData('d_day', '');
      } else {
        await HomeWidget.saveWidgetData('event_title', event.title);
        await HomeWidget.saveWidgetData('event_date', 
          '${event.targetDate.year}.${event.targetDate.month}.${event.targetDate.day}');
        
        final diff = event.targetDate.difference(DateTime.now()).inDays;

        String dDayText;
        if (diff == 0) {
          dDayText = 'D-Day';
        } else if (diff > 0) {
          dDayText = 'D-${diff + 1}';
        } else {
          dDayText = 'D+${diff.abs()}';
        }
        await HomeWidget.saveWidgetData('d_day', dDayText);
      }

      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: 'DayCounterWidget',
      );
      print('WIDGET_SERVICE: Widget updated successfully.');
    } catch (e) {
      print('WIDGET_SERVICE: Widget update error: $e');
    }
  }
}

