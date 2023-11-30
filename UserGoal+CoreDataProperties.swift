//
//  UserGoal+CoreDataProperties.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 11/29/23.
//
//

import Foundation
import CoreData


extension UserGoal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserGoal> {
        return NSFetchRequest<UserGoal>(entityName: "UserGoal")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var reason: String?
    @NSManaged public var isCompleteIf: String?
    @NSManaged public var dueDate: Date?
    @NSManaged public var createDate: Date?
    @NSManaged public var easyTask: Int32
    @NSManaged public var mediumTask: Int32
    @NSManaged public var hardTask: Int32
    @NSManaged public var tasks: NSSet?

}

// MARK: Generated accessors for tasks
extension UserGoal {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: UserTask)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: UserTask)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}

extension UserGoal : Identifiable {

}
