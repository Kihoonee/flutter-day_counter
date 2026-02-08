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
    
    static func getData() -> (title: String, dDay: String, targetDate: String, bgColor: String, fgColor: String, layoutType: Int, includeToday: Bool, excludeWeekends: Bool, themeIndex: Int) {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let title = userDefaults?.string(forKey: "widget_title") ?? "Days+"
        // dDay from defaults is ignored for calculation but kept as fallback
        let dDay = userDefaults?.string(forKey: "widget_dday") ?? "D-day"
        let targetDate = userDefaults?.string(forKey: "widget_date") ?? ""
        let bgColor = userDefaults?.string(forKey: "widget_bg_color") ?? "FFFFFF"
        let fgColor = userDefaults?.string(forKey: "widget_fg_color") ?? "000000"
        let layoutType = userDefaults?.integer(forKey: "widget_layout_type") ?? 0
        let includeToday = userDefaults?.bool(forKey: "widget_include_today") ?? false
        let excludeWeekends = userDefaults?.bool(forKey: "widget_exclude_weekends") ?? false
        // Fetch themeIndex for native wave rendering
        let themeIndex = userDefaults?.integer(forKey: "widget_theme_index") ?? 0
        
        return (title, dDay, targetDate, bgColor, fgColor, layoutType, includeToday, excludeWeekends, themeIndex)
    }
    
    static func getDataForEvent(_ event: EventEntity?) -> (title: String, dDay: String, targetDate: String, bgColor: String, fgColor: String, layoutType: Int, includeToday: Bool, excludeWeekends: Bool, themeIndex: Int) {
        // If event is provided (via Intent), try to fetch the LATEST data for this ID from UserDefaults list
        if let event = event {
            if let freshEvent = fetchEventById(event.id) {
                return (freshEvent.title, freshEvent.dDay, freshEvent.date, freshEvent.bgColor, freshEvent.fgColor, freshEvent.layoutType, freshEvent.includeToday, freshEvent.excludeWeekends, freshEvent.themeIndex)  
            }
            // Fallback to the Intent's snapshot data if not found in current list (maybe deleted?)
            return (event.title, event.dDay, event.date, event.bgColor, event.fgColor, event.layoutType, event.includeToday, event.excludeWeekends, event.themeIndex)
        }
        return getData()
    }
    
    private static func fetchEventById(_ id: String) -> EventEntity? {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        guard let jsonString = userDefaults?.string(forKey: "widget_events_list"),
              let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        
        guard let jsonArray = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            return nil
        }
        
        // Find matching item
        if let dict = jsonArray.first(where: { ($0["id"] as? String) == id }) {
             guard let id = dict["id"] as? String,
                  let title = dict["title"] as? String,
                  let dDay = dict["dday"] as? String,
                  let date = dict["date"] as? String,
                  let bgColor = dict["bgColor"] as? String,
                  let fgColor = dict["fgColor"] as? String,
                  let layoutType = dict["layoutType"] as? Int else {
                return nil
            }
            let includeToday = dict["includeToday"] as? Bool ?? false
            let excludeWeekends = dict["excludeWeekends"] as? Bool ?? false
            // Extract themeIndex
            let themeIndex = dict["themeIndex"] as? Int ?? 0
            
            return EventEntity(id: id, title: title, dDay: dDay, date: date, bgColor: bgColor, fgColor: fgColor, layoutType: layoutType, includeToday: includeToday, excludeWeekends: excludeWeekends, themeIndex: themeIndex)
        }
        return nil
    }
}

