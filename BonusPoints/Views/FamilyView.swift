//
//  FamilyView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 01.02.23.
//

import SwiftUI

struct FamilyView: View {
    
    @EnvironmentObject var dataHandler: AppDataHandler
    
    @State private var setPoints = ""
    @State private var changePoints = ""
    
    @State var showDeleteFamilyMember = false
    
    @State var userExportData: exportUserDataStruct = exportUserDataStruct(deviceId: "", userId: "", familyId: "", key: "noKey")
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                
                ForEach(0..<dataHandler.family.users.count, id: \.self) { i in
                    let user: UserStruct = dataHandler.family.users[i]
                    
                    NavigationLink(destination: {
                        
                        if user.tasksDone.count == 0 {
                            Text("When \(user.name) completes tasks, they will appear here for your approval. You can then choose to either accept or deny them. This way, you can award points only when the task has truly been completed.")
                                .padding(.horizontal)
                        }
                        
                        List(user.tasksDone, id: \.self) { t in
                            let task: TaskStruct = dataHandler.getTask(id: t.id) ?? TaskStruct(name: "error", id: "dd", listId: "dd", pointsToAdd: 1, howManyTimesDidAllUsers: 1, counter: 1, orderWeight: 1)
                            GroupBox {
                                VStack {
                                    HStack {
                                        Text("\(t.count) Times Completed")
                                        Spacer()
                                        Text("Add \(functionsClass().floatToShortString(x: Float(t.count) * task.pointsToAdd)) Points")
                                    }
                                    if dataHandler.user.role == .parent {
                                        HStack {
                                            Button("Accept") {
                                                dataHandler.family.users[i].actualPoints += Float(t.count) * task.pointsToAdd
                                                dataHandler.userUpdate(id: user.id)
                                                dataHandler.deleteTaskDone(taskId: t.id, userId: user.id)
                                                dataHandler.updateTaskAllUsersCount(taskId: t.id, allUsersCounter: task.howManyTimesDidAllUsers + t.count)
//                                                dataHandler.addToHistory(taskId: t.id, userId: user.id, count: t.count, date: .now)
                                            }.foregroundStyle(Color.green)
                                            Spacer()
                                            Button("Deny") {
                                                dataHandler.deleteTaskDone(taskId: t.id, userId: user.id)
                                            }.foregroundStyle(Color.red)
                                        }.buttonStyle(.bordered)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(task.name)
                                        .foregroundStyle(Color.accentColor)
                                    Spacer()
                                    Text("\(functionsClass().floatToShortString(x: task.pointsToAdd))P")
                                        .foregroundStyle(Color.yellow)
                                }
                            }
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .leading) {
                                    if dataHandler.user.role == .parent {
                                        Button {
                                            dataHandler.family.users[i].actualPoints += Float(t.count) * task.pointsToAdd
                                            dataHandler.userUpdate(id: user.id)
                                            dataHandler.deleteTaskDone(taskId: t.id, userId: user.id)
                                            dataHandler.updateTaskAllUsersCount(taskId: t.id, allUsersCounter: task.howManyTimesDidAllUsers + t.count)
//                                            dataHandler.addToHistory(taskId: t.id, userId: user.id, count: t.count, date: .now)
                                        } label: {
                                            Image(systemName: "checkmark.circle")
                                        }.tint(Color.green)
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    if dataHandler.user.role == .parent {
                                        Button(role: .destructive) {
                                            dataHandler.deleteTaskDone(taskId: t.id, userId: user.id)
                                        } label: {
                                            Image(systemName: "xmark.square")
                                        }
                                    }
                                }
                        }.listStyle(.plain)
                        .navigationTitle(user.name)
                        .toolbar {
                            Button {
                                dataHandler.fetchAllData()
                            } label: {
                                Image(systemName: "arrow.circlepath")
                                    .bold()
                            }
                            NavigationLink {
                                Form {
                                    Section("User Information") {
                                        HStack {
                                            Label("Role", systemImage: "person.2")
                                            Spacer()
                                            Text(user.role == .parent ? "Parent" : "Child")
                                        }
                                        
                                        HStack {
                                            Label("Account Created", systemImage: "calendar")
                                            Spacer()
                                            Text(user.getDate())
                                        }
                                        
                                        HStack {
                                            Label("Connected Devices", systemImage: "iphone")
                                            Spacer()
                                            Text(String(user.devices.count))
                                        }
                                        
                                        HStack {
                                            Label("Current Points", systemImage: "star.circle.fill")
                                            Spacer()
                                            Text(functionsClass().floatToShortString(x: user.actualPoints))
                                        }
                                        
                                        HStack {
                                            Label("Current Tasks Completed", systemImage: "checkmark.circle.fill")
                                            Spacer()
                                            Text(String(user.tasksDone.count))
                                        }
                                    }

                                    if dataHandler.user.role == .parent {
                                        Section("Change") {
                                            HStack {
                                                Label("Set Points", systemImage: "number")
                                                Spacer()
                                                TextField(functionsClass().floatToShortString(x: user.actualPoints), text: $setPoints)
                                                #if !os(macOS)
                                                    .keyboardType(.numbersAndPunctuation)
                                                #endif
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                                    .frame(width: 40, alignment: .center)
                                                    .multilineTextAlignment(.center)
                                                Button {
                                                    if Float(setPoints) != nil {
                                                        dataHandler.family.users[i].actualPoints = Float(setPoints)!
                                                        dataHandler.userUpdate(id: user.id)
                                                    }
                                                } label: {
                                                    Image(systemName: "checkmark")
                                                        .frame(width: 20, height: 20)
                                                }
                                            }
                                            HStack {
                                                Label("Change Points", systemImage: "arrow.right.circle")
                                                Spacer()
                                                Button {
                                                    if Float(changePoints) != nil {
                                                        dataHandler.family.users[i].actualPoints -= Float(changePoints)!
                                                        dataHandler.userUpdate(id: user.id)
                                                    }
                                                } label: {
                                                    Image(systemName: "minus")
                                                        .frame(width: 20, height: 20)
                                                }
                                                TextField("0", text: $changePoints)
                                                #if !os(macOS)
                                                    .keyboardType(.numbersAndPunctuation)
                                                #endif
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                                    .frame(width: 40)
                                                    .multilineTextAlignment(.center)
                                                Button {
                                                    if Float(changePoints) != nil {
                                                        dataHandler.family.users[i].actualPoints += Float(changePoints)!
                                                        dataHandler.userUpdate(id: user.id)
                                                    }
                                                } label: {
                                                    Image(systemName: "plus")
                                                        .frame(width: 20, height: 20)
                                                }
                                            }
                                        }.buttonStyle(.bordered)
                                        
                                        Section {
                                            Button("Delete Family Member") {
                                                showDeleteFamilyMember = true
                                            }.foregroundStyle(Color.red)
                                        }.confirmationDialog("", isPresented: $showDeleteFamilyMember, titleVisibility: Visibility.hidden) {
                                            Button("Delete", role: .destructive) {
                                                dataHandler.deleteUser(id: user.id)
                                            }
                                        }
                                        
                                        NavigationLink("Export your User") {
                                            Form {
                                                Section("Information") {
                                                    Text("**Proceed with caution.**")
                                                    Text("This feature allows you to export your user account along with all your private data and encryption key. While useful when transitioning to a new Apple device after selling your current one, it's essential to be mindful of the risks.")
                                                    Text("Please note that your data is exported without encryption, and your family's secret encryption key is stored in plain text.\n**Please do not delete your device or logout in this App on this device!**")
                                                }
                                                
                                                Section {
                                                    ShareLink(item: userExportData, preview: SharePreview("Family Points User Export")) {
                                                        Label("Export", systemImage: "square.and.arrow.up")
                                                    }
                                                    Text("Just open the file on your new device to log in again.")
                                                }.onAppear {
                                                    self.userExportData = exportUserDataStruct(deviceId: dataHandler.device.apiId, userId: user.id, familyId: dataHandler.family.id, key: dataHandler.AESCryptoKeyData?.base64EncodedString() ?? "noKey")
                                                }
                                            }.navigationTitle("Export User")
                                        }
                                    }
                                }.navigationTitle("Info")
                            } label: {
                                Image(systemName: "info.circle")
                            }
                        }
                        .onAppear {
                            setPoints = ""
                            changePoints = ""
                        }
                    }) {
                        GroupBox {
                            HStack {
                                Text(functionsClass().floatToShortString(x: user.actualPoints) + " Points")
                                Spacer()
                                Text("\(user.tasksDone.count) Tasks done")
                            }
                        } label: {
                            Label(user.name, systemImage: "person.circle.fill")
                                .foregroundColor(user.getColor())
                        }
                    }
                    
                }
                
            }.padding(.horizontal)
                .navigationTitle("Your Family")
                .toolbar {
                    #if os(macOS)
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                        }
                    }
                    #else
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                        }
                    }

                    if dataHandler.user.role == .parent {
                        ToolbarItem(placement: .navigationBarLeading) {
                            NavigationLink(destination: {
                                AddFamilyMemberView()
                            }) {
                                Image(systemName: "person.crop.circle.badge.plus")
                            }
                        }
                    }
                    #endif
                        
                }
                .onAppear {
                    dataHandler.fetchAllData()
                }
            
//            .onAppear {
//                dataHandler.family.tasks = [TaskList(id: "lid", name: "list", list: [TaskStruct(name: "Homework", id: "tid", listId: "lid", created: .now, pointsToAdd: 2, howManyTimesDidAllUsers: 3, counter: 1, orderWeight: 2)])]
//                dataHandler.family.users = [UserStruct(id: "id", name: "Luki", role: .parent, actualPoints: 2.2, everPoints: 2.3, tasksDoneCount: 2, created: .now, tasksDone: [TaskDoneStruct(id: "tid", count: 2),TaskDoneStruct(id: "tid", count: 2),TaskDoneStruct(id: "tid", count: 2)])]
//            }
        }
        
    }
}

struct FamilyView_Previews: PreviewProvider {
    static var previews: some View {
        FamilyView()
            .environmentObject(AppDataHandler())
    }
}
