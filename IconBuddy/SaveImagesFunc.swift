//
//  SaveImagesFunc.swift
//  IconBuddy
//
//  Created by Luke Drushell on 2/9/23.
//

import Foundation
import Cocoa
import Zip

func saveResizedImages(for originalImage: NSImage, targetSizes: [Int?], transparency: Bool) {
    // show save panel for folder selection
    let panel = NSSavePanel()
    panel.nameFieldStringValue = "IconSet"
    panel.allowedContentTypes = [.zip]
    panel.begin { result in
        if result == .OK, let url = panel.url {
            // save images to selected folder
            do {
                // create a temporary directory for resized images
                let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                let tempDirectoryURL = tempDirectory.appendingPathComponent("IconSet", isDirectory: true)
                try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true, attributes: nil)

                // save resized images to the temporary directory
                for (_, size) in targetSizes.enumerated() {
                    if size != nil {
                        let fileName = "\(size!).png"
                        let fileURL = tempDirectoryURL.appendingPathComponent(fileName)
                        
                        let resizedImage = NSImage(size: NSSize(width: size!, height: size!), flipped: false) { rect in
                            originalImage.draw(in: rect)
                            return true
                        }
                        
                        let imageRepresentation = resizedImage.tiffRepresentation!
                        let imageSource = CGImageSourceCreateWithData(imageRepresentation as CFData, nil)!
                        let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)! as Dictionary
                        let imageType = CGImageSourceGetType(imageSource)!
                        
                        let newImageProperties = NSMutableDictionary(dictionary: imageProperties)
                        newImageProperties[kCGImagePropertyColorModel] = "RGB"
                        newImageProperties[kCGImagePropertyDepth] = 8
                        newImageProperties[kCGImagePropertyHasAlpha] = transparency
                        
                        let newImageData = NSMutableData()
                        let destination = CGImageDestinationCreateWithData(newImageData as CFMutableData, imageType, 1, nil)!
                        CGImageDestinationAddImageFromSource(destination, imageSource, 0, newImageProperties as CFDictionary)
                        CGImageDestinationFinalize(destination)
                        
                        guard let pngData = NSBitmapImageRep(data: newImageData as Data)?.representation(using: .png, properties: [:]) else { continue }
                        try pngData.write(to: fileURL)
                    }
                }

                // zip the temporary directory
                let archiveURL = url
                print("Saving to URL: \(archiveURL)")
                do {
                    try Zip.zipFiles(paths: [tempDirectoryURL], zipFilePath: archiveURL, password: nil, progress: nil)
                    print("Zipped folder saved successfully")
                } catch {
                    print("Error: \(error.localizedDescription)")
                }

                // remove the temporary directory
                try FileManager.default.removeItem(at: tempDirectoryURL)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
