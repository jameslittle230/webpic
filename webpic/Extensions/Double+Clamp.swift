//
//  Float+Clamp.swift
//  webpic
//
//  Created by James Little on 3/1/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import Foundation

extension Double {
    func clamp(min minVal: Double, max maxVal: Double) -> Double {
        guard minVal < maxVal else {
            fatalError("Min clamp value must be less than max clamp value")
        }
        
        return max(min(maxVal, self), minVal)
    }
}
