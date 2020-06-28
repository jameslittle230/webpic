//
//  JPEGProcess.swift
//  webpic
//
//  Created by James Little on 3/29/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import AppKit
import Combine

struct JPEGTranError: Error {}

class JPEGProcess: Converter {
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
                  let jpegBits = bits.representation(using: .jpeg, properties: [
                    .progressive: true,
                    .compressionFactor: 0.6
                  ]) else {
                self.progressSubject.send(completion: .failure(JPEGTranError()))
                return
            }

            self.internalData = jpegBits
            self.progressSubject.send(completion: .finished)
        }
    }
}
