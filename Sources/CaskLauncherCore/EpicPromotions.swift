import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A game currently free or upcoming to claim on the Epic Games Store promotions feed.
public struct EpicFreeGame: Identifiable, Sendable, Equatable, Codable {
    public let id: String
    public let title: String
    public let description: String
    public let coverURL: URL?
    public let originalPrice: String?
    public let startDate: Date?
    public let endDate: Date?
    public let isUpcoming: Bool
    public let storeURL: URL

    public init(
        id: String,
        title: String,
        description: String,
        coverURL: URL? = nil,
        originalPrice: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        isUpcoming: Bool = false,
        storeURL: URL
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.coverURL = coverURL
        self.originalPrice = originalPrice
        self.startDate = startDate
        self.endDate = endDate
        self.isUpcoming = isUpcoming
        self.storeURL = storeURL
    }

    /// User-friendly label for promotion expiry or upcoming availability.
    public var expiryText: String? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        if isUpcoming, let startDate {
            return "Free on \(formatter.string(from: startDate))"
        } else if let endDate {
            return "Free until \(formatter.string(from: endDate))"
        }
        return nil
    }
}

/// Pure parser and client for Epic Games official promotional free games feed.
public enum EpicPromotionsParser {
    public static let feedURL = URL(
        string: "https://store-site-backend-static.ak.epicgames.com/freeGamesPromotions?locale=en-US&country=US&allowCountries=US"
    )!

    public static func parseDate(_ string: String?) -> Date? {
        guard let string, !string.isEmpty else { return nil }
        let withFraction = ISO8601DateFormatter()
        withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = withFraction.date(from: string) { return d }
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        return plain.date(from: string)
    }

