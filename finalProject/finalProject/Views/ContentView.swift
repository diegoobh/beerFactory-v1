//
//  ContentView.swift
//  finalProject
//
//  Created by Diego Borrallo Herrero on 8/12/23.
//

import SwiftUI

struct SearchConfig: Equatable{ //Filtrar por nombre y nacionalidad
    
    enum Filter{
        case all, national
    }
    var query: String = ""
    var filter: Filter = .all
}

enum Sort{ //Filtrar por nombre ascendente o descendente
    case asc, desc
}

struct ContentView: View {
    
    //Nos devuelve todos los fabricantes almacenados en nuestro CoreData
    @FetchRequest(fetchRequest: Manufacturer.all()) private var manufacturers
    
    @State private var manufacturerToEdit: Manufacturer?
    @State private var searchConfig: SearchConfig = .init()
    @State private var sort: Sort = .asc
    
    var provider = ManufacturerProvider.shared //Instancia del Singleton
    
    var body: some View {
        NavigationStack{
            
            ZStack{
                if manufacturers.isEmpty{
                    NoManufacturersView() //Si no hay fabricantes mostramos la vista vacía
                } else {
                    List{
                        //Dividimos la lista en secciones nacional e internacional filtrando los fabricantes por país
                        
                        Section("Fabricantes Nacionales"){
                            ForEach(manufacturers.filter { $0.country == "Spain" || $0.country == "España"}, id: \.id) { manufacturer in
                                ZStack(alignment: .leading){
                                    NavigationLink(destination: ManufacturerDetailView(manufacturer: manufacturer)){
                                        
                                        EmptyView() //Superponemos con el ZStack para que no se muestre la flecha de la navegación en la fila de cada fabricante
                                        
                                    }.opacity(0)
                                    
                                    //Vista de la fila de cada fabricante
                                    ManufacturerRowView(manufacturer: manufacturer)
                                        .swipeActions(allowsFullSwipe: true){
                                            Button(role: .destructive){
                                                
                                                do{ //Eliminamos el fabricante del contexto 
                                                    try provider.delete(manufacturer, in: provider.newContext)
                                                }catch{
                                                    print(error)
                                                }
                                            } label: {
                                                Label("Eliminar", systemImage: "trash")
                                            }.tint(.red)
                                            
                                            Button{ //Seleccionamos el fabricante a editar
                                                manufacturerToEdit = manufacturer
                                            } label: {
                                                Label("Editar", systemImage: "pencil")
                                            }.tint(.orange)
                                        }
                                }
                            }
                        }
                        
                        Section("Fabricantes Extranjeros"){
                            ForEach(manufacturers.filter { $0.country != "Spain" && $0.country != "España"}, id: \.id) { manufacturer in
                                ZStack(alignment: .leading){
                                    NavigationLink(destination: ManufacturerDetailView(manufacturer: manufacturer)){
                                        
                                        EmptyView()
                                        
                                    }.opacity(0)
                                    
                                    ManufacturerRowView(manufacturer: manufacturer)
                                        .swipeActions(allowsFullSwipe: true){
                                            Button(role: .destructive){
                                                
                                                do{
                                                    try provider.delete(manufacturer, in: provider.newContext)
                                                }catch{
                                                    print(error)
                                                }
                                            } label: {
                                                Label("Eliminar", systemImage: "trash")
                                            }.tint(.red)
                                            
                                            Button{
                                                manufacturerToEdit = manufacturer
                                            } label: {
                                                Label("Editar", systemImage: "pencil")
                                            }.tint(.orange)
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchConfig.query)
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button{ //Queremos añadir un fabricante asique pasamos uno "vacío"
                        manufacturerToEdit = .empty(context: provider.newContext)
                    } label : {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing){
                    Menu{
                        
                        Section{
                            Text("Filtrar por")
                            
                            Picker(selection: $searchConfig.filter){
                                Text("Todos").tag(SearchConfig.Filter.all)
                                Text("Nacionales").tag(SearchConfig.Filter.national)
                            } label: {
                                Text("Filtrar nacionales")
                            }
                        }
                        
                        Section{
                            Text("Ordenar por")
                            
                            Picker(selection: $sort){
                                Label("Ascendente", systemImage: "arrow.up").tag(Sort.asc)
                                Label("Descendente", systemImage: "arrow.down").tag(Sort.desc)
                            } label: {
                                Text("Ordenar")
                            }
                        }
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .symbolVariant(.circle)
                            .font(.title2)
                    }
                }
            }
            .sheet(item: $manufacturerToEdit, onDismiss: { //Salta cuando seleccionemos el fabricante que queramos editar o añadir
                manufacturerToEdit = nil
            }, content: { manufacturer in
                NavigationStack{
                    CreateManufacturerView(vm: .init(provider: provider, manufacturer: manufacturer))
                }
            })
            .navigationTitle("Fabricantes")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: searchConfig){ newConfig in //Escuchan cambios en la configuración de búsqueda y en el orden de nombres
                manufacturers.nsPredicate = Manufacturer.filter(with: newConfig)
            }
            .onChange(of: sort){ newSort in
                manufacturers.nsSortDescriptors = Manufacturer.sort(order: newSort)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let preview = ManufacturerProvider.shared
        ContentView(provider: preview)
            .environment(\.managedObjectContext, preview.viewContext)
            .previewDisplayName("Manufactures with data")
            .onAppear{
                //Obtenemos todos los fabricantes del JSON para esta preview 
                Manufacturer.makePreview(in: preview.viewContext)
            }
        
        //Preview sin fabricantes
        let emptyPreview = ManufacturerProvider.shared
        ContentView(provider: emptyPreview)
            .environment(\.managedObjectContext, emptyPreview.viewContext)
            .previewDisplayName("Manufactures with no data")
        
    }
}
