//
//  ContentView.swift
//  IconBuddy
//
//  Created by Luke Drushell on 2/9/23.
//

import SwiftUI
import Zip

struct ContentView: View {
    @State private var sourceImage: NSImage?
    @State var targetSizes: [Int?] = [16, 32, 64, 128, 256, 512, 1024]
    
    @State private var transparency = false
    @State private var macFormat = false
    @State private var asIconSet = false
    
    
    @State private var contentType = "None"
    let contentTypes = ["None", "macOS", "iOS", "Both"]

    var body: some View {
        HStack {
            if sourceImage != nil {
                sourceImage!.displayImage()
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .cornerRadius(30)
                    .zIndex(-5)
            } else {
                Text("Please Select Image to Continue")
                    .padding()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 200)
                    .background(.gray)
                    .cornerRadius(30)
                    .zIndex(-5)
            }
            Divider()
                .padding(.horizontal)
            VStack(alignment: .leading) {
                HStack {
                    Toggle(isOn: $transparency, label: {
                        Text("Enable Transpareny")
                    })
                    Divider()
                        .frame(height: 30)
                    Toggle(isOn: $macFormat, label: {
                        Text("Generate for macOS")
                    })
                    Divider()
                        .frame(height: 30)
                    Picker("Contents.json", selection: $contentType, content: {
                        ForEach(contentTypes, id: \.self, content: { type in
                            Text(type)
                        })
                    }) .frame(width: 200)
                    Divider()
                        .frame(height: 30)
                    Toggle(isOn: $asIconSet, label: {
                        Text("Save as .appiconset")
                    })
                }
                HStack {
                    //icon size picker
                    ForEach(targetSizes.indices, id: \.self, content: { index in
                        TextField("ex: 16", value: $targetSizes[index], format: .number)
                            .onSubmit {
                                if targetSizes[index] == nil {
                                    withAnimation { targetSizes.remove(at: index) }
                                }
                            }
                    })
                    Button {
                        withAnimation { targetSizes.append(nil) }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                VStack {
                    Button {
                        // open file picker
                        let panel = NSOpenPanel()
                        panel.allowedContentTypes = [.image]
                        panel.begin { result in
                            if result == .OK, let url = panel.url {
                                withAnimation {
                                    self.sourceImage = NSImage(contentsOf: url)!
                                }
                            }
                        }
                    } label: {
                        Text("Select Icon")
                            .padding(10)
                            .foregroundColor(.white)
                            .frame(width: 150)
                            .background(Color.accentColor)
                            .cornerRadius(4)
                    } .buttonStyle(.plain)
                    Button {
                        if sourceImage != nil {
                            if macFormat {
                                let image = Image(nsImage: sourceImage!)
                                let renderer = ImageRenderer(content: MacIconView(image: image))
                                let newImage = renderer.nsImage
                                saveResizedImages(for: newImage!, targetSizes: targetSizes, transparency: transparency, contentType: contentType, asIconSet: asIconSet)
                            } else {
                                saveResizedImages(for: sourceImage!, targetSizes: targetSizes, transparency: transparency, contentType: contentType, asIconSet: asIconSet)
                            }
                        }
                    } label: {
                        Text("Save Iconset")
                            .foregroundColor(sourceImage != nil ? .white : .white.opacity(0.45))
                            .padding(10)
                            .frame(width: 150)
                            .background(sourceImage != nil ? Color.accentColor : Color.accentColor.opacity(0.85))
                            .cornerRadius(4)
                    } .buttonStyle(.plain)
                        .disabled(sourceImage == nil)
                } .padding(.top, 10)
            }.zIndex(25)
        }
        .padding()
    }
}

extension NSImage {
    func displayImage() -> Image {
        return Image(nsImage: self)
    }
    func resized(to: CGSize) -> NSImage? {
            let frame = NSRect(x: 0, y: 0, width: to.width, height: to.height)
            guard let representation = self.bestRepresentation(for: frame, context: nil, hints: nil) else {
                return nil
            }
            let image = NSImage(size: to, flipped: false, drawingHandler: { (_) -> Bool in
                return representation.draw(in: frame)
            })

            return image
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
