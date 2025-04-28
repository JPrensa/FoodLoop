//
//  TermsView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.04.25.
//
import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Nutzungsbedingungen")
                        .font(.title)
                        .bold()
                    
                    Text("""
                    Willkommen bei FoodSharingApp!  
                    Bitte lesen Sie diese Nutzungsbedingungen sorgfältig durch, bevor Sie unsere App nutzen.

                    1. **Leistungsbeschreibung**  
                    Unsere App ermöglicht es Ihnen, überschüssige Lebensmittel zu teilen oder abzuholen.

                    2. **Nutzerpflichten**  
                    Sie verpflichten sich, nur wahrheitsgemäße Angaben zu machen und die geltenden Hygienevorschriften einzuhalten.

                    3. **Haftungsausschluss**  
                    Wir übernehmen keine Haftung für Verderb, gesundheitliche Schäden oder sonstige Verluste, die durch die Nutzung der App entstehen.

                    4. **Änderungen**  
                    Wir behalten uns vor, diese Bedingungen jederzeit zu aktualisieren. Die jeweils aktuelle Version finden Sie hier.

                    **Stand:** 28. April 2025
                    """)
                }
                .padding()
            }
            .navigationTitle("Nutzungsbedingungen")
            .navigationBarItems(trailing: Button("Fertig") { dismiss() })
        }
    }
}
