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

    // Knowledge layer v0.1 (Phase A Task 1, 2026-07-19): grounded
    // per-card data for future LLM interpretation. Draft content marked
    // `knowledge_version: 0.1-draft-unreviewed` in the registry file —
    // founder-reviewed before it becomes authoritative. All fields are
    // optional so older registry files keep decoding unchanged; nothing
    // reads these fields in UI or interpretation logic yet.
    let element: String
    let keywordsUprightZh: [String]
    let keywordsUprightEn: [String]
    let keywordsReversedZh: [String]
    let keywordsReversedEn: [String]
    let coreSymbols: [CoreSymbol]
    let coreUprightZh: String
    let coreUprightEn: String
    let coreReversedZh: String
    let coreReversedEn: String

    struct CoreSymbol: Equatable, Hashable, Codable {
        let zh: String
        let en: String
    }

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
        case element
        case keywordsUprightZh = "keywords_upright_zh"
        case keywordsUprightEn = "keywords_upright_en"
        case keywordsReversedZh = "keywords_reversed_zh"
        case keywordsReversedEn = "keywords_reversed_en"
        case coreSymbols = "core_symbols"
        case coreUprightZh = "core_upright_zh"
        case coreUprightEn = "core_upright_en"
        case coreReversedZh = "core_reversed_zh"
        case coreReversedEn = "core_reversed_en"
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
        // Knowledge fields decode defensively: an older registry file
        // (or a partially-authored one) yields empty values, never a
        // decode failure or crash.
        element = (try? c.decodeIfPresent(String.self, forKey: .element)) ?? ""
        keywordsUprightZh = (try? c.decodeIfPresent([String].self, forKey: .keywordsUprightZh)) ?? []
        keywordsUprightEn = (try? c.decodeIfPresent([String].self, forKey: .keywordsUprightEn)) ?? []
        keywordsReversedZh = (try? c.decodeIfPresent([String].self, forKey: .keywordsReversedZh)) ?? []
        keywordsReversedEn = (try? c.decodeIfPresent([String].self, forKey: .keywordsReversedEn)) ?? []
        coreSymbols = (try? c.decodeIfPresent([CoreSymbol].self, forKey: .coreSymbols)) ?? []
        coreUprightZh = (try? c.decodeIfPresent(String.self, forKey: .coreUprightZh)) ?? ""
        coreUprightEn = (try? c.decodeIfPresent(String.self, forKey: .coreUprightEn)) ?? ""
        coreReversedZh = (try? c.decodeIfPresent(String.self, forKey: .coreReversedZh)) ?? ""
        coreReversedEn = (try? c.decodeIfPresent(String.self, forKey: .coreReversedEn)) ?? ""
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
