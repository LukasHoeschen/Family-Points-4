//
//  DoneTasksListView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 11.02.24.
//

import SwiftUI
import SwiftDate

struct DoneTasksInListView: View {
    
    @EnvironmentObject var dataHandler: AppDataHandler
    
    @State var taskDone: TaskDoneStruct
    let showRemoveButton: Bool
    let userId: String
    
    var body: some View {
        if let task = dataHandler.getTask(id: taskDone.id) {
            Section {
                VStack {
                    HStack {
                        Text(task.name)
                            .foregroundStyle(Color.accentColor)
                        Spacer()
                        Text(functionsClass().dateToRelative(d: taskDone.time))
                    }.bold()
                    if taskDone.message != "" {
                        HStack {
                            Text(taskDone.message)
                            Spacer()
                        }
                    }
                    HStack {
                        Text("for \(functionsClass().floatToShortString(x: task.pointsToAdd)) Points")
                            .foregroundStyle(Color.yellow)
                        Spacer()
                        if showRemoveButton {
                            Menu {
                                Text("Remove? This task wasn't accepted yet.")
                                Button(role: .destructive) {
                                    dataHandler.deleteTaskDone(id: taskDone.doneId, userId: userId)
                                }
                            } label: {
                                Text("Remove")
                            }.buttonStyle(.borderedProminent)
                        }
                        Spacer()
                        Text(functionsClass().dateAsString(d: taskDone.time))
                    }
                    if dataHandler.user.role == .parent && !showRemoveButton {
                        HStack {
                            Spacer()
                            Button("Accept") {
                                dataHandler.acceptTaskDone(taskId: taskDone.id, userId: userId, doneId: taskDone.doneId)
                            }.tint(.green)
                            Spacer()
                            Spacer()
                            Button("Deny") {
                                dataHandler.deleteTaskDone(id: taskDone.doneId, userId: userId)
                            }.tint(.red)
                            Spacer()
                        }.buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }
}

#Preview {
    DoneTasksInListView(taskDone: TaskDoneStruct(doneId: "", id: "", time: .now, message: "no message"), showRemoveButton: false, userId: "")
        .environmentObject(AppDataHandler())
}
