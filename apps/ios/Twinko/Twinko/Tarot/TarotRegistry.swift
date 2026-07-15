import Foundation

/// One card from the canonical 78-card registry
/// (`twinko_tarot_card_registry_v1.json`). The registry file is the
/// source of truth for ids, display names, and asset filenames — card
/// mappings are never hardcoded in view code.
struct TarotCardInfo: Identifiable, Equatable, Hashable, Codable {
    let id: String
    let assetFileName: String
    let displayNameEn: String
    let displayNameZh: String
    let arcanaType: String
    let suit: String
    let rank: String

    /// Imageset name (registry filename without extension).
    var assetName: String {
        assetFileName.hasSuffix(".png") ? String(assetFileName.dropLast(4)) : assetFileName
    }

    func displayName(for lang: AppLanguage) -> String {
        lang == .english ? displayNameEn : displayNameZh
    }

    enum CodingKeys: String, CodingKey {
        case id
        case assetFileName = "asset_name"
        case displayNameEn = "display_name_en"
        case displayNameZh = "display_name_zh_tw"
        case arcanaType = "arcana_type"
        case suit, rank
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        assetFileName = try c.decode(String.self, forKey: .assetFileName)
        displayNameEn = try c.decode(String.self, forKey: .displayNameEn)
        displayNameZh = try c.decode(String.self, forKey: .displayNameZh)
        arcanaType = try c.decode(String.self, forKey: .arcanaType)
        suit = (try? c.decode(String.self, forKey: .suit)) ?? ""
        rank = (try? c.decode(String.self, forKey: .rank)) ?? ""
    }
}

/// Loads and caches the canonical card registry from the app bundle.
enum TarotRegistry {
    private struct RegistryFile: Codable {
        let deck_size: Int
        let cards: [TarotCardInfo]
    }

    /// The full 78-card deck, in registry order.
    static let cards: [TarotCardInfo] = {
        guard let url = Bundle.main.url(forResource: "twinko_tarot_card_registry_v1",
                                        withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(RegistryFile.self, from: data) else {
            assertionFailure("Tarot card registry missing or malformed")
            return []
        }
        return file.cards
    }()
}
