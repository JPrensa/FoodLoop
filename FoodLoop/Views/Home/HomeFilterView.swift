//
//  FilterView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 18.03.25.
//
import SwiftUI

// Filteransicht
struct HomeFilterView: View {
    @Binding var selectedCategories: Set<String>
    @Binding var maxDistance: Double
    @Binding var includeExpired: Bool
    let categories: [FoodCategory]
    let resetFilters: () -> Void
    let applyFilters: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    let primaryColor = Color("PrimaryGreen")
    
    // Einmalige Kategorien nach Name
    private var uniqueCategories: [FoodCategory] {
        var seenNames = Set<String>()
        return categories
            .filter { seenNames.insert($0.name).inserted }
            .sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Entfernung")) {
                    VStack {
                        Slider(value: $maxDistance, in: 1...20, step: 1) {
                            Text("Maximale Entfernung")
                        } minimumValueLabel: {
                            Text("1km")
                        } maximumValueLabel: {
                            Text("20km")
                        }
                        
                        Text("Maximale Entfernung: \(Int(maxDistance)) km")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)
                    }
                }
                
                Section(header: Text("Kategorien")) {
                    ForEach(uniqueCategories, id: \.name) { category in
                        Button {
                            toggleCategory(category.id)
                        } label: {
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(primaryColor)
                                
                                Text(category.name)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedCategories.contains(category.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(primaryColor)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Weitere Optionen")) {
                    Toggle("Abgelaufene Lebensmittel anzeigen", isOn: $includeExpired)
                }
                
                Section {
                    Button("Filter zurücksetzen") {
                        resetFilters()
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Anwenden") {
                        applyFilters()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(primaryColor)
                }
            }
        }
    }
    
    private func toggleCategory(_ categoryId: String) {
        if selectedCategories.contains(categoryId) {
            selectedCategories.remove(categoryId)
        } else {
            selectedCategories.insert(categoryId)
        }
    }
}
