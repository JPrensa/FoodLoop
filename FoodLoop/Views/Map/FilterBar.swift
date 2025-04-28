import SwiftUI
 
struct FilterBar: View {
    @Binding var selectedCategories: Set<String>
    @Binding var radiusInKm: Double
    let categories: [FoodCategory]
    
    var body: some View {
        HStack {
            Button {
                // Radius verkleinern
                if radiusInKm > 1 {
                    radiusInKm -= 1
                }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            
            Text("\(Int(radiusInKm)) km")
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(12)
            
            Button {
                // Radius vergrößern
                if radiusInKm < 20 {
                    radiusInKm += 1
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
        }
        .padding(6)
        .background(Color.black.opacity(0.4))
        .cornerRadius(20)
    }
}
