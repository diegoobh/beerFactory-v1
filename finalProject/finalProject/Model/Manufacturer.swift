//
//  Manufacturer.swift
//  finalProject
//
//  Created by Diego Borrallo Herrero on 8/12/23.
//

import Foundation
import CoreData
import SwiftUI

/*
 ------------------------------------------------------------
 Structs que coinciden parcialmente con el modelo de datos de
 CoreData, con los que nos ayudamos para decodificar el JSON
 de datos "Data.json" en el bundle del proyecto
 ------------------------------------------------------------
 */

struct BeerData: Codable {
    var name: String
    var alcoholContent: Float
    var calories: Float
    var type: String
    var logo: String
}

struct ManufacturerData: Codable {
    var name: String
    var logo: String
    var country: String
    var beers: [BeerData]
}

//Clase principal de CoreData, Manufacturer

@objc(Manufacturer)
public class Manufacturer: NSManagedObject, Identifiable{
    
    @NSManaged var name: String
    @NSManaged var logo: Data?
    @NSManaged var country: String
    @NSManaged var beers: NSSet? //Relación To-Many a la entidad Beer
    
    var beersArray: [Beer]{ //Propiedad para poder obtener el array de cervezas de un fabricante
        let beerSet = beers as? Set<Beer> ?? []
        return Array(beerSet)
    }
    
    var isValid: Bool{ //Propiedad que verifica que un fabricante sea válido, verificando sus campos nombre y país
        !name.isEmpty && !country.isEmpty
    }
}


extension Manufacturer{
    
    private static var manufacturersFetchRequest: NSFetchRequest<Manufacturer>{
        NSFetchRequest(entityName: "Manufacturer")
    }
    
    static func all() -> NSFetchRequest<Manufacturer>{ //Devuelve todos los fabricantes ordenados por nombre ascendente
        let request: NSFetchRequest<Manufacturer> = manufacturersFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Manufacturer.name, ascending: true)
        ]
        
        return request
    }
    
    /*
     ----------------------------------------------------------------------
     Función que filtra según una configuración de búsqueda. Devuelve todos
     o los nacionales, comparándolos mediante el NSPredicate con la query
     que hayamos introducido en la barra de búsqueda de la vista principal.
     En caso de seleccionar nacionales, verifica también que los fabricantes
     que devuelve tengan como país "Spain" (no dejaba añadir fabricantes con
     país "España" ya que no reconoce la letra "ñ"
     -----------------------------------------------------------------------
     */
    
    static func filter(with config: SearchConfig) -> NSPredicate {
        switch config.filter{
        case .all:
            return config.query.isEmpty ? NSPredicate(value: true) : NSPredicate(format: "name CONTAINS[cd] %@", config.query)
        case .national:
            return config.query.isEmpty ? NSPredicate(format: "country == %@", "Spain") : 
            NSPredicate(format: "name CONTAINS[cd] %@ AND country == %@", config.query, "Spain")
        }
    }
    
    /*
     ----------------------------------------------------------
     Función que ordena los nombres de los fabricantes un orden
     que se pasa como parámetro, inicialmente ascendente
     ----------------------------------------------------------
     */
    
    static func sort(order: Sort) -> [NSSortDescriptor]{
        [NSSortDescriptor(keyPath: \Manufacturer.name, ascending: order == .asc)]
    }
}

extension Manufacturer{
    
    /*
     ----------------------------------------------------------------------
     Función para obtener los datos de los diez fabricantes más relevantes
     del archivop "Data.json" del bundle del proyecto. Devuelve el array de
     fabricantes decodificados del JSON
     ----------------------------------------------------------------------
     */
    
    @discardableResult
    static func makePreview(in context: NSManagedObjectContext) -> [Manufacturer] {
        
        var manufacturers = [Manufacturer]()
        
        if let jsonURL = Bundle.main.url(forResource: "Data", withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: jsonURL)
                let decoder = JSONDecoder()

                    do {
                        let decodedManufacturers = try decoder.decode([ManufacturerData].self, from: jsonData)
                        
                        for m in decodedManufacturers {
                            let image = UIImage(named: m.logo)?.pngData() ?? UIImage(systemName: "building.2")?.pngData()!
                            let manufacturer = Manufacturer(context: context)
                            manufacturer.name = m.name
                            manufacturer.country = m.country
                            manufacturer.logo = image
                            for b in m.beers{
                                let img = UIImage(named: b.logo)?.pngData() ?? UIImage(systemName: "mug")?.pngData()!
                                let beer = Beer(context: context)
                                beer.name = b.name
                                beer.alcoholContent = b.alcoholContent
                                beer.calories = b.calories
                                beer.type = b.type
                                beer.logo = img
                                beer.manufacturer = manufacturer
                                manufacturer.mutableSetValue(forKey: "beers").add(beer) //no se debería hacer, es de la API KVC
                            }
                            manufacturers.append(manufacturer)
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
        
        return manufacturers
    }
    
    //Función auxiliar que devuelve un único fabricante en un contexto específico
    static func preview(context: NSManagedObjectContext = ManufacturerProvider.shared.viewContext) -> Manufacturer{
        return makePreview(in: context)[0]
    }
    
    //Función auxiliar que instancia un fabricante en un contexto específico
    static func empty(context: NSManagedObjectContext = ManufacturerProvider.shared.viewContext) -> Manufacturer{
        return Manufacturer(context: context)
    }
}
