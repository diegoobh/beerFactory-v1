//
//  CreateBeerView.swift
//  finalProject
//
//  Created by Diego Borrallo Herrero on 13/12/23.
//

import SwiftUI
import CoreData
import PhotosUI

struct CreateBeerView: View {
    
    /*
     -------------------------------------------------------
     Misma estructura que CreateManufacturerView más o menos
     -------------------------------------------------------
     */
    
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var vm: EditBeerViewModel //Instancia del ViewModel de la cerveza
    @ObservedObject var manufacturer: Manufacturer //Instancia del fabricante al que pertenece la cerveza
    
    @State private var hasError: Bool = false
    @State private var txtAlcohol: String = ""
    @State private var txtCalories: String = ""
    @State var imagePickerPresented: Bool = false
    @State var selectedImage: UIImage?
    
    private var beerImg: UIImage{
        !vm.isNew ? UIImage(data: vm.beer.logo!)! : UIImage(systemName: "building.2")!
    }
    
    private var unwrappedImg: UIImage{
        selectedImage ?? beerImg
    }
    
    private var formattedAlcohol: String {
        
        if(vm.beer.alcoholContent < 0){
            return "Graduación alcohólica"
        } else {
            return "\(vm.beer.alcoholContent)%"
        }
    }
    
    private var formattedCalories: String {
        
        if(vm.beer.calories < 0){
            return "Calorías"
        } else {
            return "\(vm.beer.calories)"
        }
    }
    
    var body: some View {
        Form {
            
            Section("Complete los campos"){
                
                TextField("Nombre", text: $vm.beer.name)
                    .keyboardType(.namePhonePad)
                
                TextField("Tipo", text: $vm.beer.type)
                    .keyboardType(.namePhonePad)
                
                TextField(formattedAlcohol, text: $txtAlcohol)
                    .keyboardType(.numbersAndPunctuation)
                
                TextField(formattedCalories, text: $txtCalories)
                    .keyboardType(.numbersAndPunctuation)
            }
            
            Section("Imagen de la cerveza") {
                HStack {
                    Spacer()
                    Button(action: {
                        imagePickerPresented = true}, label: {
                            Text("Seleccione una imagen")
                        })
                    .sheet(isPresented: $imagePickerPresented) {
                        PhotoPicker(selectedImage: $selectedImage)
                    }
                    Spacer()
                }
                HStack {
                    Spacer()
                    Image(uiImage: unwrappedImg)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    Spacer()
                }
            }
        }
        .navigationTitle(vm.isNew ? "Nueva cerveza" : "Actualizar cerveza")
        .toolbar{
            ToolbarItem(placement: .confirmationAction){
                Button("Aceptar"){
                    vm.assignManufacturer(manufacturer) //Llamamos a la función que asigna la relación con el fabricante
                    
                    if selectedImage == nil {
                        validate()
                    } else {
                        vm.beer.logo = selectedImage?.pngData()
                        if vm.beer.logo == nil {
                            vm.beer.logo = UIImage(systemName: "mug")?.pngData()
                        }
                        vm.beer.alcoholContent = Float(txtAlcohol) ?? 0.0
                        vm.beer.calories = Float(txtCalories) ?? 0.0
                        validate()
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading){
                Button("Cancelar"){
                    dismiss()
                }
            }
        }.alert("Algo salió mal...", isPresented: $hasError, actions: {}){
            Text("Parece que el formulario es inválido")
        }
    }
}

private extension CreateBeerView{
    
    func validate(){
        if vm.beer.isValid{
            
            do{
                try vm.save()
                dismiss()
            }catch{
                print(error)
            }
            
        } else {
            hasError = true
        }
    }
}


struct CreateBeerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            let preview = ManufacturerProvider.shared
            CreateBeerView(vm: .init(provider: preview), manufacturer: .preview())
                .environment(\.managedObjectContext, preview.viewContext)
        }
    }
}
