//
//  NSImage+GenerateThumbnail.swift
//  webpic
//
//  Created by James Little on 3/7/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import AppKit

extension NSImage {
    enum ImageContentMode {
        case aspectFit
        case aspectFill
    }
    
    func generateThumbnail(contentMode: ImageContentMode, width: CGFloat, height: CGFloat? = nil) -> NSImage {
        let height = height ?? width
        
        let thumbnail = NSImage(size: NSSize(width: width, height: height))
        
        let fromRect: NSRect = {
            let minDimension = min(self.size.width, self.size.height)
            let maxDimension = max(self.size.width, self.size.height)
            
            let maxMinusMinOverTwo = (maxDimension - minDimension) / 2
            let portraitOrientation = height > width
            
            switch contentMode {
            case .aspectFill:
                switch portraitOrientation {
                case true:
                    return NSRect(x: 0, y: maxMinusMinOverTwo, width: minDimension, height: minDimension)
                case false:
                    return NSRect(x: maxMinusMinOverTwo, y: 0, width: minDimension, height: minDimension)
                }
            case .aspectFit:
                return NSRect(x: 0, y: maxMinusMinOverTwo, width: minDimension, height: minDimension)
            }
        }()
        
        thumbnail.lockFocus()
        self.draw(in: NSRect(x: 0, y: 0, width: width, height: height), from: fromRect, operation: .copy, fraction: 1.0)
        thumbnail.unlockFocus()
        
        return thumbnail
    }
}
