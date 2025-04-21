//
//  TL.Button.swift
//  TestToDoList
//
//  Created by Tom Roney on 07/08/2024.
//

import SwiftUI

struct TL_Button: View {
    let title: String
    let background: Color
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(background)
                    .frame(height: 40)
                
                Text(title)
                    .foregroundColor(.white)
                    .bold()
            }
        }
        
    }
}

#Preview {
    TL_Button(title: "Value", background: .pink) {
        //Action
    }
}
