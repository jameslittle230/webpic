//
//  ContentView.swift
//  webpic
//
//  Created by James Little on 3/1/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var images: [JILImage] = []
    @State var dropActive: Bool = false
    @State var selectedView: String? = nil
    
    
    var body: some View {
        let sidebarDropDelegate = SidebarDropDelegate(images: $images, active: $dropActive)
        return NavigationView() {
            VStack {
                List(images) { image in
                    NavigationLink(destination: NavigationDetail(model: image),
                                   tag: image.name,
                                   selection: self.$selectedView) {
                        NavigationRow(model: image)
                    }
                }.listStyle(SidebarListStyle()).frame(minWidth: 220)
                Spacer()
                PostListActions()
            }.onDrop(of: ["public.file-url"], delegate: sidebarDropDelegate)
                .background(dropActive ? Color.blue : nil)
            WelcomeView()
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
            .onAppear() {
                 
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let images = [
            JILImage(name: "asdf.jpg", height: 200, width: 300, state: .uploaded),
            JILImage(name: "asdf2.jpg", height: 200, width: 300, state: .unuploaded),
            JILImage(name: "asdf3.jpg", height: 200, width: 300, state: .uploading),
            JILImage(name: "asdf4.jpg", height: 200, width: 300, state: .unuploaded),
            JILImage(name: "asdf5.jpg", height: 200, width: 300, state: .unuploaded)
        ]
        
        return Group {
            ContentView(images: images).previewLayout(.fixed(width: 800, height: 600))
        }
    }
}

struct PostListActions: View {
    var body: some View {
        HStack {
            Button(action: {}) {
                Text("Clear")
            }
            Button(action: {}) {
                Text("Bulk Process")
            }
            
            HelpButton(action: {})
        }.padding(.bottom)
    }
}

struct HelpButton: View, NSViewRepresentable {
    let action: () -> ()
    typealias NSViewType = NSButton
    
    func makeNSView(context: NSViewRepresentableContext<HelpButton>) -> NSButton {
        let b = NSButton(title: "", target: nil, action: nil)
        b.bezelStyle = .helpButton
        return b
    }
    
    func updateNSView(_ nsView: NSButton, context: NSViewRepresentableContext<HelpButton>) {
        return
    }
}

struct WelcomeView: View {
    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 24.0) {
                Text("Welcome to Webpic.").font(.largeTitle).bold()
                Text("Automatically convert images to WebP and Progressive JPEGs. Upload them to your server. Get the HTML to properly display them.")
                    .font(.subheadline)
                Text("Drag and drop an image here to get started.")
                    .font(.subheadline)
            }.frame(width: 330)
        }.frame(minWidth: 600, maxWidth: 10000, minHeight: 500, maxHeight: 10000)
    }
}

struct SidebarDropDelegate: DropDelegate {
    @Binding var images: [JILImage]
    @Binding var active: Bool
    
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: ["public.file-url"])
    }
    
    func dropEntered(info: DropInfo) {
        self.active = true
    }
    
    func performDrop(info: DropInfo) -> Bool {
        
        self.active = true
        
        if let item = info.itemProviders(for: ["public.file-url"]).first {
            item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                DispatchQueue.main.async {
                    guard let urlData = urlData as? Data else {
                        print(error)
                        return
                    }
                    
                    let url = NSURL(dataRepresentation: urlData, relativeTo: nil)
                    guard let image = JILImage(fromUrl: url) else {
                        print("Internal error")
                        return
                    }
                    
                    self.images.append(image)
                }
            }
            
            return true
            
        } else {
            return false
        }

    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        self.active = true
                    
        return nil
    }
    
    func dropExited(info: DropInfo) {
        self.active = false
    }
}
