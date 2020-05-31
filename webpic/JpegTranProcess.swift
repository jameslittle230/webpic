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
    private var progressSubject = PassthroughSubject<Double, Error>()
    
    private let executableURL = URL(fileURLWithPath: "Contents/Resources/lib/jpegtran", isDirectory: false, relativeTo:  NSRunningApplication.current.bundleURL)
    private let p = Process()
    
    private let input: URL
    private let output: URL
    
    private let standardErrorPipe = Pipe()
    
    required init?(input: URL, output: URL) {
        guard let inputFilePathURL = (input as NSURL).filePathURL else {
            return nil
        }
    
        p.executableURL = executableURL
        p.arguments = ["-progressive", "-verbose", "-optimize", inputFilePathURL.path]
        
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
                    let _ = fileHandle.availableData // Not doing anything with this now, but maybe later?
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
}
