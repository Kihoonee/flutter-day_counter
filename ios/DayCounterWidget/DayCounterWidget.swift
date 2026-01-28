//
//  DayCounterWidget.swift
//  DayCounterWidget
//
//  Created by Kihoonee Bang on 1/25/26.
//

import WidgetKit
import SwiftUI

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
    static let appGroupId = "group.day_counter"
    
    static func getData() -> (title: String, dDay: String, targetDate: String, bgColor: String, fgColor: String) {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let title = userDefaults?.string(forKey: "widget_title") ?? "Days+"
        let dDay = userDefaults?.string(forKey: "widget_dday") ?? "D-day"
        let targetDate = userDefaults?.string(forKey: "widget_date") ?? ""
        let bgColor = userDefaults?.string(forKey: "widget_bg_color") ?? "FFFFFF" // Default White
        let fgColor = userDefaults?.string(forKey: "widget_fg_color") ?? "000000" // Default Black
        return (title, dDay, targetDate, bgColor, fgColor)
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "Days+", dDay: "D-Day", targetDate: "2026.01.01", bgColor: "FFCDD2", fgColor: "5D1010")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let data = DataStorage.getData()
        let entry = SimpleEntry(date: Date(), title: data.title, dDay: data.dDay, targetDate: data.targetDate, bgColor: data.bgColor, fgColor: data.fgColor)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let data = DataStorage.getData()
        let entry = SimpleEntry(date: Date(), title: data.title, dDay: data.dDay, targetDate: data.targetDate, bgColor: data.bgColor, fgColor: data.fgColor)
        
        // 15분마다 갱신
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let dDay: String
    let targetDate: String
    let bgColor: String
    let fgColor: String
}

struct DayCounterWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // 배경색
            Color(hex: entry.bgColor)
            
            // PosterCard 디자인
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.title)
                            .font(.system(size: 16, weight: .bold)) // Title
                            .foregroundColor(Color(hex: entry.fgColor))
                            .lineLimit(1)
                        
                        Text(entry.targetDate)
                            .font(.system(size: 11, weight: .medium)) // Date
                            .foregroundColor(Color(hex: entry.fgColor).opacity(0.8))
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                // D-Day (우측 하단)
                HStack {
                    Spacer()
                    Text(entry.dDay)
                        .font(.system(size: 34, weight: .heavy, design: .rounded)) // 큰 글씨
                        .foregroundColor(Color(hex: entry.fgColor))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
            }
            .padding(16)
        }
        .containerBackground(for: .widget) {
             // iOS 17 이상에서 위젯 배경 처리
             Color(hex: entry.bgColor)
        }
    }
}

struct DayCounterWidget: Widget {
    let kind: String = "DayCounterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DayCounterWidgetEntryView(entry: entry)
                    // containerBackground는 EntryView 내부에서 처리함 (iOS 17+)
            } else {
                DayCounterWidgetEntryView(entry: entry)
                    // iOS 16 이하용 배경 설정은 ZStack Color로 충분함
            }
        }
        .configurationDisplayName("디데이")
        .description("이벤트를 홈 화면에서 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium]) // Small, Medium 지원
        .contentMarginsDisabled() // 중요: 여백 제거하여 배경 꽉 채우기
    }
}

#Preview(as: .systemSmall) {
    DayCounterWidget()
} timeline: {
    SimpleEntry(date: .now, title: "여행", dDay: "D-5", targetDate: "2026.05.05", bgColor: "FFCDD2", fgColor: "5D1010")
}

#Preview(as: .systemMedium) {
    DayCounterWidget()
} timeline: {
    SimpleEntry(date: .now, title: "기념일", dDay: "D+100", targetDate: "2025.12.25", bgColor: "B2DFDB", fgColor: "004D40")
}
