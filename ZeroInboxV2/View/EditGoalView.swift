//
//  EditGoalView.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 11/29/23.
//

import SwiftUI

struct EditGoalView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    private var userGoal: UserGoal?
    init(userGoal: UserGoal) { self.userGoal = userGoal } // edit existing goal
    init() {} // add new goal
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = .now
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "repeatDate < %@ || repeatDate == nil", Date.now as CVarArg)) private var tasks: FetchedResults<UserTask>
    @State var selectedTasks: [UserTask] = []
    @State private var showTaskSheet: Bool = false
    
    /// only load tasks from existing goal once, without this, the view will keep reset selectedTasks everytime the view appear
    @State var tasksAreLoaded: Bool = false
    
    var body: some View {
        Form {
            TextField("My goal / desire is...", text: $name)
            
            Section("Description") {
                TextEditor(text: $description)
            }
            
            Section {
                Button("Tasks contribute to this goal") {
                    showTaskSheet = true
                }
                
                ForEach(selectedTasks) { task in
                    Text(task.unwrapName)
                }
            }
            Section("Optional") {
                Toggle("Due date", isOn: $hasDueDate)
                if hasDueDate {
                    HStack {
                        DatePicker("", selection: $dueDate, in: Date()...Calendar.current.date(byAdding: .year, value: 10, to: Date())!)
                    }
                }
            }
        } // end form
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { saveGoal() }
            }
        }
        .sheet(isPresented: $showTaskSheet) {
            VStack {
                if tasks.isEmpty {
                    EmptyItemView(title: "No Task", subTitle: "Use Task tab to add task")
                } else {
                    List(tasks) { task in
                        HStack {
                            Text(task.unwrapName)
                            Spacer()
                            if let _ = selectedTasks.firstIndex(of: task) {
                                Image(systemName: "checkmark").foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let index = selectedTasks.firstIndex(of: task) {
                                selectedTasks.remove(at: index)
                            } else {
                                selectedTasks.append(task)
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                    //.listStyle(.inset)
                    .listRowSpacing(5)
                }
            }
            .presentationDetents([.medium,.large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            selectedTasks.removeAll { t in
                return t.id == nil
            }
            if let userGoal {
                name = userGoal.unwrapName
                description = userGoal.unwrapGoalDescription
                
                if !tasksAreLoaded {
                    selectedTasks = userGoal.unwrapTasks
                    tasksAreLoaded = true
                }
                
                if let dDate = userGoal.dueDate {
                    dueDate = dDate
                    hasDueDate = true
                }
            }
        }
    } // end body
    
    func saveGoal() {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard name != "" else {
            dismiss()
            return
        }
        var goal: UserGoal
        if let userGoal {
            goal = userGoal
        } else {
            goal = UserGoal(context: context)
            goal.id = UUID()
            goal.createDate = .now
        }
        goal.unwrapName = name
        goal.unwrapGoalDescription = description
        goal.unwrapTasks = selectedTasks

        goal.dueDate = dueDate
        if !hasDueDate {
            goal.dueDate = nil
        }
        
        do {
            try context.save()
            //print("save success")
        } catch {
            //print("save error \(error)")
        }
        dismiss()
    }
    
}

#Preview {
    EditGoalView()
}
