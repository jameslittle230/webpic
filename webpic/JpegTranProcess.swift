//
//  JPEGTranProcess.swift
//  webpic
//
//  Created by James Little on 3/29/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import AppKit

class JPEGTranProcess: JILProcess {
    let executableURL = URL(fileURLWithPath: "Contents/Resources/lib/jpegtran", isDirectory: false, relativeTo:  NSRunningApplication.current.bundleURL)
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
        p.arguments = ["-progressive", "-verbose", "optimize", inputFilePathURL.path]
        
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
                    if(data.count > 0) {
                        print(String(data: data, encoding: .utf8)!)
                    }
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
    
//    func processIncomingStandardErrorData(_ data: Data) {
//        if let string = String(data: data, encoding: String.Encoding.utf8) {
//            let lines = string.split(separator: "\n")
//
//            for line in lines {
//                let words = line.split(separator: " ")
//
//                guard words.count > 3,
//                    let intValue = Int(words[words.count - 3]),
//                    intValue <= 100,
//                    intValue >= 0 else {
//                        break
//                }
//
//                DispatchQueue.main.sync {
//                    progressDelegate?.notifyWithProgress(Double(intValue) / 100.0)
//                }
//            }
//        }
//    }
}
