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

class FoodUploadViewModel: ObservableObject {
    // Form-Daten
    @Published var title = ""
    @Published var description = ""
    @Published var selectedCategory: FoodCategory?
    @Published var image: UIImage?
    @Published var expiryDate: Date? = Calendar.current.date(byAdding: .day, value: 3, to: Date())
    @Published var availableTimes: [AvailableTimeSlot] = []
    
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
        
        // Kategorien laden
        fetchCategories()
        
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
                    self?.categories = categories
                    
                    // Standardmäßig die erste Kategorie auswählen
                    if self?.selectedCategory == nil, let firstCategory = categories.first {
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
            FoodCategory(id: UUID().uuidString, name: "Konserven", icon: "shippingbox.fill"),
            FoodCategory(id: UUID().uuidString, name: "Getränke", icon: "cup.and.saucer.fill"),
            FoodCategory(id: UUID().uuidString, name: "Sonstiges", icon: "ellipsis.circle.fill")
        ]
        
        // Kategorien in Firestore speichern
        for category in defaultCategories {
            do {
                try db.collection("categories").document(category.id).setData(from: category)
            } catch {
                print("Fehler beim Speichern der Kategorie: \(error)")
            }
        }
        
        DispatchQueue.main.async {
            self.categories = defaultCategories
            
            // Standardmäßig die erste Kategorie auswählen
            if self.selectedCategory == nil, let firstCategory = defaultCategories.first {
                self.selectedCategory = firstCategory
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
        } else {
            // Wenn kein Bild vorhanden ist, direkt die Daten hochladen
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
}
//import Foundation
//import Firebase
//import FirebaseAuth
//import FirebaseFirestore
//import CoreLocation
//
//class FoodUploadViewModel: NSObject, ObservableObject {
//    // Formulardaten
//    @Published var title = ""
//    @Published var foodDescription = ""
//    @Published var selectedCategory: FoodCategory?
//    @Published var image: UIImage?
//    @Published var imageURL: String? // Für Imgur-Bilder
//    @Published var expiryDate: Date?
//    @Published var availableTimes: [AvailableTimeSlot] = []
//    
//    // UI-State
//    @Published var isUploading = false
//    @Published var uploadProgress: Double = 0.0
//    @Published var errorMessage: String?
//    @Published var uploadSuccess = false
//    @Published var showLocationPrompt = false
//    @Published var showingImgurPicker = false
//    
//    // Locationdaten
//    @Published var userLocation: CLLocation?
//    @Published var locationName = "Aktueller Standort wird geladen..."
//    
//    // Daten aus Firestore
//    @Published var categories: [FoodCategory] = []
//    
//    private let db = Firestore.firestore()
//    private let locationManager = CLLocationManager()
//    private let geocoder = CLGeocoder()
//    
////    override init() {
////        setupLocationManager()
////    }
//    
//    // Prüft, ob das Formular gültig ist
//    var isFormValid: Bool {
//        !title.isEmpty &&
//        !description.isEmpty &&
//        selectedCategory != nil &&
//        (image != nil || imageURL != nil) &&
//        userLocation != nil
//    }
//    
//    // Kategorien aus Firestore laden
//    func fetchCategories() {
//        db.collection("categories").getDocuments { [weak self] snapshot, error in
//            guard let self = self else { return }
//            
//            if let error = error {
//                self.errorMessage = "Fehler beim Laden der Kategorien: \(error.localizedDescription)"
//                return
//            }
//            
//            guard let documents = snapshot?.documents else {
//                self.errorMessage = "Keine Kategorien gefunden"
//                return
//            }
//            
//            self.categories = documents.compactMap { document -> FoodCategory? in
//                try? document.data(as: FoodCategory.self)
//            }
//            
//            // Fallback, wenn keine Kategorien in Firestore sind
//            if self.categories.isEmpty {
//                self.createDefaultCategories()
//            }
//        }
//    }
//    
//    // Standard-Kategorien erstellen, falls keine in Firestore existieren
//    private func createDefaultCategories() {
//        let defaultCategories = [
//            FoodCategory(id: "fruits_vegetables", name: "Obst & Gemüse", icon: "leaf.fill"),
//            FoodCategory(id: "bakery", name: "Backwaren", icon: "birthday.cake"),
//            FoodCategory(id: "dairy", name: "Milchprodukte", icon: "drop.fill"),
//            FoodCategory(id: "ready_meals", name: "Fertiggerichte", icon: "fork.knife"),
//            FoodCategory(id: "beverages", name: "Getränke", icon: "cup.and.saucer.fill"),
//            FoodCategory(id: "other", name: "Sonstiges", icon: "shippingbox.fill")
//        ]
//        
//        self.categories = defaultCategories
//        
//        // Optional: Kategorien in Firestore speichern
//        for category in defaultCategories {
//            do {
//                try db.collection("categories").document(category.id).setData(from: category)
//            } catch {
//                print("Fehler beim Speichern der Kategorie: \(error)")
//            }
//        }
//    }
//    
//    // Standortmanager einrichten
//    private func setupLocationManager() {
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
//    }
//    
//    // Standort anfordern
//    func requestLocation() {
//        let status = locationManager.authorizationStatus
//        
//        if status == .notDetermined {
//            locationManager.requestWhenInUseAuthorization()
//        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
//            locationManager.requestLocation()
//        } else {
//            showLocationPrompt = true
//        }
//    }
//    
//    // Lebensmittel hochladen
//    func uploadFoodItem(userId: String) {
//        guard isFormValid else {
//            errorMessage = "Bitte fülle alle Pflichtfelder aus"
//            return
//        }
//        
//        isUploading = true
//        uploadProgress = 0.1
//        
//        
//        if let image = image {
//            Task {
//                do {
//                    
//                    if imageURL == nil {
//                        uploadProgress = 0.2
//                        let url = try await ImgurService.uploadImage(image)
//                        await MainActor.run {
//                            self.imageURL = url
//                            self.uploadProgress = 0.5
//                        }
//                    }
//                    
//                    
//                    await MainActor.run {
//                        self.saveItemToFirestore(userId: userId)
//                    }
//                } catch {
//                    await MainActor.run {
//                        self.isUploading = false
//                        self.errorMessage = "Fehler beim Hochladen des Bildes: \(error.localizedDescription)"
//                    }
//                }
//            }
//        } else if imageURL != nil {
//           
//            uploadProgress = 0.5
//            saveItemToFirestore(userId: userId)
//        } else {
//            isUploading = false
//            errorMessage = "Bitte wähle ein Bild aus"
//        }
//    }
//    
//    
//    private func saveItemToFirestore(userId: String) {
//        uploadProgress = 0.6
//        
//        guard let userLocation = userLocation,
//              let selectedCategory = selectedCategory,
//              let imageURL = imageURL else {
//            isUploading = false
//            errorMessage = "Es fehlen erforderliche Daten"
//            return
//        }
//        
//       
//        let foodItemId = UUID().uuidString
//        let newLocation = Location(
//            latitude: userLocation.coordinate.latitude,
//            longitude: userLocation.coordinate.longitude,
//            address: locationName
//        )
//        
//        let newItem = FoodItem(
//            id: foodItemId,
//            ownerId: userId,
//            title: title,
//            description: description,
//            category: selectedCategory,
//            imageURL: imageURL,
//            location: newLocation,
//            createdAt: Date(),
//            expiryDate: expiryDate,
//            availableTimes: availableTimes,
//            isAvailable: true,
//            ratings: []
//        )
//        
//        uploadProgress = 0.8
//        
//        // In Firestore speichern
//        do {
//            try db.collection("foodItems").document(foodItemId).setData(from: newItem)
//            
//            
//            let userRef = db.collection("users").document(userId)
//            db.runTransaction({ (transaction, errorPointer) -> Any? in
//                let userDocument: DocumentSnapshot
//                do {
//                    userDocument = try transaction.getDocument(userRef)
//                } catch let fetchError as NSError {
//                    errorPointer?.pointee = fetchError
//                    return nil
//                }
//                
//                if let userData = userDocument.data(),
//                   let currentSaved = userData["foodsSaved"] as? Int {
//                    let newSavedCount = currentSaved + 1
//                    
//                    
//                    let newLevel = newSavedCount / 10
//                    
//                    transaction.updateData([
//                        "foodsSaved": newSavedCount,
//                        "level": newLevel
//                    ], forDocument: userRef)
//                }
//                
//                return nil
//            }) { [weak self] (_, error) in
//                guard let self = self else { return }
//                
//                DispatchQueue.main.async {
//                    self.uploadProgress = 1.0
//                    self.isUploading = false
//                    
//                    if let error = error {
//                        self.errorMessage = "Fehler beim Aktualisieren der Benutzerstatistik: \(error.localizedDescription)"
//                    } else {
//                        
//                        self.uploadSuccess = true
//                        self.resetForm()
//                    }
//                }
//            }
//        } catch {
//            isUploading = false
//            errorMessage = "Fehler beim Speichern des Lebensmittels: \(error.localizedDescription)"
//        }
//    }
//    
//    
//    func searchImgurImagesBasedOnTitle() -> ImgurImagePickerView {
//        let searchTerm = title.isEmpty ? nil : title
//        let categoryName = selectedCategory?.name
//        
//        return ImgurImagePickerView(
////            searchTerm: searchTerm ?? "",
////            category: categoryName,
//            onImageSelected: { imgurUrl in
//                self.imageURL = imgurUrl
//                self.image = nil // Lokales Bild zurücksetzen
//            }
//        )
//    }
//    
//    // Formular zurücksetzen
//    private func resetForm() {
//        title = ""
//        foodDescription = ""
//        selectedCategory = nil
//        image = nil
//        imageURL = nil
//        expiryDate = nil
//        availableTimes = []
//    }
//}
//
//// MARK: - CLLocationManagerDelegate
//extension FoodUploadViewModel: CLLocationManagerDelegate {
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        
//        userLocation = location
//        
//        // Adresse über Geocoding ermitteln
//        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
//            guard let self = self else { return }
//            
//            if let error = error {
//                self.locationName = "Standort nicht verfügbar"
//                print("Geocoding-Fehler: \(error.localizedDescription)")
//                return
//            }
//            
//            if let placemark = placemarks?.first {
//                // Adresse formatieren
//                let address = [
//                    placemark.thoroughfare,
//                    placemark.postalCode,
//                    placemark.locality
//                ].compactMap { $0 }.joined(separator: ", ")
//                
//                if !address.isEmpty {
//                    self.locationName = address
//                } else {
//                    self.locationName = "Standort verfügbar"
//                }
//            } else {
//                self.locationName = "Standort verfügbar"
//            }
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Standortfehler: \(error.localizedDescription)")
//        locationName = "Standort nicht verfügbar"
//    }
//    
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        let status = manager.authorizationStatus
//        
//        if status == .authorizedWhenInUse || status == .authorizedAlways {
//            locationManager.requestLocation()
//        } else if status == .denied || status == .restricted {
//            locationName = "Standort nicht verfügbar"
//            showLocationPrompt = true
//        }
//    }
//}
