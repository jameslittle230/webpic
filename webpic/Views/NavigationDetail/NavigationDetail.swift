//
//  NavigationDetail.swift
//  webpic
//
//  Created by James Little on 3/1/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import SwiftUI
import Combine

struct NavigationDetail: View {
    @EnvironmentObject var imageManager: ImageManager
    @ObservedObject var model: JILImage
    @ObservedObject var optionsViewModel: ImageOptionsViewModel
    
    @State var uploadProgress = -1.0
    
    var body: some View {
        VStack {
            Button(action: {
                let size = CGSize(
                    width: self.optionsViewModel.tempWidth,
                    height: self.optionsViewModel.tempHeight
                )
                
                if let cancellable = self.model.process(
                    name: self.optionsViewModel.outputFilename,
                    size: size
                ) {
                    self.imageManager.cancellables.append(cancellable)
                }
            }) {
                CTAButton(text: model.state == .processed ? "Process Again" : "Process")
            }.buttonStyle(PlainButtonStyle())
            
            GeometryReader { geometry in
                HStack(alignment: .top, spacing: 18) {
                    ImagePreview(image: Image(nsImage: NSImage(contentsOf: self.model.url as URL)!))
                    ImageOptions(model: self.model, viewModel: self.optionsViewModel).frame(width: 300)
                }
            }
            
            Spacer()
            
            if model.state == .processed {
                PostUploadInfo(model: model)
            }
            
            if uploadProgress != -1.0 {
                ProgressBar(progress: .constant(0.5))
            }
        }.padding(18.0).frame(minWidth: 400, minHeight: 400)
    }
}

struct NavigationDetail_Previews: PreviewProvider {
    static var previews: some View {
        let model = JILImage.generate()
        return NavigationDetail(model: model, optionsViewModel: ImageOptionsViewModel(model: model))
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
