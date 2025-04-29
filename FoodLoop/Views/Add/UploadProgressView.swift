//
//  UploadProgressView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 29.04.25.
//
import SwiftUI
import PhotosUI
import CoreLocation

struct UploadProgressView: View {
    let progress: Double
    let primaryColor = Color("PrimaryGreen")
    
    var body: some View {
        VStack(spacing: 24) {
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: primaryColor))
                .frame(width: 200)
            
            Text(progressText)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.9))
    }
    
    var progressText: String {
        if progress < 0.5 {
            return "Bild wird hochgeladen..."
        } else if progress < 0.9 {
            return "Daten werden gespeichert..."
        } else {
            return "Fast fertig..."
        }
    }
}
