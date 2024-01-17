//
//  NoManufacturersView.swift
//  finalProject
//
//  Created by Diego Borrallo Herrero on 8/12/23.
//

import SwiftUI

struct NoManufacturersView: View {
    var body: some View {
        VStack{ //Si no hay fabricantes, se muestra esta vista
            Text("👀 Hey, no hay fabricantes todavía!")
                .font(.callout.bold())
        }
    }
}

struct NoManufacturersView_Previews: PreviewProvider {
    static var previews: some View {
        NoManufacturersView()
    }
}

