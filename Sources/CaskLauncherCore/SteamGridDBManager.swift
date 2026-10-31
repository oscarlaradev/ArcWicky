import Foundation

public struct SteamGridArt: Codable, Sendable, Identifiable {
    public var id: Int
    public var url: URL
    public var thumb: URL?
    public var width: Int?
    public var height: Int?

    public init(id: Int, url: URL, thumb: URL? = nil, width: Int? = nil, height: Int? = nil) {
        self.id = id
        self.url = url
        self.thumb = thumb
        self.width = width
        self.height = height
    }
}

public final class SteamGridDBManager: Sendable {
    public static let shared = SteamGridDBManager()
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Searches SteamGridDB for high quality artwork (Grids / Posters / Heroes).
    public func searchArt(for gameTitle: String, apiKey: String? = nil) async throws -> [SteamGridArt] {
        guard let encoded = gameTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let searchURL = URL(string: "https://www.steamgriddb.com/api/v2/search/autocomplete/\(encoded)") else {
            return []
        }

        var request = URLRequest(url: searchURL)
        if let key = apiKey, !key.isEmpty {
            request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        }
        request.timeoutInterval = 10

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            return []
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let success = json["success"] as? Bool, success,
              let dataArray = json["data"] as? [[String: Any]],
              let firstGame = dataArray.first,
              let gameId = firstGame["id"] as? Int else {
            return []
        }

        return try await fetchGrids(forGameId: gameId, apiKey: apiKey)
    }

    private func fetchGrids(forGameId gameId: Int, apiKey: String?) async throws -> [SteamGridArt] {
        guard let url = URL(string: "https://www.steamgriddb.com/api/v2/grids/game/\(gameId)?dimensions=600x900") else {
            return []
        }

        var request = URLRequest(url: url)
        if let key = apiKey, !key.isEmpty {
            request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        }
        request.timeoutInterval = 10

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            return []
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataArray = json["data"] as? [[String: Any]] else {
            return []
        }

        var arts: [SteamGridArt] = []
        for item in dataArray {
            guard let id = item["id"] as? Int,
                  let urlStr = item["url"] as? String,
                  let imageURL = URL(string: urlStr) else { continue }
            let thumbStr = item["thumb"] as? String
            let thumbURL = thumbStr.flatMap { URL(string: $0) }
            let width = item["width"] as? Int
            let height = item["height"] as? Int
            arts.append(SteamGridArt(id: id, url: imageURL, thumb: thumbURL, width: width, height: height))
        }

        return arts
    }
}

