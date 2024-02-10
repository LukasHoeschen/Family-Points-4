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
    
    @AppStorage("AppOpenCount") var appOpenCount = 0
    
    var body: some View {
        ZStack {
            
            if #available(iOS 17, *) {
                Text("")
                    .subscriptionStatusTask(for: "21430283") { taskState in
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
                                    dataHandler.subscriptionToPro(status: true)
                                case .inBillingRetryPeriod:
                                    debugPrint("getSubscriptionStatus user subscription is in billing retry period.")
                                    dataHandler.subscriptionToPro(status: false)
                                    return
                                case .inGracePeriod:
                                    debugPrint("getSubscriptionStatus user subscription is in grace period.")
                                    dataHandler.subscriptionToPro(status: false)
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
                    }
            }
            
            if dataHandler.family.id == "" || dataHandler.device.apiId == "" || dataHandler.user.id == "" {
                LoginView()
            } else {
                TabView {
                    TasksTabView()
                        .tabItem {
                            Label("Tasks", systemImage: "person")
                        }
                    
                    FamilyView()
                        .tabItem {
                            Label("Family", systemImage: "person.3")
                        }
                        .badge(dataHandler.familyBadge)
                }.sheet(isPresented: $dataHandler.settings.firstLogin, onDismiss: {
                    dataHandler.settings.firstLogin = false
                    dataHandler.storeSettings()
                }) {
                    NavigationStack {
                        AddFamilyMemberView()
                    }
                    .presentationDetents([.fraction(0.7), .large])

                }
                .sheet(isPresented: $dataHandler.showSubscriptionStore, content: {
                    if #available(iOS 17, *) {
                        SubscriptionStoreView(productIDs: ["org.hoeschen.dev.familyPoints.pro.monthly", "org.hoeschen.dev.familyPoints.pro.annualy"])
                            .storeButton(.visible, for: .restorePurchases, .redeemCode)
                            .subscriptionStoreControlStyle(.prominentPicker)
                            .onInAppPurchaseCompletion { product, result in
                                dataHandler.showSubscriptionStore = false
                            }
                    } else {
                        Text("Sorry, subscriptions can only be made on devices running at least iOS 17.")
                    }
                })
                
                if #available(iOS 17, *) {
                    Text("")
                        .onChange(of: scenePhase) {
                            if scenePhase == .active {
                                print("active")
                                dataHandler.fetchAllData()
                            }
                        }
                } else {
                    Text("")
                        .onChange(of: scenePhase) { _ in
                            if scenePhase == .active {
                                print("active")
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
            if self.appOpenCount == 100 {
                requestReview()
            }
        }
    }
}

