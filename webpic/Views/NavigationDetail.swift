//
//  NavigationDetail.swift
//  webpic
//
//  Created by James Little on 3/1/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import SwiftUI

struct NavigationDetail: View {
    var model: JILImage
    var body: some View {
        VStack {
            Button(action: {}) {
                CTAButton(text: model.state == .uploaded ? "Process Again" : "Process")
            }.buttonStyle(PlainButtonStyle())
            
            HStack(alignment: .top, spacing: 18) {
                ImagePreview(image: Image("sample"))
                ImageOptions(model: model)
                Spacer()
                
            }
            
            Spacer()
            
            if(model.state == .uploaded) {
                PostUploadInfo(model: model)
            }
            
            if(model.state == .uploading) {
                ProgressBar(progress: 0.38)
            }
        }.padding().frame(minWidth: 400, minHeight: 400)
    }
}

struct NavigationDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationDetail(model: JILImage(name: "asdf.jpg", height: 250, width: 400, state: .uploaded))
    }
}

struct ImageOptions: View {
    @State private var outputFilename = "output.jpg"
    @State private var showGreeting = true
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
            Text("~/Images/something.jpg").font(.caption).foregroundColor(.secondary)
            Spacer().frame(height: 18.0)
            
            Group {
                Toggle(isOn: $showGreeting) {
                    Text("Convert to WebP")
                }
                Toggle(isOn: $showGreeting) {
                    Text("Convert to Progressive JPEG")
                }
                Toggle(isOn: $showGreeting) {
                    Text("Upload to Server")
                }
                Toggle(isOn: $showGreeting) {
                    Text("Save to Disk")
                }
                Spacer().frame(height: 36.0)
                HStack {
                    Text("Output Filename")
                    TextField("asdf", text: $outputFilename)
                }
                
                HStack {
                    Text("Output Size")
                    TextField("asdf", text: $outputFilename)
                    Text("x")
                    TextField("asdf", text: $outputFilename)
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
            .frame(maxWidth: 300, maxHeight: 300, alignment: .top)
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
