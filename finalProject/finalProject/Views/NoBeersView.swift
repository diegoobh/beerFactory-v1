//
//  NoBeersView.swift
//  finalProject
//
//  Created by Diego Borrallo Herrero on 13/12/23.
//

import SwiftUI

struct NoBeersView: View {
    var body: some View {
        VStack{ //Si no hay cervezas en el array del fabricante, mostramos esta vista 
            Text("👀 Hey, no hay cervezas todavía!")
                .font(.callout.bold())
        }
    }
}

struct NoBeersView_Previews: PreviewProvider {
    static var previews: some View {
        NoBeersView()
    }
}
