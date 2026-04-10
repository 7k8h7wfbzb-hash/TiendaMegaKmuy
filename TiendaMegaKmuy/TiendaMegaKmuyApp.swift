//
//  TiendaMegaKmuyApp.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import SwiftUI
import SwiftData

@main
struct TiendaMegaKmuyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Persona.self,
            Empleado.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            
        }
        .modelContainer(sharedModelContainer)
    }
}
