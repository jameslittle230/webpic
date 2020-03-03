//
//  ProgressBar.swift
//  webpic
//
//  Created by James Little on 3/1/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import SwiftUI

struct ProgressBar: View {
    var progress: Float
    var height: CGFloat = 12
    
    var computedProgress: Float {
        return progress.clamp(min: 0.0, max: 1.0)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Capsule().frame(height: self.height)
                Capsule().fill(Color.accentColor)
                    .transformEffect(CGAffineTransform(translationX: geometry.size.width * -1.0 * CGFloat(self.progress), y: 0))
                    .frame(height: self.height)
                }.clipShape(Capsule())
        }.frame(height: height)
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(progress: 0.28)
    }
}
