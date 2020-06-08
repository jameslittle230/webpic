//
//  JPEGTranProcess.swift
//  webpic
//
//  Created by James Little on 3/29/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import AppKit
import Combine

fileprivate enum JPEGTranInput {
    case url(URL)
    case data(Data)
}

class JPEGTranProcess: JILProcess {
    var progress: AnyPublisher<Double, Error> {
        progressSubject.eraseToAnyPublisher()
    }
    private var progressSubject = PassthroughSubject<Double, Error>()
    
    private let executableURL = URL(fileURLWithPath: "Contents/Resources/lib/jpegtran", isDirectory: false, relativeTo:  NSRunningApplication.current.bundleURL)
    private let p = Process()
    
    private let input: JPEGTranInput
    private let output: URL
    
    private let standardErrorPipe = Pipe()
    
    required init?(input: URL, output: URL) {
        guard let inputFilePathURL = (input as NSURL).filePathURL else {
            return nil
        }
    
        p.executableURL = executableURL
        p.arguments = ["-progressive", "-verbose", "-optimize", inputFilePathURL.path]
        
        self.input = .url(input)
        self.output = output
    }
    
    required init?(data: Data, output: URL) {
        p.executableURL = executableURL
        p.arguments = ["-progressive", "-verbose", "-optimize"]
        
        self.input = .data(data)
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
//                self.p.standardOutput = self.standardErrorPipe
                self.p.standardError = self.standardErrorPipe
                
                if case .data(let data) = self.input {
                    let stdInPipe = Pipe()
                    self.p.standardInput = stdInPipe
                    stdInPipe.fileHandleForWriting.write(data)
                }
                
                try self.p.run()
                
                self.standardErrorPipe.fileHandleForReading.readabilityHandler = { fileHandle in
//                    let _ = fileHandle.availableData // Not doing anything with this now, but maybe later?
                    let data = fileHandle.availableData
                    let string = String(data: data, encoding: .ascii) ?? ""
                    if string.count > 0 {
                        print(string)
                    }
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
