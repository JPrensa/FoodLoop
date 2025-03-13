//
//  MapView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//


import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var showingDetail = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MapKit View
                Map(coordinateRegion: $viewModel.region,
                    showsUserLocation: true,
                    annotationItems: viewModel.foodItems) { item in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: item.location.latitude,
                        longitude: item.location.longitude
                    )) {
                        FoodMapMarker(item: item, isSelected: viewModel.selectedItem?.id == item.id)
                            .onTapGesture {
                                viewModel.selectItem(item)
                                showingDetail = true
                            }
                    }
                }
                .ignoresSafeArea(edges: .top)
                
                // Filter bar (z.B. für Kategorien, Entfernung)
                VStack {
                    HStack {
                        FilterButton(title: "Kategorien", icon: "list.bullet")
                        FilterButton(title: "Entfernung", icon: "arrow.up.arrow.down")
                        FilterButton(title: "MHD", icon: "calendar")
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Detailkarte für ausgewähltes Lebensmittel
                    if let selectedItem = viewModel.selectedItem {
                        MapFoodDetailCard(item: selectedItem)
                            .padding(.horizontal)
                            .padding(.bottom)
                            .transition(.move(edge: .bottom))
                    }
                }
            }
            .navigationTitle("In deiner Nähe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Zentrieren auf Benutzerstandort
                        viewModel.updateRegion()
                    }) {
                        Image(systemName: "location.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingDetail, onDismiss: {
                viewModel.selectedItem = nil
            }) {
                if let selectedItem = viewModel.selectedItem {
                    FoodDetailView(foodId: selectedItem.id)
                }
            }
            .onAppear {
                viewModel.fetchItemsForMap()
            }
        }
    }
}

