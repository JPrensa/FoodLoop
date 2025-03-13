//
//  HomeView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 10.03.25.
//
import SwiftUI
import MapKit
struct HomeView: View {
    @StateObject var foodListviewModel = FoodListViewModel()
    @State private var searchText = ""
    
    // Subview für den empfohlenen Bereich
    var recommendedSection: some View {
        VStack(alignment: .leading) {
            Text("Empfohlen für dich")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(foodListviewModel.recommendedItems) { item in
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
    
    // Subview für den Bereich "In deiner Nähe"
    var nearbySection: some View {
        VStack(alignment: .leading) {
            Text("In deiner Nähe")
                .font(.headline)
                .padding(.horizontal)
            
            if foodListviewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if foodListviewModel.nearbyItems.isEmpty {
                Text("Keine Lebensmittel in deiner Nähe gefunden.")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(foodListviewModel.nearbyItems) { item in
                        NavigationLink(destination: FoodDetailView(foodId: item.id)) {
                            FoodRowView(item: item)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Suchleiste
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                    
                    // Ausgelagerte Bereiche
                    recommendedSection
                    nearbySection
                }
                .padding(.vertical)
            }
            .navigationTitle("Food Rescue")
            .onAppear {
                foodListviewModel.fetchNearbyItems()
                foodListviewModel.fetchRecommendedItems()
            }
        }
    }
}

#Preview {
    HomeView(foodListviewModel: FoodListViewModel())
}
