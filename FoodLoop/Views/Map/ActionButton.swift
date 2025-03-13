//
//  ActionButton.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 10.03.25.
//
import SwiftUI
import MapKit

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Aktion
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
