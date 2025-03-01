//
//  ObjectHandler.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 07.12.22.
//

import Foundation
import SwiftUI
import Alamofire
import SimpleSwiftCrypto


class AppDataHandler: ObservableObject {
    @Published var device: DeviceStruct = DeviceStruct(apiId: "", name: "", type: "", created: Date.now)
    @Published var user: UserStruct = UserStruct(id: "", name: "", role: UserRole.children, actualPoints: 0.0, everPoints: 0.0, tasksDoneCount: 0, created: Date.now)
    @Published var family: FamilyStruct = FamilyStruct(id: "", name: "", tasks: [], users: [])
    @Published var settings: SettingsStruct = SettingsStruct()
    
    @Published var showProgress = false
    @Published var showSubscriptionStore = false
    @Published var familyBadge = 0
    @Published var showOptionsForTaskId: String? = nil
    
    @Published var AESCryptoKey = SimpleSwiftCrypto.generateRandomAES256Key()!
    @AppStorage("aesCryptoKeyAppStorage") var AESCryptoKeyData: Data?
    
    @AppStorage("deviceAppStorage") var deviceAppStorage: Data = Data()
    @AppStorage("userAppStorage") var userAppStorage: Data = Data()
    @AppStorage("familyAppStorage") var familyAppStorage: Data = Data()
//    @AppStorage("tasksAppStorage") var tasksAppStorage: Data = Data()
    @AppStorage("settingsAppStorage") var settingsAppStorage: Data = Data()
    
    @AppStorage("firstUsersPro") var firstUsersPro = false
    
    
    
    init() {
        self.loadAllFromAppStorage()
    }
    
    func loadAllFromAppStorage() {
        loadDevice()
        if self.AESCryptoKeyData != nil {
            self.AESCryptoKey = .loadIvAndPrivateAES256Key(ivAndPrivateAES256Key: self.AESCryptoKeyData!)!
        }
        
        loadUser()
        loadFamily()
//        loadTasks()
        loadSettings()
    }
    
    func storeAllInAppStorage() {
        self.AESCryptoKeyData = self.AESCryptoKey.exportIvAndPrivateAES256Key()
        storeDevice()
        storeFamily()
        storeUser()
//        storeTasks()
        storeSettings()
    }
    
    func loadDevice() {
        guard let d = try? JSONDecoder().decode(DeviceStruct.self, from: self.deviceAppStorage) else {
            print("failed to load device")
            self.device = DeviceStruct(apiId: "", name: "", type: "", created: Date.now)
            return
        }
        DispatchQueue.main.async {
            self.device = d
        }
    }
    
    func loadUser() {
        guard let u = try? JSONDecoder().decode(UserStruct.self, from: self.userAppStorage) else {
            print("failed to load user")
            self.user = UserStruct(id: "", name: "", role: .children, actualPoints: 0, everPoints: 0, tasksDoneCount: 0, created: Date.now)
            return
        }
        DispatchQueue.main.async {
            self.user = u
            self.user.linkKey = ""
            self.user.devicesWantingToLink = []
        }
    }
    
    func loadFamily() {
        guard let f = try? JSONDecoder().decode(FamilyStruct.self, from: self.familyAppStorage) else {
            print("failed to load family")
            self.family = FamilyStruct(id: "", name: "", tasks: [], users: [])
            return
        }
        DispatchQueue.main.async {
            self.family = f
            self.family.linkKey = ""
            self.family.usersWantingToLink = []
        }
    }
    
//    func loadTasks() {
//        guard let s = try? JSONDecoder().decode(MultipleTaskListStruct.self, from: self.tasksAppStorage) else {
//            self.tasks = MultipleTaskListStruct()
//            return
//        }
//        DispatchQueue.main.async {
//            self.tasks = s
//        }
//    }
    
    func loadSettings() {
        guard let s = try? JSONDecoder().decode(SettingsStruct.self, from: self.settingsAppStorage) else {
            print("failed to load settings")
            self.settings = SettingsStruct()
            return
        }
        DispatchQueue.main.async {
            self.settings = s
        }
    }
    
    func storeDevice() {
        guard let d = try? JSONEncoder().encode(self.device) else {
            print("failed to store device")
            return
        }
        DispatchQueue.main.async {
            self.deviceAppStorage = d
        }
    }
    
    func storeUser() {
        guard let u = try? JSONEncoder().encode(self.user) else {
            print("failed to store user")
            return
        }
        DispatchQueue.main.async {
            self.userAppStorage = u
        }
    }
    
    func storeFamily() {
        guard let f = try? JSONEncoder().encode(self.family) else {
            print("failed to store family")
            return
        }
        DispatchQueue.main.async {
            self.familyAppStorage = f
        }
    }
    
//    func storeTasks() {
//        guard let f = try? JSONEncoder().encode(self.tasks) else {
//            print("failed to store family")
//            return
//        }
//        DispatchQueue.main.async {
//            self.tasksAppStorage = f
//        }
//    }
    
    func storeSettings() {
        guard let s = try? JSONEncoder().encode(self.settings) else {
            print("Failed to store settings")
            return
        }
        DispatchQueue.main.async {
            self.settingsAppStorage = s
        }
    }
    
