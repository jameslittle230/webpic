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

final class JILImage: Identifiable, ObservableObject {
    /// Used for indexing lists in SwiftUI
    var id: String { return self.name }

    let name: String
    let url: NSURL
    let height: Int
    let width: Int
    let filesize: UInt64
    let imageType: JILImageType
    var thumbnail: NSImage? = nil
    
    @Published var state: JILImageState
    
    var aspectRatio: Double {
        return Double(width) / Double(height)
    }

    // MARK: - Initializers
    
    init?(fromUrl url: NSURL) {
        self.url = url
        self.name = url.lastPathComponent!
        self.state = .unprocessed
        
        guard let image = NSImage(contentsOf: url as URL),
              let rep = image.representations.first else {
            return nil
        }

        guard let tempImageType: JILImageType = ({
            switch url.pathExtension {
            case "png", "PNG":
                return .png
            case "jpeg", "JPEG", "jpg", "JPG":
                return .jpeg
            default:
                return nil
            }
        })() else {
            return nil
        }

        self.imageType = tempImageType
        
        self.thumbnail = image.generateThumbnail(contentMode: .aspectFill, width: 50)
        
        self.height = Int(rep.pixelsHigh)
        self.width = Int(rep.pixelsWide)
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path!)
            self.filesize = attr[FileAttributeKey.size] as! UInt64
        } catch {
            self.filesize = 0
        }
    }

    /// This initializer is just used for fake data.
    init(name: String, height: Int, width: Int, state: JILImageState) {
        self.name = name
        self.height = height
        self.width = width
        self.state = state
        self.imageType = .jpeg
        self.url = NSURL()
        self.filesize = 2400000
    }

    // MARK: - Public methods
    
    func process(withOptions options: ImageOptions) -> AnyCancellable? {
        self.state = .processing(0.0)
        var converters: [Converter] = []
        let size = NSSize(width: options.tempWidth, height: options.tempHeight)

        if(options.convertToWebP) {
            converters.append(WebPConverter(input: url.filePathURL!, size: size)!)
        }

        if(imageType == .jpeg && options.convertToPJpeg) {
            converters.append(JPEGConverter(input: url.filePathURL!, size: size)!)
        }

        if(imageType == .png && options.compressPNG) {
            converters.append(PNGConverger(input: url.filePathURL!, size: size)!)
        }
        
//        let publisher = webP.progress.combineLatest(jpegTran.progress)
//            .map { tuple in
//                tuple.0 + tuple.1
//        }.eraseToAnyPublisher()
        let publisher = Publishers.MergeMany(converters.map {return $0.progress})
        
        let cancellable = publisher.sink(receiveCompletion: { (completion) in
            self.state = .processed

            retry(.times(1)) {
                for converter in converters {
                    let url = self.url.deletingLastPathComponent!
                        .appendingPathComponent("\(options.outputFilename).\(options.model.imageType.rawValue)")
                    try converter.data!.write(to: url, options: .atomicWrite)
                }
            } recoveryBlock: { _ in
                let openPanel = NSOpenPanel()
                openPanel.message = "Give Webpic permission to save the image somewhere."
                openPanel.prompt = "Open"
                openPanel.directoryURL = self.url.deletingLastPathComponent!
                openPanel.canChooseDirectories = true
                let _ = openPanel.runModal()
            } failureBlock: {
                print("Couldn't save the image :(")
            }
        }) { (progress) in
            self.state = .processing(progress)
        }
        
        converters.forEach {
            $0.run()
        }
        
        return cancellable
    }
}

// MARK: - Affiliated Types

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

enum JILImageType: String {
    case png = "png"
    case jpeg = "jpeg"
}
