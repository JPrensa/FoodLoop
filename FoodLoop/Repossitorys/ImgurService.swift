//
//  ImgurService.swift
//  FoodLoop
//
//  Created by Jefferson Prensa on 11.03.25.
//

import Foundation
import UIKit


//struct ImgurService {
//    private static let clientID = "0eac2931bd2dc7e"
//    
//    static func uploadImage(_ image: UIImage) async throws -> String {
//        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//            throw UploadError.invalidImageData
//        }
//        
//        let base64Image = imageData.base64EncodedString()
//        guard let url = URL(string: "https://api.imgur.com/3/image") else {
//            throw UploadError.invalidURL
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("Client-ID \(clientID)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        
//        let body = "image=\(base64Image.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")"
//        request.httpBody = body.data(using: .utf8)
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse,
//              httpResponse.statusCode == 200 else {
//            throw UploadError.serverError
//        }
//        
//        let result = try JSONDecoder().decode(ImgurResponse.self, from: data)
//        guard let url = result.data.link else {
//            throw UploadError.invalidResponse
//        }
//        
//        return url
//    }
//    
//    enum UploadError: Error {
//        case invalidImageData
//        case invalidURL
//        case serverError
//        case invalidResponse
//    }
//    
//    struct ImgurResponse: Codable {
//        let data: ImageData
//        struct ImageData: Codable {
//            let link: String?
//        }
//    }
//}
//struct ImgurService {
//    private static let clientID = "DEIN_CLIENT_ID"
//
//   
//    static func fetchFoodImages(query: String = "food") async throws -> [String] {
//        guard let url = URL(string: "https://api.imgur.com/3/gallery/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "food")") else {
//            throw URLError(.badURL)
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Client-ID \(clientID)", forHTTPHeaderField: "Authorization")
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//            throw URLError(.badServerResponse)
//        }
//        
//        
//        let result = try JSONDecoder().decode(ImgurSearchResponse.self, from: data)
//        
//        return result.data.compactMap { $0.link }
//    }
//    
//    
//    struct ImgurSearchResponse: Codable {
//        let data: [ImgurImage]
//    }
//    struct ImgurImage: Codable {
//        let link: String?
//    }
//}
struct ImgurService {
    private static let clientID = "0eac2931bd2dc7e"

    // Methode zum Hochladen eines Bildes
    static func uploadImage(_ image: UIImage) async throws -> String {
        // Konvertiere UIImage in JPEG-Daten
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImgurService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Konnte Bild nicht in JPEG konvertieren"])
        }
        
        // Erstelle die URL für den Imgur Upload-Endpunkt
        guard let url = URL(string: "https://api.imgur.com/3/image") else {
            throw URLError(.badURL)
        }
        
        // Erstelle die URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Client-ID \(clientID)", forHTTPHeaderField: "Authorization")
        
        // Erstelle den multipart/form-data Body
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // Führe die Anfrage aus
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Dekodiere die Antwort
        let responseData = try JSONDecoder().decode(ImgurUploadResponse.self, from: data)
        guard let link = responseData.data.link else {
            throw NSError(domain: "ImgurService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Fehler beim Hochladen des Bildes"])
        }
        
        return link
    }
    
    // Bereits existierende Methode zum Abrufen von Food-Images
    static func fetchFoodImages(query: String = "food") async throws -> [String] {
        guard let url = URL(string: "https://api.imgur.com/3/gallery/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "food")") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Client-ID \(clientID)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let result = try JSONDecoder().decode(ImgurSearchResponse.self, from: data)
        
        return result.data.compactMap { $0.link }
    }
    
    // Antwortstruktur für Upload
    struct ImgurUploadResponse: Codable {
        let data: ImgurUploadedImage
    }
    
    struct ImgurUploadedImage: Codable {
        let link: String?
    }
    
    // Antwortstruktur für Suchanfragen
    struct ImgurSearchResponse: Codable {
        let data: [ImgurImage]
    }
    struct ImgurImage: Codable {
        let link: String?
    }
}