    func sendData<T: Codable>(data: [String:Any], file: String, completion: @escaping (T?) -> ()) {
        // MARK: Send Data
        
        let url = Secrets.apiURL
        
        var sendData = data
        sendData["userId"] = self.user.id
        sendData["deviceId"] = self.device.apiId
        sendData["familyId"] = self.family.id
        
        AF.request(url + file, method: .post, parameters: sendData, encoding: JSONEncoding.default).responseDecodable(of: serverResponseStruct<T>.self) { response in
            debugPrint(response)
            print()
            if let value = response.value {
                if let mes = value.message {
                    if mes == "NoCredentialsFound" {
                        self.logOut()
                        completion(nil)
                        return
                    }
                }
                if value.success {
                    if let d = value.data {
                        completion(d)
                        return
                    }
                }
            }
            completion(nil)
            return
        }
    }
    
    
    
    func encryptString(s: String) -> String {
        return self.AESCryptoKey.encrypt(data: s.prefix(100).data(using: .utf8)!)!.base64EncodedString()
    }
    
    func encryptInt(i: Int) -> String {
        return self.AESCryptoKey.encrypt(data: String(i).data(using: .utf8)!)!.base64EncodedString()
    }
    
    func encryptFloat(f: Float) -> String {
        return self.AESCryptoKey.encrypt(data: String(f).data(using: .utf8)!)!.base64EncodedString()
    }
    
    func encryptData(d: Data) -> String {
        return self.AESCryptoKey.encrypt(data: d)!.base64EncodedString()
    }
    
    func encryptDate(date: Date) -> String {
        let milliseconds = date.millisecondsSince1970

        let dateString = String(milliseconds)
        guard let data = dateString.data(using: .utf8),
              let encryptedData = self.AESCryptoKey.encrypt(data: data) else {
            return ""
        }
        return encryptedData.base64EncodedString()
    }

    
    func decryptToString(d: String) -> String {
        return String(data: self.AESCryptoKey.decrypt(data: Data(base64Encoded: d) ?? Data()) ?? Data(), encoding: .utf8) ?? ""
    }
    
    func decryptToInt(d: String) -> Int {
        return Int(self.decryptToString(d: d)) ?? 0
    }
    
    func decryptToFloat(d: String) -> Float {
        return Float(self.decryptToString(d: d)) ?? 0
    }
    
    func decryptToData(d: String) -> Data {
        AESCryptoKey.decrypt(data: Data(base64Encoded: d)!) ?? Data()
    }
    
    func getActualEncryptedDate() -> String {
        return self.encryptString(s: String(Date.now.millisecondsSince1970))
    }
    
    func decryptToDate(d: String) -> Date {
        let d = Data(base64Encoded: d)!
        let e = self.AESCryptoKey.decrypt(data: d)
        if e == nil {
            return .now
        }
        return Date(milliseconds: Int64(Int(String(data: e!, encoding: .utf8) ?? "0") ?? 0))
    }
    
    
    func decryptToStringWithRSA(rsaPrivateKey: RSAKeyPair, data: String) -> String? {
        let d = Data(base64Encoded: data)
        if d == nil {
            print("Decrypting error: Data")
            return nil
        }
        let decryptedData = rsaPrivateKey.decrypt(data: d!)
        if decryptedData == nil {
            print("Decrypting error: decrypt")
            return nil
        }
        if let decryptedString = String(data: decryptedData!, encoding: .utf8) {
            print("Decrypted string: \(decryptedString)")
            return decryptedString
        }
        print("Decrypting error: String")
        return nil
    }
    
    func encryptStringWithRSA(key: RSAPublicKey, s: String) -> String {
        // Hopefully here aren't errors
        let d = s.data(using: .utf8)
        if d == nil {
            print("Data error")
        }
        let c = key.encrypt(data: d!)
        if c == nil {
            print("crypto error")
        }
        return c!.base64EncodedString()
    }
    
    
    
    func logOut() {
//        self.removeDevice(apiId: self.device.apiId)
        self.device = DeviceStruct(apiId: "", name: "", type: "", created: Date.now)
        self.user = UserStruct(id: "", name: "", role: UserRole.children, actualPoints: 0.0, everPoints: 0.0, tasksDoneCount: 0, created: Date.now)
        self.family = FamilyStruct(id: "", name: "", tasks: [], users: [])
        self.AESCryptoKey = SimpleSwiftCrypto.generateRandomAES256Key()!
        self.settings = SettingsStruct()
        self.storeAllInAppStorage()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        print("Logged out")
    }
    
    
    
    func createNewDevice(completion: @escaping (Bool) -> ()) {
        // MARK: Create new device
        
        
        #if os(macOS)
        let deviceSend = deviceSentStruct(name: self.encryptString(s: Host.current().localizedName ?? "No name"), type: self.encryptString(s: "Mac"), created: getActualEncryptedDate(), osImage: self.encryptString(s: "laptopcomputer"))
        #else
        let deviceSend = deviceSentStruct(name: self.encryptString(s: String(UIDevice.current.name.prefix(100))), type: self.encryptString(s: String(UIDevice.current.model.prefix(100))), created: self.getActualEncryptedDate(), osImage: encryptString(s: "iphone"))
        #endif
        
        self.sendData(data: ["name":deviceSend.name, "type":deviceSend.type, "created":deviceSend.created, "osImage":deviceSend.osImage], file: "create/device.php") { (res: idResponseStruct?) in
            if let response = res {
                print(response.id)
                DispatchQueue.main.async {
                    self.device.apiId = response.id
                    #if os(macOS)
                    self.device.name = Host.current().localizedName ?? "No name"
                    self.device.type = "Mac"
                    #else
                    self.device.name = String(UIDevice.current.name.prefix(100))
                    self.device.type = String(UIDevice.current.model.prefix(100))
                    #endif
                    self.storeAllInAppStorage()

                    completion(true)
                    return
                }
            }
            completion(false)
        }
        
        
    }
    
