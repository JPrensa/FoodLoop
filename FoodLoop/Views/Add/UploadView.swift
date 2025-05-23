//
//  UploadView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 10.03.25.
//


import SwiftUI
import PhotosUI
import CoreLocation

struct UploadView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = FoodUploadViewModel()
    @State private var showingImagePicker = false
    @State private var showingSuccessView = false
    
    // Farben
    let primaryColor = Color("PrimaryGreen")
    let secondaryColor = Color("SecondaryWhite")
    let accentColor = Color("AccentCoffee")
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrund
                secondaryColor.ignoresSafeArea()
                
                if viewModel.isUploading {
                    // Lade-Overlay
                    UploadProgressView(progress: viewModel.uploadProgress)
                } else if showingSuccessView {
                    // Erfolgsansicht
                    UploadSuccessView(onDismiss: {
                        showingSuccessView = false
                    })
                } else {
                    // Hauptformular
                    ScrollView {
                        VStack(spacing: 24) {
                            // Bildauswahl
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 200)
                                    .cornerRadius(12)

                                if let link = viewModel.selectedImgurImageLink {
                                    AsyncImage(url: URL(string: link)) { img in
                                        img.resizable().aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(height: 200)
                                    .cornerRadius(12)
                                    .clipped()
                                } else if let image = viewModel.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 200)
                                        .cornerRadius(12)
                                        .clipped()
                                } else {
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 36))
                                            .foregroundColor(.gray)
                                        
                                        Text("Tippe hier, um ein Foto hinzuzufügen")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Color.black.opacity(0.001) 
                                    .onTapGesture {
                                        showingImagePicker = true
                                    }
                            }
                            // Imgur image suggestions
                            if !viewModel.suggestedImages.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(viewModel.suggestedImages) { img in
                                            AsyncImage(url: URL(string: img.link)) { image in
                                                image.resizable().aspectRatio(contentMode: .fill)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(width: 80, height: 80)
                                            .clipped()
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(viewModel.selectedImgurImageLink == img.link ? primaryColor : Color.clear, lineWidth: 2)
                                            )
                                            .onTapGesture {
                                                viewModel.selectedImgurImageLink = img.link
                                                viewModel.image = nil
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            // Titel und Beschreibung
                            VStack(spacing: 16) {
                                TextField("Titel", text: $viewModel.title)
                                    .font(.headline)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                
                                ZStack(alignment: .topLeading) {
                                    TextEditor(text: $viewModel.description)
                                        .frame(minHeight: 100)
                                        .padding(5)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                    
                                    if viewModel.description.isEmpty {
                                        Text("Beschreibung...")
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 10)
                                            .padding(.top, 12)
                                            .allowsHitTesting(false)
                                    }
                                }
                            }
                            
                            // Kategorie
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Kategorie")
                                    .font(.headline)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(viewModel.categories) { category in
                                            CategoryButton(
                                                category: category,
                                                isSelected: viewModel.selectedCategory?.id == category.id,
                                                action: { viewModel.selectedCategory = category }
                                            )
                                        }
                                    }
                                }
                                .frame(height: 100)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                .padding(.horizontal)
                            }
                            
                            // Mindesthaltbarkeitsdatum
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Mindesthaltbarkeitsdatum")
                                    .font(.headline)
                                
                                HStack {
                                    if let expiryDate = viewModel.expiryDate {
                                        DatePicker(
                                            "",
                                            selection: Binding(
                                                get: { expiryDate },
                                                set: { viewModel.expiryDate = $0 }
                                            ),
                                            displayedComponents: .date
                                        )
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                    } else {
                                        Text("Kein MHD / Unbekannt")
                                            .foregroundColor(.gray)
                                        
                                        Spacer()
                                        
                                        Button("Hinzufügen") {
                                            viewModel.expiryDate = Date()
                                        }
                                        .foregroundColor(primaryColor)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                
                                // Toggle für "Kein MHD"
                                Toggle("Kein MHD / Unbekannt", isOn: Binding(
                                    get: { viewModel.expiryDate == nil },
                                    set: { if $0 { viewModel.expiryDate = nil } else { viewModel.expiryDate = Date() } }
                                ))
                                .padding(.top, 8)
                            }
                            
                            // Standort
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Standort")
                                    .font(.headline)
                                
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(primaryColor)
                                    
                                    Text(viewModel.locationName)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Button("Aktualisieren") {
                                        viewModel.requestLocation()
                                    }
                                    .foregroundColor(primaryColor)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                            
                            // Verfügbare Abholzeiten
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Verfügbare Abholzeiten")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    if viewModel.availableTimes.count < 7 {
                                        Button(action: {
                                            let today = Date()
                                            let defaultStartTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: today) ?? today
                                            let defaultEndTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: today) ?? today
                                            
                                            viewModel.availableTimes.append(AvailableTimeSlot(
                                                day: Calendar.current.component(.weekday, from: today) - 2, // 0 = Montag
                                                startTime: defaultStartTime,
                                                endTime: defaultEndTime
                                            ))
                                        }) {
                                            Label("Hinzufügen", systemImage: "plus")
                                                .font(.subheadline)
                                                .foregroundColor(primaryColor)
                                        }
                                    }
                                }
                                
                                ForEach(Array(viewModel.availableTimes.enumerated()), id: \.element.day) { index, timeSlot in
                                    TimeSlotEditView(
                                        timeSlot: Binding(
                                            get: { timeSlot },
                                            set: { newValue in
                                                viewModel.availableTimes[index] = newValue
                                            }
                                        ),
                                        onDelete: {
                                            viewModel.availableTimes.remove(at: index)
                                        }
                                    )
                                }
                            }
                            
                            // Upload-Button
                            Button {
                                
                                if viewModel.userLocation == nil {
                                    viewModel.requestLocation()
                                }
                                
                                // Lebensmittel hochladen
                                if let userId = authViewModel.user?.uid {
                                    viewModel.uploadFoodItem(userId: userId)
                                } else {
                                    viewModel.errorMessage = "Bitte melde dich an, um Lebensmittel hochzuladen"
                                }
                            } label: {
                                Text("Lebensmittel teilen")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(viewModel.isFormValid ? primaryColor : Color.gray)
                                    .cornerRadius(12)
                            }
                            .disabled(!viewModel.isFormValid)
                            
                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                                    .padding(.top, 8)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Lebensmittel teilen")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Standort freigeben", isPresented: $viewModel.showLocationPrompt) {
                Button("OK") {
                    viewModel.requestLocation()
                }
            } message: {
                Text("Um Lebensmittel zu teilen, benötigen wir deinen Standort. Bitte erlaube den Zugriff auf deinen Standort.")
            }
            .onChange(of: viewModel.uploadSuccess) { success in
                if success {
                    showingSuccessView = true
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $viewModel.image)
            }
            .onAppear {
                // Kategorien laden, falls noch nicht geschehen
                if viewModel.categories.isEmpty {
                    viewModel.fetchCategories()
                }
                
                // Standort anfordern
                viewModel.requestLocation()
            }
        }
    }
}


