package com.handroom.daysplus

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Shader
import com.handroom.daysplus.R
import java.io.File
import java.util.Random
import android.util.TypedValue

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
    
    // Get the event ID for this widget instance
    val eventId = widgetData.getString("widget_event_id_$appWidgetId", null)
    
    // Fallback defaults
    var title = "이벤트를 선택하세요"
    var dateStr = ""
    var dday = "-"
    var bgColor = android.graphics.Color.WHITE
    var fgColor = android.graphics.Color.parseColor("#4A4A4A")

    var includeToday = false
    var themeIndex = 0
    
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
                    includeToday = event.optBoolean("includeToday", false)
                    
                    val bgHex = event.getString("bgColor")
                    val fgHex = event.getString("fgColor")
                    bgColor = android.graphics.Color.parseColor("#$bgHex")
                    fgColor = android.graphics.Color.parseColor("#$fgHex")
                    themeIndex = event.optInt("themeIndex", 0)
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
    views.setTextColor(R.id.widget_date, fgColor)

    // Apply Background: Try image first, fallback to native wave, then color tinting
    val bgImagePath = widgetData.getString("widget_bg_image", null)
    var usedImage = false

    // 1. Try loading Image from file (Legacy support)
    if (bgImagePath != null) {
        try {
            val file = File(bgImagePath)
            if (file.exists()) {
                val bitmap = BitmapFactory.decodeFile(bgImagePath)
                if (bitmap != null) {
                    views.setImageViewBitmap(R.id.widget_bg, bitmap)
                    usedImage = true
                }
            }
        } catch (e: Exception) {
            // Error loading file
        }
    }
    
    // 2. If no file, generate Native Wave Pattern (New standard)
    if (!usedImage) {
        try {
            val width = dpToPx(context, 330f).toInt() // Standard widget width
            val height = dpToPx(context, 160f).toInt() // Standard widget height
            
            // themeIndex was extracted above
            val patternBitmap = drawWavePattern(width, height, themeIndex, bgColor)
            views.setImageViewBitmap(R.id.widget_bg, patternBitmap)
            usedImage = true
        } catch (e: Exception) {
            // Fallback to solid color
        }
    }

    if (!usedImage) {
        // Fallback: Apply Background Color (Tinting the shape drawable)
        views.setInt(R.id.widget_bg, "setColorFilter", bgColor)
    }
    
    appWidgetManager.updateAppWidget(appWidgetId, views)
}

// Helper: Convert DP to PX
fun dpToPx(context: Context, dp: Float): Float {
    return TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP,
        dp,
        context.resources.displayMetrics
    )
}

// Native Wave Pattern Generator (Matches iOS/Flutter logic)
fun drawWavePattern(width: Int, height: Int, seed: Int, bgColor: Int): Bitmap {
    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)
    
    // 1. Fill Background
    canvas.drawColor(bgColor)
    
    val random = Random(seed.toLong())
    
    // 2. Draw Wavy Gradient
    val startY = height * (0.4 + random.nextDouble() * 0.2)
    val cp1x = width * (0.25 + random.nextDouble() * 0.1)
    val cp1y = height * (random.nextDouble() * 0.5)
    val cp2x = width * (0.65 + random.nextDouble() * 0.1)
    val cp2y = height * (0.5 + random.nextDouble() * 0.5)
    val endY = height * (0.4 + random.nextDouble() * 0.3)
    
    val wavePath = Path()
    wavePath.moveTo(0f, startY.toFloat())
    wavePath.cubicTo(
        cp1x.toFloat(), cp1y.toFloat(),
        cp2x.toFloat(), cp2y.toFloat(),
        width.toFloat(), endY.toFloat()
    )
    wavePath.lineTo(width.toFloat(), height.toFloat())
    wavePath.lineTo(0f, height.toFloat())
    wavePath.close()
    
    val gradientPaint = Paint().apply {
        isAntiAlias = true
        shader = LinearGradient(
            width / 2f, 0f,
            width / 2f, height.toFloat(),
            Color.argb(25, 255, 255, 255), // White 10%
            Color.argb(128, 255, 255, 255), // White 50%
            Shader.TileMode.CLAMP
        )
    }
    
    canvas.drawPath(wavePath, gradientPaint)
    
    // 3. Draw Droplets
    val dropletRandom = Random(seed.toLong())
    dropletRandom.nextDouble() // Burn
    dropletRandom.nextDouble()
    
    val count = 5 + (seed % 4)
    val dropletPaint = Paint().apply {
        isAntiAlias = true
        style = Paint.Style.FILL
    }
    
    for (i in 0 until count) {
        val dx = dropletRandom.nextDouble() * width
        val dy = height * 0.3 + dropletRandom.nextDouble() * (height * 0.7)
        val radius = 3.0 + dropletRandom.nextDouble() * 6.0
        val opacity = (0.3 + dropletRandom.nextDouble() * 0.3) * 255
        
        dropletPaint.color = Color.argb(opacity.toInt(), 255, 255, 255)
        canvas.drawCircle(dx.toFloat(), dy.toFloat(), radius.toFloat(), dropletPaint)
    }
    
    return bitmap
}
    

