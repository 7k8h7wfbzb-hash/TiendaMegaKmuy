//
//  Repositorio.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import Foundation
import SwiftData

protocol Repositorio {
    associatedtype Entity: PersistentModel

    func listarTodos(
        sortBy: [SortDescriptor<Entity>],
        predicate: Predicate<Entity>?
    ) throws -> [Entity]
    func guardar(_ entidad: Entity) throws
    func eliminar(_ entidad: Entity) throws
}

