//
//  TimeSlotEditView.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 29.04.25.
//

import SwiftUI
import PhotosUI
import CoreLocation

struct TimeSlotEditView: View {
    @Binding var timeSlot: AvailableTimeSlot
    let onDelete: () -> Void
    
    let days = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Menu {
                    ForEach(0..<days.count, id: \.self) { index in
                        Button(days[index]) {
                            timeSlot.day = index
                        }
                    }
                } label: {
                    HStack {
                        Text(days[min(max(timeSlot.day, 0), days.count - 1)])
                            .fontWeight(.medium)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
            HStack {
                Text("Von:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                DatePicker("", selection: $timeSlot.startTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                Text("Bis:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                DatePicker("", selection: $timeSlot.endTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
