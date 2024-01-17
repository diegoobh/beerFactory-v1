//
//  Beer.swift
//  finalProject
//
//  Created by Diego Borrallo Herrero on 13/12/23.
//

import Foundation
import CoreData
import UIKit

//Clase secundaria de CoreData, Beer

@objc(Beer)
public class Beer: NSManagedObject, Identifiable {
    
    @NSManaged var name: String
    @NSManaged var alcoholContent: Float
    @NSManaged var calories: Float
    @NSManaged var type: String
    @NSManaged var logo: Data?
    @NSManaged var manufacturer: Manufacturer? //Relación To-One a la entidad Manufacturer
    
    var isValid: Bool{ //Propiedad que verifica que una cerveza sea válida, verificando sus campos nombre, tipo, alcohol y calorías
        !name.isEmpty && !type.isEmpty && (alcoholContent >= 0) && (calories >= 0)
    }
}


extension Beer{
    
    /*
     --------------------------------------------------------------------------------
     Casi misma estructura que las funciones del mismo tipo en la clase Manufacturer.
     La primera genera los datos de las cervezas del JSON, la segunda devuelve una
     instancia del tipo Beer solamente y la última crea una instancia del tipo Beer
     --------------------------------------------------------------------------------
     */
    
    @discardableResult
    static func makePreviewBeers(in context: NSManagedObjectContext) -> [Beer] {
        
        var beers = [Beer]()
        
        if let jsonURL = Bundle.main.url(forResource: "Data", withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: jsonURL)
                let decoder = JSONDecoder()
                
                do {
                    let decodedManufacturers = try decoder.decode([ManufacturerData].self, from: jsonData)
                    
                    for b in decodedManufacturers.first!.beers {
                        let img = UIImage(named: b.logo)?.pngData() ?? UIImage(systemName: "mug")?.pngData()!
                        let beer = Beer(context: context)
                        beer.name = b.name
                        beer.alcoholContent = b.alcoholContent
                        beer.calories = b.calories
                        beer.type = b.type
                        beer.logo = img
                        
                        beers.append(beer)
                    }
                } catch {
                    print("Error al decodificar: \(error)")
                }
                
                try context.save()
                
            } catch {
                print("Error loading or decoding JSON: \(error)")
            }
        } else {
            print("JSON file not found in the app bundle.")
        }
        
        return beers
    }
    
    
    static func preview(context: NSManagedObjectContext = ManufacturerProvider.shared.viewContext) -> Beer{
        return makePreviewBeers(in: context)[0]
    }
    
    static func empty(context: NSManagedObjectContext = ManufacturerProvider.shared.viewContext) -> Beer{
        return Beer(context: context)
    }
}
