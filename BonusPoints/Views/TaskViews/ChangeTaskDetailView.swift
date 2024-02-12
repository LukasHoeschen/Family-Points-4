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
            Section {
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
                        }.buttonStyle(.borderedProminent)
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
                        }.buttonStyle(.borderedProminent)
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
        ChangeTaskDetailView(task: TaskStruct(name: "", id: "", listId: "", pointsToAdd: 0, howManyTimesDidAllUsers: 0, counter: .now, orderWeight: 0))
            .environmentObject(AppDataHandler())
    }
}
