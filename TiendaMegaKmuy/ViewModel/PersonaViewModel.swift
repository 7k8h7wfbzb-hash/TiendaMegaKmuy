//
//  PersonaViewModel.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import Foundation
@Observable
final class PersonaViewModel: Identifiable {
    let id = UUID()
    var personas: [Persona] = []
    var estaCargando: Bool = false
    var MensajeError: String?
    var mostraerFormulario: Bool = false
    
    let personaCasoUso: PersonaCasoUso
    
    let perosnaRepositorio: PersonaRepositorioImplementacionLocal
    
    init(repositorio: PersonaRepositorioImplementacionLocal) {
        self.perosnaRepositorio = repositorio
        personaCasoUso = PersonaCasoUso(repository: perosnaRepositorio)
    }
    
    func traerPersonas() async {
        estaCargando = true
        do {
            personas = try await perosnaRepositorio.listarTodos()
        } catch {
            MensajeError = error.localizedDescription
        }
        estaCargando = false
    }
    
    func eliminarPersona(id: UUID) async {
        MensajeError = nil
        do {
            try await perosnaRepositorio.eliminar(uuid: id)
            await traerPersonas()
        } catch {
            MensajeError = error.localizedDescription
        }
    }

    func actualizarPersona(id: UUID, persona: Persona) async {
        MensajeError = nil
        do {
            try await perosnaRepositorio.actualizar(uui: id, persona: persona)
        } catch {
            MensajeError = error.localizedDescription
        }
    }

    func crearPersona(cedula: String, nombre: String, apellido: String, fehcaNacimiento: Date, genero: String, direccion: String, telefono: String, correo: String, imagen: Data) async {
        MensajeError = nil
        do {
            try await personaCasoUso.crearPersona(cedula: cedula, nombre: nombre, apellido: apellido, fechaNacimiento: fehcaNacimiento, genero: genero, direccion: direccion, telefono: telefono, correo: correo, imagen: imagen)
        } catch {
            MensajeError = error.localizedDescription
        }
    }
}
