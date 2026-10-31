import Foundation

/// Supported category filters on itch.io.
public enum ItchCategory: String, CaseIterable, Identifiable, Sendable {
    case all = "All Free"
    case horror = "Horror"
    case action = "Action"
    case adventure = "Adventure"
    case platformer = "Platformer"
    case simulation = "Simulation"
    case visualNovel = "Visual Novel"
    case rpg = "RPG"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .all: return "sparkles"
        case .horror: return "flame.fill"
        case .action: return "bolt.fill"
        case .adventure: return "map.fill"
        case .platformer: return "gamecontroller.fill"
        case .simulation: return "gearshape.2.fill"
        case .visualNovel: return "book.fill"
        case .rpg: return "shield.fill"
        }
    }

    public func feedURL(page: Int = 1) -> URL {
        let base: String
        switch self {
        case .all: base = "https://itch.io/games/free.xml"
        case .horror: base = "https://itch.io/games/free/tag-horror.xml"
        case .action: base = "https://itch.io/games/free/genre-action.xml"
        case .adventure: base = "https://itch.io/games/free/genre-adventure.xml"
        case .platformer: base = "https://itch.io/games/free/genre-platformer.xml"
        case .simulation: base = "https://itch.io/games/free/genre-simulation.xml"
        case .visualNovel: base = "https://itch.io/games/free/genre-visual-novel.xml"
        case .rpg: base = "https://itch.io/games/free/genre-rpg.xml"
        }
        if page > 1 {
            return URL(string: "\(base)?page=\(page)")!
        }
        return URL(string: base)!
    }
}

/// Represents a game from the itch.io indie DRM-free catalog.
public struct ItchGame: Identifiable, Codable, Sendable, Equatable {
    public var id: String
    public var title: String
    public var url: URL
    public var coverURL: URL?
    public var shortText: String?
    public var price: String?
    public var isFree: Bool
    public var authorName: String?
    public var platforms: [String]

    public init(
        id: String,
        title: String,
        url: URL,
        coverURL: URL? = nil,
        shortText: String? = nil,
        price: String? = nil,
        isFree: Bool = true,
        authorName: String? = nil,
        platforms: [String] = ["Windows"]
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.coverURL = coverURL
        self.shortText = shortText
        self.price = price ?? "Free"
        self.isFree = isFree
        self.authorName = authorName
        self.platforms = platforms
    }
}

public final class ItchManager: NSObject, @unchecked Sendable {
    public static let shared = ItchManager()

    private let session: URLSession

    public override init() {
        self.session = .shared
        super.init()
    }

