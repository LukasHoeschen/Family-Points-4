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
    
    var body: some View {
        Group {
            if let user = dm.family.users.first(where: {$0.id == userId}) {
                ForEach(user.tasksDone) { taskDone in
                    DoneTasksInListView(taskDone: taskDone, showRemoveButton: showRemoveButton, userId: userId)
                        .onAppear {
                            listEmpty = false
                        }
                }
                if listEmpty {
                    if showRemoveButton {
                        ContentUnavailableView("No done tasks yet", systemImage: "xmark", description: Text("Mark some tasks as done to see them here."))
                    } else {
                        ContentUnavailableView("No done tasks", systemImage: "checkmark", description: Text("There are no completed tasks right now. Please try again later."))
                    }
                }
            } else {
                ContentUnavailableView("Family Member not found", systemImage: "xmark")
            }
        }
            .listSectionSpacing(5)
    }
}

#Preview {
    DoneTasksListView(showRemoveButton: true, userId: "none")
}
