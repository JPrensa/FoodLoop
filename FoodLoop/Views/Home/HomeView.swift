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
                

                if viewModel.isLoading && viewModel.nearbyItems.isEmpty && viewModel.recommendedItems.isEmpty {
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
                                // Meine Uploads
                                if !viewModel.userItems.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Meine Uploads")
                                            .font(.headline)
                                            .padding(.horizontal)
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 16) {
                                                ForEach(viewModel.userItems) { item in
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
            .navigationTitle("Start Seite")
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
                // Suchmodus setzen und Suche ausführen
                viewModel.isSearchMode = !newValue.isEmpty
                if newValue.isEmpty {
                    viewModel.clearSearch()
                } else {
                    viewModel.searchFoodItems(query: newValue)
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
                
                Button {
                    viewModel.showFilters = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .foregroundColor(primaryColor)
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
