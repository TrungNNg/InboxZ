//
//  UserTask+CoreDataProperties.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 12/16/23.
//
//

import Foundation
import CoreData


extension UserTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserTask> {
        return NSFetchRequest<UserTask>(entityName: "UserTask")
    }
    
    @NSManaged public var repeatDate: Date?

    @NSManaged public var difficulty: Int16
    @NSManaged public var dueDate: Date? // nil mean no due date
    @NSManaged public var priority: Int16
    @NSManaged public var repeatEvery: Int16
    @NSManaged public var status: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var createDate: Date? // always non nil
    
    @NSManaged private var name: String?
    @NSManaged private var note: String?
    @NSManaged private var subtasks: [String]?
    @NSManaged private var goals: NSSet?
    
    public var unwrapName: String {
        get { name ?? "name is nil" }
        set { name = newValue }
    }
    
    public var unwrapNote: String {
        get { note ?? "note is nil" }
        set { note = newValue }
    }
    
    public var unwrapSubTasks: [String] {
        get { subtasks ?? [] }
        set { subtasks = newValue }
    }
    
    public var unwrapGoals: [UserGoal] {
        get {
            if let arr = goals?.allObjects as? [UserGoal] {
                return arr.sorted { $0.createDate! < $1.createDate! }
            }
            return []
        }
        set {
            self.removeFromGoals(goals ?? [])
            self.addToGoals(NSSet(array: newValue))
        }
    }
    
    // MARK: - for TaskRowView
    public var secondsRemain: Double {
        guard let dueDate else { return .infinity } // no due date -> days = infinity
        return dueDate.timeIntervalSinceNow // seconds from dueDate to now
    }

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
