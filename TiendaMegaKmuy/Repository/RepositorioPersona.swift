//
//  Repositorio.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import Foundation
import SwiftData

protocol Repositorio {
   
    func listarTodos() async throws -> [Persona]
    func guardar(perosna:Persona) async throws
    func eliminar(uuid: UUID) async throws
    func actualizar(uui: UUID, persona: Persona) async throws
}

