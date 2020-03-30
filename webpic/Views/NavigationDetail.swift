//
//  NavigationDetail.swift
//  webpic
//
//  Created by James Little on 3/1/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import SwiftUI

class WebPProgressDelegate: ProgressDelegate, ObservableObject {
    @Published var progress: Double = 0.0
    
    func notifyWithProgress(_ progress: Double) {
        self.progress = progress
    }
    
    func complete() {
        self.progress = 1.0
    }
}

struct NavigationDetail: View {
    @ObservedObject var model: JILImage
    @ObservedObject var webPProgressDelegate: WebPProgressDelegate = WebPProgressDelegate()
    
    var body: some View {
        VStack {
            Button(action: {
                self.model.state = .uploading
                
                _ = WebPProcess(
                    input: self.model.url.filePathURL!,
                    output: URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("out2.webp"),
                    progressDelegate: Optional.some(self.webPProgressDelegate)
                    )?.run() {
                        print("cwebp done")
                        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                            self.model.state = .uploaded
                        }
                }
                
                _ = JPEGTranProcess(
                    input: self.model.url.filePathURL!,
                    output: URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("out2.jpeg"),
                    progressDelegate: nil
                    )?.run() {
                        print("JPEGTran Done")
                }
            }) {
                CTAButton(text: model.state == .uploaded ? "Process Again" : "Process")
            }.buttonStyle(PlainButtonStyle())
            
            GeometryReader { geometry in
                
                HStack(alignment: .top, spacing: 18) {
                    ImagePreview(image: Image(nsImage: NSImage(contentsOf: self.model.url as URL)!))
                    ImageOptions(model: self.model, viewModel: ImageOptionsViewModel(model: self.model)).frame(width: 300)
                }
            }
            
            Spacer()
            
            if(model.state == .uploaded) {
                PostUploadInfo(model: model)
            }
            
            if(model.state == .uploading) {
                ProgressBar(progress: webPProgressDelegate.progress)
            }
        }.padding(18.0).frame(minWidth: 400, minHeight: 400)
    }
}

struct NavigationDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationDetail(model: JILImage.generate())
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

struct ImageOptions: View {
    @ObservedObject var model: JILImage
    @ObservedObject var viewModel: ImageOptionsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(model.name).font(.title).bold()
                if model.state == .uploaded {
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

struct ImagePreview: View {
    var image: Image
    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 1000, maxHeight: 1000, alignment: .top)
    }
}

struct PostUploadInfo: View {
    var model: JILImage
    var body: some View {
        HStack {
            Text("https://files.jameslittle.me/blah/somethingelse.jpg")
                .font(.system(.caption, design: .monospaced))
            Spacer()
            Button(action: {}) {
                Text("Copy URL").font(.caption)
            }
            
            Button(action: {}) {
                Text("Copy HTML").font(.caption)
            }
        }
    }
}

struct Checkmark: View {
    var font = Font.title
    var body: some View {
        Text("✓").font(font).bold().foregroundColor(Color.green)
    }
}
