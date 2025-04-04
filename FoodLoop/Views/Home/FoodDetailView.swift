//
//  FoodDetailView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 21.02.25.
//

import SwiftUI

struct FoodDetailView: View {
    let foodId: String
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = FoodDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let primaryColor = Color("PrimaryGreen")
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Bild mit Favoriten-Button
                ZStack(alignment: .topTrailing) {
                    if let imageURL = viewModel.foodItem?.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 250)
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 250)
                    }
                    
                    // Favoriten-Button
                    if let foodItem = viewModel.foodItem {
                        SaveButton(foodItem: foodItem, size: 22, showBackground: true)
                            .padding(.top, 16)
                            .padding(.trailing, 16)
                    }
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    // Titel und Besitzer
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.foodItem?.title ?? "Lebensmittel")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        if let owner = viewModel.owner {
                            HStack {
                                Text("Angeboten von:")
                                    .foregroundColor(.secondary)
                                
                                Text(owner.username)
                                    .fontWeight(.medium)
                            }
                            .font(.subheadline)
                        }
                        
                        if let category = viewModel.foodItem?.category {
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(primaryColor)
                                
                                Text(category.name)
                                    .foregroundColor(.secondary)
                            }
                            .font(.subheadline)
                        }
                    }
                    
                    // Bewertung
                    if let rating = viewModel.foodItem?.averageRating {
                        HStack(spacing: 4) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(rating) ? "star.fill" : (index < Int(rating) + 1 && rating.truncatingRemainder(dividingBy: 1) > 0 ? "star.leadinghalf.filled" : "star"))
                                    .foregroundColor(.yellow)
                            }
                            
                            Text(String(format: "%.1f", rating))
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                                .padding(.leading, 4)
                        }
                    }
                    
                    Divider()
                    
                    // Beschreibung
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Beschreibung")
                            .font(.headline)
                        
                        Text(viewModel.foodItem?.description ?? "Keine Beschreibung verfügbar.")
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // MHD
                    if let expiryDate = viewModel.foodItem?.expiryDate {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Mindesthaltbarkeitsdatum")
                                .font(.headline)
                            
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(primaryColor)
                                
                                Text(expiryDate, style: .date)
                                
                                if expiryDate < Date() {
                                    Text("(abgelaufen)")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        Divider()
                    }
                    
                    // Abholzeiten
                    if let availableTimes = viewModel.foodItem?.availableTimes, !availableTimes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Abholzeiten")
                                .font(.headline)
                            
                            ForEach(availableTimes, id: \.day) { timeSlot in
                                HStack {
                                    Text(getWeekdayName(for: timeSlot.day))
                                        .fontWeight(.medium)
                                        .frame(width: 100, alignment: .leading)
                                    
                                    Text(formatTime(timeSlot.startTime))
                                    
                                    Text("-")
                                    
                                    Text(formatTime(timeSlot.endTime))
                                }
                                .font(.subheadline)
                            }
                        }
                        
                        Divider()
                    }
                    
                    // Standort
                    if let location = viewModel.foodItem?.location {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Standort")
                                .font(.headline)
                            
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(primaryColor)
                                
                                if let address = location.address {
                                    Text(address)
                                } else {
                                    Text("Etwa 5 km entfernt")
                                }
                            }
                            
                            // Hier könnte eine kleine Kartenvorschau eingefügt werden
                        }
                    }
                    
                    // Aktionsbuttons
                    HStack(spacing: 16) {
                        Button {
                            // Kontakt-Funktion
                        } label: {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("Kontakt")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button {
                            // Routenplanung
                        } label: {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("Route")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Details")
                    .font(.headline)
            }
        }
        .onAppear {
            viewModel.fetchFoodItem(id: foodId)
        }
        .alert(item: Binding<ErrorAlert?>(
            get: { viewModel.errorMessage != nil ? ErrorAlert(message: viewModel.errorMessage!) : nil },
            set: { _ in viewModel.errorMessage = nil }
        )) { error in
            Alert(title: Text("Fehler"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }
    
    // Hilfsfunktionen
    private func getWeekdayName(for day: Int) -> String {
        let weekdays = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
        return weekdays[day]
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
#Preview {
    FoodDetailView(foodId: "asadsd")
}
