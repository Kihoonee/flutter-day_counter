package com.handroom.daysplus

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.content.SharedPreferences
import android.graphics.Color
import com.handroom.daysplus.R

class DaysPlusWidget : AppWidgetProvider() {
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

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val widgetData: SharedPreferences = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
    val title = widgetData.getString("widget_title", "이벤트 없음")
    val dday = widgetData.getString("widget_dday", "-")
    val date = widgetData.getString("widget_date", "")
    val layoutType = widgetData.getInt("widget_layout_type", 0) // 0: D-Day 강조, 1: 타이틀 강조
    
    // Default colors (White BG, Black FG)
    val defaultBg = "#FFFFFF"
    val defaultFg = "#000000"
    
    val bgString = widgetData.getString("widget_bg_color", defaultBg) ?: defaultBg
    val fgString = widgetData.getString("widget_fg_color", defaultFg) ?: defaultFg
    
    // Parse Colors
    var bgColor = Color.parseColor(defaultBg)
    var fgColor = Color.parseColor(defaultFg)
    
    try {
        bgColor = Color.parseColor(if (bgString.startsWith("#")) bgString else "#$bgString")
        fgColor = Color.parseColor(if (fgString.startsWith("#")) fgString else "#$fgString")
    } catch (e: Exception) {
        // Fallback to defaults on error
    }

    // Always use D-Day emphasis layout
    val layoutId = R.layout.widget_layout

    // Construct the RemoteViews object
    val views = RemoteViews(context.packageName, layoutId)
    views.setTextViewText(R.id.widget_title, title)
    views.setTextViewText(R.id.widget_dday, dday)
    views.setTextViewText(R.id.widget_date, date)
    
    // Apply Foreground Colors
    views.setTextColor(R.id.widget_title, fgColor)
    views.setTextColor(R.id.widget_dday, fgColor)
    // Date is slightly transparent (80% opacity of fgColor)
    val dateColor = Color.argb(255, Color.red(fgColor), Color.green(fgColor), Color.blue(fgColor))
    views.setTextColor(R.id.widget_date, dateColor)

    // Apply Background Color (Tinting the shape drawable)
    views.setInt(R.id.widget_bg, "setColorFilter", bgColor)

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}
