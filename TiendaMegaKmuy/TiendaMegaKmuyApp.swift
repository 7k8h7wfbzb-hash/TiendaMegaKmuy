//
//  TiendaMegaKmuyApp.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import SwiftUI
import SwiftData


enum TemaApp:String,CaseIterable{
    case oscuro = "dark"
    case claro = "light"
    case sistema = "auto"
    
    var label:String{
        switch self {
        case .oscuro:
            return "Oscuro"
        case .claro:
            return "Claro"
        case .sistema:
            return "Sistema"
        }
    }
    
    var icono:String{
    switch self {
        case .oscuro:
            return "moon.fill"
        case .claro:
            return "sun.max.fill"
        case .sistema:
            return "slider.horizontal.3"
        }
        
    }
    
    var esquemaColor:ColorScheme?{
        switch self {
        case .oscuro:
            return .dark
        case .claro:
            return .light
        case .sistema:
            return nil
        }
    }
}


@main
struct TiendaMegaKmuyApp: App {
    
    @AppStorage("Tema") private var tema:TemaApp = .sistema
    
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
            BarraLateral().preferredColorScheme(tema.esquemaColor)
        }
        .modelContainer(sharedModelContainer)
    }
}
