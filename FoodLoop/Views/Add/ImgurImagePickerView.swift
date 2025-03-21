struct ImgurImagePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var images: [String] = []
    @State private var isLoading = true
    var onImageSelected: (String) -> Void
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Lade Bilder...")
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
                            ForEach(images, id: \.self) { imageUrl in
                                AsyncImage(url: URL(string: imageUrl)) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                            .onTapGesture {
                                                onImageSelected(imageUrl)
                                                dismiss()
                                            }
                                    } else if phase.error != nil {
                                        Color.red
                                            .frame(width: 100, height: 100)
                                    } else {
                                        ProgressView()
                                            .frame(width: 100, height: 100)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Wähle ein Imgur-Bild")
            .task {
                do {
                    images = try await ImgurService.fetchFoodImages()
                } catch {
                    print("Fehler beim Abrufen der Bilder: \(error)")
                }
                isLoading = false
            }
        }
    }
}