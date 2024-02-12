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
        ZStack {
            if let task = dataHandler.getTask(id: taskDone.id) {
                GroupBox {
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
                            Button("Remove") {
                                dataHandler.deleteTaskDone(id: taskDone.doneId, userId: userId)
                            }.buttonStyle(.borderedProminent)
                        }
                        Spacer()
                        Text(functionsClass().dateAsString(d: taskDone.time))
                    }
//                    if showRemoveButton {
//                        Button("Remove") {
//                            
//                        }.buttonStyle(.borderedProminent)
//                    } else
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
                } label: {
                    HStack {
                        Text(task.name)
                            .foregroundStyle(Color.accentColor)
                        Spacer()
                        Text(functionsClass().dateToRelative(d: taskDone.time))
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
