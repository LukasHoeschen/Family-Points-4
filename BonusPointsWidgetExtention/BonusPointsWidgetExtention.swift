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
        return SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), widgetData: widgetDataStruct(deviceId: "", userId: "", familyId: "", tasks: [TaskStruct(name: "Example Task", id: "", listId: "", pointsToAdd: 0, howManyTimesDidAllUsers: 0, counter: 0, orderWeight: 0)]))
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, widgetData: widgetDataStruct(deviceId: "", userId: "preview", familyId: "", tasks: [TaskStruct(name: "Example Task", id: "e", listId: "", pointsToAdd: 0, howManyTimesDidAllUsers: 0, counter: 0, orderWeight: 0), TaskStruct(name: "Do Homework", id: "e", listId: "", pointsToAdd: 0, howManyTimesDidAllUsers: 0, counter: 0, orderWeight: 0), TaskStruct(name: "Set the Table", id: "e", listId: "", pointsToAdd: 0, howManyTimesDidAllUsers: 0, counter: 0, orderWeight: 0), TaskStruct(name: "Tidy my Room", id: "e", listId: "", pointsToAdd: 0, howManyTimesDidAllUsers: 0, counter: 0, orderWeight: 0)]))
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        print("3")
        var entries: [SimpleEntry] = []
        
        let data = myWidgetLoadTasksHelper.loadDataForWidget() 
        
        entries.append(SimpleEntry(date: Date(), configuration: configuration, widgetData: data))

        return Timeline(entries: entries, policy: .never)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    var widgetData: widgetDataStruct
}

struct BonusPointsWidgetExtentionEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family
    @AppStorage("WidgetShowButtonWasTappedId") var showTapped = ""
    
    @State var tasks: [TaskStruct?] = []
    
    @ViewBuilder
    var body: some View {
        if entry.widgetData.familyId == "premium" || entry.widgetData.userId == "preview" {
            VStack {
                if tasks.count == 16 {
                    switch family {
                    case .systemSmall, .systemMedium:
                        ForEach(0..<3, id: \.self) { t in
                            if let task = tasks[t] {
                                HStack {
                                    Button(intent: TaskIntend(item: task.id)) {
                                        Image(systemName: showTapped == task.id ? "checkmark" : "plus.square.fill")
                                            .foregroundColor(.blue)
                                            .font(.largeTitle)
                                    }.buttonStyle(.plain)
                                        .onAppear {
                                            if showTapped == task.id {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    withAnimation {
                                                        showTapped = ""
                                                        WidgetCenter.shared.reloadAllTimelines()
                                                    }
                                                }
                                            }
                                        }
                                    Text(task.name)
                                        .foregroundStyle(Color.init(red: 246/256, green: 81/256, blue: 1/256))
                                    Spacer()
                                }.bold()
                                    .font(.title2)
                            }
                        }
                        Spacer()
                        
                    case .systemLarge:
                        ForEach(0..<8, id: \.self) { t in
                            if let task = tasks[t] {
                                HStack {
                                    Button(intent: TaskIntend(item: task.id)) {
                                        Image(systemName: showTapped == task.id ? "checkmark" : "plus.square.fill")
                                            .foregroundColor(.blue)
                                            .font(.largeTitle)
                                    }.buttonStyle(.plain)
                                        .onAppear {
                                            if showTapped == task.id {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    withAnimation {
                                                        showTapped = ""
                                                        WidgetCenter.shared.reloadAllTimelines()
                                                    }
                                                }
                                            }
                                        }
                                    Text(task.name)
                                        .foregroundStyle(Color.init(red: 246/256, green: 81/256, blue: 1/256))
                                    Spacer()
                                }.bold()
                                    .font(.title2)
                            }
                        }
                        Spacer()
                    case .systemExtraLarge:
                        HStack {
                            VStack {
                                ForEach(0..<16, id: \.self) { t in
                                    if t % 2 == 0 {
                                        if let task = tasks[t], t % 2 == 0 {
                                            HStack {
                                                Button(intent: TaskIntend(item: task.id)) {
                                                    Image(systemName: showTapped == task.id ? "checkmark" : "plus.square.fill")
                                                        .foregroundColor(.blue)
                                                        .font(.largeTitle)
                                                }.buttonStyle(.plain)
                                                    .onAppear {
                                                        if showTapped == task.id {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                                withAnimation {
                                                                    showTapped = ""
                                                                    WidgetCenter.shared.reloadAllTimelines()
                                                                }
                                                            }
                                                        }
                                                    }
                                                Text(task.name)
                                                    .foregroundStyle(Color.init(red: 246/256, green: 81/256, blue: 1/256))
                                                Spacer()
                                            }.bold()
                                                .font(.title2)
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
                                            HStack {
                                                Button(intent: TaskIntend(item: task.id)) {
                                                    Image(systemName: showTapped == task.id ? "checkmark" : "plus.square.fill")
                                                        .foregroundColor(.blue)
                                                        .font(.largeTitle)
                                                }.buttonStyle(.plain)
                                                    .onAppear {
                                                        if showTapped == task.id {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                                withAnimation {
                                                                    showTapped = ""
                                                                    WidgetCenter.shared.reloadAllTimelines()
                                                                }
                                                            }
                                                        }
                                                    }
                                                Text(task.name)
                                                    .foregroundStyle(Color.init(red: 246/256, green: 81/256, blue: 1/256))
                                                Spacer()
                                            }.bold()
                                                .font(.title2)
                                        }
                                    }
                                }
                                Spacer()
                            }.frame(maxWidth: .infinity)
                        }
                        
                    case .accessoryCircular:
                        if let t = tasks.first, let task = t {
                            Button(intent: TaskIntend(item: task.id)) {
                                Image(systemName: showTapped == task.id ? "checkmark" : "plus.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                            }.buttonStyle(.plain)
                                .onAppear {
                                    if showTapped == task.id {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation {
                                                showTapped = ""
                                                WidgetCenter.shared.reloadAllTimelines()
                                            }
                                        }
                                    }
                                }
                        }
                        
                    case .accessoryInline, .accessoryRectangular:
                        if let t = tasks.first, let task = t {
                            HStack {
                                Text(task.name)
                                Spacer()
                                Button(intent: TaskIntend(item: task.id)) {
                                    Image(systemName: showTapped == task.id ? "checkmark" : "plus.square.fill")
                                }.buttonStyle(.plain)
                                    .font(.title2)
                                    .bold()
                                    .onAppear {
                                        if showTapped == task.id {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                withAnimation {
                                                    showTapped = ""
                                                    WidgetCenter.shared.reloadAllTimelines()
                                                }
                                            }
                                        }
                                    }
                            }
                        }
                    @unknown default:
                        Text("Widget Size not yet supported")
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
        }
    }
}