// Date Calculator
struct DateCalculator {
    static func calculateDDay(targetDateStr: String, includeToday: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.timeZone = TimeZone.current
        
        guard let targetDate = formatter.date(from: targetDateStr) else {
            return "D-Day"
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: targetDate)
        
        let components = calendar.dateComponents([.day], from: today, to: target)
        
        guard let diff = components.day else { return "D-Day" }
        
        // Include Today Logic: Usually adds 1 for "counting days" (Positive count),
        // but for D-Day (Negative count), standard logic usually applies.
        // If includeToday is true, and it's a "D+" count (Past), we usually add 1.
        // If it's Future (D-), includeToday doesn't typically change standard D-Day.
        // However, aiming to match Dart's logic roughly:
        // Dart: diffDays handles logic. Simple Swift approximation:
        
        var adjust = 0
        if includeToday && diff <= 0 { // Only affect past/today counts usually
            adjust = 1 // e.g., D+1 instead of D-Day if today
        }
        // NOTE: "excludeWeekends" is complex to implement in Widget without heavy calendar logic.
        // Ignoring excludeWeekends for Widget for now to ensure stability.
        
        let finalDiff = diff
        
        if finalDiff == 0 {
            return includeToday ? "D+1" : "D-Day"
        } else if finalDiff > 0 {
            return "D-\(finalDiff)"
        } else {
            // Past
             let absDiff = abs(finalDiff)
             let plusDay = includeToday ? absDiff + 1 : absDiff
             return "D+\(plusDay)"
        }
    }
}

// Timeline Provider with Intent
struct IntentProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "Days+", dDay: "D-Day", targetDate: "2026.01.01", bgColor: "FFCDD2", fgColor: "5D1010", layoutType: 0, themeIndex: 0)
    }

    func snapshot(for configuration: SelectEventIntent, in context: Context) async -> SimpleEntry {
        let data = DataStorage.getDataForEvent(configuration.selectedEvent)
        // Recalculate D-Day for Snapshot
        let calculatedDDay = DateCalculator.calculateDDay(targetDateStr: data.targetDate, includeToday: data.includeToday)
        return SimpleEntry(date: Date(), title: data.title, dDay: calculatedDDay, targetDate: data.targetDate, bgColor: data.bgColor, fgColor: data.fgColor, layoutType: data.layoutType, themeIndex: data.themeIndex)
    }

    func timeline(for configuration: SelectEventIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let data = DataStorage.getDataForEvent(configuration.selectedEvent)
        
        // Dynamic D-Day Calculation
        let calculatedDDay = DateCalculator.calculateDDay(targetDateStr: data.targetDate, includeToday: data.includeToday)
        
        let entry = SimpleEntry(date: Date(), title: data.title, dDay: calculatedDDay, targetDate: data.targetDate, bgColor: data.bgColor, fgColor: data.fgColor, layoutType: data.layoutType, themeIndex: data.themeIndex)
        
        // 15분마다 갱신 (Next update 15 mins later)
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
    let themeIndex: Int // Theme index for native pattern rendering
}

struct DaysPlusWidgetEntryView : View {
    var entry: SimpleEntry

    var body: some View {
        ZStack {
            // Background control based on family
            if family == .systemSmall || family == .systemMedium {
                Color(hex: entry.bgColor)
                
                // Add Wave Pattern directly to the main view hierarchy
                WavePatternView(seed: entry.themeIndex)
            } else {
                // Completely transparent for Lock Screen (user request)
                Color.clear
            }
            
            // Layout 分기
            switch family {
            case .systemSmall:
                if entry.layoutType == 1 { titleEmphasisLayout } else { ddayEmphasisLayout }
            case .systemMedium:
                if entry.layoutType == 1 { titleEmphasisLayout } else { ddayEmphasisLayout }
            case .accessoryRectangular:
                accessoryRectangularLayout
            case .accessoryInline:
                accessoryInlineLayout
            case .accessoryCircular:
                accessoryCircularLayout
            default:
                ddayEmphasisLayout
            }
        }
        .widgetURL(URL(string: "daysplus://event?id=\(entry.title)")) // Deep link support preparation
        .containerBackground(for: .widget) {
            // Using main view for background rendering to ensure visibility
            if family == .systemSmall || family == .systemMedium {
                 Color(hex: entry.bgColor)
            } else {
                 Color.clear
            }
        }
    }
    
    // Environment to detect widget family
    @Environment(\.widgetFamily) var family
    
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
    
    // MARK: - Lock Screen Layouts
    
    // Accessory Rectangular: Title + Big D-Day
    var accessoryRectangularLayout: some View {
        VStack(alignment: .center, spacing: 1) {
            Text(entry.title)
                .font(.system(size: 12, weight: .semibold))
                .widgetAccentable()
                .lineLimit(1)
            
            Text(entry.targetDate)
                .font(.system(size: 9, weight: .medium))
                .opacity(0.8)
                .lineLimit(1)
            
            // Spacer removed to tighten layout as requested
            
            Text(entry.dDay)
                .font(.custom("RoundedMplus1c-ExtraBold", size: 22)) // Maximize visibility
                .fontWeight(.heavy)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .center) // Ensure full width centering
    }
    
