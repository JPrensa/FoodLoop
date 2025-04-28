//
//  AuthViewModel.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var fireUser: FireUser?
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    let database = Firestore.firestore()
    
    init() {
        Task {
            await checkIfUserExists()
            if let currentUser = Auth.auth().currentUser {
                // Lade FireUser-Daten aus Firestore
                fetchUser(id: currentUser.uid)
            } else {
                // Wenn kein eingeloggter User, anonym anmelden für Firestore-Lesezugriff
                await signInAnonymously()
            }
        }
    }
  
    
    
    
    
    
    func createUser(id: String, email: String?, username: String = "Neuer Nutzer") async {
            let newUser = FireUser(
                id: id,
                username: username,
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
        self.fireUser = newUser
           } catch {
               self.errorMessage = "Fehler beim Speichern: \(error.localizedDescription)"
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
    
    // Funktion zum Laden des Users aus Firestore
    func fetchUser(id: String) {
        database.collection("users").document(id).getDocument { document, error in
            if let error = error {
                print("Fehler beim Laden des Benutzers: \(error.localizedDescription)")
                self.errorMessage = "Fehler beim Laden des Benutzers"
                return
            }
            
            guard let document = document, document.exists else {
                print("Benutzer-Dokument nicht gefunden")
                return
            }
            do {
                let firestoreResult = try document.data(as: FireUser.self)
                                DispatchQueue.main.async {
                                    self.fireUser = firestoreResult
                                }
                            } catch {
                                print("Fehler beim Dekodieren des Benutzers: \(error.localizedDescription)")
                                self.errorMessage = "Fehler beim Laden des Benutzerprofils"
            }
        }
    }
    
        // Firebase Anonyme Anmeldung
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
          self.isLoading = true
          self.errorMessage = nil
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = authResult.user
        } catch {
            self.errorMessage = "Fehler: \(error.localizedDescription)"
            self.isLoading = false
        }
    }

    // Registrierung mit E-Mail & Passwort
    func register(email: String, password: String) async {
         self.isLoading = true
         self.errorMessage = nil
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = authResult.user
            self.isLoading = false
            await createUser(id: authResult.user.uid, email: email)
        } catch {
            self.errorMessage = "Fehler: \(error.localizedDescription)"
            self.isLoading = false
        }
    }

    // Logout
    @MainActor
    func signOut() {
        self.isLoading = true
        self.errorMessage = nil
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.fireUser = nil
            self.isLoading = false
        } catch {
            self.errorMessage = "Abmeldung fehlgeschlagen: \(error.localizedDescription)"
        }
            self.isLoading = false
    }
    
    // Prüfen, ob ein User eingeloggt ist
    var isUserLoggedIn: Bool {
        return user != nil
    }

}
