//
//  LoginView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 21.12.22.
//

import SwiftUI
import AVKit

struct LoginView: View {
    
    @EnvironmentObject var dataHandler: AppDataHandler
    
    @State private var waitingForAcceptance = false
    @State private var waitingForDeviceAcceptance = false
    @State private var waitingMessage = ""
    
    @State private var familyName = ""
    
    @State private var newUserName = ""
    @State private var newUserRole = UserRole.children
    
    @State private var pairKey: [String] = Array(repeating: "", count: 6)
    @FocusState private var loginUserFieldFocus: Int?
    
    
    @State private var userPairKey: [String] = Array(repeating: "", count: 6)
    @FocusState private var loginDeviceFieldFocus: Int?
    
    
    @State var showVideoWasNotHelpful = false
    @State var recommendations = ""
    @AppStorage("showLoginVideoFeedback") var showVideoFeedback = true
    
    var body: some View {
        ZStack {
            if dataHandler.device.apiId != "" {
                if waitingForAcceptance {
                    Form {
                        Section {
                            Text("Please ask a family member to accept you in the settings.")
                            HStack {
                                Spacer()
                                Button("Check") {
                                    dataHandler.joinFamilyCheckAccepted() { res in
                                        if let response = res {
                                            if response {
                                                self.waitingMessage = "You were accepted"
                                            } else {
                                                self.waitingMessage = "You haven't been accepted yet"
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    self.waitingMessage = ""
                                                }
                                            }
                                        } else {
                                            self.waitingMessage = "An error occurred while decrypting your data, or this user hasn't been accepted. Please try again"
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                for i in 0..<pairKey.count {
                                                    pairKey[i] = ""
                                                }
                                                loginUserFieldFocus = 0
                                                withAnimation {
                                                    self.waitingForAcceptance = false
                                                }
                                                self.waitingMessage = ""
                                            }
                                        }
                                    }
                                }
                                Spacer()
                            }
                        }
                        if waitingMessage != "" {
                            Section {
                                Text(waitingMessage)
                            }
                        }
                    }.navigationTitle("Join Family")
                } else if waitingForDeviceAcceptance {
                    Form {
                        Section {
                            Text("Please accept this Device in the Settings of your other Device.")
                            HStack {
                                Spacer()
                                Button("Check") {
                                    dataHandler.joinUserCheckAccepted { res in
                                        if let response = res {
                                            if response {
                                                self.waitingMessage = "You were accepted"
                                            } else {
                                                self.waitingMessage = "You haven't been accepted yet"
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    self.waitingMessage = ""
                                                }
                                            }
                                        } else {
                                            self.waitingMessage = "An error occurred while decrypting your data, or this device hasn't been accepted. Please try again"
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                for i in 0..<userPairKey.count {
                                                    userPairKey[i] = ""
                                                }
                                                loginDeviceFieldFocus = 0
                                                withAnimation {
                                                    self.waitingForAcceptance = false
                                                }
                                                self.waitingMessage = ""
                                            }
                                        }
                                    }
                                }
                                Spacer()
                            }
                        }
                        if waitingMessage != "" {
                            Section {
                                Text(waitingMessage)
                            }
                        }
                    }.navigationTitle("Link Device")
                } else {
                    NavigationStack {
                        Form {
                            Section {
                                NavigationLink {
                                    Form {
                                        Section {
                                            Label("Enter your first name", systemImage: "keyboard")
                                                .foregroundColor(.green)
                                            TextField("Your name", text: $newUserName)
                                                .focused($loginUserFieldFocus, equals: -1)
                                        }
                                        
                                        Section {
                                            Label("Choose your role", systemImage: "person.circle.fill")
                                                .foregroundColor(newUserRole == UserRole.children ? .blue : Color.cyan)
                                            Picker("Choose", selection: $newUserRole) {
                                                Text("Kid").tag(UserRole.children)
                                                Text("Parent").tag(UserRole.parent)
                                            }.pickerStyle(SegmentedPickerStyle())
                                        }
                                        
                                        Section {
                                            Label("Enter your Family Link-Key", systemImage: "keyboard")
                                            HStack {
                                                ForEach(0..<6) { i in
                                                    TextField("\(i+1)", text: $pairKey[i])
#if !os(macOS)
                                                        .keyboardType(.alphabet)
                                                        .autocapitalization(.allCharacters)
#endif
                                                        .multilineTextAlignment(.center)
                                                        .font(.largeTitle)
                                                        .focused($loginUserFieldFocus, equals: i)
                                                    
                                                    if #available(iOS 17, *) {
                                                        Text(i == 2 ? "-" : "")
                                                            .onChange(of: pairKey[i]) {
                                                                if pairKey[i].count != 0 {
                                                                    if pairKey[i].count != 1 {
                                                                        pairKey[i] = String(pairKey[i].last!)
                                                                    }
                                                                    loginUserFieldFocus = (loginUserFieldFocus ?? -1) + 1
                                                                }
                                                            }
                                                    } else {
                                                        Text(i == 2 ? "-" : "")
                                                            .onChange(of: pairKey[i]) { _ in
                                                                if pairKey[i].count != 0 {
                                                                    if pairKey[i].count != 1 {
                                                                        pairKey[i] = String(pairKey[i].last!)
                                                                    }
                                                                    loginUserFieldFocus = (loginUserFieldFocus ?? -1) + 1
                                                                }
                                                            }
                                                    }
                                                }
                                            }
                                            .padding()
                                        } footer: {
                                            Text("Your Family Link key can be found in the settings")
                                        }
                                        
                                        Section {
                                            Button("Check") {
                                                if newUserName.isEmpty {
                                                    loginUserFieldFocus = -1
                                                    return
                                                }
                                                for i in 0..<pairKey.count {
                                                    if pairKey[i].isEmpty {
                                                        loginUserFieldFocus = i
                                                        return
                                                    }
                                                }
                                                if dataHandler.user.id.isEmpty {
                                                    dataHandler.createNewUser(name: newUserName, role: newUserRole) { res in
                                                        if res == true{
                                                            dataHandler.joinFamily(code: pairKey.joined()) { res in
                                                                if !res {
                                                                    for i in 0..<pairKey.count {
                                                                        pairKey[i] = ""
                                                                    }
                                                                    loginUserFieldFocus = 0
                                                                } else {
                                                                    withAnimation {
                                                                        waitingForAcceptance = true
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    dataHandler.joinFamily(code: pairKey.joined()) { res in
                                                        if !res {
                                                            for i in 0..<pairKey.count {
                                                                pairKey[i] = ""
                                                            }
                                                            loginUserFieldFocus = 0
                                                        } else {
                                                            withAnimation {
                                                                waitingForAcceptance = true
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                            }
                                        }
                                        
                                    }.navigationTitle("Join a Family")
                                } label: {
                                    Label("Join an Existing Family", systemImage: "person.3.fill")
                                        .foregroundStyle(Color.green)
                                }
                            } footer: {
                                Text("If a family member has already created a family, you can join that family.")
                            }
                            
                            Section {
                                NavigationLink {
                                    Form {
                                        Section {
                                            Label("Enter your first name", systemImage: "keyboard")
                                                .foregroundColor(.green)
                                            TextField("Your name", text: $newUserName)
                                                .focused($loginUserFieldFocus, equals: -2)
                                        }
                                        
                                        Section {
                                            Label("Enter your last name", systemImage: "keyboard")
                                                .foregroundColor(.blue)
                                            TextField("Your name", text: $familyName)
                                                .focused($loginUserFieldFocus, equals: -3)
                                        }
                                        
                                        Section {
                                            Button("Create") {
                                                if newUserName.isEmpty {
                                                    loginUserFieldFocus = -2
                                                    return
                                                }
                                                if familyName.isEmpty {
                                                    loginUserFieldFocus = -3
                                                    return
                                                }
                                                dataHandler.showProgress = true
                                                dataHandler.createNewUser(name: newUserName, role: .parent) { res in
                                                    if res == true{
                                                        dataHandler.createNewFamily(name: familyName) { res in
                                                            dataHandler.showProgress = false
                                                        }
                                                    }
                                                }
                                            }
                                        } footer: {
                                            Text("All your data is securely encrypted on our servers. Neither we nor any third parties have the capability to decrypt it. Only you and your future family members possess the secret key required to decrypt the data.")
                                        }
                                    }.navigationTitle("Create a New Family")
                                } label: {
                                    Label("Create a New Family", systemImage: "figure.2.and.child.holdinghands")
                                        .foregroundStyle(Color.green)
                                }
                            } footer: {
                                Text("If you are the first in your family and want to set up your family, please create a new family.")
                            }
                            
                            Section {
                                NavigationLink {
                                    Form {
                                        Section {
                                            Label("Enter your Family Link-Key", systemImage: "keyboard")
                                            HStack {
                                                ForEach(0..<6) { i in
                                                    TextField("\(i+1)", text: $userPairKey[i])
                                                    #if !os(macOS)
                                                        .keyboardType(.alphabet)
                                                        .autocapitalization(.allCharacters)
                                                    #endif
                                                        .multilineTextAlignment(.center)
                                                        .font(.largeTitle)
                                                        .focused($loginDeviceFieldFocus, equals: i)
                                                        
                                                    
                                                    
                                                    if #available(iOS 17, *) {
                                                        Text(i == 2 ? "-" : "")
                                                            .onChange(of: userPairKey[i]) {
                                                                if userPairKey[i].count != 0 {
                                                                    if userPairKey[i].count != 1 {
                                                                        userPairKey[i] = String(userPairKey[i].last!)
                                                                    }
                                                                    loginDeviceFieldFocus = (loginDeviceFieldFocus ?? -1) + 1
                                                                }
                                                            }
                                                    } else {
                                                        Text(i == 2 ? "-" : "")
                                                            .onChange(of: userPairKey[i]) { _ in
                                                                if userPairKey[i].count != 0 {
                                                                    if userPairKey[i].count != 1 {
                                                                        userPairKey[i] = String(userPairKey[i].last!)
                                                                    }
                                                                    loginDeviceFieldFocus = (loginDeviceFieldFocus ?? -1) + 1
                                                                }
                                                            }
                                                    }
                                                }
                                            }
                                            .padding()
                                        } footer: {
                                            Text("Your Family Link key can be found in the settings")
                                        }
                                        
                                        Section {
                                            Button("Check") {
                                                for i in 0..<userPairKey.count {
                                                    if userPairKey[i].isEmpty {
                                                        loginDeviceFieldFocus = i
                                                        return
                                                    }
                                                }
                                                dataHandler.joinUser(code: userPairKey.joined()) { res in
                                                    if res {
                                                        withAnimation {
                                                            waitingForDeviceAcceptance = true
                                                        }
                                                    } else {
                                                        for i in 0..<userPairKey.count {
                                                            userPairKey[i] = ""
                                                        }
                                                        loginDeviceFieldFocus = 0
                                                    }
                                                }
                                            }
                                        }
                                        
                                        Section(content: {
                                            PasteButton(payloadType: exportUserDataStruct.self) { res in
                                                dataHandler.loadUserFromImportedStruct(data: res.first ?? exportUserDataStruct(deviceId: "", userId: "", familyId: "", key: ""))
                                            }
                                        }, header: {
                                            Text("Load User Account from File")
                                        }, footer: {
                                            Text("Alternatively, you can simply tap the file, and it should automatically open here.")
                                        })
                                        
                                    }.navigationTitle("Link Device")
                                } label: {
                                    Label("Connect to an other Device", systemImage: "person.fill.badge.plus")
                                        .foregroundStyle(Color.yellow)
                                }
                            } footer: {
                                Text("If you already have a device connected to your family, you can link this device with this one. This ensures both devices share the same user information.")
                            }
                            
                            Section {
                                NavigationLink {
                                    VStack {
                                        if showVideoWasNotHelpful {
                                            Form {
                                                Section {
                                                    Text("Do you have any recommendations?")
                                                    
                                                    TextField("Not necessary", text: $recommendations, axis: .vertical)
                                                        .multilineTextAlignment(.leading)
                                                        .lineLimit(5, reservesSpace: true)
                                                        .textFieldStyle(.roundedBorder)
                                                } footer: {
                                                    Text("Important Note: Unlike your other data, this recommendation is stored in plain text on my server to facilitate reading. Please be aware of this.")
                                                }
                                                
                                                Section {
                                                    Button("Hide") {
                                                        withAnimation {
                                                            showVideoWasNotHelpful = false
                                                        }
                                                    }
                                                    Button("Submit") {
                                                        dataHandler.sendVideoFeedback(helpful: false, message: recommendations)
                                                        withAnimation {
                                                            showVideoFeedback = false
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            VideoPlayer(player: AVPlayer(url:  Bundle.main.url(forResource: "SetupMovie", withExtension: "mov")!))
                                                .navigationTitle("Instruction Video")
#if !os(macOS)
                                                .navigationBarTitleDisplayMode(.inline)
#endif
                                            if showVideoFeedback {
                                                HStack {
                                                    Text("Was this video helpful?")
                                                    Spacer()
                                                    Button("Yes") {
                                                        dataHandler.sendVideoFeedback(helpful: true, message: nil)
                                                        withAnimation {
                                                            showVideoFeedback = false
                                                        }
                                                    }
                                                    Button("No") {
                                                        withAnimation {
                                                            showVideoWasNotHelpful = true
                                                        }
                                                    }
                                                }.padding()
                                            }
                                        }
                                    }
                                    .navigationTitle("Instruction Video")
                                } label: {
                                    Label("Instruction Video", systemImage: "person")
                                        .foregroundStyle(Color.blue)
                                }
                            } footer: {
                                Text("Watch an example video here.")
                            }
                        }.navigationTitle("Setup")
                    }
                }
            } else {
                VStack {
                    Text("Please establish an internet connection")
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                if dataHandler.device.apiId == "" {
                                    dataHandler.createNewDevice() { res in
                                    }
                                }
                            }
                        }
                    
                    Button("Try Again") {
                        dataHandler.createNewDevice() { res in
                        }
                    }
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppDataHandler())
    }
}

