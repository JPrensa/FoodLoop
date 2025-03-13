//
//  UploadView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 10.03.25.
//




import SwiftUI
import PhotosUI

struct UploadView: View {
    @StateObject private var viewModel = FoodUploadViewModel()
    @State private var showingImagePicker = false
    @State private var navigateToSuccess = false
    @Environment(\.dismiss) private var dismiss
    
    let primaryColor = Color("PrimaryGreen") // Grün
    
    var body: some View {
        NavigationStack {
            Form {
                // Bildauswahl
                Section(header: Text("Foto")) {
                    VStack {
                        if let image = viewModel.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(12)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(12)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                        Text("Klicke hier, um ein Foto hinzuzufügen")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                )
                        }
                    }
                    .onTapGesture {
                        showingImagePicker = true
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(selectedImage: $viewModel.image)
                    }
                }
                
                // Titel und Beschreibung
                Section(header: Text("Details")) {
                    TextField("Titel", text: $viewModel.title)
                    
                    TextEditor(text: $viewModel.description)
                        .frame(height: 100)
                        .overlay(
                            Group {
                                if viewModel.description.isEmpty {
                                    HStack {
                                        Text("Beschreibung des Lebensmittels...")
                                            .foregroundColor(.gray)
                                            .padding(.leading, 4)
                                        Spacer()
                                    }
                                    .allowsHitTesting(false)
                                }
                            }
                        )
                }
                
                // Kategorie
                Section(header: Text("Kategorie")) {
                    if viewModel.categories.isEmpty {
                        Text("Kategorien werden geladen...")
                            .foregroundColor(.gray)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.categories) { category in
                                    CategoryButton(
                                        category: category,
                                        isSelected: viewModel.selectedCategory?.id == category.id,
                                        action: {
                                            viewModel.selectedCategory = category
                                        }
                                    )
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                
                // Mindesthaltbarkeitsdatum
                Section(header: Text("Mindesthaltbarkeitsdatum")) {
                    DatePicker(
                        "MHD",
                        selection: Binding(
                            get: { viewModel.expiryDate ?? Date() },
                            set: { viewModel.expiryDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    
                    Toggle("Kein MHD / Unbekannt", isOn: Binding(
                        get: { viewModel.expiryDate == nil },
                        set: { if $0 { viewModel.expiryDate = nil } else { viewModel.expiryDate = Date() } }
                    ))
                }
                
                // Verfügbare Abholzeiten
                Section(header: Text("Verfügbare Abholzeiten")) {
                    ForEach(Array(0..<min(viewModel.availableTimes.count, 7)), id: \.self) { index in
                        let timeSlot = viewModel.availableTimes[index]
                        TimeSlotView(
                            day: timeSlot.day,
                            startTime: Binding(
                                get: { timeSlot.startTime },
                                set: { newValue in
                                    var updatedTimeSlot = timeSlot
                                    updatedTimeSlot.startTime = newValue
                                    viewModel.availableTimes[index] = updatedTimeSlot
                                }
                            ),
                            endTime: Binding(
                                get: { timeSlot.endTime },
                                set: { newValue in
                                    var updatedTimeSlot = timeSlot
                                    updatedTimeSlot.endTime = newValue
                                    viewModel.availableTimes[index] = updatedTimeSlot
                                }
                            )
                        )
                    }
                    
                    if viewModel.availableTimes.count < 7 {
                        Button(action: {
                            let newTimeSlot = AvailableTimeSlot(
                                day: 0, // Montag als Standard
                                startTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
                                endTime: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
                            )
                            viewModel.availableTimes.append(newTimeSlot)
                        }) {
                            Label("Weitere Zeit hinzufügen", systemImage: "plus")
                        }
                    }
                }
                
                // Absendebereich
                Section {
                    if viewModel.isUploading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                    } else {
                        Button(action: {
                            viewModel.uploadFoodItem()
                            // Nach erfolgreichem Upload zur Erfolgsseite navigieren
                            navigateToSuccess = true
                        }) {
                            Text("Lebensmittel teilen")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                        .disabled(!isFormValid)
                        .foregroundColor(isFormValid ? .white : .gray)
                        .listRowBackground(isFormValid ? primaryColor : Color.gray.opacity(0.3))
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Lebensmittel teilen")
            .onAppear {
                viewModel.fetchCategories()
            }
            .navigationDestination(isPresented: $navigateToSuccess) {
                UploadSuccessView()
            }
        }
    }
    
    private var isFormValid: Bool {
        return !viewModel.title.isEmpty &&
               viewModel.selectedCategory != nil &&
               viewModel.image != nil &&
               !viewModel.availableTimes.isEmpty
    }
}

// Erfolgsansicht nach dem Upload
struct UploadSuccessView: View {
    let primaryColor = Color("PrimaryGreen")
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(primaryColor)
            
            Text("Lebensmittel erfolgreich geteilt!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Vielen Dank für deinen Beitrag! Dein Lebensmittel wurde erfolgreich geteilt und wird nun anderen in der Nähe angezeigt.")
                .multilineTextAlignment(.center)
                .padding()
            
            // Level-Fortschritt
            VStack(spacing: 8) {
                Text("Food Rescue Level")
                    .font(.headline)
                
                HStack {
                    Text("Level 2")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("Level 3")
                        .fontWeight(.semibold)
                }
                .font(.caption)
                
                ProgressView(value: 0.7)
                    .progressViewStyle(LinearProgressViewStyle(tint: primaryColor))
                
                Text("Du bist nur noch 2 Lebensmittel von Level 3 entfernt!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            // Statistik
            Text("Du hast bisher 8 Lebensmittel vor dem Wegwerfen gerettet! 🎉")
                .fontWeight(.medium)
                .padding(.top)
            
            Spacer()
            
            Button(action: {
                // Zurück zur Hauptansicht
            }) {
                Text("Zurück zur Startseite")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

// Hilfkomponenten für den Upload
struct CategoryButton: View {
    let category: FoodCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                
                Text(category.name)
                    .font(.caption)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isSelected ? Color("PrimaryGreen").opacity(0.1) : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? Color("PrimaryGreen") : .primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color("PrimaryGreen") : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct TimeSlotView: View {
    let days = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
    var day: Int
    @Binding var startTime: Date
    @Binding var endTime: Date
    
    var body: some View {
        VStack {
            Picker("Tag", selection: .constant(day)) {
                ForEach(0..<days.count, id: \.self) { index in
                    Text(days[index]).tag(index)
                }
            }
            
            HStack {
                DatePicker("Von", selection: $startTime, displayedComponents: .hourAndMinute)
                DatePicker("Bis", selection: $endTime, displayedComponents: .hourAndMinute)
            }
        }
    }
}

// Bild-Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let result = results.first else { return }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image
                    }
                }
            }
        }
    }
}
