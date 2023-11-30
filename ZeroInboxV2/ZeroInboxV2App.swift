//
//  ZeroInboxV2App.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 11/29/23.
//

import SwiftUI

@main
struct ZeroInboxV2App: App {
    
    @StateObject var model = ZeroInboxModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, model.container.viewContext)
                //.environmentObject(model)
        }
    }
}
