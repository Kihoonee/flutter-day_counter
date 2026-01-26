import '../../features/events/domain/event.dart';

class WidgetService {
  static const String appGroupId = 'group.day_counter'; 
  
  Future<void> updateWidget(Event? event) async {
    print('WIDGET_SERVICE: Disabled for debugging.');
    return;
  }
}