    public static func parseFreeGames(from data: Data) -> [EpicFreeGame] {
        guard let root = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
              let dataDict = root["data"] as? [String: Any],
              let catalog = dataDict["Catalog"] as? [String: Any],
              let searchStore = catalog["searchStore"] as? [String: Any],
              let elements = searchStore["elements"] as? [[String: Any]]
        else { return [] }

        var results: [EpicFreeGame] = []

        for element in elements {
            guard let title = element["title"] as? String, !title.isEmpty,
                  let id = element["id"] as? String, !id.isEmpty
            else { continue }

            let description = (element["description"] as? String) ?? ""

            // Check current active free promotion
            let active = activeFreePromotion(in: element)
            let upcoming = active == nil ? upcomingFreePromotion(in: element) : nil

            guard let promo = active ?? upcoming else { continue }

            // Extract cover image
            let coverURL = bestCoverImageURL(from: element["keyImages"] as? [[String: Any]])

            // Extract original price formatting
            var originalPrice: String?
            if let priceDict = element["price"] as? [String: Any],
               let totalPrice = priceDict["totalPrice"] as? [String: Any],
               let fmtPrice = totalPrice["fmtPrice"] as? [String: Any] {
                originalPrice = fmtPrice["originalPrice"] as? String
            }

            // Extract store product URL
            let storeURL = resolveStoreURL(element: element)

            results.append(EpicFreeGame(
                id: id,
                title: title,
                description: description,
                coverURL: coverURL,
                originalPrice: originalPrice,
                startDate: promo.startDate,
                endDate: promo.endDate,
                isUpcoming: promo.isUpcoming,
                storeURL: storeURL
            ))
        }

        // Sort so current free games appear first, then upcoming
        return results.sorted {
            if $0.isUpcoming != $1.isUpcoming {
                return !$0.isUpcoming
            }
            return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }

    private static func activeFreePromotion(in element: [String: Any]) -> (isUpcoming: Bool, startDate: Date?, endDate: Date?)? {
        guard let promotions = element["promotions"] as? [String: Any],
              let offersGroups = promotions["promotionalOffers"] as? [[String: Any]]
        else { return nil }

        for group in offersGroups {
            guard let offers = group["promotionalOffers"] as? [[String: Any]] else { continue }
            for offer in offers {
                let discount = offer["discountSetting"] as? [String: Any]
                let discountPercentage = discount?["discountPercentage"] as? Int
                let discountType = discount?["discountType"] as? String

                if discountType == "PERCENTAGE" && discountPercentage == 0 {
                    let startDate = parseDate(offer["startDate"] as? String)
                    let endDate = parseDate(offer["endDate"] as? String)
                    return (false, startDate, endDate)
                }
            }
        }
        return nil
    }

    private static func upcomingFreePromotion(in element: [String: Any]) -> (isUpcoming: Bool, startDate: Date?, endDate: Date?)? {
        guard let promotions = element["promotions"] as? [String: Any],
              let offersGroups = promotions["upcomingPromotionalOffers"] as? [[String: Any]]
        else { return nil }

        for group in offersGroups {
            guard let offers = group["promotionalOffers"] as? [[String: Any]] else { continue }
            for offer in offers {
                let discount = offer["discountSetting"] as? [String: Any]
                let discountPercentage = discount?["discountPercentage"] as? Int
                let discountType = discount?["discountType"] as? String

                if discountType == "PERCENTAGE" && discountPercentage == 0 {
                    let startDate = parseDate(offer["startDate"] as? String)
                    let endDate = parseDate(offer["endDate"] as? String)
                    return (true, startDate, endDate)
                }
            }
        }
        return nil
    }

    private static func bestCoverImageURL(from images: [[String: Any]]?) -> URL? {
        guard let images, !images.isEmpty else { return nil }
        let priorities = [
            "DieselGameBoxTall",
            "Thumbnail",
            "OfferImageTall",
            "DieselGameBox",
            "VaultClosed"
        ]

        for priority in priorities {
            if let found = images.first(where: { ($0["type"] as? String)?.caseInsensitiveCompare(priority) == .orderedSame }),
               let urlString = found["url"] as? String,
               let url = URL(string: urlString) {
                return url
            }
        }

        if let first = images.first?["url"] as? String, let url = URL(string: first) {
            return url
        }
        return nil
    }

    private static func resolveStoreURL(element: [String: Any]) -> URL {
        if let mappings = element["offerMappings"] as? [[String: Any]],
           let home = mappings.first(where: { ($0["pageType"] as? String) == "productHome" }),
           let slug = home["pageSlug"] as? String, !slug.isEmpty {
            return URL(string: "https://store.epicgames.com/p/\(slug)")!
        }

        if let slug = element["productSlug"] as? String, !slug.isEmpty {
            return URL(string: "https://store.epicgames.com/p/\(slug)")!
        }

        if let slug = element["urlSlug"] as? String, !slug.isEmpty {
            return URL(string: "https://store.epicgames.com/p/\(slug)")!
        }

        return URL(string: "https://store.epicgames.com/free-games")!
    }
}

/// Client to fetch and cache Epic Games official weekly free promotions.
public actor EpicPromotionsClient {
    public static let shared = EpicPromotionsClient()

    private var cachedPromotions: [EpicFreeGame] = []
    private var lastFetch: Date?
    private let cacheTTL: TimeInterval = 1800 // 30 minutes

    private init() {}

    public func currentFreeGames(forceRefresh: Bool = false) async -> [EpicFreeGame] {
        if !forceRefresh,
           !cachedPromotions.isEmpty,
           let lastFetch,
           Date().timeIntervalSince(lastFetch) < cacheTTL {
            return cachedPromotions
        }

        var request = URLRequest(url: EpicPromotionsParser.feedURL)
        request.setValue("Vermut/1.2.0 (Mac; Apple Silicon)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15

        guard let (data, response) = try? await URLSession.shared.data(for: request) else {
            return cachedPromotions
        }

        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            return cachedPromotions
        }

        let parsed = EpicPromotionsParser.parseFreeGames(from: data)
        cachedPromotions = parsed
        lastFetch = Date()
        return parsed
    }
}
