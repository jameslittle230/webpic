//
//  Retry.swift
//  Webpic
//
//  Created by James Little on 6/7/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import Foundation

enum RetryType {
    case times(Int)
    case infinite
}

func retry(_ type: RetryType, failableBlock: () throws -> Void , recoveryBlock: (Error) -> Void) {
    if case let .times(remaining) = type {
        if remaining == 0 {
            return
        }
    }
    
    do {
        try failableBlock()
    } catch {
        recoveryBlock(error)
        let newType: RetryType = {
            switch type {
            case .infinite: return .infinite
            case let .times(count): return .times(count - 1)
            }
        }()
        retry(newType, failableBlock: failableBlock, recoveryBlock: recoveryBlock)
    }
}
