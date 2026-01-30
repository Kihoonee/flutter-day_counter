package com.handroom.daysplus

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import android.graphics.Color
import android.view.Gravity
import android.widget.Toast
import org.json.JSONArray

class DaysPlusWidgetConfigureActivity : Activity() {
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Set result to canceled in case the user backs out
        setResult(RESULT_CANCELED)
        
        // Get the widget ID from the intent
        val intent = intent
        val extras = intent.extras
        if (extras != null) {
            appWidgetId = extras.getInt(
                AppWidgetManager.EXTRA_APPWIDGET_ID, 
                AppWidgetManager.INVALID_APPWIDGET_ID
            )
        }
        
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }
        
        // Build UI programmatically
        val scrollView = ScrollView(this)
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(32, 48, 32, 32)
        }
        
        // Title
        val titleView = TextView(this).apply {
            text = "표시할 이벤트 선택"
            textSize = 24f
            setTextColor(Color.BLACK)
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 32)
        }
        layout.addView(titleView)
        
        // Load events from SharedPreferences
        val prefs = getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val eventsJson = prefs.getString("widget_events_list", "[]") ?: "[]"
        
        try {
            val events = JSONArray(eventsJson)
            
            if (events.length() == 0) {
                val emptyView = TextView(this).apply {
                    text = "등록된 이벤트가 없습니다.\n앱에서 먼저 이벤트를 등록해주세요."
                    textSize = 16f
                    setTextColor(Color.GRAY)
                    gravity = Gravity.CENTER
                    setPadding(0, 64, 0, 0)
                }
                layout.addView(emptyView)
            } else {
                for (i in 0 until events.length()) {
                    val event = events.getJSONObject(i)
                    val eventId = event.getString("id")
                    val title = event.getString("title")
                    val dday = event.getString("dday")
                    val date = event.getString("date")
                    val bgColor = event.getString("bgColor")
                    val fgColor = event.getString("fgColor")
                    val layoutType = event.getInt("layoutType")
                    
                    val itemView = LinearLayout(this).apply {
                        orientation = LinearLayout.VERTICAL
                        setPadding(32, 24, 32, 24)
                        setBackgroundColor(Color.parseColor("#$bgColor"))
                        
                        val params = LinearLayout.LayoutParams(
                            LinearLayout.LayoutParams.MATCH_PARENT,
                            LinearLayout.LayoutParams.WRAP_CONTENT
                        )
                        params.setMargins(0, 0, 0, 16)
                        layoutParams = params
                    }
                    
                    val titleText = TextView(this).apply {
                        text = title
                        textSize = 18f
                        setTextColor(Color.parseColor("#$fgColor"))
                    }
                    itemView.addView(titleText)
                    
                    val infoText = TextView(this).apply {
                        text = "$date  |  $dday"
                        textSize = 14f
                        setTextColor(Color.parseColor("#$fgColor"))
                        alpha = 0.8f
                    }
                    itemView.addView(infoText)
                    
                    itemView.setOnClickListener {
                        // Save selected event for this widget
                        saveSelectedEvent(eventId, title, dday, date, bgColor, fgColor, layoutType)
                    }
                    
                    layout.addView(itemView)
                }
            }
        } catch (e: Exception) {
            Toast.makeText(this, "이벤트 목록 로드 실패", Toast.LENGTH_SHORT).show()
        }
        
        scrollView.addView(layout)
        setContentView(scrollView)
    }
    
    private fun saveSelectedEvent(
        eventId: String,
        title: String,
        dday: String,
        date: String,
        bgColor: String,
        fgColor: String,
        layoutType: Int
    ) {
        val prefs = getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        prefs.edit().apply {
            putString("widget_selected_event_id", eventId)
            putString("widget_title", title)
            putString("widget_dday", dday)
            putString("widget_date", date)
            putString("widget_bg_color", bgColor)
            putString("widget_fg_color", fgColor)
            putInt("widget_layout_type", layoutType)
            apply()
        }
        
        // Update the widget
        val appWidgetManager = AppWidgetManager.getInstance(this)
        updateAppWidget(this, appWidgetManager, appWidgetId)
        
        // Return success
        val resultValue = Intent()
        resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        setResult(RESULT_OK, resultValue)
        finish()
    }
}
