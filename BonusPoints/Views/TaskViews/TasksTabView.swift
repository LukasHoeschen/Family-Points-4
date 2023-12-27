//
//  TasksTabView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 09.12.22.
//

import SwiftUI

struct TasksTabView: View {
    
    @EnvironmentObject var dataHandler: AppDataHandler
    @Environment(\.colorScheme) var colorScheme

    @State private var searchString = ""
    @State private var showNewTaskSheet = false
    @State private var actualTaskList = 0
    
    @State private var createNewTaskList = false
    @State private var createNewTaskListName = ""
    @State private var showDeleteListButton = false
    @State private var showDeleteListOnlyByParents = false
    @State private var deleteListSet: IndexSet = IndexSet()
    
    @State private var searchTasks: [TaskStruct] = []
    @FocusState private var focusedField: Bool?

    @State private var showOnlyPreferredTasks = false
    
    func deleteList(at offsets: IndexSet) {
        if dataHandler.user.role == .parent {
            deleteListSet = offsets
            showDeleteListButton = true
        } else {
            showDeleteListOnlyByParents = true
        }
    }
    
    func onMoveAction(source: IndexSet, destination: Int) {
        dataHandler.family.tasks.move(fromOffsets: source, toOffset: destination)
        dataHandler.settings.taskListSequence.move(fromOffsets: source, toOffset: destination)
        dataHandler.storeSettings()
    }
    
    
    var body: some View {
        NavigationStack {
            VStack {
                if searchString.isEmpty {
                    TabView(selection: $actualTaskList) {
                        
                        //MARK: Task List
                        ForEach(0..<dataHandler.family.tasks.count, id: \.self) { TaskList in
                            Group {
                                if dataHandler.family.tasks[TaskList].list.count > 0 {
                                        ScrollView {
                                            ForEach(dataHandler.family.tasks[TaskList].list, id: \.self) { t in
                                                if !showOnlyPreferredTasks || dataHandler.user.lovedTasks.contains(t.id) {
                                                    TaskInListView(task: t)
                                                        .contextMenu {
                                                            if dataHandler.user.role == .parent {
                                                                Button("Delete", role: .destructive) {
                                                                    dataHandler.deleteTask(taskId: t.id)
                                                                }
                                                            }
                                                        }
                                                }
                                            }
                                            Spacer()
                                                .frame(height: 30)
                                        }.padding(.horizontal)
                                            .refreshable {
                                                dataHandler.fetchAllData()
                                                print("refreshed list")
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
                                
                            }
//                            .onAppear {
//                                actualTaskList = TaskList
//                            }
                            .tag(TaskList)
                            .navigationTitle(dataHandler.family.tasks[TaskList].name)
                        }
                        
                        // MARK: Add new TaskListList
                        VStack {
                            List {
                                Section {
                                    ForEach(0..<dataHandler.family.tasks.count, id: \.self) { listIndex in
                                        let list = dataHandler.family.tasks[listIndex]
                                        Button(list.name) {
                                            withAnimation {
                                                actualTaskList = listIndex
                                            }
                                        }.foregroundStyle(Color.primary)
                                    }
                                    .onDelete(perform: deleteList)
                                    .onMove(perform: onMoveAction)
                                } footer: {
                                    Text("Lists can help you to organise your tasks based on specific topics. For instance, you could create a list for each family member or for categories such as cleaning or work.\nHere you can create new lists, sort or delete them.")
                                }
                            }.toolbar {

#if !os(macOS)
                                    EditButton()
#endif
                                if dataHandler.user.role == UserRole.parent {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            withAnimation {
                                                createNewTaskList.toggle()
                                            }
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                        }
                                        Spacer()
                                    }.sheet(isPresented: $createNewTaskList) {
                                        NavigationStack {
                                            Form {
                                                Section {
                                                    Label("Name", systemImage: "keyboard")
                                                        .foregroundColor(.green)
                                                    HStack {
                                                        Text("Name: ")
                                                        TextField("Please enter a name", text: $createNewTaskListName)
                                                    }
                                                }
                                                
                                                Section {
                                                    HStack {
                                                        Spacer()
                                                        Button(action: {
                                                            dataHandler.updateTaskList(name: createNewTaskListName) { res in
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
                                                }
                                            }
                                        }.presentationDetents([.fraction(0.3)])
                                            .presentationDragIndicator(.visible)
                                    }
                                }
                            }
                            .alert("Delete List?", isPresented: $showDeleteListButton, actions: {
                                Button("Cancel", role: .cancel, action: {})
                                Button("Delete", role: .destructive) {
                                    withAnimation {
                                        deleteListSet.forEach { i in
                                            dataHandler.deleteList(listId: dataHandler.family.tasks[i].id)
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
                        }.navigationTitle(dataHandler.user.role == .parent ? "Add a new List" : "Lists")
                            .tag(-1)
                    }
#if !os(macOS)
                    .tabViewStyle(.page(indexDisplayMode: .always))
#endif
                } else {
                    // MARK: Search Section
                    if searchTasks.count > 0 {
                        ScrollView {
                            ForEach(searchTasks, id: \.self) { i in
                                TaskInListView(task: i)
                                    .listRowInsets(EdgeInsets())
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        Text("No matching Tasks found.")
                        Spacer()
                    }
                    HStack {
                        Spacer()
                    }
                    .navigationTitle("Searching for: \(searchString)")
                }
                
                if actualTaskList != -1 {
                    VStack {
                        HStack {
                            Button(action: {
                                withAnimation {
                                    self.showOnlyPreferredTasks.toggle()
                                }
                            }) {
                                Image(systemName: showOnlyPreferredTasks ? "heart.fill" : "heart")
                            }
                            TextField("Search", text: $searchString)
                                .onChange(of: searchString) { _ in
                                    if searchString != "" {
                                        self.searchTasks = []
                                        dataHandler.family.tasks.forEach { l in
                                            l.list.forEach { t in
                                                if t.name.uppercased().contains(searchString.uppercased()) {
                                                    self.searchTasks.append(t)
                                                }
                                            }
                                        }
                                    }
                                }
                                .focused($focusedField, equals: true)
                            
                            Spacer()
                            
                            if searchString == "" {
                                Button(action: {
                                    showNewTaskSheet.toggle()
                                }, label: {
                                    Image(systemName: "plus")
                                        .font(.title2)
                                    //                                        .symbolRenderingMode(.palette)
                                    //                                        .foregroundStyle(Color.yellow, colorScheme == .light ? Color.gray : Color.clear)
                                }).sheet(isPresented: $showNewTaskSheet) {
                                    AddNewTaskView(actualTaskList: actualTaskList)
                                }
                            } else {
                                Button(action: {
                                    withAnimation {
                                        focusedField = nil
                                        searchString = ""
                                    }
                                }) {
                                    Text("Cancel")
                                }
                            }
                        }
                        .padding([.leading, .trailing, .top], 7)
                        
                        Divider()
                    }
                }
            }
            .animation(.easeInOut, value: actualTaskList)
//            .navigationTitle("Your Tasks")
            .toolbar {
                ToolbarItem() {
                    Button {
                        dataHandler.fetchAllData()
                    } label: {
                        Image(systemName: "arrow.circlepath")
                            .bold()
                    }
                }
                ToolbarItem() {
                    NavigationLink("\(Int(dataHandler.user.actualPoints))P", destination: {
                        TasksDetailView()
                    })
                        .bold()
                        .foregroundColor(.yellow)
                        .font(.title)
                }
            }
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
}

struct TasksTabView_Previews: PreviewProvider {
    static var previews: some View {
        TasksTabView()
            .environmentObject(AppDataHandler())
    }
}



