//
//  ContentView.swift
//  Instafilter
//
//  Created by Nikita Novikov on 05.09.2022.
//

import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 50.0
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showingFilterSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.secondary)
                    
                    Text("Tap to select a picture")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                
                HStack {
                    if currentFilter.name == "CIGaussianBlur" {
                        Text("Radius")
                        
                        Slider(value: $filterRadius, in: 0...150)
                            .onChange(of: filterRadius) { _ in applyProcessing() }
                    } else if currentFilter.name == "CIUnsharpMask" || currentFilter.name == "CIVignette" || currentFilter.name == "CIBloom" {
                        VStack {
                            HStack {
                                Text("Radius")
                                
                                Slider(value: $filterRadius, in: 0...150)
                                    .onChange(of: filterRadius) { _ in applyProcessing() }
                            }
                            
                            HStack {
                                Text("Intensity")
                                
                                Slider(value: $filterIntensity)
                                    .onChange(of: filterIntensity) { _ in applyProcessing() }
                            }
                        }
                    } else {
                        Text("Intensity")
                        
                        Slider(value: $filterIntensity)
                            .onChange(of: filterIntensity) { _ in applyProcessing() }
                    }
                }
                .padding(.vertical)
                
                HStack {
                    Button("Change Filter") { showingFilterSheet = true }
                        .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
                            Group {
                                Button("Crystallize") { setFilter(CIFilter.crystallize()) } // intensity 0.0 - 1.0
                                Button("Edges") { setFilter(CIFilter.edges()) }
                                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                                Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                                Button("Vignette") { setFilter(CIFilter.vignette()) }
                                Button("Bloom") { setFilter(CIFilter.bloom()) }
                                Button("Color Invert") { setFilter(CIFilter.colorInvert()) }
                            }
                            
                            Button("Cancel", role: .cancel) { }
                        }
                    
                    Spacer()
                    
                    Button("Save", action: save)
                        .disabled(image == nil)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .onChange(of: inputImage) { _ in loadImage() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
        }
        .navigationViewStyle(.stack)
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func save() {
        guard let processedImage = processedImage else { return }

        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            print("Success!")
        }
        
        imageSaver.errorHandler = { error in
            print("Oops! \(error.localizedDescription)")
        }
        
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterRadius, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterIntensity * 25, forKey: kCIInputScaleKey)
        }
        
        if currentFilter.name == "CIEdges" {
            currentFilter.setValue(filterIntensity * 1000, forKey: kCIInputIntensityKey)
        }
        
        if currentFilter.name == "CIUnsharpMask" || currentFilter.name == "CIVignette" || currentFilter.name == "CIBloom" {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
            currentFilter.setValue(filterRadius, forKey: kCIInputRadiusKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
