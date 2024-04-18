//
//  AppModel.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 11/29/23.
//

import Foundation
import CoreData

/// This model create CoreData, FaceID, and Storekit
class ZeroInboxModel: ObservableObject {
    //CoreData
    let container = NSPersistentContainer(name: "ZeroInbox")
    
    init() {
        container.loadPersistentStores { desc, error in
            if let error = error {
                print("load core data failed \(error)")
                exit(EXIT_FAILURE)
            }
        }
    }
}

enum TaskStatus: Int16, CaseIterable, Identifiable {
    case Active = 1
    case InProgress = 2
    case Completed = 3
    
    var id: Self { self }
    var stringDescription: String {
        switch self {
        case .Active:
            return "Active"
        case .InProgress:
            return "In Progress"
        case .Completed:
            return "Completed"
        }
    }
}

enum TaskPriority: Int16, CaseIterable, Identifiable {
    case SomeWhatImportant = 1
    case Important = 2
    case VeryImportant = 3
    
    var id: Self { self }
    var stringDescription: String {
        switch self {
        case .SomeWhatImportant:
            return "Some What Important"
        case .Important:
            return "Important"
        case .VeryImportant:
            return "Very Important"
        }
    }
}

enum TaskDifficulty: Int16, CaseIterable, Identifiable {
    case Easy = 1
    case Medium = 2
    case Hard = 3
    
    var id: Self { self }
    var stringDescription: String {
        switch self {
        case .Easy:
            return "Easy"
        case .Medium:
            return "Medium"
        case .Hard:
            return "Hard"
        }
    }
}
