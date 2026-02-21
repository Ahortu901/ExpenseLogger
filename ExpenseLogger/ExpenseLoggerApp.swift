//
//  ExpenseLoggerApp.swift
//  ExpenseLogger
//
//  Created by Derrick Ahortu on 20/02/2026.
//

import SwiftUI
import SwiftData

@main
struct ExpenseLoggerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Receipt.self)
        }
    }
}
