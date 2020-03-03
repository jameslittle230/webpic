//
//  JILImage.swift
//  webpic
//
//  Created by James Little on 3/1/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import Foundation
import AppKit

struct JILImage: Identifiable {
    var id: String {
        return self.name
    }
    
    enum JILImageState {
        case unuploaded
        case uploaded
        case uploading
    }
    
    let name: String
    let url: NSURL
    let height: Int
    let width: Int
    let filesize: UInt64
    var thumbnail: NSImage? = nil
    let state: JILImageState
    
    init(name: String, height: Int, width: Int, state: JILImageState) {
        self.name = name
        self.height = height
        self.width = width
        self.state = state
        self.url = NSURL()
        self.filesize = 2400000
    }
    
    init?(fromUrl url: NSURL) {
        self.url = url
        self.name = url.lastPathComponent!
        self.state = .unuploaded
        
        guard let image = NSImage(contentsOf: url as URL) else {
            return nil
        }
        
        self.thumbnail = NSImage(size: NSSize(width: 50, height: 50))
        let originalSize = image.size
        let fromRect = NSRect(x: 0, y: 0, width: originalSize.width, height: originalSize.height)
        self.thumbnail?.lockFocus()
        image.draw(in: NSRect(x: 0, y: 0, width: 50, height: 50), from: fromRect, operation: .copy, fraction: 1.0)
        self.thumbnail?.unlockFocus()
        
        self.height = Int(image.size.height)
        self.width = Int(image.size.width)
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path!)
            self.filesize = attr[FileAttributeKey.size] as! UInt64
        } catch {
            self.filesize = 0
        }
    }
}
