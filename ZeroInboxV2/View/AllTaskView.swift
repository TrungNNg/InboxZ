//
//  AllTaskView.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 11/29/23.
//

import SwiftUI
import StoreKit

struct AllTaskView: View {
    @Environment(\.managedObjectContext) private var context
    
    // filter out task that has repeatDate in the future
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "repeatDate < %@ || repeatDate == nil", Date.now as CVarArg)) private var tasks: FetchedResults<UserTask>
    
    @EnvironmentObject var model: ZeroInboxModel
    @AppStorage("darkModeOn") private var darkModeOn = false
    
    private var filteredTasks: [UserTask] {
        var temp: [UserTask] = []
        switch showListOption {
        case .All:
            temp = tasks.filter {_ in true}
        case .Active:
            temp = tasks.filter { $0.status == TaskStatus.Active.rawValue }
        case .InProgress:
            temp = tasks.filter { $0.status == TaskStatus.InProgress.rawValue }
        case .Completed:
            temp = tasks.filter { $0.status == TaskStatus.Completed.rawValue }
        }
        switch sortOption {
        case .DueDate:
            temp.sort { $0.secondsRemain < $1.secondsRemain }
        case .Priority:
            temp.sort { $0.priority > $1.priority }
        case .Difficulty:
            temp.sort { $0.difficulty > $1.difficulty }
        case .Goals:
            temp.sort { $0.unwrapGoals.count > $1.unwrapGoals.count }
        }
        return temp
    }
    
    private var totalCompletedTasks: Int {
        var n: Int = 0
        for t in tasks {
            if t.status == TaskStatus.Completed.rawValue { n += 1}
        }
        return n
    }
    
    @State private var showListOption: ShowListOptions = .All
    @State private var sortOption: SortOptions = .DueDate
    
    @State private var showSheet: Bool = false
    @State private var showSecondSheetContent = false
    @State private var temp: ShowListOptions = .All
    
    @State private var showRegisterAlert: Bool = false
    @State private var alertMessage = AlertMessage(title: "", description: "")
    
    var body: some View {
        NavigationStack {
            ZStack {
                if tasks.isEmpty {
                    EmptyItemView(title: "No Task", subTitle: "Use  +  to add task")
                        .toolbar {
                            toolbarContent()
                        }
                        .sheet(isPresented: $showSheet) {
                            filterSheetContent
                        }
                        .alert(alertMessage.title, isPresented: $showRegisterAlert, presenting: alertMessage) { m in
                            Button("Ok") { }
                        } message: { m in
                            Text(alertMessage.description)
                        }
                } else {
                    List {
                        if filteredTasks.count != 0 {
                            ForEach(filteredTasks, id: \.self) { task in
                                //Text(task.repeatDate?.formatted() ?? "No repeat Date") // debug repeatDate
                                NavigationLink {
                                    EditTaskView(userTask: task)
                                        .toolbar(.hidden, for: .tabBar)
                                } label: {
                                    TaskRowView(task: task)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deleteTask(task)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    if task.status == TaskStatus.Active.rawValue {
                                        ChangeTaskStatus(task: task, targetStatus: .InProgress)
                                        ChangeTaskStatus(task: task, targetStatus: .Completed)
                                    } else if task.status == TaskStatus.InProgress.rawValue {
                                        ChangeTaskStatus(task: task, targetStatus: .Active)
                                        ChangeTaskStatus(task: task, targetStatus: .Completed)
                                    } else {
                                        ChangeTaskStatus(task: task, targetStatus: .Active)
                                        ChangeTaskStatus(task: task, targetStatus: .InProgress)
                                    }
                                }
                            }
                        } else {
                            // there are no tasks match current status, so display empty view
                            VStack(alignment: .leading) {
                                Text("There are no \(showListOption.rawValue) tasks")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                Divider()
                                Text("Please select filter for All task to see all avaiable tasks.")
                                    .font(.subheadline)
                            }
                        }
                    } // end list
                    //.listStyle(InsetListStyle())
                    .listRowSpacing(5)
                    .listRowSeparator(.hidden)
                    .navigationTitle("Task")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        toolbarContent()
                    }
                    .toolbarTitleMenu {
                        toolbarTitleContent
                    }
                    .sheet(isPresented: $showSheet) {
                        filterSheetContent
                    }
                    .alert(alertMessage.title, isPresented: $showRegisterAlert, presenting: alertMessage) { m in
                        Button("Ok") { }
                    } message: { m in
                        Text(alertMessage.description)
                    }
                }
                
                
            } // end navigation stack
        } // end body
    }
        // MARK: - Functions
        func deleteTask(_ task: UserTask) {
            context.delete(task)
            do {
                try context.save()
                print("delete task sucess")
            } catch let error {
                print("delete task error: \(error)")
            }
        }
        
        func registedCompleteTasks() {
            var temp: Int = 0
            for t in tasks {
                if t.status == TaskStatus.Completed.rawValue {
                    for g in t.unwrapGoals {
                        switch t.difficulty {
                        case TaskDifficulty.Easy.rawValue:
                            g.easyTask += 1
                        case TaskDifficulty.Medium.rawValue:
                            g.mediumTask += 1
                        case TaskDifficulty.Hard.rawValue:
                            g.hardTask += 1
                        default:
                            break
                        }
                    }
                    /// if the task is repeated, set the repeatDate else delete task
                    /// repeated task exist in database, but won't be display until pass repeatDate
                    /// 1. UserGoal's tasks relationship       [DONE]
                    /// 2. list of task in allTaskView              [DONE]
                    /// 3. List of task in multiselect view      [DONE]
                    if t.repeatEvery > 0 {
                        setTaskRepeatDate(task: t)
                        t.status = TaskStatus.Active.rawValue
                    } else {
                        context.delete(t)
                    }
                    temp += 1
                }
            }
            
            if temp == 0 {
                alertMessage = AlertMessage(title: "No completed task to register", description: "Change a task's status to Completed to register the task.")
            } else {
                alertMessage = AlertMessage(title: "Good Job!", description: "You have registered \(temp) tasks")
            }
            showRegisterAlert = true
            
            do {
                try context.save()
            } catch {
                //print("register all completed tasks error")
            }
        }
        
        /// repeated task is set to repeat every 4AM on the schedual day
        func setTaskRepeatDate(task: UserTask) {
            if task.repeatEvery > 0 {
                let nextDate: Date = Date.now.addingTimeInterval(60 * 60 * 24 * Double(task.repeatEvery))
                task.repeatDate = Calendar.current.date(bySettingHour: 4, minute: 0, second: 0, of: nextDate)
                if task.repeatDate == nil {
                    //print("set repeat date failed")
                    return
                }
            }
        }
        
        // MARK: - Nested Structure
        enum ShowListOptions: String, CaseIterable, Identifiable {
            case All = "All"
            case Active = "Active"
            case InProgress = "In Progress"
            case Completed = "Completed"
            var id: Self { self }
        }
        
        enum SortOptions: String, CaseIterable, Identifiable {
            case DueDate = "Due date"
            case Priority = "Priority"
            case Difficulty = "Difficulty"
            case Goals = "Goals"
            var id: Self { self }
        }
        
        struct AlertMessage {
            let title: String
            let description: String
        }
        
        // MARK: - Nested View
        private var filterSheetContent: some View {
            VStack {
                Text("FILTER TASK")
                    .fontWeight(.light)
                VStack(alignment: .leading, spacing: 30) {
                    Divider()
                    if !showSecondSheetContent {
                        ForEach(ShowListOptions.allCases) { l in
                            Button(action: {
                                showSecondSheetContent = true
                                temp = l
                            }, label: {
                                HStack {
                                    Image(systemName: showListOption == l ? "circle.fill" : "circle")
                                    Text(l.rawValue)
                                }
                            })
                            .foregroundStyle(Color.gray)
                            .fontWeight(showListOption == l ? .heavy : .light)
                        }
                    } else {
                        ForEach(SortOptions.allCases) { opt in
                            Button(action: {
                                showSecondSheetContent = false
                                showSheet = false
                                sortOption = opt
                                showListOption = temp
                            }, label: {
                                HStack {
                                    Image(systemName: sortOption == opt ? "circle.fill" : "circle")
                                    Text(opt.rawValue)
                                }
                            })
                            .foregroundStyle(Color.gray)
                            .fontWeight(sortOption == opt ? .heavy : .light)
                        }
                    }
                }
                .presentationDetents([.height(400)])
                .padding()
                Divider()
                    .padding(.bottom)
                Button {
                    showSheet = false
                } label: {
                    Text("Close")
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                //.controlSize(.large)
                .padding(.horizontal)
            }
        }
        
        @ToolbarContentBuilder
        func toolbarContent() -> some ToolbarContent {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    EditTaskView()
                        .toolbar(.hidden, for: .tabBar)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        
        private var toolbarTitleContent: some View {
            VStack {
                Button("Filter Task") {
                    showSheet = true
                    showSecondSheetContent = false
                }
                Button("Register Task") {
                    registedCompleteTasks()
                }
            }
        }
        
    
}

struct ChangeTaskStatus: View {
    @Environment(\.managedObjectContext) private var context
    let task: UserTask
    let targetStatus: TaskStatus
    
    var body: some View {
        Button {
            task.status = targetStatus.rawValue
            do {
                try context.save()
            } catch {
                print("Save task when moving to \(targetStatus.rawValue) failed")
            }
        } label: {
            Image(systemName: targetStatus == .Active ? "a.circle.fill" : targetStatus == .InProgress ? "i.circle.fill" : "c.circle.fill")
        }
        .tint(targetStatus == .Active ? .green : targetStatus == .InProgress ? .orange : .blue)
    }
}


#Preview {
    AllTaskView()
}
