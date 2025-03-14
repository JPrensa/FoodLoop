//
//  MainView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//

//import SwiftUI
//import MapKit
//
//struct MainView: View {
// //   @ObservedObject var userViewModel: UserProfileViewModel
//    @StateObject var authViewModel = AuthViewModel()
//    @State private var selectedTab = 0
//    
//    let primaryColor = Color("PrimaryGreen") 
//    let secondaryColor = Color("SecondaryWhite")
//    let accentColor = Color("AccentCoffee")
//    
//    var body: some View {
//        Group {
////            if authViewModel.isAuthenticated {
//                TabView(selection: $selectedTab) {
//                    HomeView()
//                        .tabItem {
//                            Label("Home", systemImage: "house.fill")
//                        }
//                        .tag(0)
//                    
//                    MapView()
//                        .tabItem {
//                            Label("Karte", systemImage: "map.fill")
//                        }
//                        .tag(1)
//                    
//                    UploadView()
//                        .tabItem {
//                            Label("Teilen", systemImage: "plus.circle.fill")
//                        }
//                        .tag(2)
//                    
//                    SavedItemsView()
//                        .tabItem {
//                            Label("Favoriten", systemImage: "heart.fill")
//                        }
//                        .tag(3)
//                    
//                    ProfileView()
//                        .tabItem {
//                            Label("Profil", systemImage: "person.fill")
//                        }
//                        .tag(4)
//                }
//                .accentColor(primaryColor)
////            } else {
////                AuthView()
////            }
//        }
//        .environmentObject(authViewModel)
//    }
//}
import SwiftUI
import MapKit

struct MainView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
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
                    Label("Karte", systemImage: "map.fill")
                }
                .tag(1)
            
            UploadView()
                .tabItem {
                    Label("Teilen", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            SavedItemsView()
                .tabItem {
                    Label("Favoriten", systemImage: "heart.fill")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
                .tag(4)
        }
        .accentColor(primaryColor)
        // Wir benutzen @ObservedObject für direktes Binding
        // aber die Umgebungsvariable kann auch nützlich sein
        .environmentObject(authViewModel)
    }
}

#Preview {
    MainView(authViewModel: AuthViewModel())
}
