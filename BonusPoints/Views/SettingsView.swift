//
//  SettingsView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 21.01.23.
//

import SwiftUI
import UserNotifications
import SwiftDate
//import StoreKit

struct SettingsView: View {
    
    @EnvironmentObject var dataHandler: AppDataHandler
    
    @State var newUserName = ""
    @State var newFamilyName = ""
    @State var edit = false
    
    @State var contactMessage = ""
    @State var showManageSubscription = false
    
    @State private var deleteDeviceApiId = ""
    @State private var showDeleteDeviceApiId = false
    @State private var logOutAlert = false
    @State private var logOutUserAlert = false
    @State private var logOutFamilyAlert = false
    
    var body: some View {
        
        Form {
            
            Section("Your Information") {
                HStack {
                    Label("Your Name", systemImage: "person.fill")
                        .bold()
                        .foregroundColor(.teal)
                    Spacer()
                    if edit {
                        TextField("Your first Name", text: $newUserName)
                            .submitLabel(.done)
                            .onSubmit {
                                dataHandler.user.name = newUserName
                                dataHandler.userUpdate()
                                edit = false
                            }
                    } else {
                        Text(dataHandler.user.name)
                    }
                }
                
                HStack {
                    Label("Your Role", systemImage: "person.fill")
                        .bold()
                        .foregroundColor(.teal)
                    Spacer()
                    Text(dataHandler.user.role == .children ? "Children" : "Parent")
                }
                if dataHandler.user.role == .parent {
                    NavigationLink {
                        NotificationSettingsView()
                            .navigationBarTitle("Notification Settings")
                    } label: {
                        Label("Notifications", systemImage: "calendar.badge.checkmark")
                    }
                }
            }
            
            Section("Your Devices") {
                NavigationLink {
                    ScrollView {
                        ForEach(dataHandler.user.devices, id: \.self) { d in
                            GroupBox {
                                HStack {
                                    Text("Device:")
                                    Spacer()
                                    Text(d.type)
                                }
                                HStack {
                                    Text("Created:")
                                    Spacer()
                                    Text(d.getDate())
                                }
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        deleteDeviceApiId = d.apiId
                                        showDeleteDeviceApiId.toggle()
                                    }) {
                                        Label("Remove", systemImage: "trash.fill")
                                            .foregroundColor(.red)
                                    }.alert("Remove Device?", isPresented: $showDeleteDeviceApiId, actions: {
                                            Button("Cancel", role: .cancel) {
                                            }
                                            Button("Remove", role: .destructive) {
                                                dataHandler.removeDevice(apiId: deleteDeviceApiId)
                                            }
                                        }, message: {
                                            Text("Do you really want to remove this Device?")
                                        })
                                    Spacer()
                                }
                            } label: {
                                Label(d.name, systemImage: d.osImage)
                            }
                        }
                    }
                    .navigationTitle("Your Devices")
                    .padding(.horizontal)
                        
                } label: {
                    Text("Your Devices")
                        .foregroundStyle(Color.blue)
                        .bold()
                }
                
//                Button("No-pro") {
//                    dataHandler.family.premium = false
//                    dataHandler.family.maxTasks = 4
//                    dataHandler.storeFamily()
//                    dataHandler.familyUpdate()
//                }
                
