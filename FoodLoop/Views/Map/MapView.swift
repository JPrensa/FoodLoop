//
//  MapView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//


//import SwiftUI
//import MapKit
//
//struct MapView: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//    @StateObject private var viewModel = MapViewModel()
//    @State private var mapType: MKMapType = .standard
//    
//    // Farben
//    let primaryColor = Color("PrimaryGreen")
//    let secondaryColor = Color("SecondaryWhite")
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                // Karte
//                Map(coordinateRegion: $viewModel.region,
//                    showsUserLocation: true,
//                    mapType: mapType,
//                    annotationItems: viewModel.filteredItems) { item in
//                    MapAnnotation(coordinate: item.location.coordinate) {
//                        FoodMapMarker(
//                            item: item,
//                            isSelected: viewModel.selectedItem?.id == item.id,
//                            onTap: {
//                                viewModel.selectItem(item)
//                            }
//                        )
//                    }
//                }
//                .ignoresSafeArea(edges: .top)
//                .overlay(
//                    // Maptype-Kontrollleiste
//                    VStack {
//                        Picker("Kartentyp", selection: $mapType) {
//                            Text("Standard").tag(MKMapType.standard)
//                            Text("Satellit").tag(MKMapType.satellite)
//                            Text("Hybrid").tag(MKMapType.hybrid)
//                        }
//                        .pickerStyle(SegmentedPickerStyle())
//                        .padding(.horizontal)
//                        .padding(.top, 10)
//                        
//                        Spacer()
//                    }
//                )
//                
//                // Filter-Leiste
//                VStack {
//                    HStack {
//                        Spacer()
//                        
//                        FilterBar(
//                            selectedCategories: $viewModel.selectedCategories,
//                            radiusInKm: $viewModel.radiusInKm,
//                            categories: viewModel.availableCategories
//                        )
//                        .padding(.top, 60)
//                        .padding(.trailing)
//                    }
//                    
//                    Spacer()
//                    
//                    // Detailkarte für ausgewähltes Lebensmittel
//                    if let selectedItem = viewModel.selectedItem {
//                        MapFoodDetailCard(
//                            item: selectedItem,
//                            onClose: {
//                                viewModel.selectedItem = nil
//                            },
//                            onNavigate: { foodId in
//                                viewModel.navigateToDetailId = foodId
//                            }
//                        )
//                        .padding(.horizontal)
//                        .padding(.bottom)
//                        .transition(.move(edge: .bottom))
//                        .animation(.spring(), value: viewModel.selectedItem != nil)
//                    }
//                }
//            }
//            .navigationTitle("In deiner Nähe")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button {
//                        viewModel.showFilters.toggle()
//                    } label: {
//                        Image(systemName: "line.3.horizontal.decrease")
//                            .foregroundColor(primaryColor)
//                    }
//                }
//                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        viewModel.recenterMap()
//                    } label: {
//                        Image(systemName: "location.circle.fill")
//                            .foregroundColor(primaryColor)
//                    }
//                }
//            }
//            .sheet(isPresented: $viewModel.showFilters) {
//                FilterView(
//                    selectedCategories: $viewModel.selectedCategories,
//                    radiusInKm: $viewModel.radiusInKm,
//                    categories: viewModel.availableCategories,
//                    resetFilters: viewModel.resetFilters
//                )
//                .presentationDetents([.medium, .large])
//            }
//            .navigationDestination(item: $viewModel.navigateToDetailId) { foodId in
//                FoodDetailView(foodId: foodId)
//            }
//            .overlay(
//                // Ladeindikator
//                ZStack {
//                    if viewModel.isLoading {
//                        Color.black.opacity(0.3)
//                            .ignoresSafeArea()
//                        
//                        VStack {
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                            
//                            Text("Lade Daten...")
//                                .foregroundColor(.white)
//                                .padding(.top, 8)
//                        }
//                        .padding()
//                        .background(Color.black.opacity(0.6))
//                        .cornerRadius(12)
//                    }
//                }
//            )
//            .overlay(
//                // Keinen Standort gefunden
//                ZStack {
//                    if viewModel.showLocationPrompt {
//                        VStack {
//                            Text("Standort erforderlich")
//                                .font(.headline)
//                                .padding(.bottom, 4)
//                            
//                            Text("Um Lebensmittel in deiner Nähe zu finden, benötigen wir deinen Standort.")
//                                .font(.subheadline)
//                                .multilineTextAlignment(.center)
//                                .padding(.bottom, 16)
//                            
//                            Button {
//                                viewModel.requestLocationPermission()
//                            } label: {
//                                Text("Standort freigeben")
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(.white)
//                                    .padding(.vertical, 10)
//                                    .padding(.horizontal, 20)
//                                    .background(primaryColor)
//                                    .cornerRadius(10)
//                            }
//                        }
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(16)
//                        .shadow(radius: 10)
//                        .padding()
//                    }
//                }
//            )
//            .alert(item: $viewModel.alertMessage) { message in
//                Alert(
//                    title: Text("Hinweis"),
//                    message: Text(message.message),
//                    dismissButton: .default(Text("OK"))
//                )
//            }
//            .task {
//                // Beim Erscheinen die Daten laden
//                await viewModel.loadItems()
//            }
//        }
//    }
//}

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
                .ignoresSafeArea(edges: .top)
                .overlay(MapTypePickerView(mapStyle: $mapStyle))
                
                // Filter und Detailanzeigen als separater Overlay-Container
                MapOverlaysView(viewModel: viewModel, primaryColor: primaryColor)
                
                // Ladeindikator
                if viewModel.isLoading {
                    LoadingIndicatorOverlay()
                }
                
                // Standort-Prompt
                if viewModel.showLocationPrompt {
                    LocationPromptView(
                        primaryColor: primaryColor,
                        requestLocationPermission: viewModel.requestLocationPermission
                    )
                }
            }
            .navigationTitle("In deiner Nähe")
            .navigationBarTitleDisplayMode(.inline)
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

