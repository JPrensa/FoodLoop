//
//  SettingsRowView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 29.04.25.
//

import SwiftUI

struct SettingsRowView: View {
    let icon: String
    let title: String
    let showDivider: Bool
    var showNavigationIcon: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color("PrimaryGreen"))
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if showNavigationIcon {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding(16)
            
            if showDivider {
                Divider()
                    .padding(.leading, 56)
            }
        }
    }
}
