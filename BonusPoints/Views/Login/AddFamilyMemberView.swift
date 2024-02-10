//
//  AddFamilyMemberView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 10.12.23.
//

import SwiftUI

struct AddFamilyMemberView: View {
    
    @EnvironmentObject var dataHandler: AppDataHandler
    
    var body: some View {
        Form {
            if dataHandler.family.premium || dataHandler.family.users.count < 4 {
                Section {
                    Text("Add your Family Members to your Family")
                } footer: {
                    Text("Family members can also be added through the settings.")
                }
                
                Section {
                    Text("On your family member's device, select **\"Join an existing Family\"**. Then enter your family member's name and the provided code.")
                        .onAppear {
                            if dataHandler.family.linkKey.isEmpty {
                                withAnimation {
                                    dataHandler.joinFamilyInit()
                                }
                            }
                        }
                    
                    if !dataHandler.family.linkKey.isEmpty {
                        let keyArray = Array(dataHandler.family.linkKey)
                        
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
                        Label("Members wanting to join", systemImage: "exclamationmark.shield.fill")
                            .foregroundColor(.yellow)
                        
                        Spacer()
                        
                        Button("Refresh") {
                            dataHandler.joinFamilyInit()
                        }
                    }
                    
                    ForEach(0..<dataHandler.family.usersWantingToLink.count, id: \.self) { i in
                        let user = dataHandler.family.usersWantingToLink[i]
                        GroupBox(user.name) {
                            HStack {
                                Text("Role:")
                                Spacer()
                                Text(user.type)
                            }
                            
                            HStack {
                                Text("Created:")
                                Spacer()
                                Text(user.created)
                            }
                            
                            HStack {
                                Button("Accept") {
                                    dataHandler.joinFamilyUpdateDeviceWantingToJoin(i: i, accept: true)
                                }.foregroundColor(.green)
                                
                                Spacer()
                                
                                Button("Deny") {
                                    dataHandler.joinFamilyUpdateDeviceWantingToJoin(i: i, accept: false)
                                }.foregroundColor(.red)
                            }
                        }
                    }
                }
            } else {
                Section {
                    Text("For adding more Family Members, please subscribe.")
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button("Subscribe now") {
                            dataHandler.showSubscriptionStore = true
                        }
                        .bold()
                        .buttonStyle(.borderedProminent)
                        Spacer()
                    }
                    .listRowBackground(EmptyView())
                }
            }
        }
        .navigationTitle("Add Family Members")
    }
}

#Preview {
    AddFamilyMemberView()
}
