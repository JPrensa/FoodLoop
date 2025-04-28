//
//  AuthView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 10.03.25.
//


import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showingRegistration = false
    @State private var email = ""
    @State private var password = ""
    
    // Farben
    let primaryColor = Color("PrimaryGreen")
    let secondaryColor = Color("SecondaryWhite")
    let accentColor = Color("AccentCoffee")
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrund
                secondaryColor.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Logo und Titel
                    VStack(spacing: 16) {
                        Image("App Logo")
                            .resizable()
                            .frame(width: 150, height: 150)
                            
                        
                        Text("Food Loop")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(primaryColor)
                        
                        Text("Rette Lebensmittel in deiner Nähe")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)
                    
                    // Login-Formular
                    VStack(spacing: 20) {
                        // E-Mail
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("E-mail", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                        }
                        
                        // Passwort
                        VStack(alignment: .leading, spacing: 8) {
                            SecureField("Passwort", text: $password)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                        }
                        
                        // Anmelde-Button
                        Button {
                            Task {
                                await authViewModel.login(email: email, password: password)
                            }
                        } label: {
                            HStack {
                                Text("Anmelden")
                                    .fontWeight(.semibold)
                                
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .padding(.leading, 8)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(primaryColor)
                            .cornerRadius(12)
                        }
                        .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
                        .opacity((email.isEmpty || password.isEmpty || authViewModel.isLoading) ? 0.7 : 1)
                        
                        // Passwort vergessen
                        Button("Passwort vergessen?") {
                            // Passwort-Reset-Funktion
                        }
                        .font(.footnote)
                        .foregroundColor(accentColor)
                    }
                    .padding(.horizontal, 24)
                    
                    // Trennlinie mit "oder"
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        
                        Text("oder")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 24)
                    
                    // Alternative Anmeldemethoden
                    VStack(spacing: 16) {
                        // Google-Anmeldung (Platzhalter, da nicht implementiert)
//                        Button {
//                            // Google-Anmeldung ausführen
//                        } label: {
//                            HStack {
//                                Image(systemName: "g.circle.fill")
//                                    .font(.title3)
//                                
//                                Text("Mit Google fortfahren")
//                                    .fontWeight(.medium)
//                            }
//                            .foregroundColor(.primary)
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(12)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                            )
//                        }
                        
                        // Anonyme Anmeldung
                        Button {
                            Task {
                                await authViewModel.signInAnonymously()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "person.fill.questionmark")
                                    .font(.title3)
                                
                                Text("Anonym fortfahren")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(authViewModel.isLoading)
                        .opacity(authViewModel.isLoading ? 0.7 : 1)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Registrierungslink
                    HStack {
                        Text("Noch kein Konto?")
                            .foregroundColor(.secondary)
                        
                        Button("Registrieren") {
                            showingRegistration = true
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(primaryColor)
                    }
                    .font(.subheadline)
                    .padding(.bottom, 24)
                }
            }
            .navigationDestination(isPresented: $showingRegistration) {
                RegisterView(authViewModel: authViewModel)
            }
            .alert(item: Binding<AuthError?>(
                get: {
                    authViewModel.errorMessage != nil ? AuthError(message: authViewModel.errorMessage!) : nil
                },
                set: { _ in authViewModel.errorMessage = nil }
            )) { error in
                Alert(
                    title: Text("Fehler"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}


struct AuthError: Identifiable {
    let id = UUID()
    let message: String
}

#Preview {
   AuthView(authViewModel: AuthViewModel())
}
