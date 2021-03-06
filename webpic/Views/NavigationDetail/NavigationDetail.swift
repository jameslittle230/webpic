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
    @ObservedObject var optionsViewModel: ImageOptions

    var progressBar: ProgressBar? {
        if case let .processing(progress) = model.state {
            return ProgressBar(progress: .constant(progress))
        } else {
            return nil
        }
    }

    var ctaButton: CTAButton {
        switch model.state {
        case .unprocessed:
            return CTAButton(text: "Process")
        case .processing(_):
            return CTAButton(text: "Processing", disabled: true)
        case .processed:
            return CTAButton(text: "Process Again")
        }
    }

    var preview: Image {
        if let modelPreview = model.preview {
            return Image(nsImage: modelPreview)
        }

        return Image("sample")
    }
    
    var body: some View {
        VStack {
            Button(action: {
                if case .processing(_) = self.model.state {
                    return
                }
                
                if let cancellable = self.model.process(withOptions: self.optionsViewModel) {
                    self.imageManager.cancellables.append(cancellable)
                }
            }) {
                ctaButton
            }.buttonStyle(PlainButtonStyle())
            
            GeometryReader { geometry in
                HStack(alignment: .top, spacing: 18) {
                    ImagePreview(image: preview)
                    ImageOptionsEditor(model: self.model, viewModel: self.optionsViewModel).frame(width: 300)
                }
            }
            
            Spacer()
            
            if model.state == .processed {
                PostUploadInfo(model: model)
            }

            progressBar

        }.padding(18.0).frame(minWidth: 400, minHeight: 400)
    }
}

struct NavigationDetail_Previews: PreviewProvider {
    static var previews: some View {
        let model = JILImage.generate()
        return NavigationDetail(model: model, optionsViewModel: ImageOptions(model: model))
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
