//
//  Message.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//
import Foundation

struct Message: Identifiable, Codable {
    let id: String
    let senderId: String
    let receiverId: String
    let foodItemId: String?
    let content: String
    let timestamp: Date
    let isRead: Bool
}
