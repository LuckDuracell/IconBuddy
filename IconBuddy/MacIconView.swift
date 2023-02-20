//
//  MacIconView.swift
//  IconBuddy
//
//  Created by Luke Drushell on 2/17/23.
//

import SwiftUI

struct MacIconView: View {
    
    var image: Image
    
    var body: some View {
        ZStack {
//            Color.white
//                .frame(width: 1024, height: 1024)
            Color.black.opacity(0.2)
                .frame(width: 819.2, height: 819.2)
                .cornerRadius(185)
                .blur(radius: 25)
                .offset(x: 15, y: 15)
            image
                .resizable()
                .frame(width: 820, height: 820)
                .scaledToFit()
                .cornerRadius(185)
                .frame(width: 1024, height: 1024)
        }
    }
}

struct MacIconView_Previews: PreviewProvider {
    static var previews: some View {
        MacIconView(image: Image("IconBuddyXC"))
    }
}
