//
//  HeaderView.swift
//  TestToDoList
//
//  Created by Tom Roney on 02/08/2024.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack {
                Text(title)
                    .font(.system(size: 60))
                    .bold()
                    .padding(40)
                
                Text(subtitle)
                    .font(.system(size: 30))
                    .padding(.bottom, -5)
                
        }
        .frame(width: UIScreen.main.bounds.width * 3,
               height: 200)
        
        
        .offset(y:-50)
    }
}

#Preview {
    HeaderView(title: "Develop Daily", subtitle: "Welcome!")
}
