//
//  TempFile.swift
//  Webpic
//
//  Created by James Little on 6/20/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import Foundation

class TempFile {
    let url: URL
    
    init(data: Data) {
        url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("temp-\(Date().hashValue).tmp")
        do {
            try data.write(to: url)
        } catch {
            print("Couldn't write to temp file \(url)")
        }
    }

    func destroy() {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            // do nothing
        }
    }
    
    deinit {
        destroy()
    }
}
