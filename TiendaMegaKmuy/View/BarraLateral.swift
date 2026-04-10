//
//  BarraLateral.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import SwiftUI

enum OpcionMenu: String, CaseIterable {
    case personas = "Personas"
    case empleados = "Empleados"

    var icono: String {
        switch self {
        case .personas: return "person.2"
        case .empleados: return "briefcase"
        }
    }
}

struct BarraLateral: View {
    @State private var seleccion: OpcionMenu? = .personas

    var body: some View {
        NavigationSplitView {
            List(OpcionMenu.allCases, id: \.self, selection: $seleccion) { opcion in
                Label(opcion.rawValue, systemImage: opcion.icono)
            }
            .navigationTitle("Mega Kmuy")
        } detail: {
            switch seleccion {
            case .personas:
                PersonaListaView()
            case .empleados:
                Text("Empleados - Próximamente")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            case nil:
                Text("Selecciona una opción")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
