//
//  MapFoodDetailCard.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 10.03.25.
//
import SwiftUI
import MapKit

struct MapFoodDetailCard: View {
    let item: FoodItem
    let onClose: () -> Void
    let onNavigate: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
                .padding(.top, 8)
            }
            
            HStack(spacing: 12) {
                // Bild
                if let imageURL = item.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
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
                        Text(item.location.distanceToCurrentLocation())
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 16)
            
            // Aktionsbuttons
            HStack {
                Button {
                    // Zur Detailansicht navigieren
                    onNavigate(item.id)
                } label: {
                    HStack {
                        Image(systemName: "info.circle.fill")
                        Text("Details")
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color("PrimaryGreen"))
                    .cornerRadius(8)
                }
                
                Button {
                    // Route in Apple Maps öffnen
                    openInMaps(to: item.location.coordinate)
                } label: {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("Route")
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
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
    
    // In Apple Maps öffnen
    private func openInMaps(to coordinate: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = item.title
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

//struct MapFoodDetailCard: View {
//    let item: FoodItem
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            HStack(spacing: 12) {
//                // Bild
//                if let imageURL = item.imageURL {
//                    AsyncImage(url: URL(string: imageURL)) { image in
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                    } placeholder: {
//                        Rectangle()
//                            .foregroundColor(.gray.opacity(0.3))
//                    }
//                    .frame(width: 80, height: 80)
//                    .clipped()
//                    .cornerRadius(8)
//                } else {
//                    Rectangle()
//                        .foregroundColor(.gray.opacity(0.3))
//                        .frame(width: 80, height: 80)
//                        .cornerRadius(8)
//                }
//                
//                // Informationen
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(item.title)
//                        .font(.headline)
//                    
//                    Text(item.category.name)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    
//                    if let expiryDate = item.expiryDate {
//                        Text("MHD: \(dateFormatter.string(from: expiryDate))")
//                            .font(.caption)
//                            .foregroundColor(.red)
//                    }
//                    
//                    // Entfernung
//                    HStack {
//                        Image(systemName: "location.circle")
//                        Text("5 km entfernt")
//                    }
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                }
//                
//                Spacer()
//            }
//            .padding(16)
//            
//            // Aktionsbuttons
//            HStack {
//                ActionButton(title: "Speichern", icon: "heart", color: .pink)
//                
//                Divider()
//                    .frame(height: 24)
//                
//                ActionButton(title: "Kontakt", icon: "message.fill", color: .blue)
//                
//                Divider()
//                    .frame(height: 24)
//                
//                ActionButton(title: "Route", icon: "map.fill", color: .green)
//            }
//            .padding(.vertical, 12)
//            .background(Color(.systemGray6))
//        }
//        .background(Color.white)
//        .cornerRadius(16)
//        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
//    }
//    
//    private var dateFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        return formatter
//    }
//}