                NavigationLink(destination: {
                    
                    Form {
                        if dataHandler.family.premium {
                            Section {
                                Label("Your Personal Link-Key", systemImage: "key.fill")
                                Text("Use this key instead of creating a new user on your second device.")
                                
                                if dataHandler.user.linkKey.isEmpty {
                                    Button("Create a new Key") {
                                        withAnimation {
                                            dataHandler.joinUserFetchDevices()
                                        }
                                    }
                                } else {
                                    let keyArray = Array(dataHandler.user.linkKey)
                                    
                                    HStack {
                                        Spacer()
                                        
                                        ForEach(0..<keyArray.count, id: \.self) { k in
                                            GroupBox {
                                                Text(String(keyArray[k]))
                                                    .textCase(.uppercase)
                                                    .bold()
                                                    .font(.custom("Menlo", size: 17))
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                            
                            Section {
                                HStack {
                                    Label("Devices wanting to connect", systemImage: "exclamationmark.shield.fill")
                                        .foregroundColor(.yellow)
                                    Spacer()
                                    Button("Refresh") {
                                        dataHandler.joinUserFetchDevices()
                                    }
                                }
                                
                                ForEach(0..<dataHandler.user.devicesWantingToLink.count, id: \.self) { i in
                                    let d = dataHandler.user.devicesWantingToLink[i]
                                    GroupBox(d.name) {
                                        HStack {
                                            Text("Device:")
                                            Spacer()
                                            Text(d.type)
                                        }
                                        HStack {
                                            Text("Created:")
                                            Spacer()
                                            Text(d.created)
                                        }
                                        HStack {
                                            Button("Accept") {
                                                dataHandler.joinUserUpdateDeviceWantingToJoin(i: i, accept: true)
                                            }.foregroundColor(.green)
                                            Spacer()
                                            Button("Deny") {
                                                dataHandler.joinUserUpdateDeviceWantingToJoin(i: i, accept: false)
                                            }.foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                        } else {
                            Section {
                                Text("Multi-device connectivity is supported exclusively for subscribers.")
                            }
                            Section {
                                if dataHandler.user.role == .parent {
                                    HStack {
                                        Spacer()
                                        Button("Subscribe now") {
                                            dataHandler.showSubscriptionStore.toggle()
                                        }
                                        .bold()
                                        .buttonStyle(.borderedProminent)
                                        Spacer()
                                    }
                                    .listRowBackground(EmptyView())
                                } else {
                                    Text("Please ask your Parents for help.")
                                }
                            }
                        }
                        
                    }.navigationTitle("Connect new Device")
                    
                }) {
                    Label("Connect new Device", systemImage: "lock.display")
                        .bold()
                        .foregroundColor(.blue)
                }
            }
            
            Section("Your Family") {
                HStack {
                    Label("Name", systemImage: "person.3.fill")
                        .bold()
                        .foregroundColor(.green)
                    Spacer()
                    if edit && dataHandler.user.role == .parent {
                        TextField("Your last Name", text: $newFamilyName)
                            .submitLabel(.done)
                            .onSubmit {
                                edit = false
                                dataHandler.family.name = newFamilyName
                                dataHandler.familyUpdate()
                            }
                    } else {
                        Text(dataHandler.family.name)
                    }
                }
                
                if dataHandler.user.role == .parent {
                    NavigationLink(destination: {
                        AddFamilyMemberView()
                    }) {
                        Label("Add Family Member", systemImage: "person.crop.circle.badge.plus")
                            .bold()
                            .foregroundColor(.green)
                    }
                }
            }
            
            Section {
//                Button("Press Me") {
//                    print(dataHandler.family.premium)
//                }
                if dataHandler.user.role == .parent && !dataHandler.firstUsersPro {
                    if !dataHandler.family.premium {
                        NavigationLink {
                            Form {
                                FamilyPointsStoreView()
                            }
                        } label: {
                            Text("Upgrade Options")
                                .foregroundStyle(Color.accentColor)
                        }
                    } else {
                        Button("Manage your Subscription") {
                            showManageSubscription = true
                        }
                        .foregroundStyle(Color.accentColor)
                        .manageSubscriptionsSheet(isPresented: $showManageSubscription)
                    }
                }
                
                NavigationLink {
                    Form {
                        Section("The Idea Behind Family Points") {
                            Text("This app was inspired by an idea my sister came up with some time ago. Initially, we recorded our points on our fridge. To make this fantastic idea accessible to everyone, I created this app.")
                        }
                        
                        Section("Encryption") {
                            Text("All your data is end-to-end encrypted. Wondering how we store your data on our server? For example, your family name looks like this: \(dataHandler.encryptString(s: dataHandler.family.name))")
                            
                            #if !os(macOS)
                            if dataHandler.family.name == "Hoeschen" && dataHandler.user.name == "Lukas" {
                                Group {
                                    Text("This is only visible if your family name is \"Hoeschen\" and your user name is \"Lukas\". It seems like we have the same name!")
                                    Button("Copy my (unencrypted) Data") {
                                        UIPasteboard.general.string = dataHandler.getNiceJsonData()
                                    }
                                }
                            }
                            #endif
                        }
                        
                        Section("About Me") {
                            Text("I'm Lukas, a 18-year-old boy from Germany (2025). If you have ideas for new features or any suggestions, please feel free to contact me. Thank you so much for using my app.")
                            NavigationLink("Contact me") {
                                ScrollView {
                                    TextField("Write something...", text: $contactMessage, axis: .vertical)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(10, reservesSpace: true)
                                        .textFieldStyle(.roundedBorder)
                                    
                                    Text("Important Note: Your message will be transmitted and stored in plain text to facilitate communication. Please provide details and ensure it's at least 100 characters.")
                                                .foregroundColor(.secondary)
                                                .font(.footnote)
                                                .padding(.top, 8)
                                    
                                    Button("Send") {
                                        dataHandler.sendMessage(message: contactMessage)
                                        contactMessage = ""
                                    }.disabled(contactMessage.count < 100 || contactMessage.count > 5000)
                                        .buttonStyle(.borderedProminent)
                                }.navigationTitle("Contact")
                                    .padding(.horizontal)
                                    .scrollDismissesKeyboard(.interactively)
                            }
                            Link("Write me an Email", destination: URL(string: "mailto:heirs.airmail.0s@icloud.com")!)
                        }
                        
                        Section("Support Me") {
                            Text("I'm a Mechatronics student developing this app in my free time. It's kinda expensive to host servers storing your data and making Apps available at the App Store. That's actually the only reason im working with in App-Purchases. So, if you like my App, I'd really appreciate your support and I would love to hear your Feedback!")
                            Text("Donate via [buyMeACoffee.com](https://buymeacoffee.com/hoeschenDevelopment)")
                            Text("Donate via [PayPal](https://paypal.me/hoeschenDevelopment)")
                            RateThisAppHelperViewForSettingsView()
                        }
                    }
                    .navigationTitle("About")
                } label: {
                    Text("About & Contact")
                        .foregroundStyle(Color.accentColor)
                }

            }
            
            Section("Legal") {
                Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!, label: {
                    Text("Terms of Use")
                })
                Link(destination: URL(string: "https://lukas.hoeschen.org/apps/bonusPoints/privacyPolicy/index.html")!, label: {
                    Text("Privacy Policy")
                })
            }
            
            Section {
                NavigationLink("Log out") {
                    Form {
                        Section {
                            Button("Log out") {
                                logOutAlert = true
                            }.foregroundStyle(Color.red)
                        } footer: {
                            Text("Logging out will delete all your data on this device. Your account (\(dataHandler.user.name)) won't be deleted on our servers, but you'll need to export your account information and import it on your new device. If you have a second device connected to your account, you can use it to set up your new device.")
                        }
                        if dataHandler.user.role == .parent {
                            Section {
                                Button("Delete your User") {
                                    logOutUserAlert = true
                                }.foregroundStyle(Color.red)
                            } footer: {
                                Text("Deleting your user will remove all your user data (\(dataHandler.user.name)) stored on our servers. Your account cannot be reinstalled.")
                            }
                            Section {
                                Button("Delete your Family") {
                                    logOutFamilyAlert = true
                                }.foregroundStyle(Color.red)
                            } footer: {
                                Text("Deleting your family (\(dataHandler.family.name)) will erase all your data from our servers, including tasks, lists, family members, and their devices. This action cannot be undone.")
                            }
                        }
                    }.navigationTitle("Log out")
                }
            }
            
        }
        .alert("Log out", isPresented: $logOutAlert, actions: {
                Button("Cancel", role: .cancel, action: {
                    // nothing when canceled
                })
                Button("Log out", role: .destructive, action: {
                    dataHandler.logOut()
                })
            }, message: {
                Text("Do you really want to log out?")
            })
        .alert("Log out", isPresented: $logOutUserAlert, actions: {
                Button("Cancel", role: .cancel, action: {
                    // nothing when canceled
                })
                Button("Delete User", role: .destructive, action: {
                    dataHandler.deleteUser(id: dataHandler.user.id)
                })
            }, message: {
                Text("Do you really want to delete your User-Account, all connected Devices and Data?")
            })
        .alert("Log out", isPresented: $logOutFamilyAlert, actions: {
                Button("Cancel", role: .cancel, action: {
                    // nothing when canceled
                })
                Button("Delete Family", role: .destructive, action: {
                    dataHandler.deleteFamily()
                })
            }, message: {
                Text("Do you really want to delete your Family, all connected Users, Devices and Data?")
            })
            .navigationTitle("Settings")
            .toolbar {
                Button {
                    edit.toggle()
                } label: {
                    Image(systemName: edit ? "pencil.circle.fill" : "pencil.circle")
                }
            }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppDataHandler())
}

struct RateThisAppHelperViewForSettingsView: View {
    
    @Environment(\.requestReview) var requestReviewHere
    
    var body: some View {
            Button("Rate Family Points") {
                requestReviewHere()
            }
    }
}




struct NotificationSettingsView: View {
    @State private var selectedDay = Date()
    @AppStorage("NotificationScheduledOnDayMon") private var mon = false
    @AppStorage("NotificationScheduledOnDayTue") private var tue = false
    @AppStorage("NotificationScheduledOnDayWed") private var wed = false
    @AppStorage("NotificationScheduledOnDayThu") private var thu = false
    @AppStorage("NotificationScheduledOnDayFri") private var fri = false
    @AppStorage("NotificationScheduledOnDaySat") private var sat = false
    @AppStorage("NotificationScheduledOnDaySun") private var sun = false
    @State private var selectedTime = Date()

    var body: some View {
        Form {
            Section("Select Days") {
                HStack {
                    Button(action: {
                        mon.toggle()
                    }) {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(mon ? Color.accentColor : Color.gray)
                            .overlay(Text("Mon").foregroundColor(.white))
                    }
                    Button(action: {
                        tue.toggle()
                    }) {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(tue ? Color.accentColor : Color.gray)
                            .overlay(Text("Tue").foregroundColor(.white))
                    }
                    Button(action: {
                        wed.toggle()
                    }) {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(wed ? Color.accentColor : Color.gray)
                            .overlay(Text("Wed").foregroundColor(.white))
                    }
                    Button(action: {
                        thu.toggle()
                    }) {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(thu ? Color.accentColor : Color.gray)
                            .overlay(Text("Thu").foregroundColor(.white))
                    }
                    Button(action: {
                        fri.toggle()
                    }) {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(fri ? Color.accentColor : Color.gray)
                            .overlay(Text("Fri").foregroundColor(.white))
                    }
                    Button(action: {
                        sat.toggle()
                    }) {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(sat ? Color.accentColor : Color.gray)
                            .overlay(Text("Sat").foregroundColor(.white))
                    }
                    Button(action: {
                        sun.toggle()
                    }) {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(sun ? Color.accentColor : Color.gray)
                            .overlay(Text("Sun").foregroundColor(.white))
                    }
                }.buttonStyle(.plain)
            }

            Section(header: Text("Select Time")) {
                DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
            }

            Button("Save Changes") {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        updateNotifications()
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }

    
    func updateNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        // Schedule notifications for selected days
        scheduleNotification(on: 2, isActive: mon) // Monday
        scheduleNotification(on: 3, isActive: tue) // Tuesday
        scheduleNotification(on: 4, isActive: wed) // Wednesday
        scheduleNotification(on: 5, isActive: thu) // Thursday
        scheduleNotification(on: 6, isActive: fri) // Friday
        scheduleNotification(on: 7, isActive: sat) // Saturday
        scheduleNotification(on: 1, isActive: sun) // Sunday
    }

    func scheduleNotification(on weekday: Int, isActive: Bool) {
        guard isActive else { return }

        var dateComponents = DateComponents()
        dateComponents.weekday = weekday
        dateComponents.hour = Calendar.current.component(.hour, from: selectedTime)
        dateComponents.minute = Calendar.current.component(.minute, from: selectedTime)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "Family Points Reminder"
        content.body = "Remember to check if your Kids completed some Tasks"
        
        let request = UNNotificationRequest(identifier: "\(weekday)", content: content, trigger: trigger)
        
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully for \(weekday)")
            }
        }
    }
}