    // Accessory Inline: "Title D-Day"
    var accessoryInlineLayout: some View {
        Text("\(entry.title) \(entry.dDay)")
    }
    
    // Accessory Circular: Gauge or simple Stack
    var accessoryCircularLayout: some View {
        ZStack {
            // No background, just text, single line as requested
            Text(entry.dDay)
                .font(.system(size: 11, weight: .bold))
                .minimumScaleFactor(0.3)
        }
    }
}

struct DaysPlusWidget: Widget {
    let kind: String = "DaysPlusWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectEventIntent.self, provider: IntentProvider()) { entry in
            DaysPlusWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Days+")
        .description("이벤트를 홈 화면에서 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline, .accessoryCircular])
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemSmall) {
    DaysPlusWidget()
} timeline: {
    SimpleEntry(date: .now, title: "여행", dDay: "D-5", targetDate: "2026.05.05", bgColor: "FFCDD2", fgColor: "5D1010", layoutType: 0, themeIndex: 0)
}

#Preview(as: .systemMedium) {
    DaysPlusWidget()
} timeline: {
    SimpleEntry(date: .now, title: "기념일", dDay: "D+100", targetDate: "2025.12.25", bgColor: "B2DFDB", fgColor: "004D40", layoutType: 1, themeIndex: 3)
}

// MARK: - Native Pattern Rendering (matches Flutter PosterCard)

/// Wave pattern overlay that matches Flutter's _drawWavyGradient
struct WavePatternView: View {
    let seed: Int
    
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                // Use the size provided by GeometryReader -> Canvas
                let width = size.width
                let height = size.height
                
                let random = SeededRandom(seed: seed)
                
                // Draw wavy gradient
                let startY = height * (0.4 + random.nextDouble() * 0.2)
                let cp1x = width * (0.25 + random.nextDouble() * 0.1)
                let cp1y = height * (random.nextDouble() * 0.5)
                let cp2x = width * (0.65 + random.nextDouble() * 0.1)
                let cp2y = height * (0.5 + random.nextDouble() * 0.5)
                let endY = height * (0.4 + random.nextDouble() * 0.3)
                
                var path = Path()
                path.move(to: CGPoint(x: 0, y: startY))
                path.addCurve(
                    to: CGPoint(x: width, y: endY),
                    control1: CGPoint(x: cp1x, y: cp1y),
                    control2: CGPoint(x: cp2x, y: cp2y)
                )
                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.closeSubpath()
                
                context.fill(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [.white.opacity(0.1), .white.opacity(0.5)]),
                        startPoint: CGPoint(x: width / 2, y: 0),
                        endPoint: CGPoint(x: width / 2, y: height)
                    )
                )
                
                // Draw droplets
                let dropletRandom = SeededRandom(seed: seed)
                dropletRandom.nextDouble() // Burn
                dropletRandom.nextDouble()
                
                let count = 5 + (seed % 4)
                for _ in 0..<count {
                    let dx = dropletRandom.nextDouble() * width
                    let dy = height * 0.3 + dropletRandom.nextDouble() * (height * 0.7)
                    let radius = 3.0 + dropletRandom.nextDouble() * 6.0
                    let opacity = 0.3 + dropletRandom.nextDouble() * 0.3
                    
                    let circle = Path(ellipseIn: CGRect(x: dx - radius, y: dy - radius, width: radius * 2, height: radius * 2))
                    context.fill(circle, with: .color(.white.opacity(opacity)))
                }
            }
        }
    }
}

/// Seeded random number generator (matches Flutter _SeededRandom)
class SeededRandom {
    private var seed: Int
    
    init(seed: Int) {
        self.seed = seed
    }
    
    func nextDouble() -> Double {
        seed = (seed &* 1103515245 &+ 12345) & 0x7FFFFFFF
        return Double(seed) / Double(0x7FFFFFFF)
    }
}
