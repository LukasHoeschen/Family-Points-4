//
//  AppIntent.swift
//  BonusPointsWidgetExtention
//
//  Created by Lukas Marius Hoeschen on 27.12.23.
//

import WidgetKit
import AppIntents
import SwiftUI



struct myWidgetLoadTasksHelper {
    static func loadDataForWidget() -> widgetDataStruct {
        if let defaults = UserDefaults(suiteName: "group.org.hoeschen.development.bonusPoints") {
            if let storedData = defaults.data(forKey: "widgetData") {
                if let data = try? JSONDecoder().decode(widgetDataStruct.self, from: storedData) {
                    if !data.tasks.isEmpty {
                        return data
                    }
                }
            }
        }
        return widgetDataStruct(deviceId: "", userId: "", familyId: "", tasks: [TaskStruct(name: "Example Task", id: "", listId: "", pointsToAdd: 0, howManyTimesDidAllUsers: 0, counter: 0, orderWeight: 0)])
    }
}

struct widgetSelectedTasksStruct: AppEntity {
    var id: String // name
    var name: String
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Widget Task"
    static var defaultQuery = WidgetTasksQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
    
    static var allWidgetTasks: [widgetSelectedTasksStruct] {
        var result: [widgetSelectedTasksStruct] = []
        if let defaults = UserDefaults(suiteName: "group.org.hoeschen.development.bonusPoints") {
            if let storedData = defaults.data(forKey: "widgetData") {
                if let data = try? JSONDecoder().decode(widgetDataStruct.self, from: storedData) {
                    data.tasks.forEach { t in
                        result.append(widgetSelectedTasksStruct(id: t.id, name: t.name))
                    }
                }
            }
        }
//        if result.isEmpty {
//            result.append(widgetSelectedTasksStruct(id: "", name: "Example Task"))
//        }
        return result
    }
}

struct WidgetTasksQuery: EntityQuery {
    func entities(for identifiers: [widgetSelectedTasksStruct.ID]) async throws -> [widgetSelectedTasksStruct] {
        widgetSelectedTasksStruct.allWidgetTasks.filter {
            return identifiers.contains($0.id)
        }
    }
    
    func suggestedEntities() async throws -> [widgetSelectedTasksStruct] {
        return widgetSelectedTasksStruct.allWidgetTasks
    }
    
    func defaultResult() async -> [widgetSelectedTasksStruct]? {
        return Array(widgetSelectedTasksStruct.allWidgetTasks.prefix(3))
    }
}


struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("Select Tasks to display")

    // An example configurable parameter.
    @Parameter(title: "Selected Tasks", default: [])
    var selectedTasks: [widgetSelectedTasksStruct]
}


struct TaskIntend: AppIntent {
    static var title: LocalizedStringResource = "Complete Task"
    static var description: IntentDescription = IntentDescription("Complete selected task")
    
    @Parameter(title: "TaskItemId")
    var item: String
    
    init() { }
    init(item: String) {
        self.item = item
    }
    
    
    @AppStorage("WidgetShowButtonWasTappedId") var showTapped = ""
    
    func perform() async throws -> some IntentResult {
        print("pressed")
        var data: widgetChangesStruct?
        if let defaults = UserDefaults(suiteName: "group.org.hoeschen.development.bonusPoints") {
            if let storedData = defaults.data(forKey: "widgetAddedCount") {
                if let d = try? JSONDecoder().decode(widgetChangesStruct.self, from: storedData) {
                    data = d
                }
            }
        }
        
        var list: [String] = []
        if data != nil {
            list = data!.list
        }
        list.append(item)
        let l = list
        
        DispatchQueue.global().async {
            if let defaults = UserDefaults(suiteName: "group.org.hoeschen.development.bonusPoints") {
                if let encoded = try? JSONEncoder().encode(widgetChangesStruct(list: l)) {
                    showTapped = item
                    defaults.setValue(encoded, forKey: "widgetAddedCount")
                    defaults.synchronize()
                }
            }
        }
        
        
        return .result()
    }
    
    
}
