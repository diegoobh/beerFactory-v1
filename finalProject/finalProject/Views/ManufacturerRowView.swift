//
//  ManufacturerRowView.swift
//  finalProject
//
//  Created by Diego Borrallo Herrero on 8/12/23.
//

import SwiftUI

struct ManufacturerRowView: View {
    
    //Instancia del fabricante
    @ObservedObject var manufacturer: Manufacturer
    
    var body: some View{
        HStack{
            //Si fallan los datos del logo, ponemos uan imagen por defencto(de Símbolos SF)
            let uiImage = UIImage(data: manufacturer.logo!) ?? UIImage(systemName: "building.2")!
            Image(uiImage: uiImage)
                .renderingMode(.original)
                .resizable()
                .frame(width: 70, height: 70)
            
            VStack(alignment: .leading){
                Text(manufacturer.name)
                    .font(.system(size:25, design: .rounded).bold())
                    .lineLimit(2)
                HStack{
                    Label(manufacturer.country, systemImage: "mappin")
                }
                
            }
        }
    }
}

struct ManufacturerRowView_Previews: PreviewProvider {
    static var previews: some View{
        ManufacturerRowView(manufacturer: .preview())
    }
}
