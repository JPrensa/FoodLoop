//
//  LoginView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 21.02.25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var userViewModel: UserViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isRegistering: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(isRegistering ? "Registrieren" : "Einloggen")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.blue)

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
                            await userViewModel.register(email: email, password: password)
                        } else {
                            await userViewModel.login(email: email, password: password)
                        }
                    }
                }) {
                    Text(isRegistering ? "Registrieren" : "Einloggen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                Button(action: {
                    isRegistering.toggle()
                }) {
                    Text(isRegistering ? "Hast du ein Konto? Einloggen" : "Noch kein Konto? Registrieren")
                        .foregroundColor(.blue)
                }

                Button(action: {
                    
                    Task {
                        await userViewModel.signInAnonymously()
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

// Preview für LoginView
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(userViewModel: UserViewModel())
    }
}