struct widgetHelperView: View {
    let id: String
    let name: String
    
    @AppStorage("WidgetShowButtonWasTappedId") var showTapped = ""
    
    var body: some View {
        ZStack {
            Button(intent: TaskIntend(item: id)) {
                Image(systemName: showTapped == id ? "checkmark" : "plus.square.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 70))
            }.buttonStyle(.plain)
                .onAppear {
                    if showTapped == id {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showTapped = ""
                                WidgetCenter.shared.reloadAllTimelines()
                            }
                        }
                    }
                }
            
            VStack {
                Spacer()
                Text(name)
                    .foregroundStyle(Color.init(red: 246/256, green: 81/256, blue: 1/256))
            }
        }.bold()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                widgetHelperView(id: t.id, name: t.name)
                            } else {
                                Text("Long press to configure")
                            }
                        }
                    case .systemMedium:
                        HStack {
                            if tasks.count == 12 {
                                if let task = tasks[0] {
                                    widgetHelperView(id: task.id, name: task.name)
                                } else {
                                    Text("Long press to configure")
                                }
                                if let task = tasks[1] {
                                    Divider()
                                    widgetHelperView(id: task.id, name: task.name)
                                }
                            }
                        }
                    case .systemLarge:
                        VStack {
                            if tasks.count == 12 {
                                HStack {
                                    if let t = tasks[0] {
                                        widgetHelperView(id: t.id, name: t.name)
                                    } else {
                                        Text("Long press to configure")
                                    }
                                    if let task = tasks[1] {
                                        Divider()
                                        widgetHelperView(id: task.id, name: task.name)
                                    }
                                }
                                
                                if tasks[2] != nil {
                                    Divider()
                                }
                                
                                HStack {
                                    if let task = tasks[2] {
                                        widgetHelperView(id: task.id, name: task.name)
                                    }
                                    if let task = tasks[3] {
                                        Divider()
                                        widgetHelperView(id: task.id, name: task.name)
                                    }
                                }
                                
                                if tasks[4] != nil {
                                    Divider()
                                }
                                
                                HStack {
                                    if let task = tasks[4] {
                                        widgetHelperView(id: task.id, name: task.name)
                                    }
                                    if let task = tasks[5] {
                                        Divider()
                                        widgetHelperView(id: task.id, name: task.name)
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
                                            widgetHelperView(id: task.id, name: task.name)
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
                                            widgetHelperView(id: task.id, name: task.name)
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
    SimpleEntry(date: .now, configuration: ConfigurationAppIntent(), widgetData: widgetDataStruct(deviceId: "", userId: "", familyId: "", tasks: [TaskStruct(name: "Do Homework", id: "", listId: "", pointsToAdd: 1, howManyTimesDidAllUsers: 0, counter: 2, orderWeight: 5)]))
}
