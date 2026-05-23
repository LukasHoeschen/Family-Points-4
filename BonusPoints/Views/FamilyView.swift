//
//  FamilyView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 01.02.23.
//

import SwiftUI

struct FamilyView: View {
    
    @EnvironmentObject var dataHandler: AppDataHandler
    
    enum FamilyRoute: Hashable {
        case userDetail(id: String)
        case settings
        case addMember
    }
    
    var body: some View {
        Form {
            ForEach(0..<dataHandler.family.users.count, id: \.self) { i in
                let user: UserStruct = dataHandler.family.users[i]
                
                
                Section {
                    NavigationLink(value: FamilyRoute.userDetail(id: user.id)) {
                        VStack(alignment: .leading, spacing: 12) {
                            Label(user.name, systemImage: "person.circle.fill")
                                .foregroundColor(user.getColor())
                                .font(.title3)
                                .bold()
                            
                            HStack {
                                Label(functionsClass().floatToShortString(x: user.actualPoints) + " Points", systemImage: "star.fill")
                                    .foregroundStyle(.yellow)
                                
                                Spacer()
                                
                                Label("\(user.tasksDone.count) Tasks done", systemImage: "checkmark.circle.fill")
                                    .foregroundStyle(user.tasksDone.count > 0 ? Color.accentColor : .secondary)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            
        }
        .listSectionSpacing(5)
        .navigationTitle("Your Family")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(value: FamilyRoute.settings) {
                    Image(systemName: "gear")
                }
            }
            
            if dataHandler.user.role == .parent {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(value: FamilyRoute.addMember) {
                        Image(systemName: "person.crop.circle.badge.plus")
                    }
                }
            }
        }
        .onAppear {
            dataHandler.fetchAllData()
        }
        .navigationDestination(for: FamilyRoute.self) { route in
                switch route {
                case .userDetail(let id):
                    UserDetailView(userId: id)
                case .settings:
                    SettingsView()
                case .addMember:
                    AddFamilyMemberView()
                }

            }
    }
}

struct FamilyView_Previews: PreviewProvider {
    static var previews: some View {
        FamilyView()
            .environmentObject(AppDataHandler())
    }
}
