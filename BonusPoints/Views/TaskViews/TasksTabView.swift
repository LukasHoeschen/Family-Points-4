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
    @State private var currentTaskList: String? = nil
    
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
        Group {
            GeometryReader { geo in
                if geo.size.width < 800 {
                    NavigationStack {
                        List {
                            Section {
                                ForEach(dm.family.tasks) { taskList in
//                                    NavigationLink(value: taskList.id) {
                                    Button {
                                        currentTaskList = taskList.id
                                    } label: {
                                        VStack(alignment: .leading) {
                                            Text(taskList.name)
                                                .foregroundStyle(Color.accent)
                                                .font(.title2)
                                            Text("\(taskList.list.count) Tasks")
                                        }
                                    }.buttonStyle(.plain)
                                }.onMove(perform: onMoveAction)
                                    .onDelete(perform: deleteList)
                            }
                            
                            Section {
                                Button {
                                    withAnimation {
                                        createNewTaskList.toggle()
                                    }
                                } label: {
                                    Label("Add new List", systemImage: "plus")
                                }
                                
                                EditButton()
                            }.buttonStyle(.plain)
                        }
                        .navigationDestination(item: $currentTaskList) { id in
                            TasksListListView(taskListId: id)
                                .onAppear {
                                    actualTaskListId = id
                                }
                        }
                        .onAppear {
                            currentTaskList = actualTaskListId
                        }
                        .navigationTitle("My Lists")
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    dm.fetchAllData()
                                } label: {
                                    Image(systemName: "arrow.circlepath")
                                        .bold()
                                }
                            }
                            ToolbarItem(placement: .topBarTrailing) {
                                NavigationLink(destination: TasksDetailView()) {
                                    Text("\(Int(dm.user.actualPoints))P")
                                        .bold()
                                        .foregroundColor(.yellow)
                                        .font(.title)
                                }
                            }
                        }
                    }
                } else {
                    // MARK: For wide devices
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
                                }
                                
                                EditButton()
                            }
                        }
                        .navigationTitle("My Lists")
                        
                        
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
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    dm.fetchAllData()
                                } label: {
                                    Image(systemName: "arrow.circlepath")
                                        .bold()
                                }
                            }
                            ToolbarItem(placement: .topBarTrailing) {
                                NavigationLink(value: TasksViewRoute.statistics) {
                                    Text("\(Int(dm.user.actualPoints))P")
                                        .bold()
                                        .foregroundColor(.yellow)
                                        .font(.title)
                                }
                            }
                            
                            ToolbarItemGroup (placement: .bottomBar) {
                                HStack {
                                    NavigationLink {
                                        NavigationStack {
                                            Form {
                                                ForEach(dm.user.tasksDone) { t in
                                                    DoneTasksInListView(taskDone: t, showRemoveButton: true, userId: dm.user.id)
                                                }
                                                if dm.user.tasksDone.isEmpty {
                                                    ContentUnavailableView("No done tasks yet", systemImage: "xmark", description: Text("Mark some tasks as done to see them here."))
                                                }
                                            }.navigationTitle("Your done Tasks")
                                                .listSectionSpacing(5)
                                        }
                                    } label: {
                                        IconWithBadge(systemName: "list.bullet.rectangle", text: "Done Tasks", badgeCount: 0)
                                    }
                                    
                                    NavigationLink {
                                        FamilyView()
                                    } label: {
                                        IconWithBadge(systemName: "person.3", text: "Family", badgeCount: dm.familyBadge)
                                    }
                                    
                                    NavigationLink {
                                        SearchView()
                                    } label: {
                                        IconWithBadge(systemName: "magnifyingglass", text: "Search", badgeCount: 0)
                                    }
                                }.font(.caption)
                                    .padding()
                                    .glassEffect()
                                    .offset(x: 0, y: -10)
                                    .padding(.bottom)
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
        }
        .sheet(isPresented: $createNewTaskList) {
            NavigationStack {
                Form {
                    if dm.family.tasks.count < 4 || dm.family.premium {
                        Section("Name") {
                            TextField("e.g. Cleaning", text: $createNewTaskListName)
                                .onSubmit {
                                    dm.updateTaskList(name: createNewTaskListName) { res in
                                    }
                                    withAnimation {
                                        createNewTaskListName = ""
                                        createNewTaskList = false
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
                                        .foregroundColor(.accentColor)
                                }
                                Spacer()
                            }
                        }.navigationTitle("New List")
                            .navigationBarTitleDisplayMode(.inline)
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
                .refreshable {
                    dm.fetchAllData()
                }
            }.presentationDetents([.fraction(0.4), .large])
                .presentationDragIndicator(.visible)
        }
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
                        List {
                            ForEach(dm.family.tasks[index].list, id: \.self) { t in
                                if !showOnlyPreferredTasks || dm.user.lovedTasks.contains(t.id) {
                                    TaskInListView(task: t)
                                }
                            }
                        }
                            .refreshable {
                                dm.fetchAllData()
                            }
                            .navigationTitle(taskList.name)
                    } else {
                        ContentUnavailableView {
                            Label("List empty", systemImage: "list.dash")
                        } description: {
                            Text("No Tasks in this list yet")
                        } actions: {
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
                            withAnimation {
                                showOnlyPreferredTasks.toggle()
                            }
                        } label: {
                            Image(systemName: showOnlyPreferredTasks ? "heart.fill" : "heart")
                        }
                    }
                }
            } else {
                ContentUnavailableView("List not found", systemImage: "list.dash")
            }
        }
    }
}

struct IconWithBadge: View {
  let systemName: String
  let text: String
  let badgeCount: Int

  var body: some View {
    ZStack(alignment: .topTrailing) {
      VStack {
        Image(systemName: systemName)
        Text(text)
      }
      if badgeCount > 0 {
        Text("\(badgeCount)")
          .font(.caption2)
          .foregroundColor(.white)
          .padding(6)
          .background(Circle().foregroundColor(.red))
          .offset(x: 12, y: -8)
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



