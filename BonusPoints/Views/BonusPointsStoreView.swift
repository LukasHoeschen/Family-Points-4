//
//  StoreView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 25.12.23.
//

import SwiftUI
import StoreKit

struct BonusPointsStoreView: View {
    
    @EnvironmentObject var dataHandler: AppDataHandler
    
    var body: some View {
//        Form {
            Section {
                ProductView(id: "org.hoeschen.bonusPoints.purchase.tasks20") {
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
                }
                
                ProductView(id: "org.hoeschen.bonusPoints.subscribe.pro.monthly")
                    .productViewStyle(.compact)
            } header: {
                Text("Bonus Points PRO")
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
                            Text("With the free version of Bonus Points, you enjoy the following features:")
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
                    }.navigationTitle("Information")
                } label: {
                    Image(systemName: "info.circle")
                }
            })
    }
}

#Preview {
    BonusPointsStoreView()
        .environmentObject(AppDataHandler())
}
