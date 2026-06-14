//
//  DoneTasksListView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 12.05.26.
//

import SwiftUI

struct DoneTasksListView: View {
    @EnvironmentObject var dm: AppDataHandler
    
    @State private var listEmpty: Bool = true
    
    let showRemoveButton: Bool
    let userId: String
    
    var tasksDone: [TaskDoneStruct]? {
        guard let tasks = dm.family.users.first(where: {$0.id == userId})?.tasksDone else {
            return nil
        }
        return tasks.sorted(by: {$0.time < $1.time})
    }
    
    var body: some View {
        Group {
            if let tasksDone {
                ForEach(tasksDone, id: \.doneId) { taskDone in
                    DoneTasksInListView(taskDone: taskDone, showRemoveButton: showRemoveButton, userId: userId)
                        .onAppear {
                            listEmpty = false
                        }
                }
                if listEmpty {
                    if showRemoveButton {
                        ContentUnavailableView("No done tasks", systemImage: "checklist", description: Text("Mark some tasks as done to see them here."))
                    } else {
                        ContentUnavailableView("No done tasks", systemImage: "checkmark", description: Text("There are no completed tasks right now. Please try again later."))
                    }
                }
            } else {
                ContentUnavailableView("Family Member not found", systemImage: "person.slash")
            }
        }
            .listSectionSpacing(5)
    }
}

#Preview {
    DoneTasksListView(showRemoveButton: true, userId: "none")
}
