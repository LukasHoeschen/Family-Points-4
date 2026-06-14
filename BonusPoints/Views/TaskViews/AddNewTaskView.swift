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
        if let d = Double(createNewTaskPointsToAdd) {
            let clampedD = min(10000, max(-10000, d))
            createNewTaskPointsToAdd = String((clampedD * 100).rounded() / 100)
        } else {
            createNewTaskPointsToAdd = ""
            fieldFocus = 1
            return
        }
        if createNewTaskName.isEmpty {
            fieldFocus = 0
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
                        FamilyPointsStoreView()
                    }
                } else {
                    Section {
                        TextField("e.g. Do homework", text: $createNewTaskName)
                            .focused($fieldFocus, equals: 0)
                            .onSubmit {
                                createNewTask()
                            }
                            .submitLabel(.return)
                    } header: {
                        Text("Name")
                            .foregroundStyle(.accent)
                    }
                    Section {
                            TextField("Number", text: $createNewTaskPointsToAdd)
                                .focused($fieldFocus, equals: 1)
#if !os(macOS)
                                .keyboardType(.numbersAndPunctuation)
#endif
                                .onSubmit {
                                    createNewTask()
                                }
                                .submitLabel(.return)
                    } header: {
                        Text("Points")
                            .foregroundStyle(.accent)
                    } footer: {
                        Text("These Points will be added if the Task is complete. Enter both positive and negative numbers.")
                    }
                    
                    Section {
                        HStack {
                            Text(String(Int(createNewTaskImportantNum)))
                                .bold()
                            
                            Slider(value: $createNewTaskImportantNum, in: -5...5, step: 1)
                        }
                    } header: {
                        Text("Importance")
                            .foregroundStyle(.accent)
                    } footer: {
                        Text("Adjust the importance level to priorities or de-priorities your tasks. Tasks will be sorted based on their importance.")
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
                
            }.navigationTitle("New Task")
                .navigationBarTitleDisplayMode(.inline)
        }.presentationDetents([.large, .fraction(0.7)])
            .presentationDragIndicator(.visible)
    }
}

struct AddNewTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewTaskView(actualTaskList: 0)
            .environmentObject(AppDataHandler())
    }
}
