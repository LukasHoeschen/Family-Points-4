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
    @AppStorage("AppOpenCount") var appOpenCount = 0
    var body: some View {
        
        ZStack {
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
                }.onAppear {
                    dataHandler.fetchAllData()
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
                    SubscriptionStoreView(productIDs: ["org.hoeschen.bonusPoints.subscribe.pro.monthly", "org.hoeschen.bonusPoints.subscription.pro"])
                        .storeButton(.visible, for: .restorePurchases, .redeemCode)
                        .subscriptionStoreControlStyle(.prominentPicker)
                        .onInAppPurchaseCompletion { product, result in
                            dataHandler.showSubscriptionStore = false
                        }
                })
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
        .subscriptionStatusTask(for: "F518ABC0") { taskState in
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
}

