//
//  AvailableTimeSlot.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//
import Foundation

struct AvailableTimeSlot: Codable {
    var day: Int // 0-6 für Wochentage
    var startTime: Date
    var endTime: Date
}
