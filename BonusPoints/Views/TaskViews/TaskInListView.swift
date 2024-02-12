//
//  TaskInListView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 15.12.22.
//

import SwiftUI

struct TaskInListView: View {
    
    @State var task: TaskStruct
    
    @State private var showDone = false
    
    @EnvironmentObject var dataHandler: AppDataHandler
    
    var body: some View {
            GroupBox {
                HStack {
                    Button {
                        dataHandler.showOptionsForTaskId = task.id
                    } label: {
                        VStack {
                            HStack {
                                Button(action: {
                                    // fill heart
                                    dataHandler.toggleLovedTask(taskId: task.id)
                                }) {
                                    Image(systemName: dataHandler.user.lovedTasks.contains(task.id) ? "heart.fill" : "heart")
                                }
                                if task.orderWeight > 0 {
                                    Text(task.orderWeight > 4 ? "!!!" : "!")
                                        .bold()
                                        .foregroundColor(.red)
                                }
                                Text(task.name)
                                Spacer()
                            }
                            .bold()
                            .font(.title3)
                            .foregroundColor(.accentColor)
                            
                            HStack {
                                Text("For:")
                                Text(functionsClass().floatToShortString(x: task.pointsToAdd) + " Points")
                                    .bold()
                                    .frame(minWidth: 30)
                                //Text(dataHandler.tasks.data.list[taskListNum].list[taskNum].name)
                                
                                Spacer()
                                
                                //                                    Button(action: {
                                //                                        // Add done task
                                //                                        withAnimation {
                                ////                                            TODO: Update
                                ////                                            dataHandler.updateTaskDone(taskId: task.id, count: task.counter+1)
                                //                                        }
                                //                                    }) {
                                //                                        Image(systemName: "plus.square.fill")
                                //                                            .font(.title)
                                //                                            .foregroundColor(.blue)
                                //                                    }.buttonStyle(PlainButtonStyle())
                                
                                
                                //                                    Button(action: {
                                //                                        showNumberPicker.toggle()
                                //                                    }) {
                                //                                        Text("\(task.counter)")
                                //                                    }.sheet(isPresented: $showNumberPicker) {
                                //                                        Number_Picker_View(task: task)
                                //                                    }.buttonStyle(PlainButtonStyle())
                                //                                        .frame(minWidth: 20)
                                
                                
                                //                                    Button(action: {
                                //                                        withAnimation {
                                ////                                        TODO: Update
                                ////                                            dataHandler.updateTaskDone(taskId: task.id, count: task.counter-1)
                                //                                        }
                                //                                    }) {
                                //                                        Image(systemName: "minus.square.fill")
                                //                                            .font(.title)
                                //                                            .foregroundColor(.blue)
                                //                                    }.buttonStyle(PlainButtonStyle())
                                
                                
                                //                                    Text("\(functionsClass().floatToShortString(x: task.archivedPoints))P")
                                //                                        .frame(minWidth: 30)
                                //                                        .padding(0)
                                
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    
                    Button {
                        withAnimation {
                            dataHandler.updateTaskDone(taskId: task.id, time: .now, message: "")
                            showDone = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showDone = false
                                }
                            }
                        }
                    } label: {
                        Image(systemName: showDone ? "checkmark.circle.fill" : "circle")
                            .font(.largeTitle)
                            .foregroundStyle(showDone ? Color.green : Color.accentColor)
                    }
                }
                    
            }.contextMenu(ContextMenu(menuItems: {
                NavigationLink(destination: ChangeTaskDetailView(task: task)) {
                    Text("Details")
                }
                Text("Delete")
                Button {
                    dataHandler.showOptionsForTaskId = task.id
                } label: {
                    Text("Options to select time")
                }
            }))
    }
}

struct TaskInListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskInListView(task: TaskStruct(name: "", id: "", listId: "", pointsToAdd: 0, howManyTimesDidAllUsers: 0, counter: .now, orderWeight: 0))
            .environmentObject(AppDataHandler())
    }
}
