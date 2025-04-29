//
//  EditProfileView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 29.04.25.
//

import SwiftUI

struct EditProfileView: View {
    let user: FireUser?
    @Environment(\.presentationMode) var presentationMode
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profil Infos")) {
                    if let user = user {
                        Text("Anonymer Nutzer: \(user.email == "Anonymous User" ? "Ja" : "Nein")")
                        Text("Name: \(user.username)")
                        Text("E-Mail: \(user.email ?? "-")")
                        Text("ID: \(user.id)")
                        Text("Level: \(user.levelTitle)")
                        Text("Geteilte Lebensmittel: \(user.foodsSaved)")
                    } else {
                        Text("Keine Nutzerdaten vorhanden")
                    }
                }
                
            }
            .navigationTitle("Profilinfos")
            .navigationBarItems(trailing: Button("Abbrechen") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                // Daten aus dem User-Objekt laden
                if let user = user {
                    username = user.username
                    email = user.email ?? ""
                    phoneNumber = user.phoneNumber ?? ""
                }
            }
        }
    }
}
