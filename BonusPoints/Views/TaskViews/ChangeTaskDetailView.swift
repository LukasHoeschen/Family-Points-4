//
//  ChangeTaskDetailView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 21.01.23.
//

import SwiftUI
import Charts
import SwiftDate

struct ChangeTaskDetailView: View {
    
    @State var task: TaskStruct
    
    @State private var editTask = false
    @State var editTaskNewName = ""
    @State var editTaskNewPointsToAdd = ""
    
    @State private var showReallyDeleteTask = false
    
    @State var chartData: [TaskHistoryStruct] = []
    
    @EnvironmentObject var dataHandler: AppDataHandler
    
    
    var body: some View {
        Form {
            Section("Details") {
                Label("Name", systemImage: "keyboard")
                if editTask {
                    HStack {
                        TextField(task.name, text: $editTaskNewName)
                            .onSubmit {
                                withAnimation {
                                    dataHandler.updateTask(taskId: task.id, taskListId: task.listId, name: editTaskNewName, pointsToAdd: task.pointsToAdd, orderWeight: task.orderWeight, created: task.created)
                                    self.task.name = editTaskNewName
                                    editTask = false
                                }
                            }
                        Button("Done") {
                            withAnimation {
                                dataHandler.updateTask(taskId: task.id, taskListId: task.listId, name: editTaskNewName, pointsToAdd: task.pointsToAdd, orderWeight: task.orderWeight, created: task.created)
                                self.task.name = editTaskNewName
                                editTask = false
                            }
                        }
                    }
                    
                } else {
                    Text(task.name)
                }
            }
            
            Section {
                Label("Points Earned Upon Completion", systemImage: "number")
                if editTask {
                    HStack {
                        TextField(functionsClass().floatToShortString(x: task.pointsToAdd), text: $editTaskNewPointsToAdd)
#if os(iOS)
                            .keyboardType(.numberPad)
#endif
                            .onSubmit {
                                withAnimation {
                                    dataHandler.updateTask(taskId: task.id, taskListId: task.listId, name: task.name, pointsToAdd: Float(editTaskNewPointsToAdd) ?? 1, orderWeight: task.orderWeight, created: task.created)
                                    self.task.pointsToAdd = Float(editTaskNewPointsToAdd) ?? 1
                                    editTask = false
                                }
                            }
                        Text("Points")
                        Button("Done") {
                            withAnimation {
                                dataHandler.updateTask(taskId: task.id, taskListId: task.listId, name: task.name, pointsToAdd: Float(editTaskNewPointsToAdd) ?? 1, orderWeight: task.orderWeight, created: task.created)
                                //                                dataHandler.tasks.newPointsToAdd(taskListNum: taskListNum, taskNum: taskNum, points: Float(editTaskNewPointsToAdd) ?? 0.0)
                                self.task.pointsToAdd = Float(editTaskNewPointsToAdd) ?? 1
                                editTask = false
                            }
                        }
                    }
                } else {
                    Text(functionsClass().floatToShortString(x: task.pointsToAdd) + " Points")
                }
            }
            
            Section("Info") {
                Text("**\(task.howManyTimesDidAllUsers) times** completed by all family members")

                Text("**\(functionsClass().floatToShortString(x: task.pointsToAdd * Float(task.howManyTimesDidAllUsers)))** total achieved points with this task")

                HStack {
                    Spacer()
                    Text(task.getDate())
                    Spacer()
                }
            }
            
//            if dataHandler.family.premium {
//                Section("Insights") {
//                    Chart {
//                        ForEach(chartData, id: \.self) { item in
//                            
//                            LineMark(
//                                x: .value("Date", item.date),
//                                y: .value("Count", item.count)
//                            )
//                            .annotation {
//                                Text(String(item.count))
//                                    .foregroundColor(Color.gray)
//                                    .font(.system(size: 12, weight: .bold))
//                            }
//                            .foregroundStyle(Color.accentColor)
//                            
//                        }
//                    }.frame(height: 500)
//                        .chartXAxisLabel("Day", alignment: .center)
//                        .chartYAxisLabel("Count")
//                }
//                .onAppear {
//                    dataHandler.family.doneTasksHistory = [
//                        TaskHistoryStruct(userId: "", taskId: "9buhkabuusldzl6596bym8kvrnjvz8", date: .now - 7 .days, count: 2),
//                        TaskHistoryStruct(userId: "", taskId: "9buhkabuusldzl6596bym8kvrnjvz8", date: .now - 6 .days, count: 5),
//                        TaskHistoryStruct(userId: "", taskId: "9buhkabuusldzl6596bym8kvrnjvz8", date: .now - 4 .days, count: 1),
//                        TaskHistoryStruct(userId: "", taskId: "9buhkabuusldzl6596bym8kvrnjvz8", date: .now - 1 .days, count: 4),
//                        TaskHistoryStruct(userId: "", taskId: "9buhkabuusldzl6596bym8kvrnjvz8", date: .now - 0 .days, count: 2)
//                    ]
//                    dataHandler.family.doneTasksHistory.forEach { i in
//                        if i.taskId == task.id {
//                            print(i)
//                            if let j = chartData.firstIndex(where: { $0.date.day == i.date.day }) {
//                                chartData[j].count += i.count
//                            } else {
//                                chartData.append(i)
//                            }
//                        }
//                    }
//                    print(chartData)
//                }
//            }
            
            
            if dataHandler.user.role == UserRole.parent {
                Button(action: {
                    showReallyDeleteTask = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete this Task")
                    }
                }.foregroundColor(.red)
                    .confirmationDialog("", isPresented: $showReallyDeleteTask) {
                        Button("Delete", role: .destructive) {
                            dataHandler.deleteTask(taskId: task.id)
                        }
                    }
            }
            
        }.navigationTitle(task.name)
            .toolbar {
                ToolbarItem(content: {
                    if dataHandler.user.role == UserRole.parent {
                        Button(action: {
                            withAnimation {
                                editTask.toggle()
                            }
                        }) {
                            Image(systemName: "pencil.circle")
                        }
                    }
                })
            }
    }
}

struct ChangeTaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeTaskDetailView(task: TaskStruct(name: "", id: "", listId: "", pointsToAdd: 0, howManyTimesDidAllUsers: 0, counter: 0, orderWeight: 0))
            .environmentObject(AppDataHandler())
    }
}
