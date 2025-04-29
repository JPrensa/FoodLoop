//
//  UserProfileViewModel.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class UserProfileViewModel: ObservableObject {
    @Published var fireUser: FireUser?
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var foodsSaved = 0
    @Published var userRating: Double?
    @Published var isDarkMode = false
    @Published var userItems: [FoodItem] = []
    let database = Firestore.firestore()
    
    init() {
        Task {
            await checkIfUserExists()
        }
    }

    // Überprüfung, ob bereits ein User existiert
    func checkIfUserExists() async {
        guard let currentUser = Auth.auth().currentUser else {
            print("Kein bestehender User gefunden")
            return
        }
        self.user = currentUser
        print("Bestehender User geladen: \(currentUser.uid)")
    }

    func createUser(id: String, email: String?) async {
        let newUser = FireUser(
                id: id,
                username: "Neuer Nutzer",
                email: email,
                location: nil,
                profileImageURL: nil,
                phoneNumber: nil,
                preferences: [],
                savedItems: [],
                level: 0,
                foodsSaved: 0,
                createdAt: Date()
            )

    do {
               try database.collection("users").document(id).setData(from: newUser)
               fetchUser(id: id)
           } catch {
               self.errorMessage = "Fehler beim Speichern: \(error.localizedDescription)"
           }
       }

// Funktion zum Laden des Users aus Firestore
func fetchUser(id: String) {
    database.collection("users").document(id).getDocument { document, error in
        if let error {
            print(error)
            return
        }
        
        guard let document else { return }
        
        do {
            let firestoreResult = try document.data(as: FireUser.self)
            self.fireUser = firestoreResult
        } catch {
            print("Dokument ist kein User")
        }
    }
}



// Anonymer Login
func signInAnonymously() async {
    do {
        let authResult = try await Auth.auth().signInAnonymously()
        self.user = authResult.user
        await createUser(id: authResult.user.uid, email: "Anonymous User")
    } catch {
        self.errorMessage = "Fehler: \(error.localizedDescription)"
    }
}

// Login mit E-Mail & Passwort
func login(email: String, password: String) async {
    do {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        self.user = authResult.user
    } catch {
        self.errorMessage = "Fehler: \(error.localizedDescription)"
    }
}

// Registrierung mit E-Mail & Passwort
func register(email: String, password: String) async {
    do {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        self.user = authResult.user
        await createUser(id: authResult.user.uid, email: email)
    } catch {
        self.errorMessage = "Fehler: \(error.localizedDescription)"
    }
}

// Logout
func signOut() async {
    do {
        try Auth.auth().signOut()
        self.user = nil
        self.fireUser = nil
    } catch {
        self.errorMessage = "Fehler: \(error.localizedDescription)"
    }
}

// Prüfen, ob ein User eingeloggt ist
var isUserLoggedIn: Bool {
    return user != nil
}
    
    // Lade alle aktiven Uploads des aktuellen Users
    @MainActor
    func fetchUserItems() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let snapshot = try await database.collection("foodItems")
                .whereField("ownerId", isEqualTo: uid)
                .whereField("isAvailable", isEqualTo: true)
                .getDocuments()
            let items = snapshot.documents.compactMap { try? $0.data(as: FoodItem.self) }
            self.userItems = items
        } catch {
            self.errorMessage = "Fehler beim Laden deiner Uploads: \(error.localizedDescription)"
        }
    }

    // Entferne ein Upload (lösche Firestore-Dokument)
    @MainActor
    func removeItem(_ item: FoodItem) async {
        do {
            try await database.collection("foodItems").document(item.id).delete()
            self.userItems.removeAll { $0.id == item.id }
        } catch {
            self.errorMessage = "Fehler beim Entfernen: \(error.localizedDescription)"
        }
    }
    
    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        database.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                print("Fehler beim Laden des Profils: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                return
            }
            guard let document = document, document.exists else {
                print("Benutzerprofil nicht gefunden")
                return
            }
            do {
                let user = try document.data(as: FireUser.self)
                DispatchQueue.main.async {
                    self.fireUser = user
                    self.foodsSaved = user.foodsSaved
                }
            } catch {
                print("Fehler beim Dekodieren des Profils: \(error.localizedDescription)")
            }
        }
    }
    
    func updateUserPreferences(_ preferences: [FoodCategory]) {
        // Aktualisieren der Nutzerpräferenzen
    }
    
    func toggleDarkMode() {
        // Umschalten des Dark Mode
    }
    
    func calculateUserStats() {
        // Berechnen der Nutzerstatistiken
    }
}