    func deviceUpdate() {
        // MARK: Update Device
        
        self.sendData(data: ["name":self.encryptString(s: device.name), "type":self.encryptString(s: device.type), "created":self.encryptString(s: String(device.created.millisecondsSince1970)), "osImage":self.encryptString(s: device.osImage)], file: "update/device.php") { (res: someResponseStruct?) in
            
        }
    }
    
    func removeDevice(apiId: String) {
        // MARK: delete Device
        self.sendData(data: ["id":apiId], file: "remove/device.php") { (res: someResponseStruct?) in
            self.fetchAllData()
        }
    }
    
    func createNewUser(name: String, role: UserRole, completion: @escaping (Bool) -> ()) {
        // MARK: Create new user
        let newName = String(name.prefix(100))
        let newRole = try! JSONEncoder().encode(role)
        
        self.sendData(data: ["name":encryptString(s: newName), "deviceId":self.device.apiId, "role": encryptData(d: newRole), "actualPoints":encryptFloat(f: 0.0), "everPoints": encryptFloat(f: 0.0), "created":self.getActualEncryptedDate()], file: "create/user.php") { (res: idResponseStruct?) in
            if let response = res {
                print(response.id)
                DispatchQueue.main.async {
                    self.user.id = response.id
                    self.user.role = role
                    self.user.name = name
                    self.storeUser()
                    completion(true)
                    return
                }
            }
            completion(false)
        }
    }
    
    func userUpdate(id: String) {
        // MARK: Update User
        let user = self.family.users.first {$0.id == id}!
        
        let role = try! JSONEncoder().encode(user.role)
        
        self.sendData(data: ["id":id, "name":self.encryptString(s: user.name), "role":self.encryptData(d: role), "created":self.encryptString(s: String(user.created.millisecondsSince1970)), "actualPoints":self.encryptFloat(f: user.actualPoints), "everPoints":self.encryptFloat(f: user.everPoints), "tasksDoneCount":self.encryptInt(i: user.tasksDoneCount)], file: "update/user.php") { (res: someResponseStruct?) in
            if res != nil {
                if id == self.user.id {
                    self.user = user
                }
            }
        }
    }
    
    func userUpdate() {
        // MARK: Update User
        let role = try! JSONEncoder().encode(user.role)
        
        self.sendData(data: ["id":user.id, "name":self.encryptString(s: user.name), "role":self.encryptData(d: role), "created":self.encryptString(s: String(user.created.millisecondsSince1970)), "actualPoints":self.encryptFloat(f: user.actualPoints), "everPoints":self.encryptFloat(f: user.everPoints), "tasksDoneCount":self.encryptInt(i: user.tasksDoneCount)], file: "update/user.php") { (res: someResponseStruct?) in
            
        }
    }
    
    func deleteUser(id: String) {
        self.sendData(data: ["id":id], file: "remove/user.php") { (res: someResponseStruct?) in
            self.fetchAllData()
        }
    }
    
    func createNewFamily(name: String, completion: @escaping (Bool) -> ()) {
        // MARK: Create new Family
        
        self.sendData(data: ["userId":self.user.id, "name": self.encryptString(s: String(name.prefix(100))), "publicKey":"pubKey", "created":self.getActualEncryptedDate(), "maxTasks":self.encryptInt(i: family.maxTasks), "subscribedToPro":self.encryptString(s: family.premium ? "true" : "false")], file: "create/family.php") { (res: idResponseStruct?) in
            if let response = res {
                DispatchQueue.main.async {
                    self.family.id = response.id
                    self.storeFamily()
                    self.updateTaskList(name: NSLocalizedString("Your Tasks", comment: "The name of the initial Tasklist")) { res in
                        if res {
                            self.updateTask(taskListId: self.family.tasks.first!.id, name: NSLocalizedString("Do Homework", comment: "Initialised Tasks"), pointsToAdd: 1, orderWeight: 0, created: .now)
                            self.updateTask(taskListId: self.family.tasks.first!.id, name: NSLocalizedString("Tidy my Room", comment: "Initialised Tasks"), pointsToAdd: 2, orderWeight: 0, created: .now)
                            self.updateTask(taskListId: self.family.tasks.first!.id, name: NSLocalizedString("Set the Table", comment: "Initialised Tasks"), pointsToAdd: 1, orderWeight: 0, created: .now)
                            self.updateTask(taskListId: self.family.tasks.first!.id, name: NSLocalizedString("Play Video Games for 30 Minutes", comment: "Initialised Tasks"), pointsToAdd: -5, orderWeight: 0, created: .now)
                        }
                    }
                    //self.subscriptionToPro(status: true)
                    completion(true)
                    return
                }
            }
            completion(false)
        }
    }
    
