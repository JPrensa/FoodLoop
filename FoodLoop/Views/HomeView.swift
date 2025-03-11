// Home View mit zwei Listen
struct HomeView: View {
    @StateObject var viewModel = FoodListViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Suchleiste
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                    
                    // Empfohlene Lebensmittel
                    VStack(alignment: .leading) {
                        Text("Empfohlen für dich")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
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
                    
                    // Lebensmittel in der Nähe
                    VStack(alignment: .leading) {
                        Text("In deiner Nähe")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if viewModel.nearbyItems.isEmpty {
                            Text("Keine Lebensmittel in deiner Nähe gefunden.")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.nearbyItems) { item in
                                    NavigationLink(destination: FoodDetailView(foodId: item.id)) {
                                        FoodRowView(item: item)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Food Rescue")
            .onAppear {
                viewModel.fetchNearbyItems()
                viewModel.fetchRecommendedItems()
            }
        }
    }
}