//
//  AboutView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 29.04.25.
//
import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text("Ich habe mich für FoodLoop entschieden, weil ich aktiv gegen Lebensmittelverschwendung vorgehen und gleichzeitig Menschen in meiner Umgebung vernetzen möchte. Jeder Beitrag zählt, um unsere Umwelt zu schützen und Ressourcen zu schonen.")
                
                Text("Lebensmittelverlust ist ein globales Problem: Jedes Jahr werden Millionen Tonnen noch genießbarer Nahrungsmittel weggeworfen. Dies führt zu unnötigen CO₂-Emissionen, verschwendetem Wasser und Boden sowie ethischen Fragestellungen hinsichtlich Welthunger.")
                
                Text("Mit FoodLoop möchten wir einen einfachen und nachhaltigen Weg bieten, übrig gebliebene Lebensmittel zu teilen statt wegzuwerfen. So können wir gemeinsam Ressourcen sparen, Emissionen reduzieren und die Gemeinschaft stärken.")
            }
            .padding()
        }
        .navigationTitle("Über uns")
    }
}
