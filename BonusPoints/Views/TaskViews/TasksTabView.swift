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
    @State private var path = NavigationPath()
    @State private var stackId = UUID()
    
    @State private var createNewTaskList = false
    @State private var createNewTaskListName = ""
    @State private var showDeleteListButton = false
    @State private var showDeleteListOnlyByParents = false
    @State private var deleteListSet: IndexSet = IndexSet()
    
    @State private var selection: TasksViewRoute? = nil
    
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
                if geo.size.width < 800 || UIDevice.current.userInterfaceIdiom == .phone{
                    // small App Window / iPhone
                    NavigationStack {
                        sideBar(geo: geo)
                        .navigationDestination(item: $selection) { _ in
                            detail(selection: selection)
                        }
                        .navigationTitle("My Lists")
                    }
                } else {
                    // MARK: For wide devices
                    NavigationSplitView {
                        sideBar(geo: geo)
                    } detail: {
                        detail(selection: selection)
                    }.navigationSplitViewStyle(.balanced)
                }
            }
        }
        .onAppear {
            selection = .taskList(id: actualTaskListId)
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
    
    func detail(selection: TasksViewRoute?) -> some View {
        Group {
            switch selection {
            case .taskList(let id):
                TasksListListView(taskListId: id)
                    .onAppear { actualTaskListId = id }
            case .statistics:
                StatisticsView()
            case .doneTasks:
                NavigationStack {
                    Form {
                        DoneTasksListView(showRemoveButton: true, userId: dm.user.id)
                    }.navigationTitle("Your done Tasks")
                }
            case .search:
                SearchView()
            case .family:
                NavigationStack {
                    FamilyView()
                }
            case nil:
                Text("Please select a List")
            }
        }.environmentObject(dm)
    }
    
    func sideBar(geo: GeometryProxy) -> some View {
        List {
            Section {
                ForEach(dm.family.tasks) { taskList in
                    Button { selection = .taskList(id: taskList.id) } label: {
                        VStack(alignment: .leading) {
                            Text(taskList.name)
                                .foregroundStyle(Color.accentColor)
                                .font(.title2)
                                .fontWeight(selection == .taskList(id: taskList.id) ? .bold : .medium)
                            Text("\(taskList.list.count) Tasks")
                                .foregroundStyle(selection == .taskList(id: taskList.id) ? Color.primary : Color.secondary)
                        }
                    }
                }
                .onMove(perform: onMoveAction)
                .onDelete(perform: deleteList)
            }
            
            Section {
                Button {
                    withAnimation { createNewTaskList.toggle() }
                } label: {
                    Label("Add List", systemImage: "plus")
                }
                EditButton()
                    .foregroundStyle(.primary)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("My Lists")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dm.fetchAllData() } label: {
                    Image(systemName: "arrow.circlepath").bold()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { selection = .statistics } label: {
                    Text("\(Int(dm.user.actualPoints))P")
                        .bold()
                        .foregroundColor(.yellow)
                        .font(.title)
                }
            }
            if geo.size.width > 800 {
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack {
                        Button { selection = .doneTasks } label: {
                            IconWithBadge(systemName: "list.bullet.rectangle", text: String(localized: "Done Tasks"), badgeCount: 0)
                        }
                        .foregroundStyle(selection == .doneTasks ? Color.accentColor : Color.primary)
                        .fontWeight(selection == .doneTasks ? .bold : .regular)
                        
                        Button { selection = .family } label: {
                            IconWithBadge(systemName: "person.3", text: String(localized: "Family"), badgeCount: dm.familyBadge)
                        }
                        .foregroundStyle(selection == .family ? Color.accentColor : Color.primary)
                        
                        Button { selection = .search } label: {
                            IconWithBadge(systemName: "magnifyingglass", text: String(localized: "Search"), badgeCount: 0)
                        }
                        .foregroundStyle(selection == .search ? Color.accentColor : Color.primary)
                    }
                    .font(.caption)
                    .padding()
                    .glassEffect()
                    .offset(x: 0, y: -10)
                    .padding(.bottom)
                }
            }
        }
    }
}

enum TasksViewRoute: Hashable {
    case taskList(id: String)
    case statistics
    case doneTasks
    case search
    case family
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
                        .environmentObject(dm)
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
        Group {
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
        }    }
}





struct TasksTabView_Previews: PreviewProvider {
    static var previews: some View {
        TasksTabView()
            .environmentObject(AppDataHandler())
    }
}



