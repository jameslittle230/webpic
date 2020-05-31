//
//  ListActions.swift
//  Webpic
//
//  Created by James Little on 5/28/20.
//  Copyright © 2020 James Little. All rights reserved.
//

import SwiftUI

struct ListActions: View {
    @EnvironmentObject var imageManager: ImageManager
    var body: some View {
        VStack {
            Text("\(imageManager.images.count) images")
        HStack {
            Button(action: {
                self.imageManager.clearCompletedImages()
            }) {
                Text("Clear Completed")
            }
            Button(action: {
                self.imageManager.bulkProcess()
            }) {
                Text("Bulk Process")
            }
            
            HelpButton(action: {})
        }.padding(.bottom)
    }
    }
}

struct ListActions_Previews: PreviewProvider {
    static var previews: some View {
        ListActions()
    }
}
