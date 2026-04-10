//
//  PersonaListaView.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

private func imageFromData(_ data: Data) -> Image? {
    #if canImport(UIKit)
    guard let uiImage = UIImage(data: data) else { return nil }
    return Image(uiImage: uiImage)
    #elseif canImport(AppKit)
    guard let nsImage = NSImage(data: data) else { return nil }
    return Image(nsImage: nsImage)
    #endif
}

struct PersonaListaView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: PersonaViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    if viewModel.estaCargando {
                        ProgressView("Cargando...")
                    } else if viewModel.personas.isEmpty {
                        ContentUnavailableView(
                            "Sin personas",
                            systemImage: "person.slash",
                            description: Text("Agrega una persona con el botón +")
                        )
                    } else {
                        List(viewModel.personas, id: \.id) { persona in
                            HStack(spacing: 12) {
                                if let imagenData = persona.imagen, let img = imageFromData(imagenData) {
                                    img
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundStyle(.gray)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(persona.nombres) \(persona.apellidos)")
                                        .font(.headline)
                                    Text(persona.cedula)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Text(persona.email)
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
            .navigationTitle("Personas")
            .toolbar {
                if let viewModel {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            viewModel.mostraerFormulario = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(.glass)
                    }
                }
            }
            .sheet(item: Binding(
                get: { viewModel?.mostraerFormulario == true ? viewModel : nil },
                set: { _ in viewModel?.mostraerFormulario = false }
            )) { vm in
                PersonaFormularioView(viewModel: vm)
            }
            .task {
                if viewModel == nil {
                    let repositorio = PersonaRepositorioImplementacionLocal(context: modelContext)
                    viewModel = PersonaViewModel(repositorio: repositorio)
                }
                if let viewModel {
                    await viewModel.traerPersonas()
                }
            }
        }
    }
}
