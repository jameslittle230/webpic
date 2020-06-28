//
//  ContentView.swift
//  webpic
//
//  Created by James Little on 3/1/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import SwiftUI

struct Main: View {
    @EnvironmentObject var imageManager: ImageManager
    @State var dropActive: Bool = false
    @State var selectedView: String? = nil
    
    
    var body: some View {
        let sidebarDropDelegate = SidebarDropDelegate(
            imageManager: imageManager,
            active: $dropActive,
            selectedView: $selectedView
        )
        
        let detailDropDelegate = SidebarDropDelegate(
            imageManager: imageManager,
            active: $dropActive,
            selectedView: $selectedView
        )
        
        return NavigationView() {
            VStack {
                List(imageManager
                    .images) { image in
                        NavigationLink(destination: NavigationDetail(model: image, optionsViewModel: ImageOptions(model: image))
                            .environmentObject(self.imageManager)
                            .onDrop(
                                of: detailDropDelegate.allowedUTIs,
                                delegate: detailDropDelegate),
                                       tag: image.name,
                                       selection: self.$selectedView) {
                                        NavigationRow(model: image)
                        }
                }.listStyle(SidebarListStyle()).frame(minWidth: 320)
                Spacer()
                ListActions().environmentObject(imageManager)
            }
                .onDrop(of: sidebarDropDelegate.allowedUTIs, delegate: sidebarDropDelegate)
                .background(self.dropActive ? DropGradientBackground() : nil)
            .popover(isPresented: .constant(false)) {
                Text("this should never happen")
            }
            WelcomeView()
            .environmentObject(imageManager)
            .onDrop(of: detailDropDelegate.allowedUTIs, delegate: detailDropDelegate)
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
            .onAppear() {
                 
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let images = [
            JILImage(name: "asdf.jpg", height: 200, width: 300, state: .processed),
            JILImage(name: "asdf2.jpg", height: 200, width: 300, state: .unprocessed),
            JILImage(name: "asdf3.jpg", height: 200, width: 300, state: .processing(0.28)),
            JILImage(name: "asdf4.jpg", height: 200, width: 300, state: .unprocessed),
            JILImage(name: "asdf5.jpg", height: 200, width: 300, state: .unprocessed)
        ]
        
        let imageManager = ImageManager()
        imageManager.images = images
        
        return Group {
            Main()
            .environmentObject(imageManager)
            .previewLayout(.fixed(width: 800, height: 600))
        }
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
