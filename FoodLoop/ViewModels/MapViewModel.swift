//
//  MapViewModel.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//


class MapViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = []
    @Published var selectedItem: FoodItem?
    @Published var userLocation: Location?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    
    func fetchItemsForMap() {
        // Laden aller Lebensmittel für die Karte
    }
    
    func updateRegion() {
        // Aktualisieren der Kartenregion
    }
    
    func selectItem(_ item: FoodItem) {
        // Auswählen eines Items auf der Karte
    }
}