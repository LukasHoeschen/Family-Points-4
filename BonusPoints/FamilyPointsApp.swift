//
//  BonusPointsApp.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 07.12.22.
//

import SwiftUI

@main
struct FamilyPointsApp: App {
    
    @StateObject var mainHandler: AppDataHandler = AppDataHandler()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mainHandler)
//                .accentColor(colorScheme == .dark ? Color(red: 188 / 255.0, green: 47 / 255.0, blue: 1 / 255.0) : .orange)
                .onOpenURL { url in
                    if let data = try? Data(contentsOf: url),
                       let decodedObject = try? JSONDecoder().decode(exportUserDataStruct.self, from: data) {
                        mainHandler.loadUserFromImportedStruct(data: decodedObject)
                    }
                }
        }
    }
}
