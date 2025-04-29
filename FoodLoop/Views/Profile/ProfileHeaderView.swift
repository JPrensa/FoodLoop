//
//  ProfileHeaderView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 29.04.25.
//
import SwiftUI


struct ProfileHeaderView: View {
    let user: FireUser?
    let rating: Double?
    
    
    private var displayName: String {
        guard let u = user else { return "Gast" }
        let name = u.username
        if !name.isEmpty && name.lowercased() != "neuer nutzer" {
            return name
        } else {
            return u.id
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            Image(user?.levelTitle ?? "Einsteiger")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 4)
                )
                .shadow(radius: 5)
            
//            // Name 
//            VStack(spacing: 8) {
                Text(displayName)
//                    .font(.title2)
//                    .fontWeight(.bold)
                
//                if let rating = rating {
//                    HStack {
//                        ForEach(0..<5) { i in
//                            Image(systemName: i < Int(rating) ? "star.fill" : (i < Int(rating) + 1 && rating.truncatingRemainder(dividingBy: 1) > 0 ? "star.leadinghalf.filled" : "star"))
//                                .foregroundColor(.yellow)
//                        }
//                        
//                        Text(String(format: "%.1f", rating))
//                            .foregroundColor(.secondary)
//                            .font(.subheadline)
//                    }
//                }
            }
//        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}
