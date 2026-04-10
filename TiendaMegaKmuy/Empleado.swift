//
//  Empleado.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import Foundation
import SwiftData

@Model
final class Empleado{
    var id:UUID
    var cargo:String
    var departamento:String
    @Relationship(inverse: \Persona.empleado) var persona: Persona
    
    init(id: UUID = UUID(), cargo: String, departamento: String, persona: Persona) {
        self.id = id
        self.cargo = cargo
        self.departamento = departamento
        self.persona = persona
    }
}
