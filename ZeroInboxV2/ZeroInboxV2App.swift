//
//  ZeroInboxV2App.swift
//  ZeroInboxV2
//
//  Created by Trung Nguyen on 11/29/23.
//

import SwiftUI

@main
struct ZeroInboxV2App: App {
    @AppStorage("darkModeOn") private var darkModeOn = false
    @AppStorage("inactiveBegin") private var inactiveBegin: Double = 0
    @AppStorage("FaceIDOn") private var FaceIDOn: Bool = false
    
    @StateObject var model = ZeroInboxModel() // set up CoreData and LAContext
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, model.container.viewContext)
                .environmentObject(model)
                .preferredColorScheme(darkModeOn ? .dark : .light)
        }
    }
}