    /// Curated instant free titles so user never waits for network and top games are immediately visible.
    public static let curatedFreeGames: [ItchGame] = [
        ItchGame(
            id: "the-baby-in-yellow",
            title: "The Baby In Yellow",
            url: URL(string: "https://teamterrible.itch.io/the-baby-in-yellow")!,
            coverURL: URL(string: "https://img.itch.zone/aW1nLzExMTgxNTM4LnBuZw==/315x250%23c/zA8Mw4.png"),
            shortText: "Who is in control? Keep an unruly infant happy through multiple escalating nights of terror.",
            authorName: "Team Terrible",
            platforms: ["Windows", "Android"]
        ),
        ItchGame(
            id: "fears-to-fathom-home-alone",
            title: "Fears to Fathom - Home Alone",
            url: URL(string: "https://rayll.itch.io/fears-to-fathom-home-alone")!,
            coverURL: URL(string: "https://img.itch.zone/aW1nLzYzODAyODQucG5n/315x250%23c/4jF6l%2F.png"),
            shortText: "An episodic psychological horror game where each episode unveils a short story narrated by the ones who survived.",
            authorName: "Rayll",
            platforms: ["Windows"]
        ),
        ItchGame(
            id: "sort-the-court",
            title: "Sort the Court!",
            url: URL(string: "https://graemeborland.itch.io/sort-the-court")!,
            coverURL: URL(string: "https://img.itch.zone/aW1nLzI4NTUzMTMucG5n/315x250%23c/rIeQfV.png"),
            shortText: "Give your decree in simple yes or no answers, and help your kingdom grow in this beloved kingdom builder.",
            authorName: "Graeme Borland",
            platforms: ["Windows", "macOS", "Web"]
        ),
        ItchGame(
            id: "first-cut",
            title: "First Cut",
            url: URL(string: "https://drasnus.itch.io/first-cut")!,
            coverURL: URL(string: "https://img.itch.zone/aW1nLzM0MjYwMjgucG5n/315x250%23c/c21w4F.png"),
            shortText: "A precision samurai sword-fighting game where any strike can be lethal.",
            authorName: "Drasnus",
            platforms: ["Windows"]
        ),
        ItchGame(
            id: "voices-of-the-void",
            title: "Voices Of The Void",
            url: URL(string: "https://mrdrnose.itch.io/votv")!,
            coverURL: URL(string: "https://img.itch.zone/aW1nLzI2NDI5NTgzLmpwZw==/315x250%23c/5lRRHP.jpg"),
            shortText: "Gather unknown signals from deep, silent space. Atmospheric simulation horror.",
            authorName: "mrdrnose",
            platforms: ["Windows"]
        ),
        ItchGame(
            id: "trauma-lab",
            title: "Trauma Lab",
            url: URL(string: "https://traumalab.itch.io/trauma-lab")!,
            coverURL: URL(string: "https://img.itch.zone/aW1nLzMxMTI5MDA2LnBuZw==/315x250%23c/tCwu6l.png"),
            shortText: "An anatomy and physics sandbox. Every bullet is tracked through bone and organ.",
            authorName: "traumalab",
            platforms: ["Windows", "Web"]
        ),
        ItchGame(
            id: "mindmindmind",
            title: "MindMindMind",
            url: URL(string: "https://chattercap.itch.io/mindmindmind")!,
            coverURL: URL(string: "https://img.itch.zone/aW1nLzE1NTcxNjIzLmdpZg==/315x250%23c/ylozxG.gif"),
            shortText: "Play mind games with your yandere British ghost in this captivating psychological visual novel.",
            authorName: "Chattercap",
            platforms: ["Windows", "macOS", "Web"]
        ),
        ItchGame(
            id: "friday-night-funkin",
            title: "Friday Night Funkin'",
            url: URL(string: "https://ninja-muffin24.itch.io/funkin")!,
            coverURL: URL(string: "https://img.itch.zone/aW1nLzQ1MTU3MjkucG5n/315x250%23c/X5L%2FpD.png"),
            shortText: "The hit rhythm arcade game with incredible soundtrack and animations.",
            authorName: "ninja_muffin24",
            platforms: ["Windows", "macOS"]
        ),
        ItchGame(
            id: "spookys-jump-scare-mansion",
            title: "Spooky's Jump Scare Mansion",
            url: URL(string: "https://lagslabs.itch.io/spookys-jump-scare-mansion")!,
            coverURL: URL(string: "https://img.itch.zone/aW1nLzE2MzA1NTAucG5n/315x250%23c/yM%2B34S.png"),
            shortText: "Can you survive 1000 rooms of cute terror? Iconic indie horror classic.",
            authorName: "Lag Studios",
            platforms: ["Windows"]
        ),
        ItchGame(
            id: "cave-story",
            title: "Cave Story (Doukutsu Monogatari)",
            url: URL(string: "https://pixel.itch.io/cave-story")!,
            coverURL: URL(string: "https://img.itch.zone/aW1nLzEyNTExNDkucG5n/315x250%23c/jD%2F7v1.png"),
            shortText: "The legendary action-adventure platformer created by Daisuke Amaya.",
            authorName: "Studio Pixel",
            platforms: ["Windows"]
        ),
        ItchGame(
            id: "celeste-classic",
            title: "Celeste Classic",
            url: URL(string: "https://maddymakesgames.itch.io/celeste-classic")!,
            coverURL: URL(string: "https://img.itch.zone/aW1nLzEwMjQ0ODEucG5n/315x250%23c/Fhy96Y.png"),
            shortText: "The original PICO-8 precision platformer that inspired the full game.",
            authorName: "Maddy Makes Games",
            platforms: ["Windows", "Web"]
        ),
        ItchGame(
            id: "the-masterplan",
            title: "The Masterplan",
            url: URL(string: "https://santiago-garcia.itch.io/the-masterplan")!,
            coverURL: URL(string: "https://img.itch.zone/aW1nLzMwOTY1NDQ2LnBuZw==/315x250%23c/PC8zOT.png"),
            shortText: "Home alone for a day, Stuart invites his best friend over in this atmospheric mystery.",
            authorName: "santiago-garcia",
            platforms: ["Windows", "Linux"]
        ),
        ItchGame(
            id: "ghost-town-pumpkin",
            title: "The Annual Ghost Town Pumpkin Festival",
            url: URL(string: "https://adamgryu.itch.io/pumpkin-carver")!,
            coverURL: URL(string: "https://img.itch.zone/aW1nLzEzNTk4NTQ0LnBuZw==/315x250%23c/4CPM83.png"),
            shortText: "Carve a pumpkin and share it with the world in this cozy indie simulator.",
            authorName: "adamgryu",
            platforms: ["Windows", "macOS", "Linux"]
        )
    ]

