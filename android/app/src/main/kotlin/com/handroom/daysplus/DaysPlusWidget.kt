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
    val dateStr = widgetData.getString("widget_date", "")
    val includeToday = widgetData.getBoolean("widget_include_today", false)
    val excludeWeekends = widgetData.getBoolean("widget_exclude_weekends", false)
    
    // Dynamic D-Day Calculation
    var dday = "D-Day"
    if (!dateStr.isNullOrEmpty()) {
        try {
            val sdf = java.text.SimpleDateFormat("yyyy.MM.dd", java.util.Locale.getDefault())
            val targetDate = sdf.parse(dateStr)
            
            if (targetDate != null) {
                val todayCal = java.util.Calendar.getInstance()
                // Reset time to midnight for accurate day diff
                todayCal.set(java.util.Calendar.HOUR_OF_DAY, 0)
                todayCal.set(java.util.Calendar.MINUTE, 0)
                todayCal.set(java.util.Calendar.SECOND, 0)
                todayCal.set(java.util.Calendar.MILLISECOND, 0)
                
                val targetCal = java.util.Calendar.getInstance()
                targetCal.time = targetDate
                targetCal.set(java.util.Calendar.HOUR_OF_DAY, 0)
                targetCal.set(java.util.Calendar.MINUTE, 0)
                targetCal.set(java.util.Calendar.SECOND, 0)
                targetCal.set(java.util.Calendar.MILLISECOND, 0)
                
                val diffMillis = targetCal.timeInMillis - todayCal.timeInMillis
                val diffDays = diffMillis / (24 * 60 * 60 * 1000)
                
                // Include Today Logic (Simple approximation matching iOS/Dart)
                // If includeToday is true, we count "days" including today. 
                // Usually affects Past/Today counts => D+1 instead of D-Day.
                
                if (diffDays == 0L) {
                    dday = if (includeToday) "D+1" else "D-Day"
                } else if (diffDays > 0) {
                    dday = "D-$diffDays"
                } else {
                    val absDiff = Math.abs(diffDays)
                    val plusDay = if (includeToday) absDiff + 1 else absDiff
                    dday = "D+$plusDay"
                }
            }
        } catch (e: Exception) {
            dday = widgetData.getString("widget_dday", "-") ?: "-"
        }
    } else {
        dday = widgetData.getString("widget_dday", "-") ?: "-"
    }

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
    views.setTextViewText(R.id.widget_date, dateStr)
    
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
