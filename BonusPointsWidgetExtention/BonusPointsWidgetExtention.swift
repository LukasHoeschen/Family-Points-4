//
//  BonusPointsWidgetExtention.swift
//  BonusPointsWidgetExtention
//
//  Created by Lukas Marius Hoeschen on 27.12.23.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        print("1")
        return SimpleEntry(date: Date(), showTapped: "", configuration: ConfigurationAppIntent(), widgetData: widgetDataStruct(deviceId: "", userId: "", familyId: "", tasks: [TaskStruct(name: "Example Task", id: "", listId: "", pointsToAdd: 0, howManyTimesDidAllUsers: 0, counter: .now, orderWeight: 0)]))
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), showTapped: "", configuration: configuration, widgetData: widgetDataStruct(deviceId: "", userId: "preview", familyId: "", tasks: [TaskStruct(name: "Example Task", id: "e", listId: "", pointsToAdd: 0, howManyTimesDidAllUsers: 0, counter: .now, orderWeight: 0), TaskStruct(name: "Do Homework", id: "e", listId: "", pointsToAdd: 0, howManyTimesDidAllUsers: 0, counter: .now, orderWeight: 0), TaskStruct(name: "Set the Table", id: "e", listId: "", pointsToAdd: 0, howManyTimesDidAllUsers: 0, counter: .now, orderWeight: 0), TaskStruct(name: "Tidy my Room", id: "e", listId: "", pointsToAdd: 0, howManyTimesDidAllUsers: 0, counter: .now, orderWeight: 0)]))
    }
    
    func timeline(
        for configuration: ConfigurationAppIntent,
        in context: Context
    ) async -> Timeline<SimpleEntry> {
        
        var entries: [SimpleEntry] = []
        
        let data = myWidgetLoadTasksHelper.loadDataForWidget()
        
        let tapped =
        UserDefaults(
            suiteName: "group.org.hoeschen.lukas.familyPoints.App.AppGroup"
        )?.string(
            forKey: "WidgetShowButtonWasTappedId"
        ) ?? ""
        
        entries.append(
            SimpleEntry(
                date: Date(),
                showTapped: tapped,
                configuration: configuration,
                widgetData: data
            )
        )
        
        return Timeline(entries: entries, policy: .never)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let showTapped: String
    let configuration: ConfigurationAppIntent
    var widgetData: widgetDataStruct
}

struct BonusPointsWidgetExtentionEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family
    var showTapped: String {
        UserDefaults(suiteName: "group.org.hoeschen.lukas.familyPoints.App.AppGroup")?.string(forKey: "WidgetShowButtonWasTappedId") ?? ""
    }
    
    @State var tasks: [TaskStruct?] = []
    
    @ViewBuilder
    var body: some View {
        if entry.widgetData.familyId == "premium" || entry.widgetData.userId == "preview" {
            VStack {
                if tasks.count == 16 {
                    if tasks[0] == nil {
                        Text("Long press to configure")
                    } else {
                        switch family {
                        case .systemSmall, .systemMedium:
                            ForEach(0..<3, id: \.self) { t in
                                if let task = tasks[t] {
                                    widgetHelperInLineView(id: task.id, name: task.name, showTapped: entry.showTapped)
                                }
                            }
                            Spacer()
                            
                        case .systemLarge:
                            ForEach(0..<8, id: \.self) { t in
                                if let task = tasks[t] {
                                    widgetHelperInLineView(id: task.id, name: task.name, showTapped: entry.showTapped)
                                }
                            }
                            Spacer()
                        case .systemExtraLarge:
                            HStack {
                                VStack {
                                    ForEach(0..<16, id: \.self) { t in
                                        if t % 2 == 0 {
                                            if let task = tasks[t], t % 2 == 0 {
                                                widgetHelperInLineView(id: task.id, name: task.name, showTapped: entry.showTapped)
                                            }
                                        }
                                    }
                                    Spacer()
                                }.frame(maxWidth: .infinity)
                                Divider()
                                VStack {
                                    ForEach(0..<16, id: \.self) { t in
                                        if t % 2 == 1 {
                                            if let task = tasks[t] {
                                                widgetHelperInLineView(id: task.id, name: task.name, showTapped: entry.showTapped)
                                            }
                                        }
                                    }
                                    Spacer()
                                }.frame(maxWidth: .infinity)
                            }
                            
                        case .accessoryCircular:
                            if let t = tasks.first, let task = t {
                                widgetHelperInLineView(id: task.id, name: "", showTapped: entry.showTapped)
                            }
                            
                        case .accessoryInline, .accessoryRectangular:
                            if let t = tasks.first, let task = t {
                                widgetHelperInLineView(id: task.id, name: task.name, showTapped: entry.showTapped)
                            }
                        @unknown default:
                            Text("Widget Size not yet supported")
                        }
                    }
                } else {
                    Text("Long press to configure")
                }
            }.onAppear {
                entry.widgetData.tasks.forEach { t in
                    if entry.configuration.selectedTasks.contains(where: {$0.id == t.id}) || entry.widgetData.userId == "preview" {
//                        print("Hiiit")
                        //            entry.configuration.selectedTasks.forEach { s in
                        tasks.append(t)
                    }
                }
                while tasks.count < 16 {
                    tasks.append(nil)
                }
            }
        } else {
            Text("Please subscribe to use widgets")
                .onAppear {
//                    print(entry.widgetData)
                }
        }
    }
}