    func familyUpdate() {
        // MARK: Update Family
        self.sendData(data: ["id":family.id, "name":self.encryptString(s: family.name), "maxTasks":self.encryptInt(i: family.maxTasks), "subscribedToPro":self.encryptString(s: family.premium ? "true" : "false")], file: "update/family.php") { (res: someResponseStruct?) in
            
        }
    }
    
    func subscriptionToPro(status: Bool) {
        // MARK: Subscribe to Pro
        print("subscriptionToPro()")
        print(status)
        print(family.premium)
        if self.family.premium != status {
            if !status {
                self.family.maxTasks = countTasks() > 30 ? countTasks() : 30
            }
            self.family.premium = status
            self.familyUpdate()
            self.storeFamily()
            print("Stored Premium on Server")
        }
    }
    
    func deleteFamily() {
        self.sendData(data: [:], file: "remove/family.php") { (res: someResponseStruct?) in
            self.logOut()
        }
    }
    
    func updateTaskAllUsersCount(taskId: String, allUsersCounter: Int) {
        // MARK: Update Task Count
        self.sendData(data: ["taskId": taskId, "allUsersCount":self.encryptInt(i: allUsersCounter)], file: "update/taskUserDoneCount.php") { (res: someResponseStruct?) in
            DispatchQueue.main.async {
                if res != nil {
                    for i in 0..<self.family.tasks.count {
                        for j in 0..<self.family.tasks[i].list.count {
                            if self.family.tasks[i].list[j].id == taskId {
                                self.family.tasks[i].list[j].howManyTimesDidAllUsers = allUsersCounter
                            }
                        }
                    }
                }
            }
        }
    }
    
    func countTasks() -> Int {
        var i = 0
        family.tasks.forEach { j in
            j.list.forEach { k in
                i += 1
            }
        }
        return i
    }
    
