//
//  TasksTabView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 09.12.22.
//

import SwiftUI

struct TasksTabView: View {
    
    @EnvironmentObject var dm: AppDataHandler
    @Environment(\.colorScheme) var colorScheme

    @State private var searchString = ""
    @State private var showNewTaskSheet = false
    @AppStorage("currentSeenTaskList") var actualTaskList: Int = 0
    
    @State private var createNewTaskList = false
    @State private var createNewTaskListName = ""
    @State private var showDeleteListButton = false
    @State private var showDeleteListOnlyByParents = false
    @State private var deleteListSet: IndexSet = IndexSet()
    
    @State private var searchTasks: [TaskStruct] = []
    @FocusState private var focusedField: Bool?

    @State private var showOnlyPreferredTasks = false
    
    func deleteList(at offsets: IndexSet) {
        if dm.user.role == .parent {
            deleteListSet = offsets
            showDeleteListButton = true
        } else {
            showDeleteListOnlyByParents = true
        }
    }
    
    func onMoveAction(source: IndexSet, destination: Int) {
        dm.family.tasks.move(fromOffsets: source, toOffset: destination)
        dm.settings.taskListSequence.move(fromOffsets: source, toOffset: destination)
        dm.storeSettings()
    }
    
    
    var body: some View {
        NavigationSplitView {
            List {
                Section {
                    ForEach(dm.family.tasks) { taskList in
                        NavigationLink(value: TasksViewRoute.taskList(taskList)) {
                            VStack(alignment: .leading) {
                                Text(taskList.name)
                                    .foregroundStyle(Color.accent)
                                    .font(.title2)
                                Text("\(taskList.list.count) Tasks")
                            }
                        }
                    }.onMove(perform: onMoveAction)
                        .onDelete(perform: deleteList)
                }
                
                Section {
                    Button {
                        withAnimation {
                            createNewTaskList.toggle()
                        }
                    } label: {
                        Label("Add List", systemImage: "plus")
                    }.sheet(isPresented: $createNewTaskList) {
                        NavigationStack {
                            Form {
                                if dm.family.tasks.count < 4 || dm.family.premium {
                                    Section {
                                        Label("Name", systemImage: "keyboard")
                                            .foregroundColor(.green)
                                        HStack {
                                            Text("Name: ")
                                            TextField("Name new List", text: $createNewTaskListName)
                                                .onSubmit {
                                                    dm.updateTaskList(name: createNewTaskListName) { res in
                                                    }
                                                    withAnimation {
                                                        createNewTaskListName = ""
                                                        createNewTaskList = false
                                                    }
                                                }
                                        }
                                    }
                                    
                                    Section {
                                        HStack {
                                            Spacer()
                                            Button(action: {
                                                dm.updateTaskList(name: createNewTaskListName) { res in
                                                }
                                                withAnimation {
                                                    createNewTaskListName = ""
                                                    createNewTaskList = false
                                                }
                                            }) {
                                                Text("Create")
                                                    .foregroundColor(.blue)
                                            }
                                            Spacer()
                                        }
                                    }.navigationTitle("New List")
                                } else {
                                    Section {
                                        Text("To create more Lists, please subscribe to Family Points Pro.")
                                    }
                                    if dm.user.role == .parent {
                                        Section {
                                            FamilyPointsStoreView()
                                        }
                                    }
                                }
                            }.toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button(role: .close) {
                                        createNewTaskList = false
                                    }
                                }
                            }
                        }.presentationDetents([.fraction(0.4), .large])
                            .presentationDragIndicator(.visible)
                    }
                    
                    
                    EditButton()
                }
            }
            .navigationTitle("My Lists")
            .alert("Delete List?", isPresented: $showDeleteListButton, actions: {
                Button("Cancel", role: .cancel, action: {})
                Button("Delete", role: .destructive) {
                    withAnimation {
                        deleteListSet.forEach { i in
                            dm.deleteList(listId: dm.family.tasks[i].id)
                        }
                    }
                }
            }, message: {
                Text("Do you really want to delete this list with all tasks? This can't be undo.")
            })
            .alert("Delete List", isPresented: $showDeleteListOnlyByParents, actions: {
                Button("OK", role: .cancel, action: {})
            }, message: {
                Text("Only parents can delete Lists.")
            })
            
            //MARK: Detail View
            .navigationDestination(for: TasksViewRoute.self) { route in
                switch route {
                case .taskList(let taskList):
                    NavigationStack {
                        if let index = dm.family.tasks.firstIndex(where: { $0.id == taskList.id }) {
                            if dm.family.tasks[index].list.count > 0 {
                                ScrollView {
                                    ForEach(dm.family.tasks[index].list, id: \.self) { t in
                                        if !showOnlyPreferredTasks || dm.user.lovedTasks.contains(t.id) {
                                            TaskInListView(task: t)
                                                .contextMenu {
                                                    if dm.user.role == .parent {
                                                        Button("Delete", role: .destructive) {
                                                            dm.deleteTask(taskId: t.id)
                                                        }
                                                    }
                                                }
                                        }
                                    }
                                    Spacer()
                                        .frame(height: 30)
                                }.padding(.horizontal)
                                    .refreshable {
                                        dm.fetchAllData()
                                    }
                            } else {
                                VStack {
                                    Text("No Tasks in this list yet")
                                    Spacer()
                                        .frame(height: 10)
                                    Button(action: {
                                        showNewTaskSheet = true
                                    }) {
                                        Text("Add a new Task")
                                    }
                                }
                            }
                        } else {
                            Text("List not found")
                        }
                    }
                case .statistics:
                    NavigationStack {
                        TasksDetailView()
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        dm.fetchAllData()
                    } label: {
                        Image(systemName: "arrow.circlepath")
                            .bold()
                    }
                }
                ToolbarItem {
                    NavigationLink(value: TasksViewRoute.statistics) {
                        Text("\(Int(dm.user.actualPoints))P")
                        .bold()
                        .foregroundColor(.yellow)
                        .font(.title)
                    }
                }
            }
        } detail: {
            Text("Please select a List")
        }
    }
}

enum TasksViewRoute: Hashable {
    case taskList(TaskList)
    case statistics
}


struct TasksTabView_Previews: PreviewProvider {
    static var previews: some View {
        TasksTabView()
            .environmentObject(AppDataHandler())
    }
}



