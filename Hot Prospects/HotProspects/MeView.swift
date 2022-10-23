//
//  MeView.swift
//  HotProspects
//
//  Created by Nikita Novikov on 21.09.2022.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct MeView: View {
    @EnvironmentObject var prospects: Prospects
    @State private var qrCode = UIImage()
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    private var name: Binding<String> {
        Binding(get: { prospects.me.name },
                set: { newValue in
            prospects.setMe(Me(name: newValue, email: prospects.me.email))
        })
    }
    
    private var email: Binding<String> {
        Binding(get: { prospects.me.email },
                set: { newValue in
            prospects.setMe(Me(name: prospects.me.name, email: newValue))
        })
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: name)
                    .textContentType(.name)
                    .font(.title)
                
                TextField("Email address", text: email)
                    .textContentType(.emailAddress)
                    .font(.title)
                
                Image(uiImage: qrCode)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .frame(maxWidth: .infinity)
                    .contextMenu {
                        Button {
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: qrCode)
                        } label: {
                            Label("Save to Photos", systemImage: "square.and.arrow.down")
                        }
                    }
            }
            .navigationTitle("Your code")
            .onAppear(perform: updateCode)
            .onChange(of: prospects.me) { _ in updateCode() }
        }
    }
    
    func updateCode() {
        qrCode = generateQRCode(from: "\(prospects.me.name)\n\(prospects.me.email)")
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
            .environmentObject(Prospects.testData)
    }
}
