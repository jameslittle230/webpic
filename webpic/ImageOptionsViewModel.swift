//
//  ImageOptionsViewModel.swift
//  Webpic
//
//  Created by James Little on 6/27/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import SwiftUI

class ImageOptionsViewModel: ObservableObject {
    static let tempWidthDefaultsKey = "imageoptionsviewmodel.tempwidth"
    static let tempHeightDefaultsKey = "imageoptionsviewmodel.tempheight"
    let model: JILImage

    init(model: JILImage) {
        self.model = model

        let savedWidth = UserDefaults.standard.integer(forKey: ImageOptionsViewModel.tempWidthDefaultsKey)
        let savedHeight = UserDefaults.standard.integer(forKey: ImageOptionsViewModel.tempHeightDefaultsKey)
        self.tempWidth = savedWidth != 0 ? savedWidth : model.width
        self.tempHeight = savedHeight != 0 ? savedHeight : model.height

        var fileNameComponents = model.name.split(separator: ".")
        _ = fileNameComponents.popLast()
        outputFilename = fileNameComponents.joined(separator: ".").appending("-p")
    }

    enum LastEditedImageDimension {
        case none
        case width
        case height
    }

    var tempWidth: Int
    var tempHeight: Int

    var outputWidth: String {
        get {
            return String(tempWidth)
        }

        set {
//            lastEditedImageDimension = .width
            tempWidth = Int(newValue) ?? 0
            tempHeight = Int(Double(tempWidth) / model.aspectRatio)
        }
    }

    var outputHeight: String {
        get {
            return String(tempHeight)
        }

        set {
//            lastEditedImageDimension = .height
            tempHeight = Int(newValue) ?? 0
            tempWidth = Int(Double(tempHeight) * model.aspectRatio)
        }
    }

    @Published var lastEditedImageDimension = LastEditedImageDimension.none
    @Published var outputFilename = ""
    @Published var convertToWebP = true
    @Published var convertToPJpeg = true
    @Published var compressPNG = true
    @Published var uploadToServer = false
    @Published var saveToDisk = true
}
