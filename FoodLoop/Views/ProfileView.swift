//
//  ProfileView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 10.03.25.
//




import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var userProfileviewModel = UserProfileViewModel()
    @State private var showEditProfile = false
    
    let primaryColor = Color("PrimaryGreen")
    let secondaryColor = Color("SecondaryWhite")
    let accentColor = Color("AccentCoffee")
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profilheader
                    ProfileHeaderView(user: userProfileviewModel.fireUser, rating: userProfileviewModel.userRating)
                        .padding(.bottom)
                    
                    // Statistiken
                    VStack(spacing: 16) {
                        Text("Deine Statistiken")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 20) {
                            // Gerettete Lebensmittel
                            StatisticCard(
                                value: "\(userProfileviewModel.foodsSaved)",
                                label: "Gerettete Lebensmittel",
                                icon: "leaf.fill",
                                color: primaryColor
                            )
                            
                            // Level
                            StatisticCard(
                                value: userProfileviewModel.fireUser?.levelTitle ?? "Einsteiger",
                                label: "Aktuelles Level",
                                icon: "trophy.fill",
                                color: .yellow
                            )
                        }
                        
                        // CO2 Ersparnis (Beispiel)
                        let co2Saved = Double(userProfileviewModel.foodsSaved) * 2.5 // Annahme: 2.5kg CO2 pro Lebensmittel
                        HStack(spacing: 20) {
                            StatisticCard(
                                value: String(format: "%.1f kg", co2Saved),
                                label: "CO₂ Ersparnis",
                                icon: "leaf.fill",
                                color: .green
                            )
                            
                            // Level-Fortschritt
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Level-Fortschritt")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 12)
                                        
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(primaryColor)
                                            .frame(width: min(CGFloat(userProfileviewModel.foodsSaved % 10) / 10.0 * geometry.size.width, geometry.size.width), height: 12)
                                    }
                                }
                                .frame(height: 12)
                                
                                Text("Noch \(10 - (userProfileviewModel.foodsSaved % 10)) für das nächste Level")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Einstellungen
                    VStack(spacing: 16) {
                        Text("Einstellungen")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 0) {
                            // Profil bearbeiten
                            Button(action: {
                                showEditProfile = true
                            }) {
                                SettingsRowView(
                                    icon: "person.fill",
                                    title: "Profil bearbeiten",
                                    showDivider: true
                                )
                            }
                            
                            // Benachrichtigungen
                            NavigationLink(destination: NotificationsSettingsView()) {
                                SettingsRowView(
                                    icon: "bell.fill",
                                    title: "Benachrichtigungen",
                                    showDivider: true
                                )
                            }
                            
                            // Dark Mode
                            HStack {
                                SettingsRowView(
                                    icon: "moon.fill",
                                    title: "Dark Mode",
                                    showDivider: true,
                                    showNavigationIcon: false
                                )
                                
                                Spacer()
                                
                                Toggle("", isOn: $userProfileviewModel.isDarkMode)
                                    .toggleStyle(SwitchToggleStyle(tint: primaryColor))
                                    .onChange(of: userProfileviewModel.isDarkMode) { newValue in
                                        userProfileviewModel.toggleDarkMode()
                                    }
                                    .padding(.trailing)
                            }
                            .contentShape(Rectangle())
                            
                            // Suchradius
                            NavigationLink(destination: SearchRadiusSettingsView()) {
                                SettingsRowView(
                                    icon: "location.circle.fill",
                                    title: "Suchradius",
                                    showDivider: true
                                )
                            }
                            
                            // Lebensmittelpräferenzen
                            NavigationLink(destination: FoodPreferencesSettingsView()) {
                                SettingsRowView(
                                    icon: "heart.fill",
                                    title: "Lebensmittelpräferenzen",
                                    showDivider: true
                                )
                            }
                            
                            // Über uns
                            NavigationLink(destination: AboutView()) {
                                SettingsRowView(
                                    icon: "info.circle.fill",
                                    title: "Über uns",
                                    showDivider: true
                                )
                            }
                            
                            // Hilfe & Support
                            NavigationLink(destination: HelpSupportView()) {
                                SettingsRowView(
                                    icon: "questionmark.circle.fill",
                                    title: "Hilfe & Support",
                                    showDivider: false
                                )
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    // Abmelden-Button
                    Button(action: {
                        Task {
                          await  authViewModel.signOut()
                        }
                    }) {
                        Text("Abmelden")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // App-Version
                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                }
                .padding(.vertical)
            }
            .navigationTitle("Profil")
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(user: userProfileviewModel.fireUser)
            }
            .onAppear {
                userProfileviewModel.fetchUserProfile()
            }
        }
    }
}

