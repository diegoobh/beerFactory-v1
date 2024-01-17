//
//  ManufacturerDetailView.swift
//  finalProject
//
//  Created by Diego Borrallo Herrero on 8/12/23.
//

import SwiftUI

/*
 --------------------------------------------------------
 Enumeraciones para poder ordenar por alcohol y calorías
 de manera ascendente y descendente, pudiendo combinarlos
 en otro estado SortState para que tenga en cuenta
 las dos selecciones en el menú
 --------------------------------------------------------
 */

enum SortAlcohol{
    case alcoholAsc, alcoholDesc
}
enum SortCalories{
    case caloriesAsc, caloriesDesc
}

struct SortState: Equatable {
    var sortAlcohol: SortAlcohol
    var sortCalories: SortCalories
}

struct ManufacturerDetailView: View {
    
    @ObservedObject var manufacturer: Manufacturer //Instancia del fabricante
    
    @State private var beerToEdit: Beer? //Mismo mecanismo que la vista anterior, presentando el sheet cuando se pulsa en "Editar"
    @State private var selectedCategory: String = "All"
    @State private var searchText: String = ""
    
    @State private var sortAlcohol: SortAlcohol = .alcoholAsc
    @State private var sortCalories: SortCalories = .caloriesAsc
    @State private var sortState = SortState(sortAlcohol: .alcoholAsc, sortCalories: .caloriesAsc)
    
    @State private var sortedBeers: [Beer] = []
    
    private var filteredBeers: [Beer] { //Array de cervezas que coinciden con el texto de la barra de búsqueda
        let filtered = sortedBeers.filter { beer in
            searchText.isEmpty || beer.name.localizedCaseInsensitiveContains(searchText)
        }
        return selectedCategory == "All" ? filtered : filtered.filter { $0.type == selectedCategory }
    }
    
    var provider = ManufacturerProvider.shared //Instancia del Singleton
    
    private var unwrappedImg: UIImage{
        UIImage(data: manufacturer.logo!) ?? UIImage(systemName: "building.2")!
    }
    
    var body: some View {
        NavigationStack{
            List {
                Section("General"){
                    
                    HStack {
                        Spacer()
                        Image(uiImage: unwrappedImg)
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 100, height: 100)
                        Spacer()
                    }
                    
                    LabeledContent{
                        Text(manufacturer.name)
                    } label: {
                        Text("Nombre")
                    }
                    
                    LabeledContent{
                        Text(manufacturer.country)
                    } label: {
                        Text("País")
                    }
                }
            }
            //Se mapean los tipos de las cervezas del array de cervezas del fabricante y se añaden al Picker
            Picker("Category", selection: $selectedCategory) {
                Text("All").tag("All")
                ForEach(Array(Set(manufacturer.beersArray.map { $0.type })), id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(.menu)
            List{
                Section("Cervezas"){
                    if(manufacturer.beersArray.isEmpty){
                        NoBeersView()
                    } else {
                        ForEach(filteredBeers){ beer in
                            
                            ZStack(alignment: .leading) {
                                NavigationLink(destination: BeerDetailView(beer: beer)){
                                    EmptyView()
                                }.opacity(0)
                                
                                BeerRowView(beer: beer)
                                    .swipeActions(allowsFullSwipe: true){
                                        Button(role: .destructive){
                                            
                                            do{
                                                try provider.delete(beer, in: provider.newContext)
                                            }catch{
                                                print(error)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }.tint(.red)
                                        
                                        Button{
                                            beerToEdit = beer
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }.tint(.orange)
                                    }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .refreshable {
                refreshData() //Cuendo arrastremos hacia abajo la lista de cervezas, esta se refrescará
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button{ //Mismo procedimiento que en la vista anterior para añadir una cerveza
                        beerToEdit = .empty(context: provider.newContext)
                    } label : {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing){
                    Menu{
                        //Secciones para ordenar por graduación y calorías
                        Section{
                            Text("Ordenar por graduación")
                            
                            Picker(selection: $sortAlcohol){
                                Label("Ascendente", systemImage: "arrow.up").tag(SortAlcohol.alcoholAsc)
                                Label("Descendente", systemImage: "arrow.down").tag(SortAlcohol.alcoholDesc)
                            } label: {
                                Text("Ordenar")
                            }.onChange(of: sortAlcohol) { newValue in
                                sortState.sortAlcohol = newValue
                            }
                        }
                        
                        Section{
                            Text("Ordenar por calorías")
                            
                            Picker(selection: $sortCalories){
                                Label("Ascendente", systemImage: "arrow.up").tag(SortCalories.caloriesAsc)
                                Label("Descendente", systemImage: "arrow.down").tag(SortCalories.caloriesDesc)
                            } label: {
                                Text("Ordenar")
                            }.onChange(of: sortCalories) { newValue in
                                sortState.sortCalories = newValue
                            }
                        }
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .symbolVariant(.circle)
                            .font(.title2)
                    }
                }
            }
            .sheet(item: $beerToEdit, onDismiss: {
                beerToEdit = nil
            }, content: { beer in
                NavigationStack{
                    CreateBeerView(vm: .init(provider: provider, beer: beer), manufacturer: manufacturer)
                }
            })
            .onAppear(){ //Asignamos el array del fabricante al array de cervezas ordenadas para poder irlo modificando, ya que beersArray es una propiedad get-only
                sortedBeers = manufacturer.beersArray
            }
            .onChange(of: sortState) { _ in //Escucha los cambios en la ordenación y actúa en consecuencia
                sortedBeers = combinedSort(beers: manufacturer.beersArray, sortState: sortState)
            }
            .navigationTitle(manufacturer.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    /*
     -------------------------------------------------------
     Función que devuelve un array de cervezas ordenadas por
     graduación y calorías, según los valores de los campòs
     del parámetro sortState
     -------------------------------------------------------
     */
    
    func combinedSort(beers: [Beer], sortState: SortState) -> [Beer] {
        return beers.sorted { firstBeer, secondBeer in
            switch sortState.sortAlcohol {
            case .alcoholAsc:
                if firstBeer.alcoholContent == secondBeer.alcoholContent {
                    switch sortState.sortCalories {
                    case .caloriesAsc:
                        return firstBeer.calories < secondBeer.calories
                    case .caloriesDesc:
                        return firstBeer.calories > secondBeer.calories
                    }
                } else {
                    return firstBeer.alcoholContent < secondBeer.alcoholContent
                }
            case .alcoholDesc:
                if firstBeer.alcoholContent == secondBeer.alcoholContent {
                    switch sortState.sortCalories {
                    case .caloriesAsc:
                        return firstBeer.calories < secondBeer.calories
                    case .caloriesDesc:
                        return firstBeer.calories > secondBeer.calories
                    }
                } else {
                    return firstBeer.alcoholContent > secondBeer.alcoholContent
                }
            }
        }
    }
    
    /*
     ----------------------------------------------------------------
     Vuelve a asignar el array de cervezas del fabricante a las
     cervezas ordenadas, para cuando añadimos o eliuminamos cualquier
     cerveza
     ----------------------------------------------------------------
     */
    
    func refreshData(){
        sortedBeers = manufacturer.beersArray
    }
    
}

struct ManufacturerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            ManufacturerDetailView(manufacturer: .preview())
        }
    }
}
