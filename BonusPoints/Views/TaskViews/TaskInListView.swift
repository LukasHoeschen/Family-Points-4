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
    @State private var deleteTask = false
    
    @EnvironmentObject var dataHandler: AppDataHandler
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Button(action: {
                        dataHandler.toggleLovedTask(taskId: task.id)
                    }) {
                        Image(systemName: dataHandler.user.lovedTasks.contains(task.id) ? "heart.fill" : "heart")
                    }.buttonStyle(.plain)
                    
                    Text(task.name)
                    Spacer()
                }
                .bold()
                .font(.title3)
                .foregroundColor(.accentColor)
                
                HStack {
                    if task.orderWeight > 0 {
                        Text(task.orderWeight > 4 ? "!!!" : "!")
                            .bold()
                            .foregroundColor(.red)
                    }
                    Text("For:")
                    Text(functionsClass().floatToShortString(x: task.pointsToAdd))
                        .bold()
                    Text(task.pointsToAdd == 1 ? "Point" : "Points")
                        .bold()
                    
                    Spacer()
                    
                }
                .foregroundColor(.primary)
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
            }.buttonStyle(.plain)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            dataHandler.showOptionsForTaskId = task.id
        }
        .contextMenu {
            NavigationLink(destination: ChangeTaskDetailView(task: task)) {
                Text("Details")
            }
            //                Text("Delete")
            Button {
                dataHandler.showOptionsForTaskId = task.id
            } label: {
                Text("More Options")
            }
            if dataHandler.user.role == .parent {
                Button("Delete", role: .destructive) {
                    deleteTask = true
                }
            }
        }
        .alert("Delete Task?", isPresented: $deleteTask) {
            Button(role: .cancel) { }
            Button(role: .destructive) {
                dataHandler.deleteTask(taskId: task.id)
            }
        }
    }
}

struct TaskInListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskInListView(task: TaskStruct(name: "", id: "", listId: "", pointsToAdd: 0, howManyTimesDidAllUsers: 0, counter: .now, orderWeight: 0))
            .environmentObject(AppDataHandler())
    }
}
