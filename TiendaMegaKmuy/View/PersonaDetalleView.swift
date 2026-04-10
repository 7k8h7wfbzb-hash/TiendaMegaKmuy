//
//  PersonaDetalleView.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import SwiftUI
import AppKit

private func imageFromData(_ data: Data) -> Image? {
    guard let nsImage = NSImage(data: data) else { return nil }
    return Image(nsImage: nsImage)
}

struct PersonaDetalleView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: PersonaViewModel
    var persona: Persona

    @State private var mostrarFormularioEdicion = false
    @State private var mostrarConfirmacionEliminar = false

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        if let imagenData = persona.imagen, let img = imageFromData(imagenData) {
                            img
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(.tertiary)
                        }

                        Text("\(persona.nombres) \(persona.apellidos)")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text(persona.cedula)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }

            Section("Información Personal") {
                LabeledContent("Cédula:", value: persona.cedula)
                LabeledContent("Nombres:", value: persona.nombres)
                LabeledContent("Apellidos:", value: persona.apellidos)
                LabeledContent("Fecha de Nacimiento:") {
                    Text(persona.fechaNacimiento, style: .date)
                }
                LabeledContent("Género:", value: persona.genero)
            }

            Section("Contacto") {
                LabeledContent("Dirección:", value: persona.direccion)
                LabeledContent("Teléfono:", value: persona.telefono)
                LabeledContent("Correo:", value: persona.email)
            }

            Section {
                HStack {
                    Spacer()
                    Button(role: .destructive) {
                        mostrarConfirmacionEliminar = true
                    } label: {
                        Label("Eliminar Persona", systemImage: "trash")
                    }
                    Spacer()
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("\(persona.nombres) \(persona.apellidos)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    mostrarFormularioEdicion = true
                } label: {
                    Label("Editar", systemImage: "pencil")
                }
                .buttonStyle(.glass)
            }
        }
        .sheet(isPresented: $mostrarFormularioEdicion) {
            PersonaFormularioView(viewModel: viewModel, personaEditar: persona)
        }
        .alert("¿Eliminar persona?", isPresented: $mostrarConfirmacionEliminar) {
            Button("Eliminar", role: .destructive) {
                Task {
                    await viewModel.eliminarPersona(id: persona.id)
                    dismiss()
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Esta acción no se puede deshacer. Se eliminará a \(persona.nombres) \(persona.apellidos) permanentemente.")
        }
    }
}
