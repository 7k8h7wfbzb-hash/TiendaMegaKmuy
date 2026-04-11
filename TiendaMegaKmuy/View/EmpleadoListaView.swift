//
//  EmpleadoListaView.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import SwiftUI
import SwiftData

struct EmpleadoListaView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: EmpleadoViewModel?

    var body: some View {
        Group {
            if let viewModel {
                if viewModel.estaCargando {
                    ProgressView("Cargando...")
                } else if viewModel.empleados.isEmpty {
                    ContentUnavailableView(
                        "Sin empleados",
                        systemImage: "briefcase",
                        description: Text("Agrega un empleado con el botón +")
                    )
                } else {
                    List(viewModel.empleados, id: \.id) { empleado in
                        HStack(spacing: 12) {
                            Image(systemName: "person.crop.rectangle")
                                .resizable()
                                .frame(width: 36, height: 36)
                                .foregroundStyle(.secondary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(empleado.persona.nombres) \(empleado.persona.apellidos)")
                                    .font(.headline)
                                Text(empleado.cargo)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(empleado.departamento)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Empleados")
        .toolbar {
            if let viewModel {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.mostrarFormulario = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.glass)
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel?.mostrarFormulario ?? false },
            set: { viewModel?.mostrarFormulario = $0 }
        )) {
            if let viewModel {
                EmpleadoFormularioView(viewModel: viewModel)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = EmpleadoViewModel(context: modelContext)
            }
            if let viewModel {
                await viewModel.traerEmpleados()
            }
        }
    }
}
