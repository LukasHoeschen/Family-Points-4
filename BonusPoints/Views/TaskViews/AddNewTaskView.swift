//
//  AddNewTaskView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 21.01.23.
//

import SwiftUI

struct AddNewTaskView: View {
    
    @EnvironmentObject var dataHandler: AppDataHandler

    @State var actualTaskList: Int
    
    @State var createNewTaskName = ""
    @State var createNewTaskPointsToAdd = ""
    @State var createNewTaskImportantNum = 0.0
    
    @Environment(\.presentationMode) var presentationMode
    
    @FocusState var fieldFocus: Int?

    
    func createNewTask() {
        if createNewTaskName.isEmpty {
            fieldFocus = 0
            return
        }
        if createNewTaskPointsToAdd.isEmpty || Float(createNewTaskPointsToAdd) == nil {
            createNewTaskPointsToAdd = ""
            fieldFocus = 1
            return
        }
        dataHandler.updateTask(taskListId: dataHandler.family.tasks[actualTaskList].id, name: createNewTaskName, pointsToAdd: Float(createNewTaskPointsToAdd) ?? 1, orderWeight: Int(createNewTaskImportantNum), created: .now)
        presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        NavigationStack {
            
            Form {
                if dataHandler.countTasks() >= dataHandler.family.maxTasks && !dataHandler.family.premium {
                    Section {
                        Text("Your family has reached its task limit.")

                        if dataHandler.user.role == .children {
                            Text("To create more tasks, please kindly request your parents to unlock them.")
                        }
                    }
                    
                    if dataHandler.user.role == .parent {
                        BonusPointsStoreView()
                    }
                } else {
                    Section {
                        Label("Name of new Task", systemImage: "keyboard")
                            .foregroundColor(.green)
                        HStack {
                            Text("Name:")
                            TextField("Please enter the Task Name", text: $createNewTaskName)
                                .focused($fieldFocus, equals: 0)
                                .onSubmit {
                                    createNewTask()
                                }
                        }
                    }
                    Section {
                        Label("Points to add if the Task is completed", systemImage: "number.circle")
                            .foregroundColor(.blue)
                        HStack {
                            Text("Points:")
                            TextField("Enter points value (e.g., -0.5)", text: $createNewTaskPointsToAdd)
                                .focused($fieldFocus, equals: 1)
#if !os(macOS)
                                .keyboardType(.numbersAndPunctuation)
#endif
                                .onSubmit {
                                    createNewTask()
                                }
                        }
                    }
                    
                    Section {
                        Label("Importance", systemImage: "exclamationmark.square")
                            .foregroundColor(.red)
                        
                        HStack {
                            Text(String(Int(createNewTaskImportantNum)))
                                .bold()
                            
                            Slider(value: $createNewTaskImportantNum, in: -5...5, step: 1)
                        }
                    } footer: {
                        Text("Adjust the importance level to prioritise or de-prioritise your tasks. Tasks will be sorted based on their importance.")
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            createNewTask()
                        }) {
                            Text("Create")
                        }
                        Spacer()
                    }
                    
                }
                
            }.navigationTitle("Create a new Task")

        }.presentationDetents([.fraction(0.7), .large])
            .presentationDragIndicator(.visible)
    }
}

struct AddNewTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewTaskView(actualTaskList: 0)
            .environmentObject(AppDataHandler())
    }
}
