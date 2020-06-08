//
//  JILImage.swift
//  webpic
//
//  Created by James Little on 3/1/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import Foundation
import AppKit
import Combine

enum JILImageState {
    case unprocessed
    case processed
    case processing(Double)
}

extension JILImageState {
    func eqState(other: JILImageState) -> Bool {
        switch self {
        case .processed:
            if case .processed = other { return true }
        case .unprocessed:
            if case .unprocessed = other { return true }
        case .processing(_):
            if case .processing(_) = other { return true }
        }
        
        return false
    }
    
    static func ==(lhs: JILImageState, rhs: JILImageState) -> Bool {
        return lhs.eqState(other: rhs)
    }
}

enum ImageProcessError: Error {
    case couldNotStartProcess
}

final class JILImage: Identifiable, ObservableObject {
    var id: String {
        return self.name
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
        self.state = .unprocessed
        
        guard let image = NSImage(contentsOf: url as URL) else {
            return nil
        }
        
        self.thumbnail = image.generateThumbnail(contentMode: .aspectFill, width: 50)
        
        guard let rep = image.representations.first else {
            return nil
        }
        
        self.height = Int(rep.pixelsHigh)
        self.width = Int(rep.pixelsWide)
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path!)
            self.filesize = attr[FileAttributeKey.size] as! UInt64
        } catch {
            self.filesize = 0
        }
    }
    
    func process(name: String, size: NSSize) -> AnyCancellable? {
        self.state = .processing(0.0)
        
        guard let webP = WebPProcess(
            input: url.filePathURL!,
            output: URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("\(name).webp"),
            size: size
            ) else {
                return nil
        }
        
        guard let jpegTran: JPEGTranProcess = {
            let output = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("\(name).jpg")
            switch size == NSSize(width: self.width, height: self.height) {
            case true:
                return JPEGTranProcess(input: url.filePathURL!, output: output)
            case false:
                guard
                    let toBeResized = NSImage(contentsOf: url as URL),
                    let bits = toBeResized.resized(to: size)?.representations.first as? NSBitmapImageRep,
                    let jpegBits = bits.representation(using: .jpeg, properties: [:])
                else {
                    return nil
                }

                do {
                    let temp = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("temp.jpg")
                    try jpegBits.write(to: temp)
                    return JPEGTranProcess(input: temp, output: output)
                } catch {
                    return nil
                }
            }
            }() else {
                return nil
        }
        
        let publisher = webP.progress.combineLatest(jpegTran.progress)
            .map { tuple in
                tuple.0 + tuple.1
        }.eraseToAnyPublisher()
        
        let cancellable = publisher.sink(receiveCompletion: { (completion) in
            self.state = .processed
            
            retry(failableBlock: {
                try FileManager.default.moveItem(
                    at: URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("\(name).jpg"),
                    to: self.url.deletingLastPathComponent!.appendingPathComponent("\(name)-p.jpg"))
                
                try FileManager.default.moveItem(
                    at: URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("\(name).webp"),
                    to: self.url.deletingLastPathComponent!.appendingPathComponent("\(name)-p.webp"))
                
                try FileManager.default.removeItem(at: URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("temp.jpg"))
            }, recoveryBlock: { _ in
                let openPanel = NSOpenPanel()
                openPanel.message = "Give Webpic permission to save the image somewhere."
                openPanel.prompt = "Open"
                openPanel.canChooseDirectories = true
                let _ = openPanel.runModal()
            })
        }) { (progress) in
            self.state = .processing(progress)
        }
        
        
        
        webP.run()
        jpegTran.run()
        
        return cancellable
    }
}

protocol FakeData {
    static func generate() -> Self
}
    

extension JILImage: FakeData {
    static func generate() -> JILImage {
        return JILImage(name: "asdf.jpg", height: 250, width: 380, state: [
            .processed,
            .unprocessed,
            .processing(0.28)
            ].randomElement()!)
    }
}
