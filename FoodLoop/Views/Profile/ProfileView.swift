////
////  ProfileView.swift
////  Food
////
////  Created by Jefferson Prensa on 03.03.25.
////
//
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var showEditProfile = false
    @State private var showMyUploads = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let primaryColor = Color("PrimaryGreen")
    let secondaryColor = Color("SecondaryWhite")
    let accentColor = Color("AccentCoffee")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profilheader
                    ProfileHeaderView(user: viewModel.fireUser, rating: viewModel.userRating)
                        .padding(.bottom)
                    
                    // Statistiken
                    VStack(spacing: 16) {
                        Text("Deine Statistiken")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 20) {
                            // Gerettete Lebensmittel
                            StatisticCard(
                                value: "\(viewModel.foodsSaved)",
                                label: "Gerettete Lebensmittel",
                                icon: "leaf.fill",
                                color: primaryColor
                            )
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 120)
                            
                            // Level
                            StatisticCard(
                                value: viewModel.fireUser?.levelTitle ?? "Einsteiger",
                                label: "Aktuelles Level",
                                icon: "trophy.fill",
                                color: .yellow
                            )
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 120)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Level-Fortschritt
                        HStack(spacing: 20) {
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
                                            .frame(width: min(CGFloat(viewModel.foodsSaved % 10) / 10.0 * geometry.size.width, geometry.size.width), height: 12)
                                    }
                                }
                                .frame(height: 12)
                                
                                Text("Noch \(10 - (viewModel.foodsSaved % 10)) für das nächste Level")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
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
                                    title: "Profilinfos",
                                    showDivider: true
                                )
                            }
                            
                            Button(action: { showMyUploads = true }) {
                                SettingsRowView(
                                    icon: "tray.full.fill",
                                    title: "Meine Uploads",
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
                                Toggle("", isOn: $isDarkMode)
                                    .labelsHidden()
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
                        Task{
                            await authViewModel.signOut()
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
                EditProfileView(user: viewModel.fireUser)
            }
            .sheet(isPresented: $showMyUploads) {
                MyUploadsView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.fetchUserProfile()
                Task { await viewModel.fetchUserItems() }
            }
        }
    }
}
