//
//  FilterButton.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 10.03.25.
//
import SwiftUI
import MapKit

struct FilterButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        Button(action: {
            // Filteraktion
        }) {
            Label(title, systemImage: icon)
                .font(.system(size: 14, weight: .medium))
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .foregroundColor(.primary)
    }
}
