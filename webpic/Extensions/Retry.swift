//
//  Retry.swift
//  Webpic
//
//  Created by James Little on 6/7/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import Foundation

func retry(failableBlock: () throws -> Void , recoveryBlock: (Error) -> Void) {
    do {
        try failableBlock()
    } catch {
        recoveryBlock(error)
        retry(failableBlock: failableBlock, recoveryBlock: recoveryBlock)
    }
}
