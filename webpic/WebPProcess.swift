//
//  WebPProcess.swift
//  webpic
//
//  Created by James Little on 3/10/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import AppKit

protocol JILProcess {
    var executableURL: URL { get }
    init?(input: URL, output: URL, progressDelegate: ProgressDelegate?)
    func run(_ completion: @escaping () -> Void)
}

class WebPProcess: JILProcess {
    let executableURL = URL(fileURLWithPath: "Contents/Resources/lib/cwebp", isDirectory: false, relativeTo:  NSRunningApplication.current.bundleURL)
    let p = Process()
    
    let input: URL
    let output: URL
    let progressDelegate: ProgressDelegate?
    
    let standardErrorPipe = Pipe()
    
    required init?(input: URL, output: URL, progressDelegate: ProgressDelegate? = nil) {
        guard let inputFilePathURL = (input as NSURL).filePathURL else {
            return nil
        }
    
        p.executableURL = executableURL
        p.arguments = ["-preset", "picture", "-progress", inputFilePathURL.path, "-o", "-"]
        
        self.input = input
        self.output = output
        self.progressDelegate = progressDelegate
    }
    
    func run(_ completion: @escaping () -> Void) {

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
                    self.progressDelegate?.complete()
                    completion()
                }
            } catch {
                print("error!")
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
                    progressDelegate?.notifyWithProgress(Double(intValue) / 100.0)
                }
            }
        }
    }
}

protocol ProgressDelegate {
    var progress: Double { get set }
    func notifyWithProgress(_ progress: Double)
    func complete()
}

class PrintingProgressDelegate: ProgressDelegate {
    var progress: Double = 0.0
    
    func complete() {
        self.progress = 1.0
        print("Complete!")
    }
    
    func notifyWithProgress(_ progress: Double) {
        self.progress = progress
        print("Progress: \(progress)")
    }
}
