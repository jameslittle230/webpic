//
//  Float+Clamp.swift
//  webpic
//
//  Created by James Little on 3/1/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import Foundation

extension Float {
    func clamp(min minVal: Float, max maxVal: Float) -> Float {
        guard minVal < maxVal else {
            fatalError("Min clamp value must be less than max clamp value")
        }
        
        return max(min(maxVal, self), minVal)
    }
}

extension UInt64 {
    public var kilobytes: Double {
      return Double(self) / 1_024
    }
    
    public var megabytes: Double {
      return kilobytes / 1_024
    }
    
    public var gigabytes: Double {
      return megabytes / 1_024
    }
    
    func formatBytes() -> String {
        switch self {
        case 0..<1_024:
          return "\(self) b"
        case 1_024..<(1_024 * 1_024):
          return "\(String(format: "%.2f", kilobytes)) KB"
        case 1_024..<(1_024 * 1_024 * 1_024):
          return "\(String(format: "%.2f", megabytes)) MB"
        case 1_024..<(1_024 * 1_024 * 1_024 * 1_024):
          return "\(String(format: "%.2f", gigabytes)) GB"
        default:
          return "\(self) bytes"
        }
    }
}
