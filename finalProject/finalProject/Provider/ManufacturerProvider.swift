//
//  ManufacturerProvider.swift
//  finalProject
//
//  Created by Diego Borrallo Herrero on 8/12/23.
//

import Foundation
import CoreData
import SwiftUI

final class ManufacturerProvider {
    
    //Singleton
    static let shared = ManufacturerProvider()
    
    private let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext{
        persistentContainer.viewContext //Contexto principal
    }
    
    var newContext: NSManagedObjectContext{
        persistentContainer.newBackgroundContext() //Contexto secundario para otras tareas
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "finalProject")
        if EnvironmentValues.isPreview{ //Si estamos en preview, no guardamos los cambios que hagamos, es solo para pruebas
            persistentContainer.persistentStoreDescriptions.first?.url = .init(fileURLWithPath: "/dev/null")
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Unable to load store with error: \(error)")
            }
        }
    }
    
    /*
     ----------------------------------------------------------------------------
     Funciones que verifican si un fabricante o una cerveza
     existen en un contexto en concreto. Según el parámetro que
     pasemos (Manufacturer o Beer), devuelven Manufacturer o beer respectivamente.
     ----------------------------------------------------------------------------
     */
    
    func exists(_ manufacturer: Manufacturer, in context: NSManagedObjectContext) -> Manufacturer? {
        
        try? context.existingObject(with: manufacturer.objectID) as? Manufacturer
    }
    
    func exists(_ beer: Beer, in context: NSManagedObjectContext) -> Beer? {
        
        try? context.existingObject(with: beer.objectID) as? Beer
    }
    
    /*
     ----------------------------------------------------------------------------
     Funciones que eliminan el fabricante o la cerveza que se pasen por parámetro
     dentro del contexto que se pase también como parámetro
     ----------------------------------------------------------------------------
     */
    
    func delete(_ manufacturer: Manufacturer, in context: NSManagedObjectContext) throws {
        
        if let existingManufacturer = exists(manufacturer, in: context) {
            
            for b in existingManufacturer.beersArray{
                context.delete(b) //Eliminamos primero el array de cervezas
            }
            
            context.delete(existingManufacturer) //Eliminamos el fabricante
            
            Task(priority: .background){
                try await context.perform{
                    try context.save()
                }
            }
        }
    }
    
    func delete(_ beer: Beer, in context: NSManagedObjectContext) throws {
        
        if let existingBeer = exists(beer, in: context) {
            context.delete(existingBeer)
            Task(priority: .background){
                try await context.perform{
                    try context.save()
                }
            }
        }
    }
    
    /*
     -----------------------------------------------------------------
     Función de persistencia de datos que trata de guardar el contexto
     pasado por parámetro si este ha tenido cambios cuando esta
     función haya sido llamada
     -----------------------------------------------------------------
     */
    
    func persist(in context: NSManagedObjectContext) throws {
        
        if context.hasChanges{
            try context.save()
        }
    }
}

extension EnvironmentValues{
    static var isPreview: Bool{
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
