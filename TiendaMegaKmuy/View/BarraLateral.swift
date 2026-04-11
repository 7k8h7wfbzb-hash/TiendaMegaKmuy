//
//  BarraLateral.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import SwiftUI

enum OpcionMenu: String, CaseIterable {
    case empleados = "Empleados"

    var icono: String {
        switch self {
        case .empleados: return "briefcase"
        }
    }
}

struct BarraLateral: View {
    @State private var seleccion: OpcionMenu? = .empleados
    @AppStorage("Tema") private var tema: TemaApp = .sistema

    var body: some View {
        NavigationSplitView {
            List(OpcionMenu.allCases, id: \.self, selection: $seleccion) { opcion in
                Label(opcion.rawValue, systemImage: opcion.icono)
            }
            .navigationTitle("Mega Kmuy")
            .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 300)
            .safeAreaInset(edge: .bottom) {
                Menu {
                    ForEach(TemaApp.allCases, id: \.self) { opcionTema in
                        Button {
                            tema = opcionTema
                        } label: {
                            Label(opcionTema.label, systemImage: opcionTema.icono)
                        }
                    }
                } label: {
                    Label(tema.label, systemImage: tema.icono)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        } detail: {
            switch seleccion {
            case .empleados:
                EmpleadoListaView()
            case nil:
                Text("Selecciona una opción")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}
