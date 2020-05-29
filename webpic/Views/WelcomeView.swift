//
//  WelcomeView.swift
//  webpic
//
//  Created by James Little on 4/7/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import SwiftUI

struct WelcomeButton: View {
    @State var hovered = false;
    
    var method: () -> Void
    var icon: Image?
    var text: String
    
    let gradient = Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.2)])
    
    var body: some View {
        Button(action: method) {
            HStack {
                icon
                Text(text).font(.callout)
            }.padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.primary.opacity(hovered ? 0.15 : 0.1))
                .background(LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom))
            .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.primary.opacity(0.2), lineWidth: 1.5)
                )
                .onHover { _ in
                    self.hovered.toggle()
            }
        }.buttonStyle(PlainButtonStyle())
    }
}

struct WelcomeView: View {
    @EnvironmentObject var imageManager: ImageManager
    @State var hovered = false;
    var body: some View {
        Group {
            VStack(spacing: 42.0) {
                Spacer()
                HStack {
                    Text("Welcome to Webpic.").font(.largeTitle).bold()
                        .font(.subheadline)
                    Spacer()
                }
                
                VStack(spacing: 7) {
                    WelcomeButton(method: runOpenPanel, icon: nil, text: "Open an Image or Folder")

                    Text("(Or drag and drop)").font(.footnote)
                }
                
                WelcomeButton(method: {}, icon: nil, text: "Configure an Upload Destination")
                Spacer()
                Text("Made by James Little in San Francisco, Calif. © 2020").font(.footnote)
            }.padding().frame(width: 380)
        }.frame(minWidth: 600, maxWidth: 10000, minHeight: 500, maxHeight: 10000)
    }
    
    func runOpenPanel() -> Void {
        let openPanel = NSOpenPanel()
        openPanel.message = "Open an image or directory"
        openPanel.prompt = "Open"
        openPanel.allowedFileTypes = ["png", "jpg", "jpeg"]
        openPanel.allowsMultipleSelection = true
        openPanel.allowsOtherFileTypes = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = true
        
        let _ = openPanel.runModal()
        for url in openPanel.urls {
            let imagesAddedCount = imageManager.addFromUrl(url as NSURL)
            print(imagesAddedCount)
        }
        print(openPanel.urls)
    }
}

struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WelcomeButton(method: {}, icon: nil, text: "Open an Image").padding().environment(\.colorScheme, .dark)
            WelcomeButton(method: {}, icon: nil, text: "Open an Image").padding().background(Color(NSColor.windowBackgroundColor)).environment(\.colorScheme, .light)
            WelcomeView()
        }
    }
}
