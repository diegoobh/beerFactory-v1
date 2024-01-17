//
//  CreateManufacturerView.swift
//  finalProject
//
//  Created by Diego Borrallo Herrero on 8/12/23.
//

import SwiftUI
import PhotosUI
import UIKit

struct CreateManufacturerView: View {
    
    @Environment(\.dismiss) private var dismiss //Variable de entorno para no guardar cambios 
    
    @ObservedObject var vm: EditManufacturerViewModel //Pasamos instancia del ViewModel del fabricante
    
    @State private var hasError: Bool = false //Variables de control y para el PhotoPicker
    @State var imagePickerPresented: Bool = false
    @State var selectedImage: UIImage?
    
    private var manufacturerImg: UIImage{ //Para decidir qué imagen aparece debajo del botón del picker
        !vm.isNew ? UIImage(data: vm.manufacturer.logo!)! : UIImage(systemName: "building.2")!
    }
    
    private var unwrappedImg: UIImage{
        selectedImage ?? manufacturerImg
    }
    
    var body: some View {
        Form {
            
            Section("Logo del fabricante") {
                HStack {
                    Spacer()
                    Button(action: { //Botón que activa el PhotoPicker
                        imagePickerPresented = true}, label: {
                            Text("Seleccione una imagen")
                        })
                    .sheet(isPresented: $imagePickerPresented) {
                        PhotoPicker(selectedImage: $selectedImage)
                    }
                    Spacer()
                }
                HStack { //Para centrar la imagen
                    Spacer()
                    Image(uiImage: unwrappedImg)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    Spacer()
                }
            }
            
            //Modificamos nombre y país con los dos siguientes campos
            Section("Nombre"){
                
                TextField("Introduzca el nombre", text: $vm.manufacturer.name)
                    .keyboardType(.namePhonePad)
                
            }
            
            Section("País"){
                
                TextField("Introduzca el país", text: $vm.manufacturer.country)
                    .keyboardType(.namePhonePad)
            }
            
        }
        .navigationTitle(vm.isNew ? "Nuevo Fabricante" : "Actualizar Fabricante") //Cambiamos el encabezado según si estamos añadiendo o editando el fabricante
        .toolbar{
            ToolbarItem(placement: .confirmationAction){
                Button("Aceptar"){
                    
                    if selectedImage == nil{
                        validate()
                    } else {
                        //Asignamos la imagen seleccionada y validamos
                        vm.manufacturer.logo = selectedImage?.pngData()
                        if vm.manufacturer.logo == nil {
                            vm.manufacturer.logo = UIImage(systemName: "building.2")?.pngData()
                        }
                        validate()}
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading){
                Button("Cancelar"){
                    //No hacemos nada
                    dismiss()
                }
            } //Si no hemos rellenado campos, salta el siguiente error
        }.alert("Algo salió mal...", isPresented: $hasError, actions: {}){
            Text("Parece que el formulario es inválido")
        }
    }
}

private extension CreateManufacturerView{
    
    func validate(){
        if vm.manufacturer.isValid{
            
            do{
                try vm.save() //Si el fabricante es válido, intentamos guardar en el contexto
                dismiss()
            }catch{
                print(error)
            }
            
        } else {
            hasError = true
        }
    }
}

//Código para el PhotoPicker visto en clase
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> some UIViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    self.parent.selectedImage = image as? UIImage
                }
            }
        }
    }
}


struct CreateManufacturerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            let preview = ManufacturerProvider.shared
            CreateManufacturerView(vm: .init(provider: preview))
                .environment(\.managedObjectContext, preview.viewContext)
        }
        
    }
}
