//
//  PersonaCasoUso.swift
//  TiendaMegaKmuy
//
//  Created by Kleber Oswaldo Muy Landi on 10/4/26.
//

import Foundation


enum PersonaError: LocalizedError {
    case campoVacio(String)
    case correoInvalido(String)
    case fechaInvalida(String)
    case cedulaInvalida(String)
    
    var errorDescription: String? {
        switch self {
        case .campoVacio(let mensaje):
            return mensaje
            
        case .correoInvalido(let correo):
            return "El correo \(correo) no es valido"
        case .fechaInvalida(let fecha):
            return "La fecha \(fecha) no es valida"
        case .cedulaInvalida(_):
            return "La cedula no es valida"
        }
    }
    
    
}

struct PersonaCasoUso {
    private let repository: PersonaRepositorioImplementacionLocal
    
    init(repository: PersonaRepositorioImplementacionLocal) {
        self.repository = repository
    }
    
    func crearPersona(cedula:String,nombre:String,apellido:String,fechaNacimiento:Date,genero:String,direccion:String,telefono:String,correo:String,imagen:Data) async throws {
        guard !cedula.isEmpty else {
            throw PersonaError.campoVacio("no puede estar vacio")
        }
        
        guard !nombre.isEmpty else {
            throw PersonaError.campoVacio("no puede estar vacio")
        }
        
        guard !apellido.isEmpty else {
            throw PersonaError.campoVacio("no puede estar vacio")
        }
        
        guard !correo.isEmpty else {
            throw PersonaError.campoVacio("no puede estar vacio")
        }
        
        guard fechaNacimiento < Date() else {
            throw PersonaError.fechaInvalida("no puede ser mayor a la fecha actual")
        }
        
        
        let nuevaPersona = Persona(cedula: cedula, nombres: nombre, apellidos: apellido, fechaNacimiento: fechaNacimiento, genero: genero, direccion: direccion, telefono: telefono, email: correo)
        try await repository.guardar(perosna: nuevaPersona)
    }
    
    static func validarCorreo(correo:String) -> Bool {
        let patron = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return correo.range(of: patron, options: .regularExpression) != nil
    }
    
    /// Valida si una cédula de identidad ecuatoriana es auténtica.
    /// Utiliza el algoritmo de Luhn (módulo 10) que es el estándar del Registro Civil de Ecuador.
    /// La cédula ecuatoriana tiene 10 dígitos: 2 de provincia, 1 de tipo, 6 de secuencia y 1 verificador.
    func validarCedula(cedula:String) -> Bool {
        // Paso 1: La cédula debe tener exactamente 10 caracteres numéricos.
        // Si tiene menos, más, o contiene letras/símbolos, se rechaza inmediatamente.
        guard cedula.count == 10 ,cedula.allSatisfy(\.isNumber) else {
            return false
        }
        // Paso 2: Se convierte cada carácter del String en un número entero.
        // Ejemplo: "1710034065" se convierte en [1, 7, 1, 0, 0, 3, 4, 0, 6, 5]
        let digitos = cedula.compactMap(\.wholeNumberValue)
        // Paso 3: Los primeros 2 dígitos representan la provincia donde fue emitida.
        // Se combinan para formar el código de provincia. Ejemplo: dígitos 1 y 7 forman el 17 (Pichincha).
        let provincia = digitos[0] * 10 + digitos[1]
        // Paso 4: Ecuador tiene 24 provincias, por lo tanto el código debe estar entre 1 y 24.
        // Si el código no está en ese rango, la cédula no corresponde a ninguna provincia válida.
        guard provincia >= 1 && provincia <= 24 else {
            return false
        }
        
        // Paso 5: El tercer dígito indica el tipo de documento.
        // Para cédulas de personas naturales, este dígito debe ser menor a 6 (valores 0-5).
        // Valores 6 o superiores corresponden a otros tipos de documentos (RUC de sociedades, etc).
        guard digitos[2] < 6 else {
            return false
        }
        
        // Paso 6: Aplicación del algoritmo de Luhn (módulo 10).
        // Este algoritmo verifica la integridad de la cédula mediante operaciones matemáticas
        // sobre los primeros 9 dígitos, y compara el resultado con el décimo dígito (verificador).
        var suma  = 0
        // Se recorren los primeros 9 dígitos (posiciones 0 a 8), excluyendo el dígito verificador (posición 9).
        for i in 0..<9 {
            var valor = digitos[i]
            // Paso 6a: Los dígitos en posiciones pares (0, 2, 4, 6, 8) se multiplican por 2.
            // Si el resultado de la multiplicación es mayor o igual a 10, se le resta 9.
            // Esto equivale a sumar los dos dígitos del resultado (ej: 14 → 1+4 = 5, que es igual a 14-9 = 5).
            if i % 2 == 0 {
                valor *= 2
                if valor >= 10 {
                    valor -= 9
                }
            }
            // Paso 6b: Los dígitos en posiciones impares (1, 3, 5, 7) se mantienen sin cambios.
            // Se acumula cada valor (modificado o no) en la variable suma.
            suma += valor
        }
        // Paso 7: Se calcula el dígito verificador esperado.
        // Se obtiene el residuo de dividir la suma entre 10, luego se resta de 10.
        // El segundo módulo 10 maneja el caso especial donde la suma es múltiplo de 10
        // (sin él, el resultado sería 10 en vez de 0).
        let digitoVerificador = (10 - (suma % 10)) % 10
        // Paso 8: Se compara el dígito verificador calculado con el último dígito de la cédula.
        // Si coinciden, la cédula es válida; si no, es falsa o tiene un error de digitación.
        return digitoVerificador == digitos[9]
    }
    
    
    
}
