//
//  FoodUploadViewModel.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SwiftUI
import CoreLocation
import Combine

class FoodUploadViewModel: ObservableObject {
    // Form-Daten
    @Published var title = ""
    @Published var description = ""
    @Published var selectedCategory: FoodCategory?
    @Published var image: UIImage?
    @Published var expiryDate: Date? = Calendar.current.date(byAdding: .day, value: 3, to: Date())
    @Published var availableTimes: [AvailableTimeSlot] = []
    @Published var suggestedImages: [ImgurImage] = []
    @Published var selectedImgurImageLink: String?
    
    // Daten für UI-Steuerung
    @Published var categories: [FoodCategory] = []
    @Published var isUploading = false
    @Published var uploadProgress: Double = 0.0
    @Published var errorMessage: String?
    @Published var uploadSuccess = false
    @Published var showLocationPrompt = false
    
    // Lokationsdaten
    @Published var userLocation: CLLocation?
    @Published var locationName: String = "Aktueller Standort"
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Standardmäßig einen Zeitslot für heute hinzufügen
        let today = Date()
        let defaultStartTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: today) ?? today
        let defaultEndTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: today) ?? today
        
        availableTimes = [
            AvailableTimeSlot(
                day: Calendar.current.component(.weekday, from: today) - 2, // 0 = Montag
                startTime: defaultStartTime,
                endTime: defaultEndTime
            )
        ]
        
        // Initial default categories and load from Firestore
        createDefaultCategories()
        fetchCategories()
        
        // Setup Imgur search on title changes
        $title
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newTitle in
                Task { await self?.searchImgur(query: newTitle) }
            }
            .store(in: &cancellables)
    }
    
    // Kategorien aus Firestore laden
    func fetchCategories() {
        db.collection("categories").getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Fehler beim Laden der Kategorien: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    // Wenn keine Kategorien in Firestore vorhanden sind, Standard-Kategorien erstellen
                    self?.createDefaultCategories()
                    return
                }
                
                let categories = documents.compactMap { document -> FoodCategory? in
                    do {
                        return try document.data(as: FoodCategory.self)
                    } catch {
                        print("Fehler beim Dekodieren der Kategorie: \(error)")
                        return nil
                    }
                }
                
                if categories.isEmpty {
                    // Wenn keine gültigen Kategorien in Firestore vorhanden sind, Standard-Kategorien erstellen
                    self?.createDefaultCategories()
                } else {
                    // Entferne Duplikate (einzigartige Kategorien nach Name)
                    let uniqueCategories = categories.reduce(into: [FoodCategory]()) { acc, cat in
                        if !acc.contains(where: { $0.name == cat.name }) {
                            acc.append(cat)
                        }
                    }
                    self?.categories = uniqueCategories
                    
                    // Standardmäßig die erste Kategorie auswählen
                    if self?.selectedCategory == nil, let firstCategory = uniqueCategories.first {
                        self?.selectedCategory = firstCategory
                    }
                }
            }
        }
    }
    
    private func createDefaultCategories() {
        let defaultCategories = [
            FoodCategory(id: UUID().uuidString, name: "Obst & Gemüse", icon: "leaf.fill"),
            FoodCategory(id: UUID().uuidString, name: "Backwaren", icon: "birthday.cake"),
            FoodCategory(id: UUID().uuidString, name: "Milchprodukte", icon: "drop.fill"),
            FoodCategory(id: UUID().uuidString, name: "Fertiggerichte", icon: "fork.knife"),
            FoodCategory(id: UUID().uuidString, name: "Konserven", icon: "shippingbox.fill")
        ]
        
        self.categories = defaultCategories
        
        // Standardmäßig die erste Kategorie auswählen
        if self.selectedCategory == nil, let firstCategory = defaultCategories.first {
            self.selectedCategory = firstCategory
        }
        
        // Kategorien in Firestore speichern
        for category in defaultCategories {
            do {
                try db.collection("categories").document(category.id).setData(from: category)
            } catch {
                print("Fehler beim Speichern der Kategorie: \(error)")
            }
        }
    }
    
    // Standort des Nutzers ermitteln
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let location = locationManager.location {
            userLocation = location
            
            // Geokodierung: Koordinaten in Adresse umwandeln
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Geokodierungsfehler: \(error.localizedDescription)")
                    self.locationName = "Aktueller Standort"
                    return
                }
                
                if let placemark = placemarks?.first {
                    // Adresse formatieren
                    let address = [
                        placemark.locality,
                        placemark.postalCode,
                        placemark.thoroughfare,
                        placemark.subThoroughfare
                    ].compactMap { $0 }.joined(separator: ", ")
                    
                    DispatchQueue.main.async {
                        self.locationName = address.isEmpty ? "Aktueller Standort" : address
                    }
                }
            }
        }
    }
    
    // Validierung vor dem Upload
    var isFormValid: Bool {
        guard !title.isEmpty else { return false }
        guard !description.isEmpty else { return false }
        guard selectedCategory != nil else { return false }
        guard !availableTimes.isEmpty else { return false }
        return true
    }
    
    // Lebensmittel hochladen
    func uploadFoodItem(userId: String) {
        guard isFormValid else {
            errorMessage = "Bitte fülle alle Pflichtfelder aus"
            return
        }
        
        guard let userLocation = userLocation else {
            showLocationPrompt = true
            return
        }
        
        DispatchQueue.main.async {
            self.isUploading = true
            self.uploadProgress = 0.1
            self.errorMessage = nil
        }
        
        // 1. Zuerst das Bild hochladen (falls vorhanden)
        if let image = image {
            uploadImage(image) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let imageURL):
                    self.uploadProgress = 0.5
                    self.uploadFoodData(userId: userId, imageURL: imageURL)
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.isUploading = false
                        self.errorMessage = "Fehler beim Hochladen des Bildes: \(error.localizedDescription)"
                    }
                }
            }
        } else if let imgurLink = selectedImgurImageLink {
            // Nutze den Imgur-Link direkt
            self.uploadProgress = 0.5
            self.uploadFoodData(userId: userId, imageURL: imgurLink)
        } else {
            // Kein Bild vorhanden
            self.uploadProgress = 0.5
            self.uploadFoodData(userId: userId, imageURL: nil)
        }
    }
    
    // Bild in Firebase Storage hochladen
    private func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "FoodUploadViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Bild konnte nicht konvertiert werden"])))
            return
        }
        
        let imageName = "\(UUID().uuidString).jpg"
        let imageRef = storage.child("food_images/\(imageName)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let uploadTask = imageRef.putData(imageData, metadata: metadata)
        
        // Upload-Fortschritt überwachen
        uploadTask.observe(.progress) { [weak self] snapshot in
            guard let percentComplete = snapshot.progress?.fractionCompleted else { return }
            
            DispatchQueue.main.async {
                // Progress zwischen 0.1 und 0.5 skalieren
                self?.uploadProgress = 0.1 + (percentComplete * 0.4)
            }
        }
        
        uploadTask.observe(.success) { _ in
            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "FoodUploadViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Keine Download-URL erhalten"])))
                    return
                }
                
                completion(.success(downloadURL.absoluteString))
            }
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                completion(.failure(error))
            }
        }
    }
    
    // Lebensmitteldaten in Firestore speichern
    private func uploadFoodData(userId: String, imageURL: String?) {
        guard let userLocation = userLocation, let selectedCategory = selectedCategory else { return }
        
        let location = Location(
            latitude: userLocation.coordinate.latitude,
            longitude: userLocation.coordinate.longitude,
            address: locationName
        )
        
        let foodItem = FoodItem(
            id: UUID().uuidString,
            ownerId: userId,
            title: title,
            description: description,
            category: selectedCategory,
            imageURL: imageURL,
            location: location,
            createdAt: Date(),
            expiryDate: expiryDate,
            availableTimes: availableTimes,
            isAvailable: true
        )
        
        do {
            try db.collection("foodItems").document(foodItem.id).setData(from: foodItem) { [weak self] error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.uploadProgress = 1.0
                    
                    if let error = error {
                        self.isUploading = false
                        self.errorMessage = "Fehler beim Speichern: \(error.localizedDescription)"
                    } else {
                        // Upload erfolgreich
                        self.uploadSuccess = true
                        
                        // Formular zurücksetzen
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.isUploading = false
                            self.resetForm()
                        }
                        
                        // Benutzerstatistik aktualisieren (Anzahl gespeicherter Lebensmittel)
                        self.incrementUserFoodSaved(userId: userId)
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isUploading = false
                self.errorMessage = "Fehler beim Serialisieren: \(error.localizedDescription)"
            }
        }
    }
    
    // Benutzerstatistik aktualisieren
    private func incrementUserFoodSaved(userId: String) {
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists, error == nil else { return }
            
            self.db.runTransaction({ (transaction, errorPointer) -> Any? in
                let document: DocumentSnapshot
                do {
                    document = try transaction.getDocument(userRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                guard let oldFoodsSaved = document.data()?["foodsSaved"] as? Int else {
                    return nil
                }
                
                let newFoodsSaved = oldFoodsSaved + 1
                let newLevel = newFoodsSaved / 10 // z.B. Level 1 nach 10 Lebensmitteln
                
                transaction.updateData([
                    "foodsSaved": newFoodsSaved,
                    "level": newLevel
                ], forDocument: userRef)
                
                return nil
            }) { _, error in
                if let error = error {
                    print("Fehler bei der Aktualisierung der Benutzerstatistik: \(error)")
                }
            }
        }
    }
    
    // Formular zurücksetzen
    func resetForm() {
        title = ""
        description = ""
        image = nil
        expiryDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())
        
        // Standard-Zeitslot für heute
        let today = Date()
        let defaultStartTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: today) ?? today
        let defaultEndTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: today) ?? today
        
        availableTimes = [
            AvailableTimeSlot(
                day: Calendar.current.component(.weekday, from: today) - 2, // 0 = Montag
                startTime: defaultStartTime,
                endTime: defaultEndTime
            )
        ]
        
        uploadProgress = 0.0
        uploadSuccess = false
    }
    
    /// Search images on Imgur based on title
    func searchImgur(query: String) async {
        guard !query.isEmpty else {
            DispatchQueue.main.async { self.suggestedImages = [] }
            return
        }
        do {
            let all = try await ImgurService.shared.searchImages(query: query)
            let limited = Array(all.shuffled().prefix(8))
            DispatchQueue.main.async {
                self.suggestedImages = limited
            }
        } catch {
            print("Error fetching Imgur images: \(error)")
        }
    }
}
