//
//  MainView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//


import SwiftUI
import MapKit

struct MainView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let primaryColor = Color("PrimaryGreen")
    let secondaryColor = Color("SecondaryWhite")
    let accentColor = Color("AccentCoffee")
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(1)
            
            UploadView()
                .tabItem {
                    Label("Share", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            SavedItemsView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
       }
        .tint(primaryColor)
        .environmentObject(authViewModel)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    MainView(authViewModel: AuthViewModel())
}
