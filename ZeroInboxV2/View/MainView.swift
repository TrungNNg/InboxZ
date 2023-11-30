//
//  MainView.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 11/29/23.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {
                NavigationLink {
                    EditTaskView()
                } label: {
                    Text("Edit Task")
                }
                /*
                NavigationLink {
                    EditGoalView()
                } label: {
                    Text("Edit Goal")
                }
                NavigationLink {
                    AllTaskView()
                } label: {
                    Text("All Tasks")
                }
                NavigationLink {
                    AllGoalView()
                } label: {
                    Text("All Goals")
                }
                 */
            }
        }
    }
    
    
}

#Preview {
    MainView()
}
