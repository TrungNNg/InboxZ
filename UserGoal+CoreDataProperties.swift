//
//  UserGoal+CoreDataProperties.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 12/3/23.
//
//

import Foundation
import CoreData


extension UserGoal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserGoal> {
        return NSFetchRequest<UserGoal>(entityName: "UserGoal")
    }

    @NSManaged public var createDate: Date?
    @NSManaged public var dueDate: Date?
    @NSManaged public var easyTask: Int32
    @NSManaged public var hardTask: Int32
    @NSManaged public var id: UUID?
    @NSManaged private var goalDescription: String?
    @NSManaged public var mediumTask: Int32
    @NSManaged private var name: String?
    @NSManaged public var tasks: NSSet?
    
     public var unwrapName: String {
         get { name ?? "name is nil" }
         set { name = newValue }
     }
     
     public var unwrapGoalDescription: String {
         get { goalDescription ?? "goalDescription is nil" }
         set { goalDescription = newValue }
     }
     
     public var unwrapTasks: [UserTask] {
         get {
             if let arr = tasks?.allObjects as? [UserTask] {
                 let temp = arr.filter({ t in   // filter out task that has repeatDate in the future
                     if let repeatDate = t.repeatDate { return repeatDate < .now }
                     return true
                 })
                 return temp.sorted { $0.createDate! < $1.createDate! } // createDate always non-nil
             }
             return []
         }
         set {
             self.removeFromTasks(tasks ?? [])
             self.addToTasks(NSSet(array: newValue))
         }
     }
    
    public var secondsRemain: Double {
        guard let dueDate else { return .infinity } // no due date -> days = infinity
        return dueDate.timeIntervalSinceNow // seconds from dueDate to now
    }

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
