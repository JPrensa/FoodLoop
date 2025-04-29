//
//  CategoryButton.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 29.04.25.
//

import SwiftUI
import PhotosUI
import CoreLocation

struct CategoryButton: View {
    let category: FoodCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                
                Text(category.name)
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(minWidth: 80)
            .background(isSelected ? Color("PrimaryGreen").opacity(0.1) : Color.white)
            .foregroundColor(isSelected ? Color("PrimaryGreen") : .primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color("PrimaryGreen") : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: isSelected ? 3 : 1, x: 0, y: 1)
        }
    }
}
