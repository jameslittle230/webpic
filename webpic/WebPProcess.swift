//
//  WebPProcess.swift
//  webpic
//
//  Created by James Little on 3/10/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import AppKit
import Combine

protocol JILProcess {
    var progress: AnyPublisher<Double, Error> { get }
    init?(input: URL, output: URL)
    func run()
}

class WebPProcess: JILProcess {
    var progress: AnyPublisher<Double, Error> {
        progressSubject.eraseToAnyPublisher()
    }
    private var progressSubject = PassthroughSubject<Double, Error>()
    
    private let executableURL = URL(fileURLWithPath: "Contents/Resources/lib/cwebp", isDirectory: false, relativeTo:  NSRunningApplication.current.bundleURL)
    private let p = Process()
    
    private let input: URL
    private let output: URL
    
    private let standardErrorPipe = Pipe()
    
    required init?(input: URL, output: URL) {
        guard let inputFilePathURL = (input as NSURL).filePathURL else {
            return nil
        }
    
        p.executableURL = executableURL
        p.arguments = ["-preset", "picture", "-progress", inputFilePathURL.path, "-o", "-"]
        
        self.input = input
        self.output = output
    }
    
    func run() {
        progressSubject.send(0.0)

        do {
            try Data().write(to: output)
        } catch {
            print("Couldn't write to output file")
        }
            
        DispatchQueue.global().async {
            do {
                let outputHandle = try FileHandle(forUpdating: self.output)
                self.p.standardOutput = outputHandle
                self.p.standardError = self.standardErrorPipe
                
                try self.p.run()
                
                self.standardErrorPipe.fileHandleForReading.readabilityHandler = { fileHandle in
                    let data = fileHandle.availableData
                    self.processIncomingStandardErrorData(data)
                }
                
                self.p.waitUntilExit()
                self.standardErrorPipe.fileHandleForReading.readabilityHandler = nil
                try outputHandle.close()
                
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
