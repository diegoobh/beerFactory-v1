//
//  EditBeerViewModel.swift
//  finalProject
//
//  Created by Diego Borrallo Herrero on 13/12/23.
//

import Foundation
import CoreData

final class EditBeerViewModel: ObservableObject{
    
    @Published var beer: Beer //Instancia pública de la cerveza
    let isNew: Bool //Decide si estamos añadiendo o editando la cerveza
    private let provider: ManufacturerProvider //Instancia de la clase que maneja los datos en el contexto
    private let context: NSManagedObjectContext //Contexto de ejecución
    
    init(provider: ManufacturerProvider, beer: Beer? = nil){
        self.provider = provider
        self.context = provider.newContext
        if let beer,
           let existingBeerCopy = provider.exists(beer, in: context){ //Ya hay una cerveza existente igual en el contexto
            self.beer = existingBeerCopy
            self.isNew = false
        } else {
            self.beer = Beer(context: self.context) //Si no existe otro igual, creamos una nueva
            self.isNew = true
        }
    }
    
    func save() throws {
        try provider.persist(in: context)
    }
    
    /*
     ---------------------------------------------------
     Función que asigna la relación de pertenencia de la
     cerveza a un fabricante en concreto, que pasamos
     como parámetro
     ---------------------------------------------------
     */
    
    func assignManufacturer(_ manufacturer: Manufacturer) {
        if let manufacturerInContext = self.provider.exists(manufacturer, in: self.context) {
            self.beer.manufacturer = manufacturerInContext
        } else {
            beer.manufacturer = nil
            print("Error al asignar fabricante a la cerveza \(self.beer.name)")
        }
    }
}

