//
//  JILImage.swift
//  webpic
//
//  Created by James Little on 3/1/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import Foundation
import AppKit

final class JILImage: Identifiable, ObservableObject {
    var id: String {
        return self.name
    }
    
    enum JILImageState: CaseIterable {
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
    
    @Published var state: JILImageState
    
    var aspectRatio: Double {
        return Double(width) / Double(height)
    }
    
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
        
        self.thumbnail = image.generateThumbnail(contentMode: .aspectFill, width: 50)
        
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

protocol FakeData {
    static func generate() -> Self
}
    

extension JILImage: FakeData {
    static func generate() -> JILImage {
        return JILImage(name: "asdf.jpg", height: 250, width: 380, state: JILImageState.allCases.randomElement()!)
    }
    
    
}
