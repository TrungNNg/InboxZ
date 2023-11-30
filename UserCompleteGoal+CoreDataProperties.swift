//
//  UserCompleteGoal+CoreDataProperties.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 11/29/23.
//
//

import Foundation
import CoreData


extension UserCompleteGoal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserCompleteGoal> {
        return NSFetchRequest<UserCompleteGoal>(entityName: "UserCompleteGoal")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var goalName: String?
    @NSManaged public var completeDate: Date?

}

extension UserCompleteGoal : Identifiable {

}
