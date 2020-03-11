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
        let sidebarDropDelegate = SidebarDropDelegate(
            images: $images,
            active: $dropActive,
            selectedView: $selectedView
        )
        
        let detailDropDelegate = SidebarDropDelegate(
            images: $images,
            active: $dropActive,
            selectedView: $selectedView
        )
        
        return NavigationView() {
            VStack {
                List(images) { image in
                    NavigationLink(destination: NavigationDetail(model: image).onDrop(of: detailDropDelegate.allowedUTIs, delegate: detailDropDelegate),
                                   tag: image.name,
                                   selection: self.$selectedView) {
                        NavigationRow(model: image)
                    }
                }.listStyle(SidebarListStyle()).frame(minWidth: 320)
                Spacer()
                PostListActions()
            }
                .onDrop(of: sidebarDropDelegate.allowedUTIs, delegate: sidebarDropDelegate)
                .background(self.dropActive ? DropGradientBackground() : nil)
            WelcomeView().onDrop(of: detailDropDelegate.allowedUTIs, delegate: detailDropDelegate)
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
                Text("Clear Completed")
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
            VStack(spacing: 24.0) {
                Text("Welcome to Webpic.").font(.largeTitle).bold()
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
    @Binding var selectedView: String?
    
    let allowedUTIs = ["public.image", "public.file-url", "public.directory"]
    
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: allowedUTIs)
    }
    
    func dropEntered(info: DropInfo) {
        self.active = true
    }
    
    func performDrop(info: DropInfo) -> Bool {
        
        self.active = true
        
        if let item = info.itemProviders(for: allowedUTIs).first {
            item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                DispatchQueue.main.async {
                    guard let urlData = urlData as? Data else {
                        print(error!)
                        return
                    }
                    
                    let url = NSURL(dataRepresentation: urlData, relativeTo: nil)
                    guard let image = JILImage(fromUrl: url) else {
                        print("Can't generate JILImage from file URL")
                        return
                    }
                    
                    self.images.append(image)
                }
            }
            
            return true
            
        } else {
            print("Invalid UTI")
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

struct DropGradientBackground: View {
    var body: some View {
        GeometryReader { geometry in
            RadialGradient(
                gradient: Gradient(colors: [Color.accentColor.opacity(0.8), Color.accentColor.opacity(0.1)]),
                center: UnitPoint(x: 0.5, y: 0.5),
                startRadius: 1,
                endRadius: max(geometry.size.width, geometry.size.height))
        }
    }
}
