//
//  PrivacyView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.04.25.
//

import SwiftUI
struct PrivacyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Datenschutzerklärung")
                        .font(.title)
                        .bold()
                    
                    Text("""
                    Datenschutz hat einen hohen Stellenwert für uns.  
                    Nachfolgend informieren wir, wie wir mit Ihren Daten umgehen.

                    1. **Verantwortlicher**  
                    FoodSharingApp GmbH, Musterstraße 1, 12345 Berlin.

                    2. **Erhobene Daten**  
                    - E-Mail-Adresse, UID, ggf. Standort  
                    - App-Log-Daten (Nutzung, Abstürze)

                    3. **Zweck der Verarbeitung**  
                    - Authentifizierung  
                    - Verbesserung unserer Dienste  
                    - Kommunikation mit Ihnen

                    4. **Speicherdauer**  
                    Wir speichern Ihre Daten nur so lange, wie es für den jeweiligen Zweck erforderlich ist.

                    5. **Ihre Rechte**  
                    Sie haben Auskunftsrecht, Recht auf Berichtigung, Löschung und Einschränkung der Verarbeitung.

                    **Stand:** 28. April 2025
                    """)
                }
                .padding()
            }
            .navigationTitle("Datenschutzerklärung")
            .navigationBarItems(trailing: Button("Fertig") { dismiss() })
        }
    }
}


