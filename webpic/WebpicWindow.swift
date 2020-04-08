//
//  WebpicWindow.swift
//  Webpic
//
//  Created by James Little on 4/7/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import AppKit

class WebpicWindow: NSWindow {
    let imageManager: ImageManager
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        imageManager = ImageManager()
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
    }
}
