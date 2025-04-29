//
//  SavedItemRow.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 29.04.25.
//
import SwiftUI

struct SavedItemRow: View {
    let item: FoodItem
    let onRemove: () -> Void
    
    var body: some View {
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
                
                HStack {
                    // Entfernung
                    HStack {
                        Image(systemName: "location.circle")
                        Text("5 km")
                    }
                    .font(.caption)
                    
                    Spacer()
                    
                    // Bewertung
                    if let rating = item.averageRating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                        }
                        .font(.caption)
                    }
                }
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Entfernen-Button
            Button(action: onRemove) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}