    /// Fetches games for a specific category and page.
    public func fetchGames(category: ItchCategory = .all, page: Int = 1) async throws -> [ItchGame] {
        let url = category.feedURL(page: page)
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Vermut/1.2", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 8

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                return page == 1 ? Self.curatedFreeGames : []
            }

            let parsed = parseRSS(data: data)
            if parsed.isEmpty {
                return page == 1 ? Self.curatedFreeGames : []
            }

            if category == .all && page == 1 {
                // Merge with curated list so top classics like The Baby In Yellow are always at the top
                var combined: [ItchGame] = []
                var seenUrls = Set<String>()

                for curated in Self.curatedFreeGames {
                    let key = curated.url.absoluteString.lowercased()
                    if seenUrls.insert(key).inserted {
                        combined.append(curated)
                    }
                }

                for item in parsed {
                    let key = item.url.absoluteString.lowercased()
                    if seenUrls.insert(key).inserted {
                        combined.append(item)
                    }
                }
                return combined
            }
            return parsed
        } catch {
            return page == 1 ? Self.curatedFreeGames : []
        }
    }

    /// Performs a live search across itch.io's entire database.
    public func searchGames(query: String) async throws -> [ItchGame] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return try await fetchGames(category: .all, page: 1)
        }

        // Instant local matches from curated catalog
        let localMatches = Self.curatedFreeGames.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed) ||
            ($0.shortText?.localizedCaseInsensitiveContains(trimmed) ?? false) ||
            ($0.authorName?.localizedCaseInsensitiveContains(trimmed) ?? false)
        }

        guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let searchURL = URL(string: "https://itch.io/search?type=games&q=\(encoded)") else {
            return localMatches
        }

        var request = URLRequest(url: searchURL)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Vermut/1.2", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 10

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode),
                  let html = String(data: data, encoding: .utf8) else {
                return localMatches
            }

            let remoteMatches = parseSearchHTML(html)
            if remoteMatches.isEmpty {
                return localMatches
            }

            var combined: [ItchGame] = []
            var seen = Set<String>()

            // Prioritize exact or local curated match first
            for local in localMatches {
                let key = local.url.absoluteString.lowercased()
                if seen.insert(key).inserted {
                    combined.append(local)
                }
            }

            for remote in remoteMatches {
                let key = remote.url.absoluteString.lowercased()
                if seen.insert(key).inserted {
                    combined.append(remote)
                }
            }

            return combined
        } catch {
            return localMatches
        }
    }

    private func parseSearchHTML(_ html: String) -> [ItchGame] {
        var results: [ItchGame] = []
        // itch.io game cards start with `<div data-game_id="`
        let blocks = html.components(separatedBy: "<div data-game_id=\"")
        guard blocks.count > 1 else { return [] }

        for block in blocks.dropFirst() {
            let gameId = String(block.prefix(while: { $0 != "\"" }))

            // Title & Link
            guard let titleRange = block.range(of: "class=\"game_title\"><a") else { continue }
            let afterTitle = String(block[titleRange.upperBound...])
            guard let hrefStart = afterTitle.range(of: "href=\""),
                  let hrefEnd = afterTitle[hrefStart.upperBound...].range(of: "\"") else { continue }
            let linkStr = String(afterTitle[hrefStart.upperBound..<hrefEnd.lowerBound])
            guard let pageURL = URL(string: linkStr) else { continue }

            guard let openClose = afterTitle.range(of: ">"),
                  let closeA = afterTitle[openClose.upperBound...].range(of: "</a>") else { continue }
            let rawTitle = String(afterTitle[openClose.upperBound..<closeA.lowerBound])
            let title = decodeEntities(rawTitle.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines))
            guard !title.isEmpty else { continue }

            // Image
            var coverURL: URL?
            if let lazyRange = block.range(of: "data-lazy_src=\""),
               let endQuote = block[lazyRange.upperBound...].range(of: "\"") {
                let imgStr = String(block[lazyRange.upperBound..<endQuote.lowerBound])
                coverURL = URL(string: imgStr)
            } else if let srcRange = block.range(of: "src=\"https://img.itch.zone"),
                      let endQuote = block[srcRange.lowerBound...].range(of: "\"") {
                let imgStr = String(block[srcRange.lowerBound...].dropFirst(5).prefix(while: { $0 != "\"" }))
                coverURL = URL(string: String(imgStr))
            } else if let imgZoneRange = block.range(of: "https://img.itch.zone"),
                      let endQuote = block[imgZoneRange.lowerBound...].range(of: "\"") {
                let imgStr = String(block[imgZoneRange.lowerBound..<endQuote.lowerBound])
                coverURL = URL(string: imgStr)
            }

            // Description / Text
            var shortText: String?
            if let textRange = block.range(of: "class=\"game_text\""),
               let textTagEnd = block[textRange.upperBound...].range(of: ">"),
               let closeText = block[textTagEnd.upperBound...].range(of: "</div>") {
                let rawText = String(block[textTagEnd.upperBound..<closeText.lowerBound])
                let decoded = decodeEntities(rawText.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines))
                if !decoded.isEmpty { shortText = decoded }
            }

            // Author
            var authorName: String?
            if let authorRange = block.range(of: "class=\"game_author\"><a"),
               let authorTagEnd = block[authorRange.upperBound...].range(of: ">"),
               let closeAuthor = block[authorTagEnd.upperBound...].range(of: "</a>") {
                let rawAuthor = String(block[authorTagEnd.upperBound..<closeAuthor.lowerBound])
                let decoded = decodeEntities(rawAuthor.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines))
                if !decoded.isEmpty { authorName = decoded }
            } else if let host = pageURL.host?.components(separatedBy: ".").first {
                authorName = host
            }

            // Platforms
            var platforms: [String] = []
            if block.contains("icon-windows8") || block.lowercased().contains("windows") {
                platforms.append("Windows")
            }
            if block.contains("icon-apple") || block.lowercased().contains("macos") || block.lowercased().contains("osx") {
                platforms.append("macOS")
            }
            if block.contains("icon-android") {
                platforms.append("Android")
            }
            if block.contains("web_flag") || block.contains("Play in browser") {
                platforms.append("Web")
            }
            if platforms.isEmpty {
                platforms = ["Windows", "DRM-Free"]
            }

            results.append(ItchGame(
                id: gameId.isEmpty ? pageURL.absoluteString : gameId,
                title: title,
                url: pageURL,
                coverURL: coverURL,
                shortText: shortText,
                price: "Free",
                isFree: true,
                authorName: authorName ?? pageURL.host?.components(separatedBy: ".").first ?? "itch.io",
                platforms: platforms
            ))
        }

        return results
    }

    private func parseRSS(data: Data) -> [ItchGame] {
        let parser = ItchRSSParser(data: data)
        return parser.parse()
    }

    private func decodeEntities(_ text: String) -> String {
        var str = text
        let entities = [
            ("&quot;", "\""),
            ("&#039;", "'"),
            ("&apos;", "'"),
            ("&amp;", "&"),
            ("&lt;", "<"),
            ("&gt;", ">"),
            ("&nbsp;", " "),
            ("&#8217;", "’"),
            ("&#8216;", "‘"),
            ("&#8220;", "“"),
            ("&#8221;", "”"),
            ("&#8211;", "–"),
            ("&#8212;", "—")
        ]
        for (entity, rep) in entities {
            str = str.replacingOccurrences(of: entity, with: rep)
        }
        return str
    }
}

