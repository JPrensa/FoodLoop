//
//  FoodRowView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 10.03.25.
//
import SwiftUI
import MapKit

// Lebensmittel-Listenzeile
struct FoodItemRow: View {
    let item: FoodItem
    let primaryColor = Color("PrimaryGreen")
    
    var body: some View {
        HStack(spacing: 16) {
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
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
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
                        .foregroundColor(isExpired(date: expiryDate) ? .red : .orange)
                }
                
                HStack {
                    // Entfernung
                    HStack {
                        Image(systemName: "location.circle")
                        Text(formatDistance(for: item))
                    }
                    .font(.caption)
                    
                    Spacer()
                    
                    // Verfügbarkeit
                    Text(formatAvailability(for: item))
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(item.isAvailable ? Color.green.opacity(0.1) : Color.gray.opacity(0.2))
                        .foregroundColor(item.isAvailable ? .green : .gray)
                        .cornerRadius(4)
                }
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Speichern-Button
            SaveButton(foodItem: item, size: 18)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // Hilfsfunktionen
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    private func isExpired(date: Date) -> Bool {
        return date < Date()
    }
    
    private func formatDistance(for item: FoodItem) -> String {
        // Berechnet die tatsächliche Entfernung zum Benutzerstandort
        return item.location.distanceToCurrentLocation()
    }
    
    private func formatAvailability(for item: FoodItem) -> String {
        // Zeige 'Reserviert' wenn nicht verfügbar
        if !item.isAvailable {
            return "Reserviert"
        }
        // Diese Funktion formatiert die Verfügbarkeit basierend auf den Abholzeiten
        if item.availableTimes.isEmpty {
            return "Verfügbar"
        }
        
        // Wenn mindestens eine Abholzeit für heute existiert
        let today = Calendar.current.component(.weekday, from: Date()) - 2 // 0 = Montag
        if item.availableTimes.contains(where: { $0.day == today }) {
            return "Heute verfügbar"
        }
        
        return "Verfügbar"
    }
}
