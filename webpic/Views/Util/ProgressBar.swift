//
//  ProgressBar.swift
//  webpic
//
//  Created by James Little on 3/1/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import SwiftUI

struct ProgressBar: View {
    @Binding var progress: Double
    var height: CGFloat = 12
    
    var computedProgress: Double {
        return progress.clamp(min: 0.0, max: 1.0)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Capsule().frame(height: self.height)
                Capsule().fill(Color.accentColor)
                    .transformEffect(CGAffineTransform(translationX: geometry.size.width * -1.0 * (1 - CGFloat(self.progress)), y: 0))
                    .animation(.easeInOut) // not working?
                    .frame(height: self.height)
                }.clipShape(Capsule())
        }.frame(height: height)
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(progress: .constant(0.28))
    }
}
