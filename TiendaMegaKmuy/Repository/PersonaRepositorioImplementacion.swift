//
//  PersonaRepositorio.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import Foundation
import SwiftData

@MainActor
final class PersonaRepositorioImplementacionLocal: Repositorio {
    let context:ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func listarTodos() async throws -> [Persona] {
        let descriptor = FetchDescriptor<Persona>()
        return try context.fetch(descriptor)
    }
    
    func guardar(perosna: Persona) async throws {
        context.insert(perosna)
    }
    
    func eliminar(uuid: UUID) async throws {
        let descriptor = FetchDescriptor<Persona>(predicate: #Predicate{$0.id == uuid})
        if let cliente = try context.fetch(descriptor).first {
            context.delete(cliente)
            try context.save()
        }
    }
    
    func actualizar(uui: UUID, persona: Persona) async throws {
        let descriptor = FetchDescriptor<Persona>(predicate: #Predicate { $0.id == uui })
        if let personaExistente = try context.fetch(descriptor).first {
            personaExistente.cedula = persona.cedula
            personaExistente.nombres = persona.nombres
            personaExistente.apellidos = persona.apellidos
            personaExistente.fechaNacimiento = persona.fechaNacimiento
            personaExistente.genero = persona.genero
            personaExistente.direccion = persona.direccion
            personaExistente.telefono = persona.telefono
            personaExistente.email = persona.email
            personaExistente.imagen = persona.imagen
            try context.save()
        }
    }
    

}

