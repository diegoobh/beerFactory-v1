//
//  BeerDetailView.swift
//  finalProject
//
//  Created by Diego Borrallo Herrero on 13/12/23.
//

import SwiftUI

struct BeerDetailView: View {
    
    @ObservedObject var beer: Beer //Instancia de la cerveza
    
    private var unwrappedImg: UIImage{
        UIImage(data: beer.logo!) ?? UIImage(systemName: "mug")!
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
                            .frame(width: 50, height: 50)
                        Spacer()
                    }
                    
                    LabeledContent{
                        Text(beer.name)
                    } label: {
                        Text("Nombre")
                    }
                    
                    LabeledContent{
                        Text(beer.type)
                    } label: {
                        Text("Tipo")
                    }
                    
                    LabeledContent{
                        Text(String(format: "%.2f%%", beer.alcoholContent))
                    } label: {
                        Text("Porcentaje de alcohol")
                    }
                    
                    LabeledContent{
                        Text(String(format: "%.1f", beer.calories))
                    } label: {
                        Text("Calorías")
                    }
                }
            }
            .navigationTitle(beer.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct BeerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            BeerDetailView(beer: .preview())
        }
    }
}
