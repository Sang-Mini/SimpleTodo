//
//  SimpleTodoApp.swift
//  SimpleTodo
//
//  Created by 유상민 on 2023/09/17.
//

import SwiftUI

@main
struct SimpleTodoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
