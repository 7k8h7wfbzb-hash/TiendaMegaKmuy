//
//  EmpleadoFormularioView.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import SwiftUI
import PhotosUI
import AppKit

private func imageFromData(_ data: Data) -> Image? {
    guard let nsImage = NSImage(data: data) else { return nil }
    return Image(nsImage: nsImage)
}

struct EmpleadoFormularioView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: EmpleadoViewModel

    @State private var paso = 1

    // Paso 1: Datos de Persona
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

    // Paso 2: Datos de Empleado
    @State private var cargo = ""
    @State private var departamento = ""

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
        !direccion.isEmpty || !telefono.isEmpty || !email.isEmpty ||
        !cargo.isEmpty || !departamento.isEmpty || imagenData != nil
    }

    private var puedeContinuar: Bool {
        esCedulaValida && !nombres.isEmpty && !apellidos.isEmpty &&
        esCorreoValido && fechaNacimiento < Date()
    }

    private var puedeGuardar: Bool {
        !cargo.isEmpty && !departamento.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Indicador de pasos
                HStack(spacing: 16) {
                    pasoIndicador(numero: 1, titulo: "Persona", activo: paso == 1)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                    pasoIndicador(numero: 2, titulo: "Empleado", activo: paso == 2)
                }
                .padding()

                if paso == 1 {
                    formularioPersona
                        .transition(.move(edge: .leading))
                } else {
                    formularioEmpleado
                        .transition(.move(edge: .trailing))
                }
            }
            .animation(.default, value: paso)
            .navigationTitle(paso == 1 ? "Datos Personales" : "Datos de Empleado")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        if formularioTieneDatos {
                            mostrarConfirmacionCancelar = true
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if paso == 1 {
                        Button("Siguiente") {
                            paso = 2
                        }
                        .disabled(!puedeContinuar)
                    } else {
                        Button("Guardar") {
                            guardar()
                        }
                        .disabled(!puedeGuardar)
                    }
                }
                if paso == 2 {
                    ToolbarItem(placement: .navigation) {
                        Button {
                            paso = 1
                        } label: {
                            Label("Anterior", systemImage: "chevron.left")
                        }
                    }
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
        }
        .frame(minWidth: 480, minHeight: 520)
    }

    // MARK: - Paso 1: Formulario Persona

    private var formularioPersona: some View {
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
    }

    // MARK: - Paso 2: Formulario Empleado

    private var formularioEmpleado: some View {
        Form {
            Section("Resumen Persona") {
                LabeledContent("Cédula", value: cedula)
                LabeledContent("Nombre", value: "\(nombres) \(apellidos)")
                LabeledContent("Correo", value: email)
            }

            Section("Datos del Empleado") {
                TextField("Cargo:", text: $cargo)
                TextField("Departamento:", text: $departamento)
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Indicador de paso

    private func pasoIndicador(numero: Int, titulo: String, activo: Bool) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(activo ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: 28, height: 28)
                Text("\(numero)")
                    .font(.caption.bold())
                    .foregroundStyle(activo ? .white : .secondary)
            }
            Text(titulo)
                .font(.subheadline)
                .foregroundStyle(activo ? .primary : .secondary)
        }
    }

    // MARK: - Guardar

    private func guardar() {
        Task {
            await viewModel.crearEmpleado(
                cedula: cedula,
                nombres: nombres,
                apellidos: apellidos,
                fechaNacimiento: fechaNacimiento,
                genero: genero,
                direccion: direccion,
                telefono: telefono,
                email: email,
                imagen: imagenData,
                cargo: cargo,
                departamento: departamento
            )

            if let error = viewModel.mensajeError {
                mensajeAlerta = error
                mostrarAlerta = true
            } else {
                await viewModel.traerEmpleados()
                dismiss()
            }
        }
    }
}
