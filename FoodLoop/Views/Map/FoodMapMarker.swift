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
    
    var body: some View {
        ZStack {
            Circle()
                .fill(categoryColor)
                .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
            
            Image(systemName: categoryIcon)
                .foregroundColor(.white)
                .font(.system(size: isSelected ? 22 : 18))
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(.spring(), value: isSelected)
    }
    
    // Farbe basierend auf Kategorie
    private var categoryColor: Color {
        switch item.category.name {
        case "Obst & Gemüse":
            return .green
        case "Backwaren":
            return .brown
        case "Milchprodukte":
            return .blue
        case "Fertiggerichte":
            return .orange
        default:
            return .gray
        }
    }
    
    // Icon basierend auf Kategorie
    private var categoryIcon: String {
        return item.category.icon
    }
}
