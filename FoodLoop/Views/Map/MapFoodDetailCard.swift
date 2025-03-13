//
//  MapFoodDetailCard.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 10.03.25.
//
import SwiftUI
import MapKit

struct MapFoodDetailCard: View {
    let item: FoodItem
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Bild
                if let imageURL = item.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(8)
                } else {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                }
                
                // Informationen
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                    
                    Text(item.category.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let expiryDate = item.expiryDate {
                        Text("MHD: \(dateFormatter.string(from: expiryDate))")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    // Entfernung
                    HStack {
                        Image(systemName: "location.circle")
                        Text("5 km entfernt")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(16)
            
            // Aktionsbuttons
            HStack {
                ActionButton(title: "Speichern", icon: "heart", color: .pink)
                
                Divider()
                    .frame(height: 24)
                
                ActionButton(title: "Kontakt", icon: "message.fill", color: .blue)
                
                Divider()
                    .frame(height: 24)
                
                ActionButton(title: "Route", icon: "map.fill", color: .green)
            }
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}
