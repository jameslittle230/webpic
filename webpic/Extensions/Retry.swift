//
//  Retry.swift
//  Webpic
//
//  Created by James Little on 6/7/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import Foundation

enum RetryMode {
    case times(Int)
    case infinite
}

func retry(
    _ mode: RetryMode,
    failableBlock: () throws -> Void,
    recoveryBlock: (Error) -> Void,
    failureBlock: () -> Void
) {
    if case let .times(remaining) = mode {
        if remaining == 0 {
            failureBlock()
            return
        }
    }
    
    do {
        try failableBlock()
    } catch {
        recoveryBlock(error)
        let newType: RetryMode = {
            switch mode {
            case .infinite: return .infinite
            case let .times(count): return .times(count - 1)
            }
        }()
        retry(newType, failableBlock: failableBlock, recoveryBlock: recoveryBlock, failureBlock: failureBlock)
    }
}
