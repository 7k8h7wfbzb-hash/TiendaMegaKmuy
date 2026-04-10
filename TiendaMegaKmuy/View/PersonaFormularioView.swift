//
//  PersonaFormularioView.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import SwiftUI
import PhotosUI

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

struct PersonaFormularioView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: PersonaViewModel

    var personaEditar: Persona?

    @State private var cedula = ""
    @State private var nombres = ""
    @State private var apellidos = ""
    @State private var fechaNacimiento = Date()
    @State private var genero = "Masculino"
    @State private var direccion = ""
    @State private var telefono = ""
    @State private var email = ""
    @State private var imagenSeleccionada: PhotosPickerItem?
    @State private var imagenData: Data?
    @State private var mostrarAlerta = false
    @State private var mensajeAlerta = ""
    @State private var mostrarConfirmacionCancelar = false

    let generos = ["Masculino", "Femenino", "Otro"]

    private var esCedulaValida: Bool {
        PersonaCasoUso.validarCedula(cedula: cedula)
    }

    private var esCorreoValido: Bool {
        PersonaCasoUso.validarCorreo(correo: email)
    }

    private var formularioTieneDatos: Bool {
        !cedula.isEmpty || !nombres.isEmpty || !apellidos.isEmpty ||
        !direccion.isEmpty || !telefono.isEmpty || !email.isEmpty || imagenData != nil
    }

    private var puedeGuardar: Bool {
        esCedulaValida && !nombres.isEmpty && !apellidos.isEmpty &&
        esCorreoValido && fechaNacimiento < Date()
    }

    private var esEdicion: Bool {
        personaEditar != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Foto") {
                    HStack {
                        Spacer()
                        if let imagenData, let img = imageFromData(imagenData) {
                            img
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                    }

                    PhotosPicker("Seleccionar imagen", selection: $imagenSeleccionada, matching: .images)
                        .buttonStyle(.glass)
                        .onChange(of: imagenSeleccionada) {
                            Task {
                                if let data = try? await imagenSeleccionada?.loadTransferable(type: Data.self) {
                                    imagenData = data
                                }
                            }
                        }
                }

                Section("Información Personal") {
                    HStack {
                        TextField("Cédula:", text: $cedula)
                            .onChange(of: cedula) {
                                cedula = String(cedula.filter(\.isNumber).prefix(10))
                            }
                        if !cedula.isEmpty {
                            Image(systemName: esCedulaValida ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(esCedulaValida ? .green : .red)
                        }
                    }
                    TextField("Nombres:", text: $nombres)
                    TextField("Apellidos:", text: $apellidos)
                    DatePicker("Fecha de Nacimiento:", selection: $fechaNacimiento, in: ...Date(), displayedComponents: .date)
                    Picker("Género:", selection: $genero) {
                        ForEach(generos, id: \.self) { g in
                            Text(g)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Contacto") {
                    TextField("Dirección:", text: $direccion)
                    TextField("Teléfono:", text: $telefono)
                    HStack {
                        TextField("Correo Electrónico:", text: $email)
                        if !email.isEmpty {
                            Image(systemName: esCorreoValido ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(esCorreoValido ? .green : .red)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(esEdicion ? "Editar Persona" : "Nueva Persona")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        if formularioTieneDatos && !esEdicion {
                            mostrarConfirmacionCancelar = true
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guardar()
                    }
                    .disabled(!puedeGuardar)
                }
            }
            .alert("Error", isPresented: $mostrarAlerta) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(mensajeAlerta)
            }
            .alert("¿Descartar cambios?", isPresented: $mostrarConfirmacionCancelar) {
                Button("Descartar", role: .destructive) {
                    dismiss()
                }
                Button("Seguir editando", role: .cancel) {}
            } message: {
                Text("Tienes datos sin guardar. ¿Estás seguro de que quieres salir?")
            }
            .onAppear {
                if let persona = personaEditar {
                    cedula = persona.cedula
                    nombres = persona.nombres
                    apellidos = persona.apellidos
                    fechaNacimiento = persona.fechaNacimiento
                    genero = persona.genero
                    direccion = persona.direccion
                    telefono = persona.telefono
                    email = persona.email
                    imagenData = persona.imagen
                }
            }
        }
        .frame(minWidth: 480, minHeight: 520)
    }

    private func guardar() {
        Task {
            if let persona = personaEditar {
                let personaActualizada = Persona(
                    cedula: cedula,
                    nombres: nombres,
                    apellidos: apellidos,
                    fechaNacimiento: fechaNacimiento,
                    genero: genero,
                    direccion: direccion,
                    telefono: telefono,
                    email: email,
                    imagen: imagenData
                )
                await viewModel.actualizarPersona(id: persona.id, persona: personaActualizada)
            } else {
                await viewModel.crearPersona(
                    cedula: cedula,
                    nombre: nombres,
                    apellido: apellidos,
                    fehcaNacimiento: fechaNacimiento,
                    genero: genero,
                    direccion: direccion,
                    telefono: telefono,
                    correo: email,
                    imagen: imagenData ?? Data()
                )
            }

            if let error = viewModel.MensajeError {
                mensajeAlerta = error
                mostrarAlerta = true
            } else {
                await viewModel.traerPersonas()
                dismiss()
            }
        }
    }
}