struct LocationPromptView: View {
    let primaryColor: Color
    let requestLocationPermission: () -> Void
    
    var body: some View {
        VStack {
            Text("Standort erforderlich")
                .font(.headline)
                .padding(.bottom, 4)
            
            Text("Um Lebensmittel in deiner Nähe zu finden, benötigen wir deinen Standort.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)
            
            Button {
                requestLocationPermission()
            } label: {
                Text("Standort freigeben")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(primaryColor)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding()
    }
}

//struct MapView: View {
//    @StateObject private var viewModel = MapViewModel()
//    @State private var showingDetail = false
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                // MapKit View
//                Map(coordinateRegion: $viewModel.region,
//                    showsUserLocation: true,
//                    annotationItems: viewModel.foodItems) { item in
//                    MapAnnotation(coordinate: CLLocationCoordinate2D(
//                        latitude: item.location.latitude,
//                        longitude: item.location.longitude
//                    )) {
//                        FoodMapMarker(item: item, isSelected: viewModel.selectedItem?.id == item.id)
//                            .onTapGesture {
//                                viewModel.selectItem(item)
//                                showingDetail = true
//                            }
//                    }
//                }
//                .ignoresSafeArea(edges: .top)
//                
//                // Filter bar (z.B. für Kategorien, Entfernung)
//                VStack {
//                    HStack {
//                        FilterButton(title: "Kategorien", icon: "list.bullet")
//                        FilterButton(title: "Entfernung", icon: "arrow.up.arrow.down")
//                        FilterButton(title: "MHD", icon: "calendar")
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 10)
//                    
//                    Spacer()
//                    
//                    // Detailkarte für ausgewähltes Lebensmittel
//                    if let selectedItem = viewModel.selectedItem {
//                        MapFoodDetailCard(item: selectedItem)
//                            .padding(.horizontal)
//                            .padding(.bottom)
//                            .transition(.move(edge: .bottom))
//                    }
//                }
//            }
//            .navigationTitle("In deiner Nähe")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        // Zentrieren auf Benutzerstandort
//                        viewModel.updateRegion()
//                    }) {
//                        Image(systemName: "location.circle.fill")
//                    }
//                }
//            }
//            .sheet(isPresented: $showingDetail, onDismiss: {
//                viewModel.selectedItem = nil
//            }) {
//                if let selectedItem = viewModel.selectedItem {
//                    FoodDetailView(foodId: selectedItem.id)
//                }
//            }
//            .onAppear {
//                viewModel.fetchItemsForMap()
//            }
//        }
//    }
//}

