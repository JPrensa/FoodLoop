//
//  UserView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 21.02.25.
//

import SwiftUI

struct UserView: View {
    @ObservedObject var userViewModel: UserProfileViewModel
    @State private var isLoggingOut = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Willkommen, \(userViewModel.user?.email ?? "Anonymer Nutzer")!")
                    .font(.title)
                    .bold()
                    .padding()
                
                Text("User ID: \(userViewModel.user?.uid ?? "nicht angemeldet")")
                    .foregroundColor(.gray)
                    .padding()
                
                
                
                
                
                
                
                Button(action: {
                    isLoggingOut = true
                    Task {
                        await userViewModel.signOut()
                    }
                    
                }) {
                    Text("Abmelden")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                // Ladeanzeige während des Logouts
                                if isLoggingOut {
                                    ProgressView("Abmelden…")
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .padding()
                                }
            }
            .padding()
            
        }
        .onAppear {
                    // Überprüfen, ob der Benutzer beim Start noch eingeloggt ist
                    if !userViewModel.isUserLoggedIn {
                        isLoggingOut = false
                    }
                }
    }
}


#Preview {
    UserView(userViewModel: UserProfileViewModel())
}
