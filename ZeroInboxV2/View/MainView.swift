//
//  MainView.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 11/29/23.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            AllTaskView()
                .tabItem {
                    Image(systemName: "square.3.layers.3d.down.left")
                    Text("Task")
                }
            AllGoalView()
                .tabItem {
                    Image(systemName: "flag.checkered")
                    Text("Goal")
                }
            SettingView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Setting")
                }
        }
    } // end body
    
}

#Preview {
    MainView()
}
