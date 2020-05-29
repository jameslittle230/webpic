//
//  SidebarDropDelegate.swift
//  Webpic
//
//  Created by James Little on 5/28/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import SwiftUI

struct SidebarDropDelegate: DropDelegate {
    @ObservedObject var imageManager: ImageManager
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
        
        var numberOfAddedImages = 0
        let droppedItems = info.itemProviders(for: allowedUTIs)
        for item in droppedItems {
            item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                guard let urlData = urlData as? Data else {
                    fatalError(error?.localizedDescription ?? "No urlData, but no error either!")
                }
                
                let url = NSURL(dataRepresentation: urlData, relativeTo: nil)
                numberOfAddedImages += self.imageManager.addFromUrl(url)
            }
        }
        
        return numberOfAddedImages > 0
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        self.active = true
        return nil
    }
    
    func dropExited(info: DropInfo) {
        self.active = false
    }
}
