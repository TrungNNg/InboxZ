//
//  HomeView.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 12/13/23.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var context
    // fetch only active tasks, sort by due date
    @FetchRequest(sortDescriptors: [SortDescriptor(\.dueDate)], predicate: NSPredicate(format: "status == 1")) private var tasks: FetchedResults<UserTask>
    
    @State private var currentTask: UserTask?
    @State private var showSelectTaskSheet: Bool = false
    
    //@State private var showTasksDetailSheet: Bool = false
    @State private var finishSubTasks: [String] = []
    
    var body: some View {
        NavigationStack {
            if currentTask != nil { // can not use if let currentTask, because currentTask will be change in showSelectTaskSheet
                VStack {
                    // test start
                    /*
                    ForEach(tasks) { t in
                        Text(t.unwrapName)
                        Text(t.dueDate?.formatted() ?? "No due date")
                    }
                    Text("current task: \(currentTask?.unwrapName ?? "None")")
                    Divider()
                     */
                    // test end
                    Text("Current task:")
                        .fontDesign(.monospaced)
                        .fontWeight(.ultraLight)
                        .padding(.top, 20)
                    
                    Text(currentTask!.unwrapName)
                        .font(.title)
                        .fontWeight(.semibold)
                        .fontDesign(.serif)
                        .padding(30)
                        .animation(.easeInOut, value: currentTask)
                    
                    VStack(alignment: .leading) {
                        HStack(spacing: 20) {
                            Button("Delete", systemImage: "trash") {
                                context.delete(currentTask!)
                                do {
                                    try context.save()
                                    getNextActiveTask()
                                } catch {
                                    //print("delete task error: \(error)")
                                }
                            }
                            .tint(.red)
                            .padding(.trailing,26)
                            Button("Switch", systemImage: "menucard") {
                                showSelectTaskSheet = true
                            }
                        }
                        .buttonStyle(.bordered)
                        Spacer()
                        HStack(spacing: 20) {
                            Button("Complete", systemImage: "c.circle.fill") {
                                changeCurrentTaskStatus(status: .Completed)
                            }
                            .tint(.blue)
                            Button("In progress", systemImage: "i.circle.fill") {
                                changeCurrentTaskStatus(status: .InProgress)
                            }
                            .tint(.orange)
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxHeight: 85)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Divider()
                            .padding(.vertical, 20)
                        Label("Note", systemImage: "note.text")
                            //.fontDesign(.monospaced)
                        Text(currentTask!.unwrapNote)
                            .padding(.horizontal)
                            //.fontDesign(.monospaced)
                        Label("Subtasks", systemImage: "checkmark.square")
                            //.fontDesign(.monospaced)
                        ForEach(currentTask!.unwrapSubTasks, id: \.self) { s in
                            if s != "" {
                                Button {
                                    //print("tapped")
                                    if !finishSubTasks.contains(s) {
                                        finishSubTasks.append(s)
                                    } else {
                                        finishSubTasks.remove(at: finishSubTasks.firstIndex(of: s)!)
                                    }
                                } label: {
                                    Label(s, systemImage: finishSubTasks.contains(s) ? "checkmark.square" : "square")
                                        .strikethrough(finishSubTasks.contains(s))
                                        //.fontDesign(.monospaced)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        Divider()
                            .padding(.vertical, 20)
                        Label("Goals this task contributes to", systemImage: "flag.checkered")
                        ForEach(currentTask!.unwrapGoals, id: \.self) { g in
                            Text(g.unwrapName)
                        }
                    }
                    Spacer()
                }
                .padding()
                .sheet(isPresented: $showSelectTaskSheet) {
                    Text("ACTIVE TASKS")
                        .fontWeight(.light)
                        .padding(.top,30)
                        .presentationDragIndicator(.visible)
                    if tasks.count == 1 {
                        Spacer()
                        Text("No Other Active Tasks")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        Spacer()
                    } else {
                        List {
                            ForEach(tasks, id: \.self) { t in
                                if t.id != currentTask?.id {
                                    TaskRowView(task: t)
                                        .overlay {
                                            Color.clear
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    currentTask = t
                                                    finishSubTasks = []
                                                    showSelectTaskSheet = false
                                                }
                                        }
                                }
                            }
                        }
                        .listRowSpacing(5)
                        .listRowSeparator(.hidden)
                    }
                }
            } else {
                VStack {
                    Text("Inbox Zero Achieved! 🎉")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .fontDesign(.serif)
                        .padding()
                    Text("Don't forget to check \(Text("In Progess").foregroundColor(.orange)) tasks for new update.")
                        .font(.subheadline)
                        .padding()
                }
                .padding()
            }
        } // end navigation stack
        .onAppear {
            print("main view appeared")
            getNextActiveTask()
        }
        .onDisappear {
            currentTask = nil
        }
    } // end vbody
    
    // MARK: - Function
    private func changeCurrentTaskStatus(status: TaskStatus) {
        currentTask?.status = status.rawValue
        do {
            try context.save()
            getNextActiveTask()
        } catch {
            //print("Save task when changing status in HomeView failed")
        }
    }
    
    private func getNextActiveTask() {
        guard tasks.count > 0 else { // if no active task, currentTask = nil
            withAnimation(.easeInOut) {
                currentTask = nil
            }
            return
        }
        /// currentTask can be in 2 states:
        ///  1. nil because the view first load or the active task pointed to got deleted
        ///  2. point to a task with different status other than active
        ///  in both case need to re-compute an active task or set currentTask to nil
        if currentTask == nil || currentTask?.status != TaskStatus.Active.rawValue {
            currentTask = tasks.first
            for i in tasks.dropFirst() { /// because sortDescriptor put nil dueDate first, need to loop to see
                if i.dueDate != nil {    /// if there is a task with dueDate, if there is, it is the nearest due date
                    currentTask = i
                    finishSubTasks = []
                    break
                }
            }
        }
    }
    
}

#Preview {
    HomeView()
}
