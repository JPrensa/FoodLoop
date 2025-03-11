import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var showingDetail = false
    
    var body: some View {
        NavigationView {
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

// Marker für die Karte
struct FoodMapMarker: View {
    let item: FoodItem
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(categoryColor)
                .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
            
            Image(systemName: categoryIcon)
                .foregroundColor(.white)
                .font(.system(size: isSelected ? 22 : 18))
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(.spring(), value: isSelected)
    }
    
    // Farbe basierend auf Kategorie
    private var categoryColor: Color {
        switch item.category.name {
        case "Obst & Gemüse":
            return .green
        case "Backwaren":
            return .brown
        case "Milchprodukte":
            return .blue
        case "Fertiggerichte":
            return .orange
        default:
            return .gray
        }
    }
    
    // Icon basierend auf Kategorie
    private var categoryIcon: String {
        return item.category.icon
    }
}

// Detailkarte für ausgewähltes Lebensmittel auf der Karte
struct MapFoodDetailCard: View {
    let item: FoodItem
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Bild
                if let imageURL = item.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(8)
                } else {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                }
                
                // Informationen
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                    
                    Text(item.category.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let expiryDate = item.expiryDate {
                        Text("MHD: \(dateFormatter.string(from: expiryDate))")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    // Entfernung
                    HStack {
                        Image(systemName: "location.circle")
                        Text("5 km entfernt")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(16)
            
            // Aktionsbuttons
            HStack {
                ActionButton(title: "Speichern", icon: "heart", color: .pink)
                
                Divider()
                    .frame(height: 24)
                
                ActionButton(title: "Kontakt", icon: "message.fill", color: .blue)
                
                Divider()
                    .frame(height: 24)
                
                ActionButton(title: "Route", icon: "map.fill", color: .green)
            }
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

// Wiederverwendbare Komponenten
struct FilterButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        Button(action: {
            // Filteraktion
        }) {
            Label(title, systemImage: icon)
                .font(.system(size: 14, weight: .medium))
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .foregroundColor(.primary)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Aktion
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}