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
                .onOpenURL { url in
                    if let data = try? Data(contentsOf: url),
                       let decodedObject = try? JSONDecoder().decode(exportUserDataStruct.self, from: data) {
                        mainHandler.loadUserFromImportedStruct(data: decodedObject)
                    }
                    handleURL(url)
                }
        }
    }
    
    func handleURL(_ url: URL) {
        // familypoints://join?token=abc123
        guard url.scheme == "familypoints",
              url.host == "join",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let token = components.queryItems?.first(where: { $0.name == "token" })?.value
        else { return }
        
        print("Join with token: \(token)")
        
        
    }
}
