//
//  ContentView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 07.12.22.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    
    @EnvironmentObject var dataHandler: AppDataHandler
    
    @Environment(\.requestReview) var requestReview
    @Environment(\.scenePhase) var scenePhase
    
    @State var taskDoneMessage = ""
    @State var moveTaskDoneOptions = false
    
    @AppStorage("AppOpenCount") var appOpenCount = 0
    
    @State var time = Date()
    
    @AppStorage("showSupportMe") var showSupportMe: Bool = false
//    @State var showSupportMe: Bool = true
    
    
    var body: some View {
        ZStack {
            
            if #available(iOS 17, *) {
                Text("")
                    .subscriptionStatusTask(for: "21626865") { taskState in
                        print("Fetched SubscriptionnState From Apple Or Like This")
                        if let statuses = taskState.value {
                            for status in statuses {
                                switch status.state {
                                case .subscribed:
            //                        if status.state.rawValue == 1 {
            //                            debugPrint("getSubscriptionStatus user subscription is active.")
            //                            return
            //                        } else {
            //                            debugPrint("getSubscriptionStatus user subscription is expiring.")
            //                            return
            //                        }
                                    print(status.state.localizedDescription)
                                    print("---")
                                    dataHandler.subscriptionToPro(status: true)
                                    return
                                case .inBillingRetryPeriod:
                                    debugPrint("getSubscriptionStatus user subscription is in billing retry period.")
                                    dataHandler.subscriptionToPro(status: true)
                                    return
                                case .inGracePeriod:
                                    debugPrint("getSubscriptionStatus user subscription is in grace period.")
                                    dataHandler.subscriptionToPro(status: true)
                                    return
                                case .expired:
                                    debugPrint("getSubscriptionStatus user subscription is expired.")
                                    dataHandler.subscriptionToPro(status: false)
                                    return
                                case .revoked:
                                    debugPrint("getSubscriptionStatus user subscription was revoked.")
                                    dataHandler.subscriptionToPro(status: false)
                                    return
                                default:
                                    fatalError("getSubscriptionStatus WARNING STATE NOT CONSIDERED.")
                                }
                            }
                        }
                        print("no status from subscription -> no premium")
                        //dataHandler.subscriptionToPro(status: false)
                        return
                    }
            }
            
            if dataHandler.family.id == "" || dataHandler.device.apiId == "" || dataHandler.user.id == "" {
                LoginView()
            } else {
                GeometryReader { geo in
                    ZStack {
                        if geo.size.width < 800 {
                            TabView {
                                Tab("Tasks", systemImage: "person") {
                                    TasksTabView()
                                }
                                
                                Tab("Done Tasks", systemImage: "list.bullet.rectangle") {
                                    NavigationStack {
                                        Form {
                                            ForEach(dataHandler.user.tasksDone) { t in
                                                DoneTasksListView(showRemoveButton: true, userId: dataHandler.user.id)
                                            }
                                            if dataHandler.user.tasksDone.isEmpty {
                                                ContentUnavailableView("No done tasks yet", systemImage: "xmark", description: Text("Mark some tasks as done to see them here."))
                                            }
                                        }.navigationTitle("Your done Tasks")
                                            .listSectionSpacing(5)
                                    }
                                }
                                
                                Tab("Family", systemImage: "person.3") {
                                    FamilyView()
                                }
                                .badge(dataHandler.familyBadge)
                                
                                Tab(role: .search) {
                                    SearchView()
                                }
                                
                            }
                        } else {
                            TasksTabView()
                        }
                        
                        // MARK: Detailed add comment, change date etc
                        if dataHandler.showOptionsForTaskId != nil {
                            let task = dataHandler.getTask(id: dataHandler.showOptionsForTaskId!)!
                            
                            VStack {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        moveTaskDoneOptions = false
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        dataHandler.showOptionsForTaskId = nil
                                    }
                                }
                                VStack {
                                    HStack {
                                        Text(task.name)
                                            .font(.headline)
                                        Spacer()
                                    }
                                    
                                    DatePicker("Completed at: ", selection: $time, displayedComponents: [.date, .hourAndMinute])
                                    
                                    TextField("Write a comment (optional)...", text: $taskDoneMessage, axis: .vertical)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(3, reservesSpace: true)
                                        .padding(8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                        )
                                    //                                    .textFieldStyle(.roundedBorder)
                                    
                                    HStack {
                                        Button("Cancel") {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                moveTaskDoneOptions = false
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                dataHandler.showOptionsForTaskId = nil
                                            }
                                        }.buttonStyle(.bordered)
                                            .tint(Color.blue)
                                        
                                        
                                        Button("Save") {
                                            dataHandler.updateTaskDone(taskId: task.id, time: time, message: taskDoneMessage)
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                moveTaskDoneOptions = false
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                dataHandler.showOptionsForTaskId = nil
                                            }
                                        }.buttonStyle(.borderedProminent)
                                    }
                                }
                                .frame(maxWidth: 600)
                                .padding()
                                .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                                .onAppear {
                                    taskDoneMessage = ""
                                    time = .now
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        moveTaskDoneOptions = true
                                    }
                                }
                            }.padding(5)
                                .offset(y: moveTaskDoneOptions ? 0 : 300)
                                .background(Color(red: 0.3, green: 0.3, blue: 0.3, opacity: 0.2))
                        }
                    }.sheet(isPresented: $dataHandler.settings.firstLogin, onDismiss: {
                        dataHandler.settings.firstLogin = false
                        dataHandler.storeSettings()
                    }) {
                        NavigationStack {
                            AddFamilyMemberView()
                        }
                        .presentationDetents([.fraction(0.7), .large])
                        
                    }
                    .sheet(isPresented: $showSupportMe) {
                        NavigationStack {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 20) {
                                    
                                    Text("As a student, I don’t earn much, and keeping apps available on the App Store comes with costs. If you enjoy using \"Family Points\", I’d really appreciate your support!")
                                        .font(.body)
                                    
                                    Text("Donate via [buyMeACoffee.com](https://buymeacoffee.com/hoeschenDevelopment)")
                                        .font(.headline)
                                    Text("Donate via [PayPal](https://paypal.me/hoeschenDevelopment)")
                                        .font(.headline)
                                    
                                    Button(action: {
                                        requestReview()
                                    }) {
                                        Label("Rate \"Family Points\"", systemImage: "star.fill")
                                            .font(.headline)
                                            .foregroundColor(.yellow)
                                    }
                                    
                                    ShareLink(item: URL(string: "https://apps.apple.com/us/app/family-points-app/id6741044966")!) {
                                        Label("Share with Friends", systemImage: "square.and.arrow.up")
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                            .navigationTitle("Support Me")
                        }
                        .presentationDetents([.height(400), .large])
                    }
                    .sheet(isPresented: $dataHandler.showSubscriptionStore, content: {
                        SubscriptionStoreView(productIDs: ["org.hoeschen.dev.familyPoints.pro.monthly", "org.hoeschen.dev.familyPoints.pro.annualy"])
                            .storeButton(.visible, for: .restorePurchases, .redeemCode)
                            .subscriptionStoreControlStyle(.prominentPicker)
                            .onInAppPurchaseCompletion { product, result in
                                dataHandler.showSubscriptionStore = false
                            }
                    })
                    .onChange(of: scenePhase) {
                        if scenePhase == .active {
                            dataHandler.fetchAllData()
                        }
                    }
                }
            }
                

            if dataHandler.showProgress {
                VStack {
                    HStack {
                        Spacer()
                    }
                    Spacer()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(3)
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                }.background(Color.init(red: 0.4, green: 0.4, blue: 0.4, opacity: 0.7))
            }
            
            
        }.onAppear {
            self.appOpenCount = self.appOpenCount + 1
            if self.appOpenCount % 200 == 50 {
                requestReview()
            }
            if self.appOpenCount % 400 == 70 {
                showSupportMe = true
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppDataHandler())
}
