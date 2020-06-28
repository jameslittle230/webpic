//
//  WebPProcess.swift
//  webpic
//
//  Created by James Little on 3/10/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import AppKit
import Combine

class WebPConverter: Converter {
    var progress: AnyPublisher<Double, Error> {
        progressSubject.eraseToAnyPublisher()
    }
    
    var data: Data? {
        return internalData
    }
    
    // MARK: - Internal Variables
    
    private var internalData: Data = Data()
    
    private var progressSubject = PassthroughSubject<Double, Error>()
    
    private let executableURL = URL(fileURLWithPath: "Contents/Resources/lib/cwebp", isDirectory: false, relativeTo:  NSRunningApplication.current.bundleURL)
    private let p = Process()
    
    private let input: URL
    
    private let standardOutputPipe = Pipe()
    private let standardErrorPipe = Pipe()
    
    // MARK: - Initializers
    
    required init?(input: URL, size: NSSize) {
        guard let inputFilePathURL = (input as NSURL).filePathURL else {
            return nil
        }
    
        p.executableURL = executableURL
        p.arguments = [
            "-preset",
            "picture",
            "-progress",
            "-mt",
            "-resize", "\(Int(size.width))", "\(Int(size.height))",
            inputFilePathURL.path,
            "-o", "-"
        ]
        
        self.input = input
    }
    
    func run() {
        progressSubject.send(0.0)
            
        DispatchQueue.global().async {
            do {
                self.p.standardOutput = self.standardOutputPipe
                self.p.standardError = self.standardErrorPipe
                
                try self.p.run()
                
                self.standardErrorPipe.fileHandleForReading.readabilityHandler = { fileHandle in
                    let data = fileHandle.availableData
                    self.processIncomingStandardErrorData(data)
                }
                
                if #available(OSX 10.15.4, *) {
                    self.internalData.append(try (self.standardOutputPipe.fileHandleForReading.readToEnd() ?? Data()))
                } else {
                    // Fallback on earlier versions
                }
                
                self.p.waitUntilExit()
                self.standardErrorPipe.fileHandleForReading.readabilityHandler = nil
                self.standardOutputPipe.fileHandleForReading.readabilityHandler = nil
                
                DispatchQueue.main.sync {
                    self.progressSubject.send(completion: .finished)
                }
            } catch {
                self.progressSubject.send(completion: .failure(error))
            }
        }
    }
    
    func processIncomingStandardErrorData(_ data: Data) {
        if let string = String(data: data, encoding: String.Encoding.utf8) {
            let lines = string.split(separator: "\n")
            
            for line in lines {
                let words = line.split(separator: " ")
                
                guard words.count > 3,
                    let intValue = Int(words[words.count - 3]),
                    intValue <= 100,
                    intValue >= 0 else {
                        break
                }
                
                DispatchQueue.main.sync {
                    self.progressSubject.send(Double(intValue) / 100.0)
                }
            }
        }
    }
}
