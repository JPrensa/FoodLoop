//
//  SavedItemsView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 10.03.25.
//

import SwiftUI

struct SavedItemsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var foodListViewModel = FoodListViewModel()
    @State private var isRefreshing = false
    
    let primaryColor = Color("PrimaryGreen")
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("SecondaryWhite").ignoresSafeArea()
                
                if foodListViewModel.isLoading {
                    ProgressView("Lade deine Favoriten...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(primaryColor)
                } else if foodListViewModel.savedItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Keine Favoriten gefunden")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Füge Lebensmittel zu deinen Favoriten hinzu, um sie hier zu sehen.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button {
                            withAnimation {
                                loadSavedItems()
                            }
                        } label: {
                            Label("Aktualisieren", systemImage: "arrow.clockwise")
                                .foregroundColor(.white)
                                .padding()
                                .background(primaryColor)
                                .cornerRadius(10)
                        }
                        .padding(.top)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(foodListViewModel.savedItems) { item in
                                NavigationLink(destination: FoodDetailView(foodId: item.id)) {
                                    SavedItemRow(item: item) {
                                        // Hier wird das Item aus den Favoriten entfernt
                                        removeSavedItem(item)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        isRefreshing = true
                        loadSavedItems()
                        isRefreshing = false
                    }
                }
            }
            .navigationTitle("Deine Favoriten")
            .onAppear {
                loadSavedItems()
            }
            .onChange(of: authViewModel.fireUser?.savedItems) { _ in
                loadSavedItems()
            }
            .alert(item: Binding<ErrorAlert?>(
                get: {
                    foodListViewModel.errorMessage != nil ? ErrorAlert(message: foodListViewModel.errorMessage!) : nil
                },
                set: { _ in foodListViewModel.errorMessage = nil }
            )) { errorAlert in
                Alert(
                    title: Text("Fehler"),
                    message: Text(errorAlert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func loadSavedItems() {
        guard let savedItemIds = authViewModel.fireUser?.savedItems else {
            return
        }
        
        foodListViewModel.fetchSavedItems(savedIds: savedItemIds)
    }
    
    private func removeSavedItem(_ item: FoodItem) {
        // Entfernen des Favoriten: Firestore & lokale UI
        guard let user = authViewModel.fireUser else { return }
        foodListViewModel.toggleSaveItem(item: item, user: user) { success in
            DispatchQueue.main.async {
                if success {
                    // lokale Entfernung
                    if let index = foodListViewModel.savedItems.firstIndex(where: { $0.id == item.id }) {
                        foodListViewModel.savedItems.remove(at: index)
                    }
                    // aktualisiere AuthViewModel
                    var updatedUser = user
                    updatedUser.savedItems.removeAll(where: { $0 == item.id })
                    authViewModel.fireUser = updatedUser
                } else {
                    // Fehlerbehandlung
                    foodListViewModel.errorMessage = "Fehler beim Entfernen des Favoriten"
                }
            }
        }
    }
}

// Angepasste Zeilenansicht für gespeicherte Elemente
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

// Hilfsstruktur für Fehlermeldungen
struct ErrorAlert: Identifiable {
    let id = UUID()
    let message: String
}

#Preview {
    SavedItemsView()
        .environmentObject(AuthViewModel())
}
