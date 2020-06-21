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
        Gradient.Stop.init(color: Color("ButtonScrimColor").opacity(0.80), location: 0.0),
        Gradient.Stop.init(color: Color("ButtonScrimColor").opacity(0.65), location: 0.1),
        Gradient.Stop.init(color: Color("ButtonScrimColor").opacity(0.60), location: 0.3),
        Gradient.Stop.init(color: Color("ButtonScrimColor").opacity(0.65), location: 1.0),
    ])
    
    @State private var hovered = false

    var text: String
    var disabled = false
    
    var body: some View {
        HStack {
            Spacer()
            Text(text).font(.headline).padding(.vertical, 4.0)
            Spacer()
        }
        .background(LinearGradient(gradient: scrim, startPoint: .top, endPoint: .bottom))
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(NSColor.tertiaryLabelColor), lineWidth: 0.5))
        .shadow(color: Color.black.opacity(0.2), radius: 0.4, x: 0, y: 0.6)
    }
}

struct CTAButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HStack(spacing: 8.0) {
                CTAButton(text: "Buy Now")
                Button(action: {}) {
                    Text("Buy now")
                }
            }.padding().background(Color(NSColor.windowBackgroundColor)).environment(\.colorScheme, .light)

            HStack(spacing: 8.0) {
                CTAButton(text: "Buy Now")
                Button(action: {}) {
                    Text("Buy now")
                }
            }.environment(\.colorScheme, .dark).padding()
        }
    }
}
