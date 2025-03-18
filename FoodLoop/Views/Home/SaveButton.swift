//
//  SaveButton.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 18.03.25.
//


import SwiftUI

struct SaveButton: View {
    let foodItem: FoodItem
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var foodListViewModel = FoodListViewModel()
    @State private var isSaved: Bool = false
    @State private var isLoading: Bool = false
    
    var size: CGFloat = 20
    var showBackground: Bool = true
    
    var body: some View {
        Button {
            if !isLoading {
                toggleSaveStatus()
            }
        } label: {
            ZStack {
                if showBackground {
                    Circle()
                        .fill(Color.white)
                        .frame(width: size + 16, height: size + 16)
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                }
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.7)
                        .frame(width: size, height: size)
                } else {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .font(.system(size: size))
                        .foregroundColor(isSaved ? .red : .gray)
                }
            }
        }
        .buttonStyle(BorderlessButtonStyle())
        .onAppear {
            // Beim Erscheinen prüfen, ob das Element gespeichert ist
            checkSaveStatus()
        }
    }
    
    private func checkSaveStatus() {
        isSaved = foodListViewModel.isItemSaved(itemId: foodItem.id, user: authViewModel.fireUser)
    }
    
    private func toggleSaveStatus() {
        isLoading = true
        
        foodListViewModel.toggleSaveItem(item: foodItem, user: authViewModel.fireUser) { success in
            DispatchQueue.main.async {
                isLoading = false
                
                if success {
                    // Status umschalten, wenn erfolgreich
                    isSaved.toggle()
                    
                    // Auch den FireUser in AuthViewModel aktualisieren
                    if var updatedUser = authViewModel.fireUser {
                        if isSaved {
                            // Element zu Favoriten hinzufügen
                            if !updatedUser.savedItems!.contains(foodItem.id) {
                                updatedUser.savedItems?.append(foodItem.id)
                            }
                        } else {
                            // Element aus Favoriten entfernen
                            updatedUser.savedItems?.removeAll(where: { $0 == foodItem.id })
                        }
                        
                        // AuthViewModel mit dem aktualisierten Benutzer aktualisieren
                        // Hinweis: Diese Methode muss im AuthViewModel existieren
                        // authViewModel.updateUserProfile(updatedUser)
                    }
                    
                    // Feedback für den Benutzer (optional)
                    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                    feedbackGenerator.impactOccurred()
                }
            }
        }
    }
}
