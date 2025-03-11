//
//  AuthView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 10.03.25.
//


import SwiftUI

struct AuthView: View {
    @ObservedObject var userViewModel: UserProfileViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isRegistering: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(isRegistering ? "Registrieren" : "Einloggen")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.green)

                TextField("E-Mail", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                SecureField("Passwort", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                Button(action: {
                    Task {
                        if isRegistering {
 //                           await userViewModel.register(email: email, password: password)
                        } else {
 //                           await userViewModel.login(email: email, password: password)
                        }
                    }
                }) {
                    Text(isRegistering ? "Registrieren" : "Einloggen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                Button(action: {
                    isRegistering.toggle()
                }) {
                    Text(isRegistering ? "Hast du ein Konto? Einloggen" : "Noch kein Konto? Registrieren")
                        .foregroundColor(.green)
                }

                Button(action: {
                    
                    Task {
 //                       await userViewModel.signInAnonymously()
                    }
                }) {
                    Text("Anonym anmelden")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                if let errorMessage = userViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
        }
    }
}

#Preview {
    AuthView(userViewModel: UserProfileViewModel())
}
