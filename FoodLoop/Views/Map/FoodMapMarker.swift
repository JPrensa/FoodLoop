//
//  FoodMapMarker.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 10.03.25.
//
import SwiftUI
import MapKit

struct FoodMapMarker: View {
    let item: FoodItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(categoryColor)
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                
                Image(systemName: item.category.icon)
                    .foregroundColor(.white)
                    .font(.system(size: isSelected ? 22 : 18))
            }
            .scaleEffect(isSelected ? 1.2 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Farbe basierend auf Kategorie
    private var categoryColor: Color {
        // Jeder Kategorie eine konsistente Farbe zuweisen
        let colors: [Color] = [.green, .blue, .orange, .red, .purple, .pink, .yellow]
        let hash = abs(item.category.id.hashValue)
        let index = hash % colors.count
        return colors[index]
    }
}
