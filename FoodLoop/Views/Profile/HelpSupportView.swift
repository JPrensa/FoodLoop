//
//  HelpSupportView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 29.04.25.
//
import SwiftUI

struct HelpSupportView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Kontakt")
                    .font(.headline)
                HStack {
                    Image(systemName: "envelope.fill")
                    Text("support@foodloop.com")
                }
                HStack {
                    Image(systemName: "phone.fill")
                    Text("+49 123 456789")
                }
                Text("Erreichbarkeit")
                    .font(.headline)
                Text("Montag bis Samstag: 08:00 – 18:00 Uhr")
            }
            .padding()
        }
        .navigationTitle("Hilfe & Support")
    }
}
