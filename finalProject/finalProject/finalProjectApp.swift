//
//  finalProjectApp.swift
//  finalProject
//
//  Created by Diego Borrallo Herrero on 8/12/23.
//

import SwiftUI
import CoreData

@main
struct finalProjectApp: App {
    
    let preview = ManufacturerProvider.shared //Instancia del Singleton
    
    @Environment(\.scenePhase) var scenePhase //Variable de entorno para cuando pase a segundo plano 

    var body: some Scene {
        WindowGroup {
            ContentView(provider: preview)
                .environment(\.managedObjectContext, preview.viewContext)
                .onAppear {
                    loadInitialDataIfNeeded()
                }
                .onChange(of: scenePhase) { newScenePhase in
                    if newScenePhase == .background {
                        //Guardar cambios en Core Data
                        try? preview.viewContext.save()
                    }
                }
        }
    }
    
    /*
     -----------------------------------------------------
     Función que asegura una única carga de los datos a la
     base de datos, evitando duplicidad o multiplicidad
     de los datos al reabrir la app
     -----------------------------------------------------
     */

    private func loadInitialDataIfNeeded() {
        let context = preview.viewContext
        // Verificar si hay datos existentes
        let fetchRequest: NSFetchRequest<Manufacturer> = Manufacturer.all()
        let count = (try? context.count(for: fetchRequest)) ?? 0
        if count == 0 {
            // Cargar datos desde el bundle
            Manufacturer.makePreview(in: context)
            try? context.save()
        }
    }
}
