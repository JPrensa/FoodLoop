import Foundation

struct ImgurImage: Identifiable {
    let id: String
    let link: String
}

private struct ImgurGalleryItem: Decodable {
    let id: String
    let images: [ImgurImageItem]?
}

private struct ImgurImageItem: Decodable {
    let id: String
    let link: String
}

private struct ImgurSearchResponse: Decodable {
    let data: [ImgurGalleryItem]
}

class ImgurService {
    static let shared = ImgurService()
    private let clientID: String = Bundle.main.object(forInfoDictionaryKey: "IMGUR_CLIENT_ID") as? String ?? "0eac2931bd2dc7e"

    private init() {}

    func searchImages(query: String) async throws -> [ImgurImage] {
        guard !query.isEmpty,
              let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.imgur.com/3/gallery/search?sort=top&q=\(encoded)")
        else { return [] }
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(clientID)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(ImgurSearchResponse.self, from: data)
        // extract first image of each gallery item
        return response.data.compactMap { item in
            if let img = item.images?.first {
                return ImgurImage(id: img.id, link: img.link)
            }
            return nil
        }
    }
}
