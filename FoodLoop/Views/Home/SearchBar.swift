//
//  SearchBar.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 10.03.25.
//

import SwiftUI
import MapKit

// Suchleiste
struct SearchBar: View {
    @Binding var text: String
    var onSubmit: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Suchen...", text: $text)
                .foregroundColor(.primary)
                .onSubmit(onSubmit)
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}


