//
//  HomeView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 10.03.25.
//
import SwiftUI
import CoreLocation


struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var viewModel = HomeViewModel()
    @State private var searchText = ""
    
    // Farben
    let primaryColor = Color("PrimaryGreen")
    let secondaryColor = Color("SecondaryWhite")
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrund
                secondaryColor.ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.nearbyItems.isEmpty && viewModel.recommendedItems.isEmpty {
                    // Ladeansicht
                    ProgressView("Lade Lebensmittel...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(primaryColor)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Suchleiste
                            SearchBar(text: $searchText, onSubmit: {
                                viewModel.searchFoodItems(query: searchText)
                            })
                            .padding(.horizontal)
                            
                            // Wenn Suchmodus aktiv ist, nur Suchergebnisse anzeigen
                            if viewModel.isSearchMode {
                                searchResultsSection
                            } else {
                                // Empfohlene Lebensmittel
                                if !viewModel.recommendedItems.isEmpty {
                                    recommendedSection
                                }
                                
                                // Lebensmittel in der Nähe
                                nearbySection
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        // Beim Pull-to-Refresh neu laden
                        await viewModel.refreshData()
                    }
                }
            }
            .navigationTitle("Food Rescue")
            .navigationBarItems(trailing: locationButton)
            .task {
                // Daten beim Erscheinen laden
                await viewModel.refreshData()
            }
            .onChange(of: searchText) { newValue in
                // Suchmodus setzen
                viewModel.isSearchMode = !newValue.isEmpty
                
                // Wenn Suchfeld geleert wird, Suchmodus beenden
                if newValue.isEmpty {
                    viewModel.clearSearch()
                }
            }
            .alert(item: Binding<ErrorAlert?>(
                get: { viewModel.errorMessage != nil ? ErrorAlert(message: viewModel.errorMessage!) : nil },
                set: { _ in viewModel.errorMessage = nil }
            )) { error in
                Alert(
                    title: Text("Fehler"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // Standort-Button in der Navigation
    private var locationButton: some View {
        Button {
            viewModel.requestLocation()
        } label: {
            Image(systemName: "location.circle.fill")
                .foregroundColor(primaryColor)
        }
    }
    
    // Empfohlene Lebensmittel
    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Empfohlen für dich")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.recommendedItems) { item in
                        NavigationLink(destination: FoodDetailView(foodId: item.id)) {
                            FoodCardView(item: item)
                                .frame(width: 160, height: 220)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // Lebensmittel in der Nähe
    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("In deiner Nähe")
                .font(.headline)
                .padding(.horizontal)
            
            if viewModel.isLoading && viewModel.nearbyItems.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding()
            } else if viewModel.nearbyItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "mappin.slash")
                        .font(.system(size: 36))
                        .foregroundColor(.gray)
                    
                    Text("Keine Lebensmittel in der Nähe gefunden")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button {
                        viewModel.requestLocation()
                    } label: {
                        Text("Standort aktualisieren")
                            .font(.subheadline)
                            .foregroundColor(primaryColor)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.nearbyItems) { item in
                        NavigationLink(destination: FoodDetailView(foodId: item.id)) {
                            FoodItemRow(item: item)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // Suchergebnisse
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !searchText.isEmpty {
                if viewModel.isSearching {
                    HStack {
                        Spacer()
                        ProgressView("Suche...")
                        Spacer()
                    }
                    .padding()
                } else if viewModel.searchResults.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundColor(.gray)
                        
                        Text("Keine Ergebnisse für \"\(searchText)\" gefunden")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    Text("Suchergebnisse")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.searchResults) { item in
                            NavigationLink(destination: FoodDetailView(foodId: item.id)) {
                                FoodItemRow(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}











//import SwiftUI
//import MapKit
//struct HomeView: View {
//    @StateObject var foodListviewModel = FoodListViewModel()
//    @State private var searchText = ""
//    
//    // Subview für den empfohlenen Bereich
//    var recommendedSection: some View {
//        VStack(alignment: .leading) {
//            Text("Empfohlen für dich")
//                .font(.headline)
//                .padding(.horizontal)
//            
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 12) {
//                    ForEach(foodListviewModel.recommendedItems) { item in
//                        NavigationLink(destination: FoodDetailView(foodId: item.id)) {
//                            FoodCardView(item: item)
//                                .frame(width: 160, height: 220)
//                        }
//                    }
//                }
//                .padding(.horizontal)
//            }
//        }
//    }
//    
//    // Subview für den Bereich "In deiner Nähe"
//    var nearbySection: some View {
//        VStack(alignment: .leading) {
//            Text("In deiner Nähe")
//                .font(.headline)
//                .padding(.horizontal)
//            
//            if foodListviewModel.isLoading {
//                ProgressView()
//                    .frame(maxWidth: .infinity)
//                    .padding()
//            } else if foodListviewModel.nearbyItems.isEmpty {
//                Text("Keine Lebensmittel in deiner Nähe gefunden.")
//                    .foregroundColor(.gray)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//            } else {
//                LazyVStack(spacing: 12) {
//                    ForEach(foodListviewModel.nearbyItems) { item in
//                        NavigationLink(destination: FoodDetailView(foodId: item.id)) {
//                            FoodRowView(item: item)
//                        }
//                    }
//                }
//                .padding(.horizontal)
//            }
//        }
//    }
//    
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 16) {
//                    // Suchleiste
//                    SearchBar(text: $searchText)
//                        .padding(.horizontal)
//                    
//                    // Ausgelagerte Bereiche
//                    recommendedSection
//                    nearbySection
//                }
//                .padding(.vertical)
//            }
//            .navigationTitle("Food Rescue")
//            .onAppear {
//                foodListviewModel.fetchNearbyItems()
//                foodListviewModel.fetchRecommendedItems()
//            }
//        }
//    }
//}
//
//#Preview {
//    HomeView(foodListviewModel: FoodListViewModel())
//}
