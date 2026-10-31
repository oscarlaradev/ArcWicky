import XCTest
@testable import CaskLauncherCore

final class LegendaryCacheTests: XCTestCase {

    func testInstalledGameIsCodable() throws {
        let game = InstalledGame(
            store: .epic,
            appId: "Fortnite",
            name: "Fortnite",
            installDir: "/prefix/drive_c/Games/Fortnite",
            coverURLs: [URL(string: "https://example.com/cover.jpg")!],
            isInstalled: true
        )

        let data = try JSONEncoder().encode([game])
        let decoded = try JSONDecoder().decode([InstalledGame].self, from: data)

        XCTAssertEqual(decoded.count, 1)
        XCTAssertEqual(decoded[0].store, .epic)
        XCTAssertEqual(decoded[0].appId, "Fortnite")
        XCTAssertEqual(decoded[0].name, "Fortnite")
        XCTAssertEqual(decoded[0].installDir, "/prefix/drive_c/Games/Fortnite")
        XCTAssertEqual(decoded[0].coverURLs.first?.absoluteString, "https://example.com/cover.jpg")
        XCTAssertTrue(decoded[0].isInstalled)
    }

    func testSaveAndLoadDiskCache() {
        let manager = LegendaryManager.shared
        let testGames = [
            InstalledGame(
                store: .epic,
                appId: "TestGame",
                name: "Test Game",
                isInstalled: false
            )
        ]

        manager.saveDiskCache(testGames)
        let loaded = manager.loadDiskCache()
        XCTAssertEqual(loaded?.first?.appId, "TestGame")
        XCTAssertEqual(loaded?.first?.name, "Test Game")

        manager.invalidateCache()
        let afterInvalidate = manager.loadDiskCache()
        XCTAssertNil(afterInvalidate)
    }
}

