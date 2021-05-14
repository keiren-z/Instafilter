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
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var showingFilterSheet = false
    @State private var proccesedImage: UIImage?
    
    let context = CIContext()
    
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
                
                HStack {
                    Text("Intensity")
                    Slider(value: intensity)
                }.padding(.vertical)
                
                HStack {
                    Button("Chanage Filter") {
                        self.showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        guard let proccesedImage = self.proccesedImage else { return }
                        
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
                    // various Core Image filters
                    ActionSheet(title: Text("Select a filter"), buttons: [
                        .default(Text("Crystallize")) { self.setFiler(CIFilter.crystallize()) },
                        .default(Text("Edges")) { self.setFiler(CIFilter.edges()) },
                        .default(Text("Gaussian Blur")) { self.setFiler(CIFilter.gaussianBlur()) },
                        .default(Text("Pixellate")) { self.setFiler(CIFilter.pixellate()) },
                        .default(Text("Sepia Tone")) { self.setFiler(CIFilter.sepiaTone()) },
                        .default(Text("Unsharp Mask")) { self.setFiler(CIFilter.unsharpMask()) },
                        .default(Text("Vignette")) { self.setFiler(CIFilter.vignette()) },
                    ])
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
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }
        
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
