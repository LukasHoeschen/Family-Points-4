//
//  DoneTasksListView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 11.02.24.
//

import SwiftUI

struct DoneTasksInListView: View {
    
    @EnvironmentObject var dataHandler: AppDataHandler
    
    @State var list: [TaskDoneStruct]
    
    var body: some View {
        ScrollView {
            Button("Button") {
                print(dataHandler.user.tasksDone)
            }
            Text("Hi")
            ForEach(list) { t in
                if let task = dataHandler.getTask(id: t.id) {
                    Text(task.id)
                }
            }
        }
    }
}

#Preview {
    DoneTasksInListView(list: [])
}
