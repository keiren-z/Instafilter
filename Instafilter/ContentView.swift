//
//  ContentView.swift
//  Instafilter
//
//  Created by Keiren on 2021-05-12.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 0.5
    @State private var filterScale = 0.5
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var showingFilterSheet = false
    @State private var proccesedImage: UIImage?
    @State private var showingError = false
    @State private var filterButtonText = "Change Filter"
    
    let context = CIContext()
    let filters = ["Crystallize","Edges","Gaussian Blur","Pixellate","Sepia Tone","Unsharp Mask","Vignette"]
    
    var body: some View {
        let intensity = Binding<Double> (
            get: {
                self.filterIntensity
            },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
            }
        )
        
        let radius = Binding<Double> (
            get: {
                self.filterRadius
            },
            set: {
                self.filterRadius = $0
                self.applyProcessing()
            }
        )
        
        let scale = Binding<Double> (
            get: {
                self.filterScale
            },
            set: {
                self.filterScale = $0
                self.applyProcessing()
            }
        )
        
        return NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary)
                    
                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    self.showingImagePicker = true
                }
                
                if currentFilter.inputKeys.contains(kCIInputIntensityKey){
                    HStack {
                        Text("Intensity")
                        Slider(value: intensity)
                    }
                    .padding(.vertical)
                }
                
                if currentFilter.inputKeys.contains(kCIInputRadiusKey) {
                    HStack {
                        Text("Radius")
                        Slider(value: radius, in: 0...200)
                    }
                    .padding(.vertical)
                }
                
                if currentFilter.inputKeys.contains(kCIInputScaleKey) {
                    HStack {
                        Text("Scale")
                        Slider(value: scale, in: 0...100)
                    }
                    .padding(.vertical)
                }
                
                HStack {
                    Button(filterButtonText) {
                        self.showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        guard let proccesedImage = self.proccesedImage else {
                            showingError = true
                            
                            return
                        }
                        
                        let imageSaver = ImageSaver()
                        
                        imageSaver.successHandler = {
                            print("Success!")
                        }
                        
                        imageSaver.errorHandler = {
                            print("Ooops: \($0.localizedDescription)")
                        }
                        
                        imageSaver.writeToPhotoAlbum(image: proccesedImage)
                    }
                }
                .padding([.horizontal, .bottom])
                .navigationTitle("Instafilter")
                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                    ImagePicker(image: self.$inputImage)
                }
                .actionSheet(isPresented: $showingFilterSheet) {
                    ActionSheet(title: Text("Select a filter"), buttons:
                        filters.map { name in
                            .default(Text(name)) {
                                filterButtonText = name
                                if name == "Crystallize" { self.setFiler(CIFilter.crystallize()) }
                                if name == "Edges" { self.setFiler(CIFilter.edges()) }
                                if name == "Gaussian Blur" { self.setFiler(CIFilter.gaussianBlur()) }
                                if name == "Pixellate" { self.setFiler(CIFilter.pixellate()) }
                                if name == "Sepia Tone" { self.setFiler(CIFilter.sepiaTone()) }
                                if name == "Unsharp Mask" { self.setFiler(CIFilter.unsharpMask()) }
                                if name == "Vignette" { self.setFiler(CIFilter.vignette()) }
                            }
                        } + [Alert.Button.cancel()]
                    )
                }
                .alert(isPresented: $showingError) {
                    Alert(title: Text("Error‼️"), message: Text("You must select an image"), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterRadius, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterScale, forKey: kCIInputScaleKey) }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            proccesedImage = uiImage
        }
    }
    
    func setFiler(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
