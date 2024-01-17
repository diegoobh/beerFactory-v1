//
//  EditManufacturerViewModel.swift
//  finalProject
//
//  Created by Diego Borrallo Herrero on 8/12/23.
//

import Foundation
import CoreData

final class EditManufacturerViewModel: ObservableObject{
    
    @Published var manufacturer: Manufacturer //Instancia pública del fabricante
    let isNew: Bool //Decide si estamos añadiendo o editando el fabricante
    private let provider: ManufacturerProvider //Instancia de la clase que maneja los datos en el contexto
    private let context: NSManagedObjectContext //Contexto de ejecución
    
    init(provider: ManufacturerProvider, manufacturer: Manufacturer? = nil){
        self.provider = provider
        self.context = provider.newContext
        if let manufacturer,
           let existingManufacturerCopy = provider.exists(manufacturer, in: context){ //Ya hay un objeto existente igual en el contexto
            self.manufacturer = existingManufacturerCopy
            self.isNew = false
        } else {
            self.manufacturer = Manufacturer(context: self.context) //Si no existe otro igual, creamos uno nuevo
            self.isNew = true
        }
    }
    
    func save() throws {
        try provider.persist(in: context) //Función para persistencia de datos
    }
}
