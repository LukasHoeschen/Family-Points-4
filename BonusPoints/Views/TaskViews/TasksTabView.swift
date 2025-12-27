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

    @AppStorage("currentSeenTaskList") var actualTaskListId: String = ""
    
    @State private var createNewTaskList = false
    @State private var createNewTaskListName = ""
    @State private var showDeleteListButton = false
    @State private var showDeleteListOnlyByParents = false
    @State private var deleteListSet: IndexSet = IndexSet()
    
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
                        NavigationLink(value: TasksViewRoute.taskList(id: taskList.id)) {
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
                case .taskList(let id):
                    TasksListListView(taskListId: id)
                        .onAppear {
                            actualTaskListId = id
                        }
                case .statistics:
                    TasksDetailView()
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
            if dm.family.tasks.contains(where: {$0.id == actualTaskListId}) {
                TasksListListView(taskListId: actualTaskListId)
            } else if !dm.family.tasks.isEmpty  {
                TasksListListView(taskListId: dm.family.tasks.first?.id ?? "")
            } else {
                Text("Please select a List")
            }
        }
    }
}

enum TasksViewRoute: Hashable {
    case taskList(id: String)
    case statistics
}

struct TasksListListView: View {
    
    @EnvironmentObject var dm: AppDataHandler
    
    var taskListId: String
    
    @State private var showOnlyPreferredTasks = false
    @State private var showNewTaskSheet = false
    
    var body: some View {
        NavigationStack {
            if let index = dm.family.tasks.firstIndex(where: { $0.id == taskListId }) {
                let taskList = dm.family.tasks[index]
                Group {
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
                            .navigationTitle(taskList.name)
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
                }
                .sheet(isPresented: $showNewTaskSheet) {
                    AddNewTaskView(actualTaskList: index)
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            showNewTaskSheet = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showOnlyPreferredTasks.toggle()
                        } label: {
                            Image(systemName: showOnlyPreferredTasks ? "heart.fill" : "heart")
                        }
                    }
                }
            } else {
                Text("List not found")
            }
        }
    }
}


struct TasksTabView_Previews: PreviewProvider {
    static var previews: some View {
        TasksTabView()
            .environmentObject(AppDataHandler())
    }
}



