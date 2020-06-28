//
//  NavigationRow.swift
//  webpic
//
//  Created by James Little on 3/1/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import SwiftUI

struct NavigationRow: View {
    @ObservedObject var model: JILImage
    
    var progressBarVisible: Bool {
        return model.state == .processing(0)
    }

    var thumbnail: Image {
        if let thumbnail = self.model.thumbnail {
            return Image(nsImage: thumbnail)
        } else {
            if #available(OSX 10.16, *) {
                return Image(systemName: "")
            } else {
                return Image("sample")
            }
        }
    }
    
    var body: some View {
        HStack {
            thumbnail.resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipped()

            VStack(alignment: .leading, spacing: progressBarVisible ? 3.0 : 0.0) {
                HStack() {
                    Text(model.name).font(.callout).bold()
                    model.state == .processed ? Checkmark(font: .callout) : nil
                    Spacer()
                }
                .padding(0.0)
                
                Group {
                    if(progressBarVisible) {
                        ProgressBar(progress: .constant(0.5), height: 6)
                    } else {
                        Text("\(model.width) × \(model.height) • \(model.filesize.formatBytes())")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
            JILImage(name: "asdf.jpg", height: 200, width: 300, state: .processed),
            JILImage(name: "asdf2.jpg", height: 200, width: 300, state: .unprocessed),
            JILImage(name: "asdf3.jpg", height: 200, width: 300, state: .processing(0.28)),
            JILImage(name: "asdf4.jpg", height: 200, width: 300, state: .unprocessed),
            JILImage(name: "asdf5.jpg", height: 200, width: 300, state: .unprocessed)
        ]

        return Group {
            NavigationRow(model: images[0]).previewLayout(.fixed(width: 300, height: 40))
            NavigationRow(model: images[1]).previewLayout(.fixed(width: 300, height: 40))
            NavigationRow(model: images[2]).previewLayout(.fixed(width: 300, height: 40))
        }
    }
}
