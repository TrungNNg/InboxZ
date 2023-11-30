//
//  EditTaskView.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 11/29/23.
//

import SwiftUI

/// Create a new Task if no task transfer in, else edit existing task
struct EditTaskView: View {
    
    private var userTask: UserTask?
    
    /*
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
    */
    @State private var name: String = "" // can not be empty
    @State private var note: String = ""
    @State private var subTasks: [String] = [""]
    
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = .now // optional
    
    @State private var status: Int16 = TaskStatus.Active.rawValue
    @State private var difficulty: Int16 = TaskDifficulty.Easy.rawValue
    @State private var priority: Int16 = TaskPriority.SomeWhatImportant.rawValue
    
    @State private var isRepeated: Bool = false
    @State private var repeatEvery: Double = 1.0 // optional
    
    var body: some View {
        Form {
            Section {
                TextField("I want to...", text: $name)
                TextField("Add note", text: $note)
                ForEach(subTasks.indices, id: \.self) { index in
                    TextField("Add subtask", text: $subTasks[index])
                        .onChange(of: subTasks[index]) {
                            if let lastSubtask = subTasks.last {
                                if lastSubtask != "" {
                                    subTasks.append("")
                                }
                            }
                        }
                }
            }
            
            Section("Default") {
                Picker("Status", selection: $status) {
                    ForEach(TaskStatus.allCases) { taskStatus in
                        Text(taskStatus.stringDescription).tag(taskStatus.rawValue)
                    }
                }
                Picker("Difficulty", selection: $difficulty) {
                    ForEach(TaskDifficulty.allCases) { taskDif in
                        Text(taskDif.stringDescription).tag(taskDif.rawValue)
                    }
                }
                Picker("Priority", selection: $priority) {
                    ForEach(TaskPriority.allCases) { taskPri in
                        Text(taskPri.stringDescription).tag(taskPri.rawValue)
                    }
                }
            }
            
            Section("Optional") {
                Toggle("Due date", isOn: $hasDueDate)
                if hasDueDate {
                    HStack {
                        DatePicker("", selection: $dueDate, in: Date()...Calendar.current.date(byAdding: .year, value: 10, to: Date())!)
                    }
                }
                Toggle("Repeat", isOn: $isRepeated)
                if isRepeated {
                    Picker("Every", selection: $repeatEvery) {
                        ForEach(1..<30) { i in
                            Text(i == 1 ? "\(i) day" : "\(i) days").tag(Double(i))
                        }
                    }
                }
            }
            
        }
    }
}

#Preview {
    EditTaskView()
}
