//
//  Converter.swift
//  webpic
//
//  Created by James Little on 6/28/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import AppKit
import Combine

protocol Converter {
    var progress: AnyPublisher<Double, Error> { get }
    var data: Data? { get }
    func run()
}
