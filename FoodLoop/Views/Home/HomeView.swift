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
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText = ""
    
    // Farben
    let primaryColor = Color("PrimaryGreen")
    let secondaryColor = Color("SecondaryWhite")
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrund
                secondaryColor.ignoresSafeArea()
                
                if viewModel.isFirstLoad {
                    // Erste Ladung mit LocationPrompt
                    VStack(spacing: 20) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 50))
                            .foregroundColor(primaryColor)
                        
                        Text("Standort wird benötigt")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Um Lebensmittel in deiner Nähe zu finden, benötigen wir deinen Standort.")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button {
                            viewModel.requestLocationPermission()
                        } label: {
                            Text("Standort freigeben")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(primaryColor)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 50)
                        .padding(.top, 10)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    .padding()
                } else if viewModel.isLoading && viewModel.nearbyItems.isEmpty && viewModel.recommendedItems.isEmpty {
                    // Ladeansicht
                    ProgressView("Lade Lebensmittel...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(primaryColor)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Standortanzeige
                            LocationBar(
                                locationName: viewModel.locationService.locationName,
                                isLocationAvailable: viewModel.locationService.currentLocation != nil,
                                onRefresh: { viewModel.refreshLocation() }
                            )
                            .padding(.horizontal)
                            
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            viewModel.sortBy = .distance
                        } label: {
                            Label("Nach Entfernung", systemImage: "location")
                        }
                        
                        Button {
                            viewModel.sortBy = .newest
                        } label: {
                            Label("Neueste zuerst", systemImage: "clock")
                        }
                        
                        Button {
                            viewModel.sortBy = .expiry
                        } label: {
                            Label("Nach Ablaufdatum", systemImage: "calendar")
                        }
                        
                        Divider()
                        
                        Button {
                            viewModel.showFilters = true
                        } label: {
                            Label("Filter", systemImage: "line.3.horizontal.decrease")
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(primaryColor)
                    }
                }
            }
            .task {
                // Daten beim Erscheinen laden
                await viewModel.loadData()
            }
            .onChange(of: searchText) { newValue in
                // Suchmodus setzen
                viewModel.isSearchMode = !newValue.isEmpty
                
                // Wenn Suchfeld geleert wird, Suchmodus beenden
                if newValue.isEmpty {
                    viewModel.clearSearch()
                }
            }
            .alert(item: $viewModel.alertMessage) { alert in
                Alert(
                    title: Text("Hinweis"),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $viewModel.showFilters) {
                HomeFilterView(
                    selectedCategories: $viewModel.selectedCategories,
                    maxDistance: $viewModel.maxDistance,
                    includeExpired: $viewModel.includeExpired,
                    categories: viewModel.availableCategories,
                    resetFilters: viewModel.resetFilters,
                    applyFilters: viewModel.applyFilters
                )
                .presentationDetents([.medium, .large])
            }
        }
    }
    
    // Standortanzeige mit Aktualisierungsfunktion
    struct LocationBar: View {
        let locationName: String
        let isLocationAvailable: Bool
        let onRefresh: () -> Void
        
        var body: some View {
            HStack {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(Color("PrimaryGreen"))
                    
                    Text(isLocationAvailable ? locationName : "Standort nicht verfügbar")
                        .font(.subheadline)
                        .lineLimit(1)
                    
                    Spacer()
                }
                .padding(10)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
            }
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
            HStack {
                Text("In deiner Nähe")
                    .font(.headline)
                
                Spacer()
                
                if !viewModel.nearbyItems.isEmpty {
                    Text("\(viewModel.nearbyItems.count) Ergebnisse")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
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
                        viewModel.refreshLocation()
                    } label: {
                        Text("Standort aktualisieren")
                            .font(.subheadline)
                            .foregroundColor(Color("PrimaryGreen"))
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

//struct HomeView: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//    @StateObject var viewModel = HomeViewModel()
//    @State private var searchText = ""
//    
//    // Farben
//    let primaryColor = Color("PrimaryGreen")
//    let secondaryColor = Color("SecondaryWhite")
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                // Hintergrund
//                secondaryColor.ignoresSafeArea()
//                
//                if viewModel.isLoading && viewModel.nearbyItems.isEmpty && viewModel.recommendedItems.isEmpty {
//                    // Ladeansicht
//                    ProgressView("Lade Lebensmittel...")
//                        .progressViewStyle(CircularProgressViewStyle())
//                        .tint(primaryColor)
//                } else {
//                    ScrollView {
//                        VStack(spacing: 24) {
//                            // Suchleiste
//                            SearchBar(text: $searchText, onSubmit: {
//                                viewModel.searchFoodItems(query: searchText)
//                            })
//                            .padding(.horizontal)
//                            
//                            // Wenn Suchmodus aktiv ist, nur Suchergebnisse anzeigen
//                            if viewModel.isSearchMode {
//                                searchResultsSection
//                            } else {
//                                // Empfohlene Lebensmittel
//                                if !viewModel.recommendedItems.isEmpty {
//                                    recommendedSection
//                                }
//                                
//                                // Lebensmittel in der Nähe
//                                nearbySection
//                            }
//                        }
//                        .padding(.vertical)
//                    }
//                    .refreshable {
//                        // Beim Pull-to-Refresh neu laden
//                        await viewModel.refreshData()
//                    }
//                }
//            }
//            .navigationTitle("Food Rescue")
//            .navigationBarItems(trailing: locationButton)
//            .task {
//                // Daten beim Erscheinen laden
//                await viewModel.refreshData()
//            }
//            .onChange(of: searchText) { newValue in
//                // Suchmodus setzen
//                viewModel.isSearchMode = !newValue.isEmpty
//                
//                // Wenn Suchfeld geleert wird, Suchmodus beenden
//                if newValue.isEmpty {
//                    viewModel.clearSearch()
//                }
//            }
//            .alert(item: Binding<ErrorAlert?>(
//                get: { viewModel.errorMessage != nil ? ErrorAlert(message: viewModel.errorMessage!) : nil },
//                set: { _ in viewModel.errorMessage = nil }
//            )) { error in
//                Alert(
//                    title: Text("Fehler"),
//                    message: Text(error.message),
//                    dismissButton: .default(Text("OK"))
//                )
//            }
//        }
//    }
//    
//    // Standort-Button in der Navigation
//    private var locationButton: some View {
//        Button {
//            viewModel.requestLocation()
//        } label: {
//            Image(systemName: "location.circle.fill")
//                .foregroundColor(primaryColor)
//        }
//    }
//    
//    // Empfohlene Lebensmittel
//    private var recommendedSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Empfohlen für dich")
//                .font(.headline)
//                .padding(.horizontal)
//            
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 16) {
//                    ForEach(viewModel.recommendedItems) { item in
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
//    // Lebensmittel in der Nähe
//    private var nearbySection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("In deiner Nähe")
//                .font(.headline)
//                .padding(.horizontal)
//            
//            if viewModel.isLoading && viewModel.nearbyItems.isEmpty {
//                HStack {
//                    Spacer()
//                    ProgressView()
//                    Spacer()
//                }
//                .padding()
//            } else if viewModel.nearbyItems.isEmpty {
//                VStack(spacing: 12) {
//                    Image(systemName: "mappin.slash")
//                        .font(.system(size: 36))
//                        .foregroundColor(.gray)
//                    
//                    Text("Keine Lebensmittel in der Nähe gefunden")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                    
//                    Button {
//                        viewModel.requestLocation()
//                    } label: {
//                        Text("Standort aktualisieren")
//                            .font(.subheadline)
//                            .foregroundColor(primaryColor)
//                    }
//                }
//                .frame(maxWidth: .infinity)
//                .padding()
//            } else {
//                LazyVStack(spacing: 16) {
//                    ForEach(viewModel.nearbyItems) { item in
//                        NavigationLink(destination: FoodDetailView(foodId: item.id)) {
//                            FoodItemRow(item: item)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
//                .padding(.horizontal)
//            }
//        }
//    }
//    
//    // Suchergebnisse
//    private var searchResultsSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            if !searchText.isEmpty {
//                if viewModel.isSearching {
//                    HStack {
//                        Spacer()
//                        ProgressView("Suche...")
//                        Spacer()
//                    }
//                    .padding()
//                } else if viewModel.searchResults.isEmpty {
//                    VStack(spacing: 12) {
//                        Image(systemName: "magnifyingglass")
//                            .font(.system(size: 36))
//                            .foregroundColor(.gray)
//                        
//                        Text("Keine Ergebnisse für \"\(searchText)\" gefunden")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                            .multilineTextAlignment(.center)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                } else {
//                    Text("Suchergebnisse")
//                        .font(.headline)
//                        .padding(.horizontal)
//                    
//                    LazyVStack(spacing: 16) {
//                        ForEach(viewModel.searchResults) { item in
//                            NavigationLink(destination: FoodDetailView(foodId: item.id)) {
//                                FoodItemRow(item: item)
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//            }
//        }
//    }
//}












//struct HomeView: View {
//    @StateObject var foodListviewModel = FoodListViewModel()
//    @State private var searchText = ""
//    


//
//#Preview {
//    HomeView(foodListviewModel: FoodListViewModel())
//}
