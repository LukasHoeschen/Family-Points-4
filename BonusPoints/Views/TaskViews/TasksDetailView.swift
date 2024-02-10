//
//  TasksDetailsView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 17.01.23.
//

import SwiftUI
import Charts

struct TasksDetailView: View {
    
    @EnvironmentObject var dataHandler: AppDataHandler
    
    @State private var selectedChart = 0
    
    @State private var allTasks1: [TaskStruct] = []
    @State private var allTasks2: [TaskStruct] = []
    @State private var allTasks3: [TaskStruct] = []
    
    var body: some View {
        
        VStack {
            Picker("", selection: $selectedChart) {
                Text("Completed").tag(0)
                Text("Points").tag(1)
                Text("Total Achieved").tag(2)
            }.pickerStyle(.segmented)
            
            TabView(selection: $selectedChart) {
                List {
                    
                    Label("Most Completed Tasks", systemImage: "chart.bar.fill")

                    Chart {
                        ForEach(allTasks1, id: \.self) { task in
                            
                            BarMark(
                                x: .value("Total Count", task.howManyTimesDidAllUsers),
                                y: .value("Name", task.name)
                            )
                            .annotation(position: .trailing) {
                                Text(String(task.howManyTimesDidAllUsers))
                                    .foregroundColor(Color.gray)
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundStyle(Color.accentColor)
                            .cornerRadius(6)
                            
                        }
                    }.frame(height: CGFloat(allTasks1.count * 60))
                    
                    Section(content: {
                        Text("This section displays tasks that have been completed most frequently among all family members.")
                    }, header: {
                        Text("Info")
                    }, footer: {
                        if !dataHandler.family.premium {
                            Text("Please subscribe to see all Tasks in Statistics")
                        }
                    })
                    
                }.tag(0)
                
                List {
    
                    Label("Points", systemImage: "chart.bar.fill")
    
                    Chart {
                        ForEach(allTasks2, id: \.self) { task in
    
                            BarMark(
                                x: .value("Points to Add", task.pointsToAdd),
                                y: .value("Name", task.name)
                            )
                                .annotation(position: .trailing) {
                                    Text(functionsClass().floatToShortString(x: task.pointsToAdd))
                                        .foregroundColor(Color.gray)
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .foregroundStyle(Color.accentColor)
                                .cornerRadius(6)

                        }
                    }.frame(height: CGFloat(allTasks1.count * 60))
                    
                    Section(content: {
                        Text("This section displays tasks that yield the highest number of points.")
                    }, header: {
                        Text("Info")
                    }, footer: {
                        if !dataHandler.family.premium {
                            Text("Please subscribe to see all Tasks in Statistics")
                        }
                    })
                }.tag(1)
                
                List {
                    
                    Label("Total Achieved Points", systemImage: "chart.bar.fill")
    
                    Chart {
                        ForEach(allTasks3, id: \.self) { task in
    
                            BarMark(
                                x: .value("Total achieved Points", task.pointsToAdd * Float(task.howManyTimesDidAllUsers)),
                                y: .value("Name", task.name)
                            )
                                .annotation(position: .trailing) {
                                    Text(functionsClass().floatToShortString(x: task.pointsToAdd * Float(task.howManyTimesDidAllUsers)))
                                        .foregroundColor(Color.gray)
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .foregroundStyle(Color.accentColor)
                                .cornerRadius(6)

                        }
                    }.frame(height: CGFloat(allTasks1.count * 60))
                    
                    Section(content: {
                        Text("This section displays tasks that have earned the most points.")
                    }, header: {
                        Text("Info")
                    }, footer: {
                        if !dataHandler.family.premium {
                            Text("Please subscribe to see all Tasks in Statistics")
                        }
                    })
                }.tag(2)
            }
        }
        .toolbar {
            ToolbarItem {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                }
            }
        }
        #if !os(macOS)
            .tabViewStyle(.page)
        #endif
            .navigationTitle("Insights")
            .animation(.easeInOut, value: selectedChart)
            .onAppear {
                var tasks: [TaskStruct] = []
                dataHandler.family.tasks.forEach { l in
                    l.list.forEach { t in
                        tasks.append(t)
                    }
                }
                
                if !dataHandler.family.premium {
                    tasks = Array(tasks.prefix(3))
                }
                
                withAnimation(.linear(duration: 2)) {
                    self.allTasks1 = tasks.sorted { $0.howManyTimesDidAllUsers > $1.howManyTimesDidAllUsers }
                    self.allTasks2 = tasks.sorted { $0.pointsToAdd > $1.pointsToAdd }
                    self.allTasks3 = tasks.sorted { task1, task2 in
                        (Float(task1.howManyTimesDidAllUsers) * task1.pointsToAdd) > (Float(task2.howManyTimesDidAllUsers) * task2.pointsToAdd)
                    }
                }
            }
            
    }
}

struct TasksDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TasksDetailView()
            .environmentObject(AppDataHandler())
    }
}
