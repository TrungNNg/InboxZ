//
//  EditTaskView.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 11/29/23.
//

import SwiftUI

/// Create a new Task if no task transfer in, else edit existing task
struct EditTaskView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    private var userTask: UserTask?
    init(userTask: UserTask) { self.userTask = userTask } // edit existing task
    init() {} // add new task

    @FetchRequest(sortDescriptors: []) private var goals: FetchedResults<UserGoal>
    @State var selectedGoal: [UserGoal] = []
    @State var goalsAreLoaded: Bool = false // use to update selectedGoal only once when the view first appear
    @State private var showGoalSheet: Bool = false
    
    @State private var name: String = "" // can not be empty
    @State private var note: String = ""
    @State private var subTasks: [String] = [""]
    
    @State private var status: Int16 = TaskStatus.Active.rawValue
    @State private var difficulty: Int16 = TaskDifficulty.Easy.rawValue
    @State private var priority: Int16 = TaskPriority.SomeWhatImportant.rawValue
    
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = .now // optional
    @State private var isRepeated: Bool = false
    @State private var repeatEvery: Int16 = 1 // optional
        
    var body: some View {
        Form {
            Section {
                TextField("I want to...", text: $name)
                TextField("\(Image(systemName: "note.text")) note", text: $note)
                ForEach(subTasks.indices, id: \.self) { index in
                    TextField("\(Image(systemName: "square")) subtask", text: $subTasks[index])
                        .onChange(of: subTasks[index]) { _ in
                            if index == subTasks.endIndex - 1 && subTasks.last != "" {
                                subTasks.append("")
                            } else if subTasks[index] == "" {
                                subTasks.remove(at: index)
                            }
                        }
                }
            }
            
            Section {
                Button("Goals this task contributes to") {
                    showGoalSheet = true
                }
                ForEach(selectedGoal, id: \.self) { goal in
                    HStack {
                        Image(systemName: "flag.checkered")
                        Text(goal.unwrapName)
                    }
                }
            }
            
            Section("Default") {
                Picker("Status", selection: $status) {
                    ForEach(TaskStatus.allCases) { taskStatus in
                        Text(taskStatus.stringDescription)
                            .tag(taskStatus.rawValue)
                    }
                }
                Picker("Difficulty", selection: $difficulty) {
                    ForEach(TaskDifficulty.allCases) { taskDif in
                        Text(taskDif.stringDescription)
                            .tag(taskDif.rawValue)
                    }
                }
                Picker("Priority", selection: $priority) {
                    ForEach(TaskPriority.allCases) { taskPri in
                        Text(taskPri.stringDescription)
                            .tag(taskPri.rawValue)
                    }
                }
            }
            
            Section("Optional") {
                Toggle("Due date", isOn: $hasDueDate)
                if hasDueDate {
                    DatePicker("", selection: $dueDate, in: Date()...Calendar.current.date(byAdding: .year, value: 10, to: Date())!)
                }
                Toggle("Repeat", isOn: $isRepeated)
                if isRepeated {
                    Picker("Every", selection: $repeatEvery) {
                        ForEach(1..<32) { i in
                            Text(i == 1 ? "\(i) day" : "\(i) days").tag(Int16(i))
                        }
                    }
                }
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { saveTask() }
            }
        }
        .sheet(isPresented: $showGoalSheet) {
            VStack {
                if goals.isEmpty {
                    EmptyItemView(title: "No Goal", subTitle: "Use Goal tab to add goal")
                } else {
                    List(goals) { goal in
                        HStack {
                            Text(goal.unwrapName)
                            Spacer()
                            if let _ = selectedGoal.firstIndex(of: goal) {
                                Image(systemName: "checkmark").foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let index = selectedGoal.firstIndex(of: goal) {
                                selectedGoal.remove(at: index)
                            } else {
                                selectedGoal.append(goal)
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listRowSpacing(5)
                }
            }
            .presentationDetents([.medium,.large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            //print("edit task appeared")
            selectedGoal.removeAll { g in
                return g.id == nil
            }
            
            if let userTask {
                name = userTask.unwrapName
                note = userTask.unwrapNote
                subTasks = userTask.unwrapSubTasks
                status = userTask.status
                difficulty = userTask.difficulty
                priority = userTask.priority
                
                if !goalsAreLoaded {
                    //print("reset selected Goal")
                    selectedGoal = userTask.unwrapGoals
                    goalsAreLoaded = true
                }
                
                if let dDate = userTask.dueDate {
                    dueDate = dDate
                    hasDueDate = true
                }
                if userTask.repeatEvery > 0 {
                    repeatEvery = userTask.repeatEvery
                    isRepeated = true
                }
            }
        }
        
    } // end body
    
    func saveTask() {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard name != "" else {
            dismiss()
            return
        }
        var task: UserTask
        if let userTask {
            task = userTask
        } else {
            task = UserTask(context: context)
            task.id = UUID()
            task.createDate = .now
        }
        task.unwrapName = name
        task.unwrapNote = note
        task.unwrapSubTasks = subTasks
        task.status = status
        task.difficulty = difficulty
        task.priority = priority
        task.unwrapGoals = selectedGoal
        
        task.dueDate = dueDate
        if !hasDueDate { task.dueDate = nil }
        
        task.repeatEvery = repeatEvery
        if !isRepeated {
            task.repeatEvery = 0
            task.repeatDate = nil
        }
        
        do {
            try context.save()
            print("save success", task)
        } catch {
            //print("save error \(error)")
        }
        dismiss()
    }
    
}


 #Preview {
     EditTaskView()
 }

