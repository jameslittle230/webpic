//
//  ImageManager.swift
//  Webpic
//
//  Created by James Little on 4/7/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import Foundation

class ImageManager: ObservableObject {
    @Published var images: [JILImage] = []
    
    func addFromUrl(_ url: NSURL) -> Int {
        guard let path = url.path else {
            return 0
        }
        
        var imagesAdded = 0
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            if let type = attributes[FileAttributeKey.type] as? FileAttributeType {
                let isDirectory = type == FileAttributeType.typeDirectory
                
                if(isDirectory) {
                    if let enumerator = FileManager.default.enumerator(atPath: path) {
                        for element in enumerator {
                            if let pathString = element as? String {
                                let url = NSURL(fileURLWithPath: pathString, relativeTo: url as URL)
                                imagesAdded += self.addFromUrl(url)
                            }
                        }
                    }
                } else if let image = JILImage(fromUrl: url) {
                    images.append(image)
                    imagesAdded += 1
                }
            }
        } catch {}
        
        return 0
    }
    
    func clearCompletedImages() {
        
    }
    
    func bulkProcess() {
        
    }
}
