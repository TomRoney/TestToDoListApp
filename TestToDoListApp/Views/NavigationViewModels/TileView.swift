//
//  TileView.swift
//  TestToDoList
//
//  Created by Tom Roney on 08/10/2024.
//

import SwiftUI

// Custom TileView Component
struct TileView: View {
    var title: String

    var body: some View {
        VStack(alignment: .leading) { // Aligning text to the left
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .foregroundColor(.black)
                .padding(.leading, 10)
                .padding(.top, 20)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color("GreenButton"))
        .cornerRadius(10)
    }
}

