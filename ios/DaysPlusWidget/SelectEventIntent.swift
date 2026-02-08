//
//  SelectEventIntent.swift
//  DaysPlusWidget
//
//  Created by Claude on 1/30/26.
//

import AppIntents
import WidgetKit

// Event Entity for widget selection
struct EventEntity: AppEntity {
    var id: String
    var title: String
    var dDay: String
    var date: String
    var bgColor: String
    var fgColor: String
    var layoutType: Int
    var includeToday: Bool
    var excludeWeekends: Bool
    var themeIndex: Int
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "이벤트를 선택하세요"
    static var defaultQuery = EventEntityQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", subtitle: "\(dDay)")
    }
}

// Query to fetch events from UserDefaults
struct EventEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [EventEntity] {
        let allEvents = fetchAllEvents()
        return allEvents.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [EventEntity] {
        return fetchAllEvents()
    }
    
    private func fetchAllEvents() -> [EventEntity] {
        let userDefaults = UserDefaults(suiteName: DataStorage.appGroupId)
        guard let jsonString = userDefaults?.string(forKey: "widget_events_list"),
              let jsonData = jsonString.data(using: .utf8) else {
            return []
        }
        
        // Manual JSON parsing using JSONSerialization
        guard let jsonArray = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            return []
        }
        
        return jsonArray.compactMap { dict in
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
            let themeIndex = dict["themeIndex"] as? Int ?? 0
            
            return EventEntity(id: id, title: title, dDay: dDay, date: date, bgColor: bgColor, fgColor: fgColor, layoutType: layoutType, includeToday: includeToday, excludeWeekends: excludeWeekends, themeIndex: themeIndex)
        }
    }
}

// Configuration Intent
struct SelectEventIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "이벤트 선택"
    static var description: IntentDescription = IntentDescription("위젯에 표시할 이벤트를 선택하세요")
    
    @Parameter(title: "이벤트")
    var selectedEvent: EventEntity?
}
