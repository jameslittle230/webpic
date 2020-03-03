//
//  NavigationRow.swift
//  webpic
//
//  Created by James Little on 3/1/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import SwiftUI

struct NavigationRow: View {
    var model: JILImage
    var progressBarVisible: Bool {
        return model.state == .uploading
    }
    
    var body: some View {
        HStack {
            Image(nsImage: model.thumbnail!)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipped()
            
            VStack(alignment: .leading, spacing: progressBarVisible ? 3.0 : 0.0) {
                HStack() {
                    Text(model.name).font(.callout).bold()
                    model.state == .uploaded ? Checkmark(font: .callout) : nil
                    Spacer()
                }
                .padding(0.0)
                
                Group {
                    if(progressBarVisible) {
                        ProgressBar(progress: 0.28, height: 6)
                    } else {
                        Text("\(model.width) x \(model.height) • \(model.filesize.formatBytes())").font(.caption).foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }.padding(.vertical, 8.0)
        }
    }
}

struct NavigationRow_Previews: PreviewProvider {
    static var previews: some View {
        let images = [
            JILImage(name: "asdf.jpg", height: 200, width: 300, state: .uploaded),
            JILImage(name: "asdf2.jpg", height: 200, width: 300, state: .unuploaded),
            JILImage(name: "asdf3.jpg", height: 200, width: 300, state: .uploading),
            JILImage(name: "asdf4.jpg", height: 200, width: 300, state: .unuploaded),
            JILImage(name: "asdf5.jpg", height: 200, width: 300, state: .unuploaded)
        ]

        return Group {
            NavigationRow(model: images[0]).previewLayout(.fixed(width: 300, height: 40))
            NavigationRow(model: images[1]).previewLayout(.fixed(width: 300, height: 40))
            NavigationRow(model: images[2]).previewLayout(.fixed(width: 300, height: 40))
        }
    }
}
