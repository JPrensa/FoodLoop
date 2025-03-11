struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreedToTerms = false
    
    // Farben
    let primaryColor = Color("PrimaryGreen")
    let secondaryColor = Color("SecondaryWhite")
    
    var body: some View {
        ZStack {
            // Hintergrund
            secondaryColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Titel
                    Text("Konto erstellen")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Formular
                    VStack(spacing: 20) {
                        // Benutzername
                        FormField(
                            title: "Benutzername",
                            placeholder: "Dein Name",
                            text: $username,
                            keyboardType: .default
                        )
                        
                        // E-Mail
                        FormField(
                            title: "E-Mail",
                            placeholder: "beispiel@email.com",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        
                        // Passwort
                        PasswordField(
                            title: "Passwort",
                            placeholder: "Mindestens 8 Zeichen",
                            text: $password
                        )
                        
                        // Passwort bestätigen
                        PasswordField(
                            title: "Passwort bestätigen",
                            placeholder: "Passwort erneut eingeben",
                            text: $confirmPassword
                        )
                        
                        // AGB Zustimmung
                        HStack {
                            Toggle("", isOn: $agreedToTerms)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: primaryColor))
                            
                            Group {
                                Text("Ich stimme den ")
                                + Text("Nutzungsbedingungen")
                                    .foregroundColor(primaryColor)
                                    .underline()
                                + Text(" und der ")
                                + Text("Datenschutzerklärung")
                                    .foregroundColor(primaryColor)
                                    .underline()
                                + Text(" zu.")
                            }
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    // Registrieren-Button
                    Button(action: {
                        // Hier würden wir die Registrierung implementieren
                        // Da dies nicht in den Prioritäten ist, fügen wir die Implementierung später hinzu
                    }) {
                        HStack {
                            Text("Registrieren")
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
                        .background(isFormValid ? primaryColor : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || authViewModel.isLoading)
                    
                    Spacer(minLength: 40)
                    
                    // Zurück zur Anmeldung
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Zurück zur Anmeldung")
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .padding(24)
            }
        }
        .navigationBarBackButtonHidden(true)
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
    