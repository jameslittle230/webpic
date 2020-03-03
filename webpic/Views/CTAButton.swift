//
//  CTAButton.swift
//  webpic
//
//  Created by James Little on 3/1/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import SwiftUI

struct CTAButton: View {
    let scrim = Gradient(stops: [
        Gradient.Stop.init(color: Color.white.opacity(0.30), location: 0.0),
        Gradient.Stop.init(color: Color.white.opacity(0.25), location: 0.1),
        Gradient.Stop.init(color: Color.white.opacity(0.20), location: 0.3),
        Gradient.Stop.init(color: Color.white.opacity(0.25), location: 1.0),
    ])
    
    @State private var hovered = false

    var text: String
    var body: some View {
        HStack {
            Spacer()
            Text(text).font(.headline).padding(.vertical, 4.0)
            Spacer()
        }
        .background(LinearGradient(gradient: scrim, startPoint: .top, endPoint: .bottom))
        .background(hovered ? Color.accentColor : Color(NSColor.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.black, lineWidth: 0.5)
        )
        .onHover() { mouseover in
            self.hovered = mouseover
        }
    }
}

struct CTAButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CTAButton(text: "Buy Now").environment(\.colorScheme, .dark).padding()
            CTAButton(text: "Buy Now").environment(\.colorScheme, .light).padding()
        }
    }
}
