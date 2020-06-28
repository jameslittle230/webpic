//
//  PNGConverger.swift
//  webpic
//
//  Created by James Little on 6/27/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import AppKit
import Combine

struct PNGError: Error {}

class PNGConverger: Converter {
    var progress: AnyPublisher<Double, Error> {
        progressSubject.eraseToAnyPublisher()
    }
    
    var data: Data? {
        return internalData
    }
    
    // MARK: - Internal Variables
    
    private var internalData = Data()
    
    private var progressSubject = PassthroughSubject<Double, Error>()
    
    private let input: URL
    private let size: NSSize
    
    // MARK: - Initializers
    
    required init?(input: URL, size: NSSize) {
        self.input = input
        self.size = size
    }
    
    // MARK: - Public Methods
    
    func run() {
        progressSubject.send(0.0)
            
        DispatchQueue.global().async {
            guard let toBeResized = NSImage(contentsOf: self.input),
                  let bits = toBeResized.resized(to: self.size)?.representations.first as? NSBitmapImageRep,
                  let pngBits = bits.representation(using: .png, properties: [.compressionFactor: 0.6]) else {
                self.progressSubject.send(completion: .failure(PNGError()))
                return
            }

            self.internalData = pngBits
            self.progressSubject.send(completion: .finished)
        }
    }
}
