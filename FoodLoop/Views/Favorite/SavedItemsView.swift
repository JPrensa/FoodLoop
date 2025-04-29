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



// Hilfsstruktur für Fehlermeldungen
struct ErrorAlert: Identifiable {
    let id = UUID()
    let message: String
}

#Preview {
    SavedItemsView()
        .environmentObject(AuthViewModel())
}
