import XCTest
@testable import CaskLauncherCore

final class EpicPromotionsTests: XCTestCase {

    func testParseDateWithFractionAndWithout() {
        let withFraction = "2026-11-05T16:00:00.000Z"
        let date1 = EpicPromotionsParser.parseDate(withFraction)
        XCTAssertNotNil(date1)

        let plain = "2026-11-05T16:00:00Z"
        let date2 = EpicPromotionsParser.parseDate(plain)
        XCTAssertNotNil(date2)

        XCTAssertNil(EpicPromotionsParser.parseDate(nil))
        XCTAssertNil(EpicPromotionsParser.parseDate(""))
    }

    func testParseFreeGamesExtractsActiveZeroDiscountPromotion() {
        let json = """
        {
          "data": {
            "Catalog": {
              "searchStore": {
                "elements": [
                  {
                    "id": "item-123",
                    "title": "Super Cool Game",
                    "description": "An awesome indie game.",
                    "productSlug": "super-cool-game",
                    "offerMappings": [
                      { "pageSlug": "super-cool-game-slug", "pageType": "productHome" }
                    ],
                    "keyImages": [
                      { "type": "DieselGameBoxTall", "url": "https://cdn.example.com/cover.jpg" },
                      { "type": "Thumbnail", "url": "https://cdn.example.com/thumb.jpg" }
                    ],
                    "price": {
                      "totalPrice": {
                        "fmtPrice": {
                          "originalPrice": "$19.99"
                        }
                      }
                    },
                    "promotions": {
                      "promotionalOffers": [
                        {
                          "promotionalOffers": [
                            {
                              "startDate": "2026-10-30T15:00:00.000Z",
                              "endDate": "2026-11-06T15:00:00.000Z",
                              "discountSetting": {
                                "discountType": "PERCENTAGE",
                                "discountPercentage": 0
                              }
                            }
                          ]
                        }
                      ]
                    }
                  },
                  {
                    "id": "item-paid",
                    "title": "Not Free Game",
                    "description": "This game is not free.",
                    "price": {
                      "totalPrice": {
                        "fmtPrice": { "originalPrice": "$59.99" }
                      }
                    },
                    "promotions": {
                      "promotionalOffers": [
                        {
                          "promotionalOffers": [
                            {
                              "startDate": "2026-10-30T15:00:00.000Z",
                              "endDate": "2026-11-06T15:00:00.000Z",
                              "discountSetting": {
                                "discountType": "PERCENTAGE",
                                "discountPercentage": 50
                              }
                            }
                          ]
                        }
                      ]
                    }
                  }
                ]
              }
            }
          }
        }
        """.data(using: .utf8)!

        let games = EpicPromotionsParser.parseFreeGames(from: json)
        XCTAssertEqual(games.count, 1)

        let freeGame = games[0]
        XCTAssertEqual(freeGame.id, "item-123")
        XCTAssertEqual(freeGame.title, "Super Cool Game")
        XCTAssertEqual(freeGame.description, "An awesome indie game.")
        XCTAssertEqual(freeGame.originalPrice, "$19.99")
        XCTAssertEqual(freeGame.coverURL?.absoluteString, "https://cdn.example.com/cover.jpg")
        XCTAssertEqual(freeGame.storeURL.absoluteString, "https://store.epicgames.com/p/super-cool-game-slug")
        XCTAssertNotNil(freeGame.endDate)
        XCTAssertTrue(freeGame.expiryText?.contains("Free until") == true)
    }
}

