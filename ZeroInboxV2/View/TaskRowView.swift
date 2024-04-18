//
//  TaskRowView.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 12/6/23.
//

import SwiftUI

struct TaskRowView: View {
    let task: UserTask
    private var taskGoal: String { task.unwrapGoals.count > 9 ? "9+" : "\(task.unwrapGoals.count)" }
    private var timeRemainOfTask: String {
        let seconds = task.secondsRemain
        if seconds == .infinity { return "" }
        if seconds <= 0.0 { return "Overdue" }
        
        let days = seconds / 86400
        let hours = seconds / 3600
        if days >= 1 {
            return String(format: "%.1fd", days)
        } else if hours >= 1 {
            return String(format: "%.1fh", hours)
        }
        return "<1h"
    }
    private var status: String {
        if task.status == TaskStatus.Active.rawValue { return "Active" }
        return task.status == TaskStatus.InProgress.rawValue ? "In Progress" : "Completed"
    }
    private var statusStyle: any ShapeStyle {
        status == "Active" ? .green : status == "In Progress" ? .orange : .blue
    }
    private var priorityStyle: Color {
        if task.priority == TaskPriority.SomeWhatImportant.rawValue { return .green }
        return task.priority == TaskPriority.Important.rawValue ? .yellow : .red
    }
    
    var body: some View {
        HStack {
            VStack {
                Text(taskGoal)
                    .font(.system(size: 35, weight: .light, design: .rounded))
                    .frame(width: 55)
                Image(systemName: "star.fill")
                    .foregroundStyle(priorityStyle)
            }
            Divider()
                .padding(.horizontal,2)
                .padding(.vertical,0)
            VStack(alignment: .leading) {
                Text(task.unwrapName)
                    .frame(maxWidth: .infinity)
                    .fontWeight(.medium)
                    .padding(.top,10)
                Spacer()
                HStack {
                    if #available(iOS 17, *) {
                        Text("\(status)")
                            .foregroundStyle(statusStyle)
                    } else {
                        Text("\(status)")
                            .foregroundColor(statusStyle as? Color)
                    }
                    Spacer()
                    Text(timeRemainOfTask)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom,5)
            }
            .padding(.vertical,3)
        }
    }
}

/*
#Preview {
    TaskRowView(task: TempTask())
}*/
