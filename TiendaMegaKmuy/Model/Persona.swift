//
//  Persona.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import Foundation
import SwiftData

@Model

final class Persona{
    var id:UUID
    var cedula:String
    var nombres:String
    var apellidos:String
    var fechaNacimiento:Date
    var genero:String
    var direccion:String
    var telefono:String
    var email:String
    var imagen:Data?
    var empleado: Empleado?
    
    init(id: UUID=UUID(), cedula: String, nombres: String, apellidos: String, fechaNacimiento: Date, genero: String, direccion: String, telefono: String, email: String, imagen: Data? = nil) {
        self.id = id
        self.cedula = cedula
        self.nombres = nombres
        self.apellidos = apellidos
        self.fechaNacimiento = fechaNacimiento
        self.genero = genero
        self.direccion = direccion
        self.telefono = telefono
        self.email = email
        self.imagen = imagen
        self.empleado = nil
    }
}
