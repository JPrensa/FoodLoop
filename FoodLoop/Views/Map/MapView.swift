//
//  MapView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//



import SwiftUI
import MapKit
enum MapStyle: String, CaseIterable, Hashable {
    case standard
    case satellite
    case hybrid
}
struct MapView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = MapViewModel()
    @State private var mapStyle: MapStyle = .standard
    
    // Farben
    let primaryColor = Color("PrimaryGreen")
    let secondaryColor = Color("SecondaryWhite")
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Karte mit expliziter Parameterreihenfolge
                Map(
                    coordinateRegion: $viewModel.region,
                    interactionModes: .all,
                    showsUserLocation: true,
                    userTrackingMode: nil,//userTrackingMode: .constant(.none),
           //         mapStyle: mapStyle,
                    annotationItems: viewModel.filteredItems,
                    annotationContent: { item in
                        MapAnnotation(coordinate: item.location.coordinate) {
                            FoodMapMarker(
                                item: item,
                                isSelected: viewModel.selectedItem?.id == item.id,
                                onTap: { viewModel.selectItem(item) }
                            )
                        }
                    }
                )
                //.ignoresSafeArea(edges: .top)
                // Karten-Typ Picker ausgeblendet
                // .overlay(MapTypePickerView(mapStyle: $mapStyle))
                
                // Filter und Detailanzeigen als separater Overlay-Container
                MapOverlaysView(viewModel: viewModel, primaryColor: primaryColor)
                
                // Ladeindikator
                if viewModel.isLoading {
                    LoadingIndicatorOverlay()
                }
                

            }
            .navigationTitle("In deiner Nähe")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "Ort suchen")
            .onSubmit(of: .search) {
                viewModel.geocodeAddress()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.showFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .foregroundColor(primaryColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.recenterMap()
                    } label: {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(primaryColor)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showFilters) {
                FilterView(
                    selectedCategories: $viewModel.selectedCategories,
                    radiusInKm: $viewModel.radiusInKm,
                    categories: viewModel.availableCategories,
                    resetFilters: viewModel.resetFilters
                )
                .presentationDetents([.medium, .large])
            }
            .navigationDestination(item: $viewModel.navigateToDetailId) { foodId in
                FoodDetailView(foodId: foodId)
            }
            .task {
                // Standortberechtigung anfordern
                viewModel.requestLocationPermission()
                // Daten laden beim Erscheinen
                await viewModel.loadItems()
            }
            .alert(item: $viewModel.alertMessage) { message in
                Alert(
                    title: Text("Hinweis"),
                    message: Text(message.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

// MARK: - Subviews

struct MapTypePickerView: View {
    @Binding var mapStyle: MapStyle
    
    var body: some View {
        VStack {
            Picker("Kartentyp", selection: $mapStyle) {
                Text("Standard").tag(MapStyle.standard)
                Text("Satellit").tag(MapStyle.satellite)
                Text("Hybrid").tag(MapStyle.hybrid)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.top, 10)
            
            Spacer()
        }
    }
}

struct MapOverlaysView: View {
    @ObservedObject var viewModel: MapViewModel
    let primaryColor: Color
    
    var body: some View {
        VStack {
            // Filter-Leiste
            HStack {
                Spacer()
                FilterBar(
                    selectedCategories: $viewModel.selectedCategories,
                    radiusInKm: $viewModel.radiusInKm,
                    categories: viewModel.availableCategories
                )
                .padding(.top, 60)
                .padding(.trailing)
            }
            
            Spacer()
            
            // Detailkarte für ausgewähltes Lebensmittel
            if let selectedItem = viewModel.selectedItem {
                MapFoodDetailCard(
                    item: selectedItem,
                    onClose: { viewModel.selectedItem = nil },
                    onNavigate: { foodId in viewModel.navigateToDetailId = foodId }
                )
                .padding(.horizontal)
                .padding(.bottom)
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: viewModel.selectedItem != nil)
            }
        }
    }
}

struct LoadingIndicatorOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text("Lade Daten...")
                    .foregroundColor(.white)
                    .padding(.top, 8)
            }
            .padding()
            .background(Color.black.opacity(0.6))
            .cornerRadius(12)
        }
    }
}
