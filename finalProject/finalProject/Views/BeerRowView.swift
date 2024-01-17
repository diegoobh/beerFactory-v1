//
//  BeerRowView.swift
//  finalProject
//
//  Created by Diego Borrallo Herrero on 13/12/23.
//

import SwiftUI

struct BeerRowView: View {
    
    @ObservedObject var beer: Beer //Instancia de la cerveza
    
    private var data: Data?{
        beer.logo ?? UIImage(systemName: "mug")?.pngData()
    }
    
    var body: some View{
        HStack{
            //Si fallan los datos del logo de la cerveza, mostramos una taza(de Símbolos SF) en su lugar
            let uiImage = UIImage(data: data!) ?? UIImage(systemName: "mug")!
            Image(uiImage: uiImage)
                .renderingMode(.original)
                .resizable()
                .frame(width: 70, height: 70)
            
            VStack(alignment: .leading){
                Text(beer.name)
                    .font(.system(size:25, design: .rounded).bold())
                    .lineLimit(2)
                HStack{
                    Text(beer.type)
                }
                
            }
        }
    }
}

struct BeerRowView_Previews: PreviewProvider {
    static var previews: some View {
        BeerRowView(beer: .preview())
    }
}
