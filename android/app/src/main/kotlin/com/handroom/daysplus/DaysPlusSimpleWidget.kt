package com.handroom.daysplus

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.content.SharedPreferences
import android.graphics.Color
import com.handroom.daysplus.R

class DaysPlusSimpleWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppSimpleWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

internal fun updateAppSimpleWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val widgetData: SharedPreferences = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
    
    // Get the event ID for this widget instance
    val eventId = widgetData.getString("widget_event_id_$appWidgetId", null)
    
    // Fallback defaults
    var title = "이벤트를 선택하세요"
    var dateStr = ""
    var dday = "-"
    var fgColor = android.graphics.Color.WHITE // Default to White for simple widget
    
    // If this widget has an event ID, find it in the events list
    if (eventId != null) {
        val eventsListJson = widgetData.getString("widget_events_list", "[]") ?: "[]"
        try {
            val eventsArray = org.json.JSONArray(eventsListJson)
            for (i in 0 until eventsArray.length()) {
                val event = eventsArray.getJSONObject(i)
                if (event.getString("id") == eventId) {
                    title = event.getString("title")
                    dateStr = event.getString("date")
                    dday = event.getString("dday")
                    
                    val fgHex = event.getString("fgColor")
                    fgColor = android.graphics.Color.parseColor("#$fgHex")
                    break
                }
            }
        } catch (e: Exception) {
            // Fallback to per-widget stored data if JSON parsing fails
            title = widgetData.getString("widget_title_$appWidgetId", "이벤트 없음") ?: "이벤트 없음"
            dateStr = widgetData.getString("widget_date_$appWidgetId", "") ?: ""
            dday = widgetData.getString("widget_dday_$appWidgetId", "-") ?: "-"
        }
    }

    // Use Simple Layout
    val layoutId = R.layout.widget_layout_simple

    // Construct the RemoteViews object
    val views = RemoteViews(context.packageName, layoutId)
    views.setTextViewText(R.id.widget_title, title)
    views.setTextViewText(R.id.widget_dday, dday)
    views.setTextViewText(R.id.widget_date, dateStr)
    
    // Apply Foreground Colors
    views.setTextColor(R.id.widget_title, fgColor)
    views.setTextColor(R.id.widget_dday, fgColor)
    views.setTextColor(R.id.widget_date, fgColor)

    // No background color application for Simple Widget (it's transparent)

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}
