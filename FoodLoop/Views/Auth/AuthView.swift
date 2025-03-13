//
//  AuthView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 10.03.25.
//


//import SwiftUI
//
//struct AuthView: View {
//    @ObservedObject var userViewModel: UserProfileViewModel
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var isRegistering: Bool = false
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                Text(isRegistering ? "Registrieren" : "Einloggen")
//                    .font(.largeTitle)
//                    .bold()
//                    .foregroundColor(.green)
//
//                TextField("E-Mail", text: $email)
//                    .keyboardType(.emailAddress)
//                    .autocapitalization(.none)
//                    .padding()
//                    .background(Color.gray.opacity(0.2))
//                    .cornerRadius(10)
//                    .padding(.horizontal)
//
//                SecureField("Passwort", text: $password)
//                    .padding()
//                    .background(Color.gray.opacity(0.2))
//                    .cornerRadius(10)
//                    .padding(.horizontal)
//
//                Button(action: {
//                    Task {
//                        if isRegistering {
// //                           await userViewModel.register(email: email, password: password)
//                        } else {
// //                           await userViewModel.login(email: email, password: password)
//                        }
//                    }
//                }) {
//                    Text(isRegistering ? "Registrieren" : "Einloggen")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.green)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                        .padding(.horizontal)
//                }
//
//                Button(action: {
//                    isRegistering.toggle()
//                }) {
//                    Text(isRegistering ? "Hast du ein Konto? Einloggen" : "Noch kein Konto? Registrieren")
//                        .foregroundColor(.green)
//                }
//
//                Button(action: {
//                    
//                    Task {
// //                       await userViewModel.signInAnonymously()
//                    }
//                }) {
//                    Text("Anonym anmelden")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.gray)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                        .padding(.horizontal)
//                }
//
//                if let errorMessage = userViewModel.errorMessage {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                        .padding()
//                }
//            }
//            .padding()
//        }
//    }
//}
//
//#Preview {
//    AuthView(userViewModel: UserProfileViewModel())
//}
import SwiftUI
import AuthenticationServices
//import GoogleSignIn

