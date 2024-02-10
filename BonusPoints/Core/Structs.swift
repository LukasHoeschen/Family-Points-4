//
//  Structs.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 29.12.22.
//

import Foundation
import SwiftDate
import SwiftUI
import UniformTypeIdentifiers


struct DeviceStruct: Codable, Hashable {
    var apiId: String
    var name: String
    var type: String
    var created: Date
    var osImage: String = "iphone"
    
    func getDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy HH:mm"
        return formatter.string(from: created)
    }
}

struct UserStruct: Codable, Hashable {
    var id: String
    var name: String
    var role: UserRole
    var actualPoints: Float
    var everPoints: Float
    var tasksDoneCount: Int
    var created: Date
    var devices: [DeviceStruct] = []
    var linkKey = ""
    var devicesWantingToLink: [deviceWantToJoinResponseStruct] = []
    var lovedTasks: [String] = []
    var tasksDone: [TaskDoneStruct] = []
    
    func getDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy HH:mm"
        return formatter.string(from: created)
    }
    
    func getColor() -> Color {
        return role == .children ? .blue : .teal
    }
}

struct TaskDoneStruct: Codable, Hashable {
    var id: String
    var count: Int
}

enum UserRole: Codable {
    case children
    case parent
}

struct FamilyStruct: Codable {
    var id: String
    var name: String
    var tasks: [TaskList]
    var created = Date.now
    var users: [UserStruct] = []
    var linkKey = ""
    var usersWantingToLink: [deviceWantToJoinResponseStruct] = []
    var maxTasks = 30
    var doneTasksHistory: [TaskHistoryStruct] = []
    var premium = false
    
    func getDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy HH:mm"
        return formatter.string(from: created)
    }
}

struct TaskHistoryStruct: Codable, Hashable {
    var userId: String
    var taskId: String
    var date: Date
    var count: Int
}

struct TaskStruct: Codable, Hashable {
    var name: String
    var id: String
    var listId: String
    var created: Date = Date.now
    var pointsToAdd: Float
    var howManyTimesDidAllUsers: Int
    var counter: Int
    var orderWeight: Int
    var archivedPoints: Float {
        return Float(self.counter) * self.pointsToAdd
    }
    
    func getDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy, HH:mm"
        return formatter.string(from: created)
    }
}


struct MultipleTaskListStruct: Codable {
    var list: [TaskList] = []
}

struct TaskList: Codable, Hashable {
    var id: String
    var name: String
    var list: [TaskStruct]
}

struct SettingsStruct: Codable, Equatable {
    var appVersion: String = "0.0.1"
    var taskListSequence: [String] = []
    var firstLogin = true
}

struct serverResponseStruct<T: Codable>: Codable {
    var success: Bool
    var data: T?
    var message: String?
}

struct deviceSentStruct: Codable {
    var name: String
    var type: String
    var created: String
    var osImage: String
}

struct createNewUserServerRequestStruct: Codable {
    var name: String
    var role: String
    var created: String
    var publicKey: Data
}

struct userServerResponse: Codable {
    var name: String
    var apiId: String
    var role: String
    var publicKey: Data
    var created: String
    var tasksDone: String
    var actualPoints: String
    var everPoints: String
}

struct createNewFamilyServerRequestStruct: Codable {
    var name: String
    var created: String
    var creatingUserApiId: String
    var taskIds: [taskListIdsEncodedStruct]
    
}

struct userServerResponseStruct: Codable {
    var apiId: String
    var name: String
    var created: String
    var tasks: [taskListIdsStruct]
    var users: [String]
}

struct taskListIdsStruct: Codable {
    var name: String
    var list: [String]
    
//    func encrypt(key: AES256Key) -> taskListIdsEncodedStruct {
//        return taskListIdsEncodedStruct(name: key.encrypt(data: self.name.data(using: .utf8) ?? Data()) ?? Data(), list: self.list)
//    }
}

struct taskListIdsEncodedStruct: Codable {
    var name: String
    var list: [String]
    
//    func decrypt(key: AES256Key) -> taskListIdsStruct {
//        return taskListIdsStruct(name: String(data: key.decrypt(data: self.name) ?? Data(), encoding: .utf8) ?? "-no name-", list: self.list)
//    }
}




struct idResponseStruct: Codable {
    var id: String
}



struct fetchDeviceResponseStruct: Codable {
    var name: String
    var type: String
    var id: String
    var created: String
    var osIcon: String
}

struct fetchUserResponseStruct: Codable {
    var name: String
    var role: String
    var id: String
    var actualPoints: String
    var everPoints: String
    var created: String
    var devices: [fetchDeviceResponseStruct]
    var lovedTasks: [String]
    var doneTasks: [fetchTaskDoneResponseStruct]
}

struct fetchFamilyResponseStruct: Codable {
    var name: String
    var created: String
    var maxTasks: String
    var subscribedToPro: String
    var users: [fetchUserResponseStruct]
    var taskLists: [fetchTaskListsResponseStruct]
    var doneTasksHistory: [FetchTaskHistoryStruct] = []
}

struct FetchTaskHistoryStruct: Codable {
    var userId: String
    var taskId: String
    var date: String
    var count: String
}

struct fetchTaskListsResponseStruct: Codable {
    var id: String
    var name: String
    var tasks: [fetchTaskResponseStruct]
}

struct fetchTaskResponseStruct: Codable {
    var id: String
    var name: String
    var points: String
    var orderWeight: String
    var allUsersCount: String
    var created: String
}

struct fetchTaskDoneResponseStruct: Codable {
    var taskId: String
    var count: String
}


struct joinUserInitialiseResponseStruct: Codable {
    var devices: [devicesWantingToJoinResponseWithKeyStruct]
    var code: String
}


struct deviceWantToJoinResponseStruct: Codable, Hashable {
    var id: String
    var name: String
    var type: String
    var publicKey: String
    var created: String
}

struct publicKeyResponseStruct: Codable {
    var publicKey: String
}

struct devicesWantingToJoinResponseWithKeyStruct: Codable {
    var key: String
    var data: String
}

struct joinUserCheckAcceptedResponseStruct: Codable {
    var accepted: Bool
    var key: String?
    var userId: String?
    var familyId: String?
}

struct someResponseStruct: Codable {
    var some: String?
}




struct exportUserDataStruct: Codable {
    var deviceId: String
    var userId: String
    var familyId: String
    var key: String
}



struct widgetDataStruct: Codable {
    let deviceId: String
    let userId: String
    var familyId: String
    var tasks: [TaskStruct]
}

struct widgetChangesStruct: Codable {
    var list: [String]
}



extension UTType {
    static var exportUserData: UTType = UTType(exportedAs: "org.hoeschen.lukas.bonusPoints.userProfile")
}

extension exportUserDataStruct: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .exportUserData)
    }
}
