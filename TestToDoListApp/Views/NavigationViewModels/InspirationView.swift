//
//  InspirationView.swift
//  TestToDoList
//
//  Created by Tom Roney on 29/08/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        InspirationView()
    }
}

struct InspirationView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Custom beige background from Assets
                Color("BackgroundBeige")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Top full-width tile
                        NavigationLink(destination: InspirationTileOneView()) {
                            InspirationTile(title: "Why is Intention setting important?")
                        }
                        
                        // Middle row with two tiles side-by-side.
                        // Extra horizontal padding reduces the width of these tiles.
                        HStack(spacing: 10) {
                            NavigationLink(destination: InspirationTileTwoView()) {
                                InspirationTile(title: "Exercise Blog")
                            }
                            .padding(.horizontal, 2)
                            
                            NavigationLink(destination: InspirationTileThreeView()) {
                                InspirationTile(title: "Placeholder")
                            }
                            .padding(.horizontal, 2)
                        }
                        
                        // Bottom full-width tile
                        NavigationLink(destination: InspirationTileFourView()) {
                            InspirationTile(title: "How to write good Goals")
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 20)
                }
                .navigationTitle("Inspiration")
            }
        }
    }
}

struct InspirationTile: View {
    let title: String
    
    var body: some View {
        // Mimics the HomeView tile style with left-aligned white text
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .padding()
        // Full width within its container, with a fixed height
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .frame(height: 180)
        .background(Color("GreenButton"))
        .cornerRadius(10)
    }
}

// MARK: - Detail Views
struct InspirationTileOneView: View {
    var body: some View {
        Text("Details for Tile One")
            .navigationTitle("Tile One")
    }
}

struct InspirationTileTwoView: View {
    var body: some View {
        Text("Details for Tile Two")
            .navigationTitle("Tile Two")
    }
}

struct InspirationTileThreeView: View {
    var body: some View {
        Text("Details for Tile Three")
            .navigationTitle("Tile Three")
    }
}

struct InspirationTileFourView: View {
    var body: some View {
        Text("Details for Tile Four")
            .navigationTitle("Tile Four")
    }
}
