//
//  EmpleadoViewModel.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class EmpleadoViewModel {
    var empleados: [Empleado] = []
    var estaCargando = false
    var mensajeError: String?
    var mostrarFormulario = false

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func traerEmpleados() async {
        estaCargando = true
        do {
            let descriptor = FetchDescriptor<Empleado>()
            empleados = try context.fetch(descriptor)
        } catch {
            mensajeError = error.localizedDescription
        }
        estaCargando = false
    }

    func crearEmpleado(
        cedula: String,
        nombres: String,
        apellidos: String,
        fechaNacimiento: Date,
        genero: String,
        direccion: String,
        telefono: String,
        email: String,
        imagen: Data?,
        cargo: String,
        departamento: String
    ) async {
        mensajeError = nil

        guard PersonaCasoUso.validarCedula(cedula: cedula) else {
            mensajeError = "La cédula no es válida"
            return
        }
        guard PersonaCasoUso.validarCorreo(correo: email) else {
            mensajeError = "El correo no es válido"
            return
        }
        guard !cargo.isEmpty, !departamento.isEmpty else {
            mensajeError = "El cargo y departamento no pueden estar vacíos"
            return
        }

        let persona = Persona(
            cedula: cedula,
            nombres: nombres,
            apellidos: apellidos,
            fechaNacimiento: fechaNacimiento,
            genero: genero,
            direccion: direccion,
            telefono: telefono,
            email: email,
            imagen: imagen
        )
        context.insert(persona)

        let empleado = Empleado(cargo: cargo, departamento: departamento, persona: persona)
        context.insert(empleado)

        do {
            try context.save()
        } catch {
            mensajeError = error.localizedDescription
        }
    }

    func eliminarEmpleado(id: UUID) async {
        mensajeError = nil
        do {
            let descriptor = FetchDescriptor<Empleado>(predicate: #Predicate { $0.id == id })
            if let empleado = try context.fetch(descriptor).first {
                let persona = empleado.persona
                context.delete(empleado)
                context.delete(persona)
                try context.save()
                await traerEmpleados()
            }
        } catch {
            mensajeError = error.localizedDescription
        }
    }
}