// Profilheader-Ansicht
struct ProfileHeaderView: View {
    let user: FireUser?
    let rating: Double?
    
    var body: some View {
        VStack(spacing: 16) {
            // Profilbild
            if let imageURL = user?.profileImageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                )
                .shadow(radius: 5)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    )
                    .shadow(radius: 5)
            }
            
            // Name und Bewertung
            VStack(spacing: 8) {
                Text(user?.username ?? "Benutzer")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let rating = rating {
                    HStack {
                        ForEach(0..<5) { i in
                            Image(systemName: i < Int(rating) ? "star.fill" : (i < Int(rating) + 1 && rating.truncatingRemainder(dividingBy: 1) > 0 ? "star.leadinghalf.filled" : "star"))
                                .foregroundColor(.yellow)
                        }
                        
                        Text(String(format: "%.1f", rating))
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

// Statistik-Karte
struct StatisticCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// Einstellungszeile
struct SettingsRowView: View {
    let icon: String
    let title: String
    let showDivider: Bool
    var showNavigationIcon: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color("PrimaryGreen"))
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if showNavigationIcon {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding(16)
            
            if showDivider {
                Divider()
                    .padding(.leading, 56)
            }
        }
    }
}

// Profilbearbeitung
struct EditProfileView: View {
    let user: FireUser?
    @Environment(\.presentationMode) var presentationMode
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    // Profilbild
                    HStack {
                        Spacer()
                        
                        VStack {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else if let imageURL = user?.profileImageURL, let url = URL(string: imageURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                    )
                            }
                            
                            Button("Foto ändern") {
                                showingImagePicker = true
                            }
                            .font(.footnote)
                            .foregroundColor(Color("PrimaryGreen"))
                            .padding(.top, 8)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(selectedImage: $selectedImage)
                    }
                }
                
                Section(header: Text("Persönliche Informationen")) {
                    TextField("Benutzername", text: $username)
                    TextField("E-Mail", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    TextField("Telefonnummer", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section {
                    Button("Speichern") {
                        // Profil speichern und zurück
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .listRowBackground(Color("PrimaryGreen"))
                }
            }
            .navigationTitle("Profil bearbeiten")
            .navigationBarItems(trailing: Button("Abbrechen") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                // Daten aus dem User-Objekt laden
                if let user = user {
                    username = user.username
                    email = user.email ?? ""
                    phoneNumber = user.phoneNumber ?? ""
                }
            }
        }
    }
}

// Platzhalterkomponenten für die Einstellungsansichten
struct NotificationsSettingsView: View {
    var body: some View {
        Text("Benachrichtigungseinstellungen")
            .navigationTitle("Benachrichtigungen")
    }
}

struct SearchRadiusSettingsView: View {
    @State private var radius: Double = 5.0 // in km
    
    var body: some View {
        VStack {
            Text("\(Int(radius)) km")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Slider(value: $radius, in: 1...25, step: 1)
                .padding(.horizontal)
            
            Text("Wähle den Radius, in dem du nach Lebensmitteln suchen möchtest.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .navigationTitle("Suchradius")
    }
}

struct FoodPreferencesSettingsView: View {
    var body: some View {
        Text("Lebensmittelpräferenzen")
            .navigationTitle("Präferenzen")
    }
}

struct AboutView: View {
    var body: some View {
        Text("Über uns")
            .navigationTitle("Über uns")
    }
}

struct HelpSupportView: View {
    var body: some View {
        Text("Hilfe & Support")
            .navigationTitle("Hilfe & Support")
    }
}
