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
    let pipe = Pipe()
    
    @ObservedObject var model: JILImage
    @ObservedObject var webPProgressDelegate: WebPProgressDelegate = WebPProgressDelegate()
    
    var body: some View {
        VStack {
            Button(action: {
                self.model.state = .uploading
                
                _ = WebPProcess(
                    input: self.model.url.filePathURL!,
                    output: URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("out.webp"),
                    progressDelegate: Optional.some(self.webPProgressDelegate)
                    )?.run() {
                        print("cwebp done")
                        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                            self.model.state = .uploaded
                        }
                }
                
//                _ = JPEGTranProcess(
//                    input: self.model.url.filePathURL!,
//                    output: URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("out.jpeg"),
//                    progressDelegate: nil
//                    )?.run() {
//                        print("JPEGTran Done")
//                }
            }) {
                CTAButton(text: model.state == .uploaded ? "Process Again" : "Process")
            }.buttonStyle(PlainButtonStyle())
            
            GeometryReader { geometry in
                
                HStack(alignment: .top, spacing: 18) {
                    ImagePreview(image: Image(nsImage: NSImage(contentsOf: self.model.url as URL)!))
                    ImageOptions(model: self.model).frame(width: 300)
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

struct ImageOptions: View {
    
    //    init(model: JILImage) {
    //        print("asdf")
    //        self.model = model
    //        self.outputFilename = model.name
    //        self.outputWidth = "\(model.width)"
    //        self.outputHeight = "\(model.height)"
    //    }
    
    enum LastEditedImageDimension {
        case none
        case width
        case height
    }
    
    @State private var lastEditedImageDimension = LastEditedImageDimension.none
    @State private var outputFilename = ""
    @State private var outputWidth = ""
    @State private var outputHeight = ""
    @State private var convertToWebP = true
    @State private var convertToPJpeg = true
    @State private var uploadToServer = true
    @State private var saveToDisk = true
    
    var model: JILImage
    
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
                Toggle(isOn: $convertToWebP) {
                    Text("Convert to WebP")
                }
                Toggle(isOn: $convertToPJpeg) {
                    Text("Convert to Progressive JPEG")
                }
                Toggle(isOn: $uploadToServer) {
                    Text("Upload to Server")
                }
                Toggle(isOn: $saveToDisk) {
                    Text("Save to Disk")
                }
                Spacer().frame(height: 36.0)
                HStack {
                    Text("Output Filename")
                    TextField("asdf", text: $outputFilename)
                }
                
                HStack {
                    Text("Output Size")
                    TextField("asdf", text: $outputWidth)
                        .border(Color.accentColor, width: lastEditedImageDimension == .width ? 1 : 0)
                        .focusable(true) { focusApplied in
                            print(95, focusApplied)
                            if focusApplied {
                                self.lastEditedImageDimension = .width
                            }
                    }
                    Text("x")
                    TextField("asdf", text: $outputHeight)
                        .border(Color.accentColor, width: lastEditedImageDimension == .height ? 1 : 4)
                        .focusable(true) { focusApplied in
                            print(103, focusApplied)
                            if focusApplied {
                                self.lastEditedImageDimension = .height
                            }
                    }
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