struct MyEntry: TimelineEntry {

    let date: Date

    let showTapped: String

}


struct widgetHelperView: View {
    let id: String
    let name: String
    let showTapped: String

    var body: some View {

        ZStack {
            Button(intent: TaskIntend(item: id)) {
                Image(systemName: showTapped == id ? "checkmark": "circle")
                .foregroundColor(.blue)
                .font(.system(size: 70))
                .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)

            VStack {
                Spacer()

                Text(name)
                    .foregroundStyle(Color(red: 246/256,green: 81/256,blue: 1/256))
            }
        }
        .bold()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct widgetHelperInLineView: View {
    let id: String
    let name: String
    let showTapped: String

    var body: some View {
        Button(intent: TaskIntend(item: id)) {
            HStack {
                Image(systemName: showTapped == id ? "checkmark" : "circle")
                    .foregroundColor(.blue)
                    .font(.largeTitle)
                    .contentTransition(.symbolEffect(.replace))
                
                Text(name)
                    .foregroundStyle(Color.init(red: 246/256, green: 81/256, blue: 1/256))
                Spacer()
            }
        }.bold()
            .font(.title2)
            .buttonStyle(.plain)
    }
}


struct BonusPointsWidgetExtentionEntryViewSecond : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family
    
    @State var tasks: [TaskStruct?] = []

    @ViewBuilder
    var body: some View {
//        Text(entry.widgetData.userId)
        if entry.widgetData.familyId == "premium" || entry.widgetData.userId == "preview" {
            GeometryReader { size in
                ZStack {
                    switch family {
                    case .systemSmall:
                        if tasks.count == 12 {
                            if let t = tasks[0] {
                                widgetHelperView(id: t.id, name: t.name, showTapped: entry.showTapped)
                            } else {
                                Text("Long press to configure")
                            }
                        }
                    case .systemMedium:
                        HStack {
                            if tasks.count == 12 {
                                if let task = tasks[0] {
                                    widgetHelperView(id: task.id, name: task.name, showTapped: entry.showTapped)
                                } else {
                                    Text("Long press to configure")
                                }
                                if let task = tasks[1] {
                                    Divider()
                                    widgetHelperView(id: task.id, name: task.name, showTapped: entry.showTapped)
                                }
                            }
                        }
                    case .systemLarge:
                        VStack {
                            if tasks.count == 12 {
                                HStack {
                                    if let t = tasks[0] {
                                        widgetHelperView(id: t.id, name: t.name, showTapped: entry.showTapped)
                                    } else {
                                        Text("Long press to configure")
                                    }
                                    if let task = tasks[1] {
                                        Divider()
                                        widgetHelperView(id: task.id, name: task.name, showTapped: entry.showTapped)
                                    }
                                }
                                
                                if tasks[2] != nil {
                                    Divider()
                                }
                                
                                HStack {
                                    if let task = tasks[2] {
                                        widgetHelperView(id: task.id, name: task.name, showTapped: entry.showTapped)
                                    }
                                    if let task = tasks[3] {
                                        Divider()
                                        widgetHelperView(id: task.id, name: task.name, showTapped: entry.showTapped)
                                    }
                                }
                                
                                if tasks[4] != nil {
                                    Divider()
                                }
                                
                                HStack {
                                    if let task = tasks[4] {
                                        widgetHelperView(id: task.id, name: task.name, showTapped: entry.showTapped)
                                    }
                                    if let task = tasks[5] {
                                        Divider()
                                        widgetHelperView(id: task.id, name: task.name, showTapped: entry.showTapped)
                                    }
                                }
                            }
                        }
                    case .systemExtraLarge:
                        if tasks.count == 12 {
                            VStack {
                                HStack {
                                    ForEach(0..<4, id: \.self) { i in
                                        if let task = tasks[i] {
                                            if i != 0 {
                                                Divider()
                                            }
                                            widgetHelperView(id: task.id, name: task.name, showTapped: entry.showTapped)
                                        }
                                    }
                                }
                                if tasks[4] != nil {
                                    Divider()
                                }
                                HStack {
                                    ForEach(4..<8, id: \.self) { i in
                                        if let task = tasks[i] {
                                            if i != 4 {
                                                Divider()
                                            }
                                            widgetHelperView(id: task.id, name: task.name, showTapped: entry.showTapped)
                                        }
                                    }
                                }
                            }
                        } else {
                            Text("Long press to configure")
                        }
                        
                    default:
                        Text("Not supported")
                    }
                }.onAppear {
                    entry.widgetData.tasks.forEach { t in
                        if entry.configuration.selectedTasks.contains(where: {$0.id == t.id}) || entry.widgetData.userId == "preview" {
                            //            entry.configuration.selectedTasks.forEach { s in
                            tasks.append(t)
                        }
                    }
                    for _ in 0..<(12-tasks.count) {
                        tasks.append(nil)
                    }
                }
            }
        } else {
            Text("Please subscribe to use widgets")
        }
    }
}

struct BonusPointsWidgetExtention: Widget {
    let kind: String = "BonusPointsWidgetExtention"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            BonusPointsWidgetExtentionEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }.configurationDisplayName("Family Points Widget")
            .description("A Widget to access your favourite Tasks on your Home screen")
            .supportedFamilies([.systemLarge, .systemMedium, .systemExtraLarge, .accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}



struct BonusPointsWidgetExtentionSecond: Widget {
    let kind: String = "BonusPointsWidgetExtentionSecond"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            BonusPointsWidgetExtentionEntryViewSecond(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }.configurationDisplayName("Family Points Widget")
            .description("A Widget to access your favourite Tasks on your Home screen")
            .supportedFamilies([.systemSmall, .systemLarge, .systemMedium, .systemExtraLarge])
    }
}

//extension ConfigurationAppIntent {
//    fileprivate static var smiley: ConfigurationAppIntent {
//        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "😀"
//        return intent
//    }
//    
//    fileprivate static var starEyes: ConfigurationAppIntent {
//        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "🤩"
//        return intent
//    }
//}

#Preview(as: .systemSmall) {
    BonusPointsWidgetExtention()
} timeline: {
    SimpleEntry(date: .now, showTapped: "", configuration: ConfigurationAppIntent(), widgetData: widgetDataStruct(deviceId: "", userId: "", familyId: "", tasks: [TaskStruct(name: "Do Homework", id: "", listId: "", pointsToAdd: 1, howManyTimesDidAllUsers: 0, counter: .now, orderWeight: 5)]))
}