private final class ItchRSSParser: NSObject, XMLParserDelegate {
    private let parser: XMLParser
    private var games: [ItchGame] = []

    private var currentElement = ""
    private var currentGuid = ""
    private var currentTitle = ""
    private var currentPlainTitle = ""
    private var currentLink = ""
    private var currentImageURL = ""
    private var currentDescription = ""
    private var currentPrice = ""
    private var currentPlatforms: [String] = []
    private var insideItem = false
    private var insidePlatforms = false

    init(data: Data) {
        self.parser = XMLParser(data: data)
        super.init()
        self.parser.delegate = self
    }

    func parse() -> [ItchGame] {
        parser.parse()
        return games
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "item" {
            insideItem = true
            currentGuid = ""
            currentTitle = ""
            currentPlainTitle = ""
            currentLink = ""
            currentImageURL = ""
            currentDescription = ""
            currentPrice = ""
            currentPlatforms = []
        } else if elementName == "platforms" {
            insidePlatforms = true
        } else if insidePlatforms {
            if elementName == "windows" { currentPlatforms.append("Windows") }
            else if elementName == "osx" { currentPlatforms.append("macOS") }
            else if elementName == "linux" { currentPlatforms.append("Linux") }
            else if elementName == "html" { currentPlatforms.append("Web") }
            else if elementName == "android" { currentPlatforms.append("Android") }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard insideItem else { return }
        switch currentElement {
        case "guid": currentGuid += string
        case "title": currentTitle += string
        case "plainTitle": currentPlainTitle += string
        case "link": currentLink += string
        case "imageurl": currentImageURL += string
        case "description": currentDescription += string
        case "price": currentPrice += string
        default: break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "platforms" {
            insidePlatforms = false
        } else if elementName == "item" {
            insideItem = false
            let cleanPlain = decodeEntities(currentPlainTitle.trimmingCharacters(in: .whitespacesAndNewlines))
            let cleanRaw = decodeEntities(currentTitle.trimmingCharacters(in: .whitespacesAndNewlines))
            var title = cleanPlain.isEmpty ? (cleanRaw.isEmpty ? "Indie Game" : cleanRaw) : cleanPlain
            // Strip trailing [Free] [Genre] tags if plainTitle was empty
            if title.contains("[") {
                title = title.components(separatedBy: "[")[0].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            // Strip quotes around title
            if title.hasPrefix("\"") && title.hasSuffix("\"") && title.count > 2 {
                title = String(title.dropFirst().dropLast())
            }

            let cleanLink = currentLink.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let url = URL(string: cleanLink.isEmpty ? currentGuid.trimmingCharacters(in: .whitespacesAndNewlines) : cleanLink) else {
                return
            }

            let cleanImg = currentImageURL.trimmingCharacters(in: .whitespacesAndNewlines)
            let coverURL = cleanImg.isEmpty ? nil : URL(string: cleanImg)
            let rawDesc = currentDescription.components(separatedBy: "<")[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let shortText = decodeEntities(rawDesc)

            let author = url.host?.components(separatedBy: ".").first ?? "itch.io creator"

            var platforms = currentPlatforms
            if platforms.isEmpty {
                platforms = ["Windows", "DRM-Free"]
            }

            games.append(ItchGame(
                id: currentGuid.isEmpty ? url.absoluteString : currentGuid,
                title: title,
                url: url,
                coverURL: coverURL,
                shortText: shortText.isEmpty ? nil : shortText,
                price: currentPrice.isEmpty ? "Free" : currentPrice,
                isFree: true,
                authorName: author,
                platforms: platforms
            ))
        }
    }

    private func decodeEntities(_ text: String) -> String {
        var str = text
        let entities = [
            ("&quot;", "\""),
            ("&#039;", "'"),
            ("&apos;", "'"),
            ("&amp;", "&"),
            ("&lt;", "<"),
            ("&gt;", ">"),
            ("&nbsp;", " "),
            ("&#8217;", "’"),
            ("&#8216;", "‘"),
            ("&#8220;", "“"),
            ("&#8221;", "”"),
            ("&#8211;", "–"),
            ("&#8212;", "—")
        ]
        for (entity, rep) in entities {
            str = str.replacingOccurrences(of: entity, with: rep)
        }
        return str
    }
}
