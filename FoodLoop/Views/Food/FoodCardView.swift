// Wiederverwendbare Komponenten
struct FoodCardView: View {
    let item: FoodItem
    
    var body: some View {
        VStack(alignment: .leading) {
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
                .frame(height: 120)
                .clipped()
                .cornerRadius(8)
            } else {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.3))
                    .frame(height: 120)
                    .cornerRadius(8)
            }
            
            // Informationen
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(item.category.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let expiryDate = item.expiryDate {
                    Text("MHD: \(dateFormatter.string(from: expiryDate))")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                
                HStack {
                    Image(systemName: "location.circle")
                        .font(.caption2)
                    Text("5 km entfernt")
                        .font(.caption2)
                }
                .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}
