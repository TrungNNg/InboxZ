//
//  UserTask+CoreDataProperties.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 11/29/23.
//
//

import Foundation
import CoreData


extension UserTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserTask> {
        return NSFetchRequest<UserTask>(entityName: "UserTask")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var subtasks: NSObject?
    @NSManaged public var dueDate: Date?
    @NSManaged public var status: Int16
    @NSManaged public var createDate: Date?
    @NSManaged public var difficulty: Int16
    @NSManaged public var priority: Int16
    @NSManaged public var repeatEvery: Double
    @NSManaged public var goals: NSSet?

}

// MARK: Generated accessors for goals
extension UserTask {

    @objc(addGoalsObject:)
    @NSManaged public func addToGoals(_ value: UserGoal)

    @objc(removeGoalsObject:)
    @NSManaged public func removeFromGoals(_ value: UserGoal)

    @objc(addGoals:)
    @NSManaged public func addToGoals(_ values: NSSet)

    @objc(removeGoals:)
    @NSManaged public func removeFromGoals(_ values: NSSet)

}

extension UserTask : Identifiable {

}
