//
//  DaysPlusWidget.swift
//  DaysPlusWidget
//
//  Created by Kihoonee Bang on 1/25/26.
//

import WidgetKit
import SwiftUI
import AppIntents

// Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 1, 1, 1)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// UserDefaults Helper
struct DataStorage {
    static let appGroupId = "group.com.handroom.daysplus"
    
    static func getData() -> (title: String, dDay: String, targetDate: String, bgColor: String, fgColor: String, layoutType: Int) {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let title = userDefaults?.string(forKey: "widget_title") ?? "Days+"
        let dDay = userDefaults?.string(forKey: "widget_dday") ?? "D-day"
        let targetDate = userDefaults?.string(forKey: "widget_date") ?? ""
        let bgColor = userDefaults?.string(forKey: "widget_bg_color") ?? "FFFFFF"
        let fgColor = userDefaults?.string(forKey: "widget_fg_color") ?? "000000"
        let layoutType = userDefaults?.integer(forKey: "widget_layout_type") ?? 0
        return (title, dDay, targetDate, bgColor, fgColor, layoutType)
    }
    
    static func getDataForEvent(_ event: EventEntity?) -> (title: String, dDay: String, targetDate: String, bgColor: String, fgColor: String, layoutType: Int) {
        if let event = event {
            return (event.title, event.dDay, event.date, event.bgColor, event.fgColor, event.layoutType)
        }
        return getData()
    }
}

// Timeline Provider with Intent
struct IntentProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "Days+", dDay: "D-Day", targetDate: "2026.01.01", bgColor: "FFCDD2", fgColor: "5D1010", layoutType: 0)
    }

    func snapshot(for configuration: SelectEventIntent, in context: Context) async -> SimpleEntry {
        let data = DataStorage.getDataForEvent(configuration.selectedEvent)
        return SimpleEntry(date: Date(), title: data.title, dDay: data.dDay, targetDate: data.targetDate, bgColor: data.bgColor, fgColor: data.fgColor, layoutType: data.layoutType)
    }

    func timeline(for configuration: SelectEventIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let data = DataStorage.getDataForEvent(configuration.selectedEvent)
        let entry = SimpleEntry(date: Date(), title: data.title, dDay: data.dDay, targetDate: data.targetDate, bgColor: data.bgColor, fgColor: data.fgColor, layoutType: data.layoutType)
        
        // 15분마다 갱신
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let dDay: String
    let targetDate: String
    let bgColor: String
    let fgColor: String
    let layoutType: Int // 0: D-Day 강조, 1: 타이틀 강조
}

struct DaysPlusWidgetEntryView : View {
    var entry: SimpleEntry

    var body: some View {
        ZStack {
            Color(hex: entry.bgColor)
            ddayEmphasisLayout // Always use D-Day layout
        }
        .containerBackground(for: .widget) {
            Color(hex: entry.bgColor).opacity(0.8)
        }
    }
    
    // Layout 0: D-Day 강조 (기존 레이아웃)
    var ddayEmphasisLayout: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: entry.fgColor))
                        .lineLimit(1)
                    
                    Text(entry.targetDate)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: entry.fgColor))
                }
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Text(entry.dDay)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(hex: entry.fgColor))
                    .lineLimit(1)
            }
        }
        .padding(16)
    }
    
    // Layout 1: 타이틀 강조
    var titleEmphasisLayout: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 큰 타이틀
            Text(entry.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: entry.fgColor))
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            
            Spacer()
            
            // 하단: 목표일 + D-Day
            HStack {
                Text(entry.targetDate)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: entry.fgColor))
                
                Spacer()
                
                Text(entry.dDay)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: entry.fgColor))
            }
        }
        .padding(16)
    }
}

struct DaysPlusWidget: Widget {
    let kind: String = "DaysPlusWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectEventIntent.self, provider: IntentProvider()) { entry in
            DaysPlusWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("디데이")
        .description("이벤트를 홈 화면에서 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemSmall) {
    DaysPlusWidget()
} timeline: {
    SimpleEntry(date: .now, title: "여행", dDay: "D-5", targetDate: "2026.05.05", bgColor: "FFCDD2", fgColor: "5D1010", layoutType: 0)
}

#Preview(as: .systemMedium) {
    DaysPlusWidget()
} timeline: {
    SimpleEntry(date: .now, title: "기념일", dDay: "D+100", targetDate: "2025.12.25", bgColor: "B2DFDB", fgColor: "004D40", layoutType: 1)
}
