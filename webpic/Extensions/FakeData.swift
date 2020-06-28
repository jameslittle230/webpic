//
//  FakeData.swift
//  Webpic
//
//  Created by James Little on 6/28/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import Foundation

protocol FakeData {
    static func generate() -> Self
}

extension JILImage: FakeData {
    static func generate() -> JILImage {
        return JILImage(name: "asdf.jpg", height: 250, width: 380, state: [
            .processed,
            .unprocessed,
            .processing(0.28)
        ].randomElement()!)
    }
}