    func updateTask(taskId: String = "null", taskListId: String, name: String, pointsToAdd: Float, orderWeight: Int, allUsersCounter: Int = 0, created: Date) {
        // MARK: Update Task
        if taskId == "null" && countTasks() >= family.maxTasks && !family.premium {
            showSubscriptionStore = true
        } else {
            self.sendData(data: ["taskId": taskId, "listId":taskListId, "name": self.encryptString(s: name), "points": self.encryptFloat(f: pointsToAdd), "orderWeight":self.encryptInt(i: orderWeight), "allUsersCount":self.encryptInt(i: allUsersCounter), "created":self.encryptDate(date: created)], file: "update/task.php") { (res: idResponseStruct?) in
                DispatchQueue.main.async {
                    if let response = res {
                        if taskId == "null" {
                            self.family.tasks[self.family.tasks.firstIndex { $0.id == taskListId} ?? 0].list.append(TaskStruct(name: name, id: response.id, listId: taskListId, pointsToAdd: pointsToAdd, howManyTimesDidAllUsers: allUsersCounter, counter: .now, orderWeight: orderWeight))
                        } else {
                            // No new Task, just updated
                            for i in 0..<self.family.tasks.count {
                                for j in 0..<self.family.tasks[i].list.count {
                                    if self.family.tasks[i].list[j].id == taskId {
                                        self.family.tasks[i].list[j] = TaskStruct(name: name, id: taskId, listId: taskListId, pointsToAdd: pointsToAdd, howManyTimesDidAllUsers: allUsersCounter, counter: self.family.tasks[i].list[j].counter, orderWeight: orderWeight)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getTask(id: String) -> TaskStruct? {
        for list in self.family.tasks {
            if let task = list.list.first(where: { $0.id == id }) {
                return task
            }
        }
        return nil
    }
    
    func updateTaskDone(taskId: String, time: Date, message: String) {
        // MARK: Update Task Done - Count
        self.sendData(data: ["taskId": taskId, "count":self.encryptDate(date: time), "message":self.encryptString(s: message)], file: "update/taskDone.php") { (res: idResponseStruct?) in
            DispatchQueue.main.async {
                if res != nil {
                    self.user.tasksDone.append(TaskDoneStruct(doneId: res!.id, id: taskId, time: time, message: message))
//                    self.family.tasks[listNum].list[self.family.tasks[listNum].list.firstIndex { $0.id == taskId} ?? 0].counter = count
                    
//                    Not needed to show a counter if just complete tasks
//                    for i in 0..<self.family.tasks.count {
//                        for j in 0..<self.family.tasks[i].list.count {
//                            if self.family.tasks[i].list[j].id == taskId {
//                                self.family.tasks[i].list[j].counter = count
//                            }
//                        }
//                    }
                }
            }
        }
    }
    
    func deleteTaskDone(id: String, userId: String) {
        self.sendData(data: ["id": id], file: "remove/taskDone.php") { (res: someResponseStruct?) in
            DispatchQueue.main.async {
                if res != nil {
                    self.family.users[self.family.users.firstIndex {$0.id == userId}!].tasksDone.removeAll {$0.doneId == id}
                    if userId == self.user.id {
                        self.user.tasksDone.removeAll {$0.doneId == id}
                    }
                }
            }
        }
    }
    
    func acceptTaskDone(taskId: String, userId: String, doneId: String) { // userWhoDidTheTaskId
        let task = getTask(id: taskId)
        family.users[family.users.firstIndex {$0.id == userId}!].actualPoints += task!.pointsToAdd
        userUpdate(id: userId)
        updateTaskAllUsersCount(taskId: taskId, allUsersCounter: task!.howManyTimesDidAllUsers + 1)
        deleteTaskDone(id: doneId, userId: userId)
    }
    
//    func addToHistory(taskId: String, userId: String, count: Int, date: Date) {
//        if self.family.premium {
//            self.sendData(data: ["taskId": taskId, "userDoneTheTaskId":userId, "date":self.encryptDate(date: date), "count":self.encryptInt(i: count)], file: "create/userDoneTaskHistory.php") { (res: someResponseStruct?) in
//                DispatchQueue.main.async {
//                    if res != nil {
//                        What here?
//                    }
//                }
//            }
//        }
//    }
    
    func deleteTask(taskId: String) {
        self.sendData(data: ["taskId": taskId], file: "remove/task.php") { (res: someResponseStruct?) in
            DispatchQueue.main.async {
                if res != nil {
                    for i in 0..<self.family.tasks.count {
                        for j in 0..<self.family.tasks[i].list.count {
                            if self.family.tasks[i].list[j].id == taskId {
                                self.family.tasks[i].list.remove(at: j)
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    func deleteList(listId: String) {
        self.sendData(data: ["id": listId], file: "remove/list.php") { (res: someResponseStruct?) in
            DispatchQueue.main.async {
                if res != nil {
                    for i in 0..<self.family.tasks.count {
                        if self.family.tasks[i].id == listId {
                            self.family.tasks.remove(at: i)
                            return
                        }
                    }
                }
            }
        }
    }
    
    func updateTaskList(id: String = "null", name: String, completion: @escaping (Bool) -> ()) {
        // MARK: Update Tasklist
        
        if id == "null" && family.tasks.count >= 4 && !family.premium {
            completion(false)
            return
        }
        
        self.sendData(data: ["listId": id, "name":self.encryptString(s: name)], file: "update/list.php") { (res: idResponseStruct?) in
            DispatchQueue.main.async {
                if let response = res {
                    if id == "null" {
                        self.family.tasks.append(TaskList(id: response.id, name: name, list: []))
                        completion(true)
                    }
                    return
                }
                completion(false)
            }
        }
    }
    
    func toggleLovedTask(taskId: String) {
        // MARK: Toggle loved Task
        self.sendData(data: ["taskId": taskId], file: "update/toggleLovedTask.php") { (res: publicKeyResponseStruct?) in
            DispatchQueue.main.async { [self] in
                if user.lovedTasks.contains(taskId) {
                    user.lovedTasks.remove(at: user.lovedTasks.firstIndex(of: taskId)!)
                } else {
                    user.lovedTasks.append(taskId)
                }
                return
            }
        }
    }
    
    
    func fetchAllData() {
        // MARK: Fetch all Data
        
        self.sendData(data: ["":""], file: "fetchAllData.php") { (res: fetchFamilyResponseStruct?) in
            if let response = res {
                DispatchQueue.main.async { [self] in
                    
                    family.name = decryptToString(d: response.name)
                    family.created = decryptToDate(d: response.created)
                    
                    let maxTasksServer = decryptToInt(d: response.maxTasks)
                    if family.maxTasks < maxTasksServer {
                        family.maxTasks = maxTasksServer
                    }
                    family.premium = decryptToString(d: response.subscribedToPro) == "true"
                    
                    family.users = []
                    familyBadge = 0
                    response.users.forEach { u in
                        let role = try? JSONDecoder().decode(UserRole.self, from: decryptToData(d: u.role))
                        var userHere = UserStruct(id: u.id, name: decryptToString(d: u.name), role: role ?? .children, actualPoints: decryptToFloat(d: u.actualPoints), everPoints: decryptToFloat(d: u.everPoints), tasksDoneCount: -1000, created: decryptToDate(d: u.created), lovedTasks: u.lovedTasks)
                        
                        u.devices.forEach { d in
                            let deviceHere = DeviceStruct(apiId: d.id, name: decryptToString(d: d.name), type: decryptToString(d: d.type), created: decryptToDate(d: d.created), osImage: decryptToString(d: d.osIcon))
                            
                            userHere.devices.append(deviceHere)
                            
                            if deviceHere.apiId == device.apiId {
                                device.name = deviceHere.name
                                device.type = deviceHere.type
                                device.created = deviceHere.created
                                device.osImage = deviceHere.osImage
                            }
                        }
                        
                        u.doneTasks.forEach { t in
                            userHere.tasksDone.append(TaskDoneStruct(doneId: t.id, id: t.taskId, time: decryptToDate(d: t.count), message: decryptToString(d: t.message)))
                        }
                        userHere.tasksDone.sort {$0.time < $1.time}
                        
                        if u.doneTasks.count != 0 {
                            familyBadge += 1
                        }
                        
                        family.users.append(userHere)
                        
                        if userHere.id == user.id {
                            user = userHere
                        }
                    }
                    
                    family.tasks = []
                    response.taskLists.forEach { l in
                        if !settings.taskListSequence.contains(l.id) {
                            settings.taskListSequence.insert(l.id, at: 0)
                        }
                    }
                    
                    settings.taskListSequence.forEach { pref in
                        if let l = response.taskLists.first(where: {$0.id == pref}) {
                            var list: [TaskStruct] = []
                            l.tasks.forEach { t in        // for each task in list
                                list.append(TaskStruct(name: decryptToString(d: t.name), id: t.id, listId: l.id, created: decryptToDate(d: t.created), pointsToAdd: decryptToFloat(d: t.points), howManyTimesDidAllUsers: decryptToInt(d: t.allUsersCount), counter:  user.tasksDone.first {$0.id == t.id}?.time ?? .now, orderWeight: decryptToInt(d: t.orderWeight)))
                            }
                            
                            list.sort{$0.orderWeight > $1.orderWeight}
                            
                            family.tasks.append(TaskList(id: l.id, name: decryptToString(d: l.name), list: list))
                        }
                    }
                    
                    
                    self.storeAllInAppStorage()
                    
                    
                    if family.maxTasks > maxTasksServer {
                        familyUpdate()
                    }
                    
                    loadDataFromWidget()
                    saveDataForWidget()
                    return
                }
            }
        }
    }
    
    
    
    var UserRSAKey: RSAKeyPair = SimpleSwiftCrypto.generateRandomRSAKeyPair()!
    func joinUserFetchDevices() {
        // MARK: Initialise Join User
        
        self.sendData(data: ["key":self.UserRSAKey.extractPublicKey().export()!.base64EncodedString()], file: "join/user/fetch.php") { (res: joinUserInitialiseResponseStruct?) in
            if let response = res {
                DispatchQueue.main.async {
                    
                    self.user.linkKey = response.code
                    
                    self.user.devicesWantingToLink = []
                    
                    response.devices.forEach { d in
                        let devJson = self.decryptToStringWithRSA(rsaPrivateKey: self.UserRSAKey, data: d.data)
                        if devJson != nil {
                             var dev = try! JSONDecoder().decode(deviceWantToJoinResponseStruct.self, from: Data(base64Encoded: devJson!)!)
                            dev.publicKey = d.key
                            self.user.devicesWantingToLink.append(dev)
                        }
                    }
                    self.storeUser()
                }
            }
        }
    }
    
    func joinUser(code: String, completion: @escaping (Bool) -> ()) {
        // MARK: Join User request by code
        if code.count != 6 {
            completion(false)
            return
        }
        
        self.sendData(data: ["code":code], file: "join/user/init.php") { (res: publicKeyResponseStruct?) in
            if let response = res {
                self.joinUserSendData(code: code, publicKey: response.publicKey) { res in
                    DispatchQueue.main.async {
                        completion(res)
                        return
                    }
                }
            }
        }
    }
    
    
    let DeviceRSAKey: RSAKeyPair = SimpleSwiftCrypto.generateRandomRSAKeyPair()!
    func joinUserSendData(code: String, publicKey: String, completion: @escaping (Bool) -> ()) {
        // MARK: Join User send Data
        
        let rsaKey: RSAPublicKey? = .load(rsaPublicKeyData: Data(base64Encoded: publicKey)!)
        if rsaKey == nil {
            completion(false)
            return
        }
        
        let d = deviceWantToJoinResponseStruct(id: self.device.apiId, name: self.device.name, type: self.device.type, publicKey: "", created: self.device.created.description)
        
        guard let x = try? JSONEncoder().encode(d) else {
            completion(false)
            return
        }
        
        let y = encryptStringWithRSA(key: rsaKey!, s: x.base64EncodedString())
        
        self.sendData(data: ["code":code, "data":y, "key":self.DeviceRSAKey.extractPublicKey().export()!.base64EncodedString()], file: "join/user/sendData.php") { (res: publicKeyResponseStruct?) in
            if let response = res {
                if response.publicKey == "Nah, doch nicht" {
                    DispatchQueue.main.async {
                        completion(true)
                        return
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                        return
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                    return
                }
            }
        }
    }
    
    
    
    func joinUserUpdateDeviceWantingToJoin(i: Int, accept: Bool) {
        // MARK: Join User accept/deny
        
        let device = self.user.devicesWantingToLink[i]
        let devKey: RSAPublicKey = .load(rsaPublicKeyData: Data(base64Encoded: device.publicKey)!)!
        
        self.sendData(data: ["keyEncoded":accept ? self.encryptStringWithRSA(key: devKey, s: self.AESCryptoKey.exportIvAndPrivateAES256Key().base64EncodedString()) : "DENIED", "id":device.publicKey, "deviceJoiningId":device.id], file: "join/user/accept.php") { (res: idResponseStruct?) in
            if res != nil {
                // it worked no matter what Struct (idResponseStruct)
                self.fetchAllData()
            }
        }
    }
    
    func joinUserCheckAccepted(completion: @escaping (Bool?) -> ()) {
        // MARK: Join User check accept
        self.sendData(data: ["id":self.DeviceRSAKey.extractPublicKey().export()!.base64EncodedString()], file: "join/user/checkAccepted.php") { (res: joinUserCheckAcceptedResponseStruct?) in
            DispatchQueue.main.async {
                if let response = res {
                    if response.accepted {
                        let k: AES256Key? = .loadIvAndPrivateAES256Key(ivAndPrivateAES256Key: Data(base64Encoded: self.decryptToStringWithRSA(rsaPrivateKey: self.DeviceRSAKey, data: response.key!)!)!)
                        if k == nil {
                            completion(nil)
                            return
                        }
                        self.AESCryptoKey = k!
                        self.user.id = response.userId!
                        self.family.id = response.familyId!
                        self.settings.firstLogin = false
                        self.storeAllInAppStorage()
                        self.deviceUpdate()
                        completion(true)
                        return
                    } else {
                        completion(false)
                        return
                    }
                }
                completion(nil)
                return
            }
        }
    }
    
    
    
    var FamilyRSAKey: RSAKeyPair = SimpleSwiftCrypto.generateRandomRSAKeyPair()!
    func joinFamilyInit() {
        // MARK: Initialise Join Family
        
        self.sendData(data: ["key":self.FamilyRSAKey.extractPublicKey().export()!.base64EncodedString()], file: "join/family/fetch.php") { (res: joinUserInitialiseResponseStruct?) in
            if let response = res {
                DispatchQueue.main.async {
                    
                    self.family.linkKey = response.code
//                    print(response.code)
                    
                    self.family.usersWantingToLink = []
                    
                    response.devices.forEach { d in
                        let devJson = self.decryptToStringWithRSA(rsaPrivateKey: self.FamilyRSAKey, data: d.data)
                        if devJson != nil {
                             var dev = try! JSONDecoder().decode(deviceWantToJoinResponseStruct.self, from: Data(base64Encoded: devJson!)!)
                            dev.publicKey = d.key
                            self.family.usersWantingToLink.append(dev)
                        }
                    }
                    self.storeFamily()
                }
            }
        }
    }
    
    func joinFamily(code: String, completion: @escaping (Bool) -> ()) {
        // MARK: Join Family request by code
        if code.count != 6 {
            completion(false)
            return
        }
        
        self.sendData(data: ["code":code], file: "join/family/init.php") { (res: publicKeyResponseStruct?) in
            if let response = res {
                self.joinFamilySendData(code: code, publicKey: response.publicKey) { res in
                    DispatchQueue.main.async {
                        completion(res)
                        return
                    }
                }
            }
        }
    }
    
    
    let UserJoinFamilyRSAKey: RSAKeyPair = SimpleSwiftCrypto.generateRandomRSAKeyPair()!
    func joinFamilySendData(code: String, publicKey: String, completion: @escaping (Bool) -> ()) {
        // MARK: Join Family send Data
        
        let rsaKey: RSAPublicKey? = .load(rsaPublicKeyData: Data(base64Encoded: publicKey)!)
        if rsaKey == nil {
            completion(false)
            return
        }
        
        let d = deviceWantToJoinResponseStruct(id: self.user.id, name: self.user.name, type: self.user.role == .parent ? "Parent" : "Children", publicKey: "", created: self.user.created.description)
        
        guard let x = try? JSONEncoder().encode(d) else {
            completion(false)
            return
        }
        
        let y = encryptStringWithRSA(key: rsaKey!, s: x.base64EncodedString())
        
        self.sendData(data: ["code":code, "data":y, "key":self.UserJoinFamilyRSAKey.extractPublicKey().export()!.base64EncodedString()], file: "join/family/sendData.php") { (res: publicKeyResponseStruct?) in
            if let response = res {
                if response.publicKey == "Nah, doch nicht" {
                    DispatchQueue.main.async {
                        completion(true)
                        return
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                        return
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                    return
                }
            }
        }
    }
    
    
    
    func joinFamilyUpdateDeviceWantingToJoin(i: Int, accept: Bool) {
        // MARK: Join Family accept/deny
        
        let device = self.family.usersWantingToLink[i]
        let devKey: RSAPublicKey = .load(rsaPublicKeyData: Data(base64Encoded: device.publicKey)!)!
        
        self.sendData(data: ["keyEncoded":accept ? self.encryptStringWithRSA(key: devKey, s: self.AESCryptoKey.exportIvAndPrivateAES256Key().base64EncodedString()) : "DENIED", "id":device.publicKey, "deviceJoiningId":device.id], file: "join/family/accept.php") { (res: idResponseStruct?) in
            if res != nil {
                // it worked no matter what Struct (idResponseStruct)
                self.joinFamilyInit()
            }
        }
    }
    
    func joinFamilyCheckAccepted(completion: @escaping (Bool?) -> ()) {
        // MARK: Join Family check accept
        self.sendData(data: ["id":self.UserJoinFamilyRSAKey.extractPublicKey().export()!.base64EncodedString()], file: "join/family/checkAccepted.php") { (res: joinUserCheckAcceptedResponseStruct?) in
            DispatchQueue.main.async {
                if let response = res {
                    if response.accepted {
                        let k: AES256Key? = .loadIvAndPrivateAES256Key(ivAndPrivateAES256Key: Data(base64Encoded: self.decryptToStringWithRSA(rsaPrivateKey: self.UserJoinFamilyRSAKey, data: response.key!)!)!)
                        if k == nil {
                            completion(nil)
                            return
                        }
                        self.AESCryptoKey = k!
                        self.family.id = response.familyId!
                        self.settings.firstLogin = false
                        self.storeAllInAppStorage()
                        self.userUpdate()
                        self.deviceUpdate()
                        completion(true)
                        return
                    } else {
                        completion(false)
                        return
                    }
                }
                completion(nil)
                return
            }
        }
    }
    
    func getNiceJsonData() -> String {
        var duplicatedFamily = self.family
        
        duplicatedFamily.users = duplicatedFamily.users.map { user in
            var duplicatedUser = user
            duplicatedUser.id = ""
            return duplicatedUser
        }

        // Step 3: Remove IDs in task lists and tasks
        duplicatedFamily.tasks = duplicatedFamily.tasks.map { taskList in
            var duplicatedTaskList = taskList
            duplicatedTaskList.list = duplicatedTaskList.list.map { task in
                var duplicatedTask = task
                duplicatedTask.id = ""
                return duplicatedTask
            }
            return duplicatedTaskList
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(duplicatedFamily) else { return "error" }
        return String(data: data, encoding: .utf8) ?? "error"
    }
    
    
    func loadUserFromImportedStruct(data: exportUserDataStruct) {
        if self.user.id.isEmpty && self.family.id.isEmpty && !data.deviceId.isEmpty && !data.userId.isEmpty && !data.familyId.isEmpty && !data.key.isEmpty {
            self.showProgress = true
            
            let oldId = self.device.apiId
            self.device.apiId = data.deviceId
            self.user.id = data.userId
            self.family.id = data.familyId
            self.sendData(data: ["id":oldId], file: "create/addDeviceToUser.php") { (res: someResponseStruct?) in
                DispatchQueue.main.async {
                    if res != nil {
                        guard let k: AES256Key = .loadIvAndPrivateAES256Key(ivAndPrivateAES256Key: Data(base64Encoded: data.key)!) else {
                            return
                        }
                        self.AESCryptoKey = k
                        self.device.apiId = oldId
                        self.deviceUpdate()
                    } else {
                        self.device.apiId = oldId
                        self.user.id = ""
                        self.family.id = ""
                    }
                    self.showProgress = false
                    self.storeAllInAppStorage()
                }
            }
        }
    }
    
    func sendMessage(message: String) {
        // MARK: Send Message
        
        self.sendData(data: ["message":message], file: "create/message.php") { (res: someResponseStruct?) in
            
        }
    }
    
    func sendVideoFeedback(helpful: Bool, message: String?) {
        var mes = message
        if mes == nil {
            mes = "no message"
        }
        if mes!.isEmpty {
            mes = "no message"
        }
        
        self.sendData(data: ["message":mes!, "helpful":helpful ? "true" : "false"], file: "create/videoFeedback.php") { (res: someResponseStruct?) in
            
        }
    }
    
    
    // MARK: Widget stuff
    func saveDataForWidget() {
        var data = widgetDataStruct(deviceId: device.apiId, userId: user.id, familyId: family.premium ? "premium" : "no", tasks: [])
        print("-----")
        print(family.premium)
        print("-----")
        family.tasks.forEach { l in
            l.list.forEach { t in
                data.tasks.append(t)
            }
        }
        DispatchQueue.global().async {
            if let defaults = UserDefaults(suiteName: "group.org.hoeschen.lukas.familyPoints.App.AppGroup") {
                if let encoded = try? JSONEncoder().encode(data) {
                    defaults.setValue(encoded, forKey: "widgetData")
                    defaults.synchronize()
                }
            }
        }
    }
    
    func loadDataFromWidget() {
        if let defaults = UserDefaults(suiteName: "group.org.hoeschen.lukas.familyPoints.App.AppGroup") {
            if let storedData = defaults.data(forKey: "widgetAddedCount") {
                if let data = try? JSONDecoder().decode(widgetChangesStruct.self, from: storedData) {
                    
//                    var counts: [String: Int] = [:]
//
//                    for item in data.list {
//                        counts[item] = (counts[item] ?? 0) + 1
//                    }
//
//                    for (key, value) in counts {
////                        TODO: Widget
////                        self.updateTaskDone(taskId: key, count: (self.getTask(id: key)?.counter ?? 0) + value)
//                        self.updateTaskDone(taskId: key, time: .now, message: "")
//                    }
                    
                    for item in data.list {
                        self.updateTaskDone(taskId: item, time: .now, message: "")
                    }
                    
                    DispatchQueue.global().async {
                        if let defaults = UserDefaults(suiteName: "group.org.hoeschen.lukas.familyPoints.App.AppGroup") {
                            if let encoded = try? JSONEncoder().encode(widgetChangesStruct(list: [])) {
                                defaults.setValue(encoded, forKey: "widgetAddedCount")
                                defaults.synchronize()
                            }
                        }
                    }
                }
            }
        }
    }
}

extension Date {
    var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}


class functionsClass {
    
    func floatToShortString(x: Float) -> String {
        if (Float(Int(x)) == x) {
            // like 17.0
            return String(Int(x))
        } else {
            // like 17.5
            return String(x)
        }
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func dateAsString(d: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d HH:mm"
        return formatter.string(from: d)
    }
    
    func dateToRelative(d: Date) -> String {
        return d.toRelative(since: nil)
    }
}
