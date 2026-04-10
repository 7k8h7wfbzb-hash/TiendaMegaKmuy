//
//  PersonaRepositorio.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import Foundation
import SwiftData

final class PersonaRepositorioImplementacionLocal: Repositorio {
    typealias Modelo = Persona

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func listarTodos() async throws -> [Persona] {
        let descriptor = FetchDescriptor<Persona>()
        return try modelContext.fetch(descriptor)
    }

    func guardar(_ item: Persona) async throws {
        modelContext.insert(item)
        try modelContext.save()
    }

    func eliminar(_ item: Persona) async throws {
        modelContext.delete(item)
        try modelContext.save()
    }

    func actualizar(_ item: Persona) async throws {
        try modelContext.save()
    }
}

