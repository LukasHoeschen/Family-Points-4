//
//  StoreView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 25.12.23.
//

import SwiftUI
import StoreKit

struct FamilyPointsStoreView: View {
    
    @EnvironmentObject var dataHandler: AppDataHandler
    
    var body: some View {
//        Form {
        if #available(iOS 17, *) {
            Section {
                ProductView(id: "org.hoeschen.lukas.FamilyPoints.Store.tasks20") {
                    Image(systemName: "note.text.badge.plus")
                        .symbolRenderingMode(.multicolor)
                        .resizable()
                        .scaledToFit()
                }
                .productViewStyle(.compact)
                .onInAppPurchaseCompletion { product, result in
                    if case .success(.success(let transaction)) = result {
                        print("Purchased successfully: \(transaction.signedDate)")
                        self.dataHandler.family.maxTasks += 20
                        self.dataHandler.familyUpdate()
                    } else {
                        print("Something else happened")
                    }
                }
            } footer: {
                Text("Right now you're using \(dataHandler.countTasks()) Tasks of \(dataHandler.family.maxTasks) free tasks.")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Unlock premium features:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(Color.green)
                        Text("Unlimited Tasks")
                    }
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(Color.green)
                        Text("Unlimited Lists")
                    }
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(Color.green)
                        Text("Unlimited Family Members")
                    }
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(Color.green)
                        Text("Unlimited Devices")
                    }
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(Color.green)
                        Text("Unlimited Widgets (requires iOS 17.2)")
                    }
                }
                
                ProductView(id: "org.hoeschen.dev.familyPoints.pro.monthly")
                    .productViewStyle(.compact)
            } header: {
                Text("Family Points PRO")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
            } footer: {
                Text("Purchases and subscriptions are synchronised across all family members.")
            }
            
            Section {
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
            }
            //        }
            .navigationTitle("Upgrade Options")
            .navigationBarTitleDisplayMode(.large)
            .toolbar(content: {
                NavigationLink {
                    Form {
                        Section {
                            Text("With the free version of Family Points, you enjoy the following features:")
                                .foregroundColor(.secondary)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• 30 complimentary tasks")
                                Text("• 4 task lists")
                                Text("• 4 family members, including yourself")
                            }
                            
                            Text("**Please note:** Connecting multiple devices to your account is not available in the free version.")
                        }
                        
                        Section("Current Utilisation") {
                            Label("\(dataHandler.countTasks())/\(dataHandler.family.maxTasks) Tasks", systemImage: "checkmark.circle")
                            Label("\(dataHandler.family.tasks.count)/4 Task Lists", systemImage: "tray.full")
                            Label("\(dataHandler.family.users.count)/4 Family Members", systemImage: "person.3.fill")
                        }
                        
                        Section("Information") {
                            Text("Storing your data on my server is kinda expensive, so I decided to make this Store to earn a little money. If you wish, you could support me also via [PayPal](https://paypal.me/hoeschenDevelopment) or [buyMeACoffee.com](https://buymeacoffee.com/hoeschenDevelopment)")
                        }
                    }.navigationTitle("Information")
                } label: {
                    Image(systemName: "info.circle")
                }
            })
        } else {
            Section {
                Text("Purchases can only be done on devices supporting iOS 17 or newer.")
            }
        }
    }
}


struct FamilyPointsSubscriptionView: View {
    // TODO: this
    
    @Binding var isPresented: Bool
    
    var body: some View {
        if #available(iOS 17, *) {
            SubscriptionStoreView(productIDs: ["org.hoeschen.dev.familyPoints.pro.monthly", "org.hoeschen.dev.familyPoints.pro.annualy"])
                .storeButton(.visible, for: .restorePurchases, .redeemCode)
                .subscriptionStoreControlStyle(.prominentPicker)
                .onInAppPurchaseCompletion { product, result in
                    isPresented = false
                }.subscriptionStorePolicyDestination(url: URL(string: "https://lukas.hoeschen.org/apps/bonusPoints/privacyPolicy/index.html")!, for: .privacyPolicy)
                .subscriptionStorePolicyDestination(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!, for: .termsOfService)
        }
    }
}



#Preview {
    FamilyPointsStoreView()
        .environmentObject(AppDataHandler())
}