struct AuthView: View {
   // @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showingRegistration = false
    @State private var email = ""
    @State private var password = ""
    
    
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
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 70))
                            .foregroundColor(primaryColor)
                        
                        Text("Food Rescue")
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
//                            Text("E-Mail")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
                            
                            TextField("E-mail", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        // Passwort
                        VStack(alignment: .leading, spacing: 8) {
//                            Text("Passwort")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
                            
                            SecureField("Passwort", text: $password)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        // Anmelde-Button
                        Button(action: {
                            // Hier würden wir die E-Mail/Passwort-Authentifizierung implementieren,
                            // die aktuell nicht in unseren Prioritäten ist
                        }) {
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
                        // Google-Anmeldung
                        Button(action: {
                            // Google-Anmeldung ausführen
                            // Implementierung für GoogleSignIn hier
                        }) {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                    .font(.title3)
                                
                                Text("Mit Google fortfahren")
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
                        
                        // Anonyme Anmeldung
                        Button(action: {
                            Task {
                                    await authViewModel.signInAnonymously()
                                }
                        }) {
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
                RegisterView(authViewModel: AuthViewModel())
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

#Preview {
    AuthView(authViewModel: AuthViewModel())
}

//struct RegisterView: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//    @Environment(\.dismiss) private var dismiss
//    
//    @State private var username = ""
//    @State private var email = ""
//    @State private var password = ""
//    @State private var confirmPassword = ""
//    @State private var agreedToTerms = false
//    
//    // Farben
//    let primaryColor = Color("PrimaryGreen")
//    let secondaryColor = Color("SecondaryWhite")
//    
//    var body: some View {
//        ZStack {
//            // Hintergrund
//            secondaryColor.ignoresSafeArea()
//            
//            ScrollView {
//                VStack(spacing: 24) {
//                    // Titel
//                    Text("Konto erstellen")
//                        .font(.title)
//                        .fontWeight(.bold)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    
//                    // Formular
//                    VStack(spacing: 20) {
//                        // Benutzername
//                        FormField(
//                            title: "Benutzername",
//                            placeholder: "Dein Name",
//                            text: $username,
//                            keyboardType: .default
//                        )
//                        
//                        // E-Mail
//                        FormField(
//                            title: "E-Mail",
//                            placeholder: "beispiel@email.com",
//                            text: $email,
//                            keyboardType: .emailAddress
//                        )
//                        
//                        // Passwort
//                        PasswordField(
//                            title: "Passwort",
//                            placeholder: "Mindestens 8 Zeichen",
//                            text: $password
//                        )
//                        
//                        // Passwort bestätigen
//                        PasswordField(
//                            title: "Passwort bestätigen",
//                            placeholder: "Passwort erneut eingeben",
//                            text: $confirmPassword
//                        )
//                        
//                        // AGB Zustimmung
//                        HStack {
//                            Toggle("", isOn: $agreedToTerms)
//                                .labelsHidden()
//                                .toggleStyle(SwitchToggleStyle(tint: primaryColor))
//                            
//                            Group {
//                                Text("Ich stimme den ")
//                                + Text("Nutzungsbedingungen")
//                                    .foregroundColor(primaryColor)
//                                    .underline()
//                                + Text(" und der ")
//                                + Text("Datenschutzerklärung")
//                                    .foregroundColor(primaryColor)
//                                    .underline()
//                                + Text(" zu.")
//                            }
//                            .font(.footnote)
//                            .fixedSize(horizontal: false, vertical: true)
//                        }
//                    }
//                    
//                    // Registrieren-Button
//                    Button(action: {
//                        // Hier würden wir die Registrierung implementieren
//                        // Da dies nicht in den Prioritäten ist, fügen wir die Implementierung später hinzu
//                    }) {
//                        HStack {
//                            Text("Registrieren")
//                                .fontWeight(.semibold)
//                            
//                            if authViewModel.isLoading {
//                                ProgressView()
//                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                                    .padding(.leading, 8)
//                            }
//                        }
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(isFormValid ? primaryColor : Color.gray)
//                        .cornerRadius(12)
//                    }
//                    .disabled(!isFormValid || authViewModel.isLoading)
//                    
//                    Spacer(minLength: 40)
//                    
//                    // Zurück zur Anmeldung
//                    Button(action: {
//                        dismiss()
//                    }) {
//                        HStack {
//                            Image(systemName: "arrow.left")
//                            Text("Zurück zur Anmeldung")
//                        }
//                        .foregroundColor(.secondary)
//                    }
//                }
//                .padding(24)
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//        .alert(item: Binding<AuthError?>(
//            get: {
//                authViewModel.errorMessage != nil ? AuthError(message: authViewModel.errorMessage!) : nil
//            },
//            set: { _ in authViewModel.errorMessage = nil }
//        )) { error in
//            Alert(
//                title: Text("Fehler"),
//                message: Text(error.message),
//                dismissButton: .default(Text("OK"))
//            )
//        }
//    }
//    
//    // Formularvalidierung
//    private var isFormValid: Bool {
//        !username.isEmpty &&
//        !email.isEmpty && isValidEmail(email) &&
//        !password.isEmpty && password.count >= 8 &&
//        password == confirmPassword &&
//        agreedToTerms
//    }
//    
//    // E-Mail-Validierung
//    private func isValidEmail(_ email: String) -> Bool {
//        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
//        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
//        return emailPredicate.evaluate(with: email)
//    }
//}

//// Hilfskomponenten
//struct FormField: View {
//    let title: String
//    let placeholder: String
//    @Binding var text: String
//    var keyboardType: UIKeyboardType = .default
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(title)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//            
//            TextField(placeholder, text: $text)
//                .keyboardType(keyboardType)
//                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
//                .disableAutocorrection(keyboardType == .emailAddress)
//                .padding()
//                .background(Color.white)
//                .cornerRadius(12)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                )
//        }
//    }
//}

//struct PasswordField: View {
//    let title: String
//    let placeholder: String
//    @Binding var text: String
//    @State private var isSecure = true
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(title)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//            
//            HStack {
//                if isSecure {
//                    SecureField(placeholder, text: $text)
//                } else {
//                    TextField(placeholder, text: $text)
//                }
//                
//                Button(action: {
//                    isSecure.toggle()
//                }) {
//                    Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
//                        .foregroundColor(.gray)
//                }
//            }
//            .padding()
//            .background(Color.white)
//            .cornerRadius(12)
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//            )
//        }
//    }
//}
//
//// Hilfstruktur für Fehlermeldungen
//struct AuthError: Identifiable {
//    let id = UUID()
//    let message: String
//}
