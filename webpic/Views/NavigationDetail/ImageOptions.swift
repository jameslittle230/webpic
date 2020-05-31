//
//  ImageOptions.swift
//  Webpic
//
//  Created by James Little on 5/28/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import SwiftUI

struct ImageOptions: View {
    @ObservedObject var model: JILImage
    @ObservedObject var viewModel: ImageOptionsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(model.name).font(.title).bold()
                if model.state == .processed {
                    Checkmark()
                }
                Spacer()
            }
            
            Text("\(model.width) x \(model.height) • \(model.filesize.formatBytes())").font(.caption).foregroundColor(.secondary)
            Text(self.model.url.path!.replacingOccurrences(of: "/Users/\(NSUserName())", with: "~")).font(.caption).foregroundColor(.secondary)
            Spacer().frame(height: 18.0)
            
            Group {
                Toggle(isOn: $viewModel.convertToWebP) {
                    Text("Convert to WebP")
                }
                Toggle(isOn: $viewModel.convertToPJpeg) {
                    Text("Convert to Progressive JPEG")
                }
                Toggle(isOn: $viewModel.saveToDisk) {
                    Text("Strip EXIF data")
                }
                Toggle(isOn: $viewModel.uploadToServer) {
                    Text("Upload to Server")
                }
                Toggle(isOn: $viewModel.saveToDisk) {
                    Text("Save to Disk")
                }
                Spacer().frame(height: 36.0)
                HStack {
                    Text("Output Filename")
                    TextField("asdf", text: $viewModel.outputFilename)
                }
                
                HStack {
                    Text("Output Size")
                    TextField(viewModel.outputWidth, text: $viewModel.outputWidth)
                        .focusable(true)
                        .border(Color.accentColor, width: viewModel.lastEditedImageDimension == .width ? 1 : 0)
                    Text("×")
                    TextField(viewModel.outputHeight, text: $viewModel.outputHeight)
                        .border(Color.accentColor, width: viewModel.lastEditedImageDimension == .height ? 1 : 0)
                        .focusable(true)
                }
            }
        }
    }
}

class ImageOptionsViewModel: ObservableObject {
    let model: JILImage
    
    init(model: JILImage) {
        self.model = model
        self.tempWidth = model.width
        self.tempHeight = model.height
        
        var fileNameComponents = model.name.split(separator: ".")
        _ = fileNameComponents.popLast()
        outputFilename = fileNameComponents.joined(separator: ".")
    }
    
    enum LastEditedImageDimension {
        case none
        case width
        case height
    }
    
    var tempWidth: Int
    var tempHeight: Int
    
    var outputWidth: String {
        get {
            return String(tempWidth)
        }
        
        set {
            lastEditedImageDimension = .width
            tempWidth = Int(newValue) ?? 0
            tempHeight = Int(Double(tempWidth) / model.aspectRatio)
        }
    }
    
    var outputHeight: String {
        get {
            return String(tempHeight)
        }
        
        set {
            lastEditedImageDimension = .height
            tempHeight = Int(newValue) ?? 0
            tempWidth = Int(Double(tempHeight) * model.aspectRatio)
        }
    }
    
    @Published var lastEditedImageDimension = LastEditedImageDimension.none
    @Published var outputFilename = ""
    @Published var convertToWebP = true
    @Published var convertToPJpeg = true
    @Published var uploadToServer = false
    @Published var saveToDisk = true
}

struct ImageOptions_Previews: PreviewProvider {
    static var previews: some View {
        Text("Coming soon I guess")
    }
}
