//
//  UploadSuccessView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 29.04.25.
//

import SwiftUI
import PhotosUI
import CoreLocation

struct UploadSuccessView: View {
    let onDismiss: () -> Void
    let primaryColor = Color("PrimaryGreen")
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(primaryColor)
            
            Text("Lebensmittel erfolgreich geteilt!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Vielen Dank für deinen Beitrag! Dein Lebensmittel wurde erfolgreich geteilt und ist nun für andere sichtbar.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Level-Anzeige
            if let fireUser = authViewModel.fireUser {
                VStack(spacing: 12) {
                    Text("Food Rescue Level: \(fireUser.level)")
                        .font(.headline)
                    
                    // Fortschrittsanzeige
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Hintergrund
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 12)
                            
                            // Fortschritt
                            Capsule()
                                .fill(primaryColor)
                                .frame(width: min(CGFloat(fireUser.foodsSaved % 10) / 10.0 * geometry.size.width, geometry.size.width), height: 12)
                        }
                    }
                    .frame(height: 12)
                    
                    Text("Du hast bisher \(fireUser.foodsSaved) Lebensmittel geteilt!")
                        .font(.subheadline)
                    
                    Text("Noch \(10 - (fireUser.foodsSaved % 10)) für das nächste Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }
            
            Spacer()
            
            Button {
                onDismiss()
            } label: {
                Text("Zurück zur Startseite")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(primaryColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
