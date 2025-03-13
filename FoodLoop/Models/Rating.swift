//
//  Rating.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 28.02.25.
//
import Foundation

struct Rating: Codable {
    let userId: String
    let stars: Double // 1-5
    let comment: String?
    let date: Date
}
