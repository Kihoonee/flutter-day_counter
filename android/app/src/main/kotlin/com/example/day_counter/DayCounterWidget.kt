package com.example.day_counter

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.content.SharedPreferences
import com.example.day_counter.R

class DayCounterWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

import android.graphics.Color
// ...

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val widgetData: SharedPreferences = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
    val title = widgetData.getString("widget_title", "이벤트 없음")
    val dday = widgetData.getString("widget_dday", "-")
    val date = widgetData.getString("widget_date", "")
    
    // Default colors (White BG, Black FG)
    val defaultBg = "#FFFFFF"
    val defaultFg = "#000000"
    
    val bgString = widgetData.getString("widget_bg_color", defaultBg) ?: defaultBg
    val fgString = widgetData.getString("widget_fg_color", defaultFg) ?: defaultFg
    
    // Parse Colors
    var bgColor = Color.parseColor(defaultBg)
    var fgColor = Color.parseColor(defaultFg)
    
    try {
        bgColor = Color.parseColor(bgString)
        fgColor = Color.parseColor(fgString)
    } catch (e: Exception) {
        // Fallback to defaults on error
    }

    // Construct the RemoteViews object
    val views = RemoteViews(context.packageName, R.layout.widget_layout)
    views.setTextViewText(R.id.widget_title, title)
    views.setTextViewText(R.id.widget_dday, dday)
    views.setTextViewText(R.id.widget_date, date)
    
    // Apply Foreground Colors
    views.setTextColor(R.id.widget_title, fgColor)
    views.setTextColor(R.id.widget_dday, fgColor)
    // Date is slightly transparent (80% opacity of fgColor)
    val dateColor = Color.argb(204, Color.red(fgColor), Color.green(fgColor), Color.blue(fgColor))
    views.setTextColor(R.id.widget_date, dateColor)

    // Apply Background Color (Tinting the shape drawable)
    views.setInt(R.id.widget_bg, "setColorFilter", bgColor)

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}
