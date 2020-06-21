//
//  JPEGTranProcess.swift
//  webpic
//
//  Created by James Little on 3/29/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import AppKit
import Combine

class JPEGTranProcess: JILProcess {
    var progress: AnyPublisher<Double, Error> {
        progressSubject.eraseToAnyPublisher()
    }
    
    var data: Data {
        return internalData
    }
    
    // MARK: - Internal Variables
    
    private var internalData = Data()
    
    private var progressSubject = PassthroughSubject<Double, Error>()
    
    private let executableURL = URL(fileURLWithPath: "Contents/Resources/lib/jpegtran", isDirectory: false, relativeTo:  NSRunningApplication.current.bundleURL)
    
    private let p = Process()
    
    private let input: URL
    private let tempfile: TempFile
    
    private let standardOutputPipe = Pipe()
    private let standardErrorPipe = Pipe()
    
    // MARK: - Initializers
    
    required init?(input: URL, size: NSSize) {
//        guard let inputFilePathURL = (input as NSURL).filePathURL else {
//            return nil
//        }

        guard let toBeResized = NSImage(contentsOf: input),
            let bits = toBeResized.resized(to: size)?.representations.first as? NSBitmapImageRep,
            let jpegBits = bits.representation(using: .jpeg, properties: [:]) else {
                return nil
        }

        tempfile = TempFile(data: jpegBits)
    
        p.executableURL = executableURL
        p.arguments = ["-progressive", "-verbose", "-optimize", tempfile.url.path]
        self.input = input
    }
    
    // MARK: - Public Methods
    
    func run() {
        progressSubject.send(0.0)
            
        DispatchQueue.global().async {
            do {
                self.p.standardOutput = self.standardOutputPipe
                self.p.standardError = self.standardErrorPipe
                
                try self.p.run()
            
                self.standardErrorPipe.fileHandleForReading.readabilityHandler = { fileHandle in
                    let _ = fileHandle.availableData // Not doing anything with this now, but maybe later?
                }
                
                self.internalData.append(try (self.standardOutputPipe.fileHandleForReading.readToEnd() ?? Data()))
                
                self.p.waitUntilExit()
                self.standardErrorPipe.fileHandleForReading.readabilityHandler = nil
                self.standardOutputPipe.fileHandleForReading.readabilityHandler = nil
                
                DispatchQueue.main.sync {
                    self.tempfile.destroy()
                    self.progressSubject.send(completion: .finished)
                }
            } catch {
                self.progressSubject.send(completion: .failure(error))
            }
        }
    }
}
