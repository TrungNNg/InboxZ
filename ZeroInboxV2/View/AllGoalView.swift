//
//  AllGoalView.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 11/29/23.
//

import SwiftUI

struct AllGoalView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(sortDescriptors: []) private var goals: FetchedResults<UserGoal>
    
    @EnvironmentObject var model: ZeroInboxModel
    @AppStorage("darkModeOn") private var darkModeOn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if goals.isEmpty {
                    EmptyItemView(title: "No Goal", subTitle: "Use  +  to add goal")
                        .toolbar {
                            toolbarItemContent()
                        }
                } else {
                    List {
                        ForEach(goals, id: \.self) { goal in
                            NavigationLink {
                                EditGoalView(userGoal: goal)
                                    .toolbar(.hidden, for: .tabBar)
                            } label: {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(goal.unwrapName)
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text(timeRemainOfGoal(goal))
                                            .foregroundStyle(.secondary)
                                    }
                                    Divider()
                                    if goal.unwrapGoalDescription != "" {
                                        Text(goal.unwrapGoalDescription)
                                            .fontWeight(.light)
                                            .lineLimit(2)
                                    } else {
                                        Text("No description")
                                            .fontWeight(.ultraLight)
                                    }
                                    Divider()
                                    Text("Registered tasks: \(goal.easyTask + goal.mediumTask + goal.hardTask)")
                                    //.font(.system(size: 35, weight: .light, design: .rounded))
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteGoal(goal)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        //.onDelete(perform: deleteGoal)
                    }
                    .listRowSpacing(5)
                    .listRowSeparator(.hidden)
                    .navigationTitle("Goals")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        toolbarItemContent()
                    }
                }
            } // end ZStack
        } // end NavigationStack
        .onAppear {
            print(goals.count)
        }
    }
    
    // MARK: - Function
    func deleteGoal(_ goal: UserGoal) {
        context.delete(goal)
        do {
            try context.save()
            //print("delete goal sucess")
        } catch {
            //print("delete goal error: \(error)")
        }
    }
    
    func timeRemainOfGoal(_ goal: UserGoal) -> String {
        let seconds = goal.secondsRemain
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
    
    // MARK: - Nested View
    
    @ToolbarContentBuilder
    private func toolbarItemContent() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink {
                EditGoalView()
                    .toolbar(.hidden, for: .tabBar)
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

#Preview {
    AllGoalView()
}
