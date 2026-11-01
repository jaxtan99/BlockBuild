import SwiftUI
import SceneKit
import UIKit

// MARK: - Custom World Type Model

struct CustomWorldType: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var promptDescription: String
    var baseWorldType: WorldType
    var iconName: String
    var summary: String

    // Terrain parameters
    var surfaceBlock: BlockType
    var subsurfaceBlock: BlockType
    var deepBlock: BlockType
    var baseHeight: Float
    var heightVariance: Float
    var noiseFrequency: Float
    var warpScale: Float
    var waterLevel: Int // -1 for no water
    var hasTrees: Bool
    var treeStyle: String // "oak", "palm", "fungal", "none"
    var isFloatingIslands: Bool
    var isSubterranean: Bool

    // Atmospheric lighting & colors
    var skyRed: Float
    var skyGreen: Float
    var skyBlue: Float
    var fogRed: Float
    var fogGreen: Float
    var fogBlue: Float
    var ambientIntensity: Float
    var sunIntensity: Float

    // Village & Structure parameters
    var hasVillages: Bool = false
    var villageDensity: Float = 0.0 // 0.0 to 1.0 (e.g. 0.85 for full of villages)
    var villageStyle: String = "medieval" // "medieval", "desert", "stone", "cyber", "ruins"
    var structureType: String = "none" // "village", "castle", "pyramid", "temple", "tower", "cabins"

    // Waterfall & River parameters
    var hasWaterfalls: Bool = false
    var waterfallDensity: Float = 0.0 // 0.0 to 1.0 (e.g. 0.85 for dense waterfalls)

    var createdAt: Date = Date()

    var skyColor: Color {
        Color(red: Double(skyRed), green: Double(skyGreen), blue: Double(skyBlue))
    }

    var fogColor: Color {
        Color(red: Double(fogRed), green: Double(fogGreen), blue: Double(fogBlue))
    }

    enum CodingKeys: String, CodingKey {
        case id, name, promptDescription, baseWorldType, iconName, summary
        case surfaceBlock, subsurfaceBlock, deepBlock
        case baseHeight, heightVariance, noiseFrequency, warpScale, waterLevel
        case hasTrees, treeStyle, isFloatingIslands, isSubterranean
        case skyRed, skyGreen, skyBlue, fogRed, fogGreen, fogBlue
        case ambientIntensity, sunIntensity, createdAt
        case hasVillages, villageDensity, villageStyle, structureType
        case hasWaterfalls, waterfallDensity
    }

    init(
        id: UUID = UUID(),
        name: String,
        promptDescription: String,
        baseWorldType: WorldType,
        iconName: String,
        summary: String,
        surfaceBlock: BlockType,
        subsurfaceBlock: BlockType,
        deepBlock: BlockType,
        baseHeight: Float,
        heightVariance: Float,
        noiseFrequency: Float,
        warpScale: Float,
        waterLevel: Int,
        hasTrees: Bool,
        treeStyle: String,
        isFloatingIslands: Bool,
        isSubterranean: Bool,
        skyRed: Float,
        skyGreen: Float,
        skyBlue: Float,
        fogRed: Float,
        fogGreen: Float,
        fogBlue: Float,
        ambientIntensity: Float,
        sunIntensity: Float,
        hasVillages: Bool = false,
        villageDensity: Float = 0.0,
        villageStyle: String = "medieval",
        structureType: String = "none",
        hasWaterfalls: Bool = false,
        waterfallDensity: Float = 0.0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.promptDescription = promptDescription
        self.baseWorldType = baseWorldType
        self.iconName = iconName
        self.summary = summary
        self.surfaceBlock = surfaceBlock
        self.subsurfaceBlock = subsurfaceBlock
        self.deepBlock = deepBlock
        self.baseHeight = baseHeight
        self.heightVariance = heightVariance
        self.noiseFrequency = noiseFrequency
        self.warpScale = warpScale
        self.waterLevel = waterLevel
        self.hasTrees = hasTrees
        self.treeStyle = treeStyle
        self.isFloatingIslands = isFloatingIslands
        self.isSubterranean = isSubterranean
        self.skyRed = skyRed
        self.skyGreen = skyGreen
        self.skyBlue = skyBlue
        self.fogRed = fogRed
        self.fogGreen = fogGreen
        self.fogBlue = fogBlue
        self.ambientIntensity = ambientIntensity
        self.sunIntensity = sunIntensity
        self.hasVillages = hasVillages
        self.villageDensity = villageDensity
        self.villageStyle = villageStyle
        self.structureType = structureType
        self.hasWaterfalls = hasWaterfalls
        self.waterfallDensity = waterfallDensity
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        promptDescription = try container.decodeIfPresent(String.self, forKey: .promptDescription) ?? ""
        baseWorldType = try container.decode(WorldType.self, forKey: .baseWorldType)
        iconName = try container.decodeIfPresent(String.self, forKey: .iconName) ?? "globe.americas.fill"
        summary = try container.decodeIfPresent(String.self, forKey: .summary) ?? ""
        surfaceBlock = try container.decode(BlockType.self, forKey: .surfaceBlock)
        subsurfaceBlock = try container.decode(BlockType.self, forKey: .subsurfaceBlock)
        deepBlock = try container.decode(BlockType.self, forKey: .deepBlock)
        baseHeight = try container.decode(Float.self, forKey: .baseHeight)
        heightVariance = try container.decode(Float.self, forKey: .heightVariance)
        noiseFrequency = try container.decode(Float.self, forKey: .noiseFrequency)
        warpScale = try container.decode(Float.self, forKey: .warpScale)
        waterLevel = try container.decode(Int.self, forKey: .waterLevel)
        hasTrees = try container.decode(Bool.self, forKey: .hasTrees)
        treeStyle = try container.decode(String.self, forKey: .treeStyle)
        isFloatingIslands = try container.decode(Bool.self, forKey: .isFloatingIslands)
        isSubterranean = try container.decode(Bool.self, forKey: .isSubterranean)
        skyRed = try container.decode(Float.self, forKey: .skyRed)
        skyGreen = try container.decode(Float.self, forKey: .skyGreen)
        skyBlue = try container.decode(Float.self, forKey: .skyBlue)
        fogRed = try container.decode(Float.self, forKey: .fogRed)
        fogGreen = try container.decode(Float.self, forKey: .fogGreen)
        fogBlue = try container.decode(Float.self, forKey: .fogBlue)
        ambientIntensity = try container.decode(Float.self, forKey: .ambientIntensity)
        sunIntensity = try container.decode(Float.self, forKey: .sunIntensity)
        hasVillages = try container.decodeIfPresent(Bool.self, forKey: .hasVillages) ?? false
        villageDensity = try container.decodeIfPresent(Float.self, forKey: .villageDensity) ?? 0.0
        villageStyle = try container.decodeIfPresent(String.self, forKey: .villageStyle) ?? "medieval"
        structureType = try container.decodeIfPresent(String.self, forKey: .structureType) ?? "none"
        hasWaterfalls = try container.decodeIfPresent(Bool.self, forKey: .hasWaterfalls) ?? false
        waterfallDensity = try container.decodeIfPresent(Float.self, forKey: .waterfallDensity) ?? 0.0
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }
}

// MARK: - Custom Skin Model

struct CustomSkin: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var promptDescription: String
    var roleSubtitle: String
    var headColorHex: String
    var torsoColorHex: String
    var legsColorHex: String
    var accentColorHex: String
    var eyeColorHex: String
    var hairColorHex: String
    var featureStyleRaw: String
    var pngData: Data
    var createdAt: Date = Date()

    var headColor: UIColor { UIColor(hex: headColorHex) ?? .white }
    var torsoColor: UIColor { UIColor(hex: torsoColorHex) ?? .blue }
    var legsColor: UIColor { UIColor(hex: legsColorHex) ?? .darkGray }
    var accentColor: UIColor { UIColor(hex: accentColorHex) ?? .yellow }
    var eyeColor: UIColor { UIColor(hex: eyeColorHex) ?? .cyan }
    var hairColor: UIColor { UIColor(hex: hairColorHex) ?? .black }

    var bootsColor: UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        legsColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: max(0, r * 0.65), green: max(0, g * 0.65), blue: max(0, b * 0.65), alpha: 1.0)
    }

    var featureStyle: SkinFeatureStyle {
        SkinFeatureStyle(rawValue: featureStyleRaw) ?? .classic
    }
}

// MARK: - Hex Color Helper

extension UIColor {
    convenience init?(hex: String) {
        var clean = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if clean.hasPrefix("#") { clean.removeFirst() }
        guard clean.count == 6, let rgb = UInt64(clean, radix: 16) else { return nil }
        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }

    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

// MARK: - Lightweight On-Device AI Engine

final class LightweightGameAI {
    static let shared = LightweightGameAI()

    // MARK: - Sample Prompts for Inspiration

    static let sampleWorldPrompts: [String] = [
        "Volcanic inferno with dark obsidian rocks, lava pools, and ominous crimson ash skies",
        "Floating celestial sky islands with lush hanging moss, waterfalls, and lavender twilight clouds",
        "Deep mysterious cavern abyss with towering stone pillars, glowing stalactites, and cyan mist",
        "Tropical paradise archipelago with crystalline aqua seas, golden sands, and tall palm trees",
        "Gigantic snow-capped alpine peaks with extreme sheer cliffs, icy lakes, and pale winter fog",
        "Endless golden desert dunes with hidden sandstone ruins and blistering sun rays",
        "Alien cybernetic realm made of neon smooth stone, glass spires, and radioactive green mist"
    ]

    // MARK: - World Generation AI Synthesizer

    func synthesizeWorld(prompt: String) -> CustomWorldType {
        let clean = prompt.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // 1. Determine Archetype & Elevation
        var baseType: WorldType = .standard
        var isFloating = false
        var isCaverns = false
        var icon = "globe.americas.fill"
        var baseHeight: Float = 6.0
        var heightVariance: Float = 9.0
        var frequency: Float = 0.03
        var warpScale: Float = 0.02
        var waterLvl: Int = 5
        var hasTrees = true
        var treeStyle = "oak"

        if clean.contains("float") || clean.contains("sky") || clean.contains("cloud") || clean.contains("aerial") || clean.contains("void") {
            baseType = .skyIslands
            isFloating = true
            icon = "cloud.fill"
            baseHeight = 22.0
            heightVariance = 6.0
            waterLvl = -1
            treeStyle = "oak"
        } else if clean.contains("cave") || clean.contains("cavern") || clean.contains("underground") || clean.contains("subterranean") || clean.contains("abyss") || clean.contains("hollow") {
            baseType = .caveLands
            isCaverns = true
            icon = "flashlight.on.fill"
            baseHeight = 6.0
            heightVariance = 4.0
            waterLvl = 3
            treeStyle = "fungal"
        } else if clean.contains("peak") || clean.contains("mountain") || clean.contains("cliff") || clean.contains("alpine") || clean.contains("amplified") || clean.contains("towering") || clean.contains("extreme") {
            baseType = .amplified
            icon = "mountain.2.fill"
            baseHeight = 8.0
            heightVariance = 24.0
            frequency = 0.022
            warpScale = 0.025
            waterLvl = 5
            treeStyle = "oak"
        } else if clean.contains("desert") || clean.contains("dune") || clean.contains("sand") || clean.contains("arid") || clean.contains("wasteland") {
            baseType = .desert
            icon = "sun.max.fill"
            baseHeight = 6.0
            heightVariance = 8.0
            waterLvl = 4
            treeStyle = "palm"
        } else if clean.contains("ocean") || clean.contains("deep sea") || clean.contains("trench") || clean.contains("submerged") || clean.contains("aquatic") {
            baseType = .oceanWorld
            icon = "water.waves"
            baseHeight = 3.0
            heightVariance = 4.0
            waterLvl = 10
            treeStyle = "none"
            hasTrees = false
        } else if clean.contains("island") || clean.contains("archipelago") || clean.contains("tropical") || clean.contains("beach") || clean.contains("atoll") || clean.contains("coast") {
            baseType = .seaIslands
            icon = "leaf.fill"
            baseHeight = 7.0
            heightVariance = 11.0
            waterLvl = 5
            treeStyle = "palm"
        } else if clean.contains("flat") || clean.contains("level") || clean.contains("arena") || clean.contains("plain") || clean.contains("building") {
            baseType = .flat
            icon = "square.fill"
            baseHeight = 4.0
            heightVariance = 0.0
            waterLvl = -1
            treeStyle = "none"
            hasTrees = false
        }

        // 2. Determine Block Materials
        var surface: BlockType = .grass
        var subsurface: BlockType = .dirt
        var deep: BlockType = .stone

        if clean.contains("volcan") || clean.contains("magma") || clean.contains("lava") || clean.contains("inferno") || clean.contains("nether") || clean.contains("obsidian") || clean.contains("dark") {
            surface = .smoothStone
            subsurface = .stone
            deep = .stone
            treeStyle = "none"
            hasTrees = false
        } else if clean.contains("sand") || clean.contains("desert") || clean.contains("dune") || clean.contains("beach") {
            surface = .sand
            subsurface = .sand
            deep = .smoothStone
        } else if clean.contains("cyber") || clean.contains("neon") || clean.contains("alien") || clean.contains("crystal") || clean.contains("futuristic") {
            surface = .smoothStone
            subsurface = .glass
            deep = .smoothStone
        } else if clean.contains("snow") || clean.contains("ice") || clean.contains("frost") || clean.contains("arctic") || clean.contains("winter") {
            surface = .smoothStone
            subsurface = .dirt
            deep = .stone
        } else if isCaverns {
            surface = .smoothStone
            subsurface = .dirt
            deep = .stone
        }

        // 3. Atmosphere & Sky Colors
        var skyR: Float = 0.60
        var skyG: Float = 0.80
        var skyB: Float = 1.00
        var fogR: Float = 0.65
        var fogG: Float = 0.83
        var fogB: Float = 1.00
        var ambientLight: Float = 560
        var sunLight: Float = 880

        if clean.contains("red") || clean.contains("crimson") || clean.contains("volcan") || clean.contains("inferno") || clean.contains("lava") {
            skyR = 0.35; skyG = 0.08; skyB = 0.08
            fogR = 0.45; fogG = 0.12; fogB = 0.10
            ambientLight = 420; sunLight = 650
        } else if clean.contains("purple") || clean.contains("violet") || clean.contains("lavender") || clean.contains("twilight") || clean.contains("cosmic") {
            skyR = 0.28; skyG = 0.15; skyB = 0.42
            fogR = 0.36; fogG = 0.22; fogB = 0.52
            ambientLight = 480; sunLight = 720
        } else if clean.contains("green") || clean.contains("emerald") || clean.contains("toxic") || clean.contains("swamp") || clean.contains("radioactive") {
            skyR = 0.15; skyG = 0.32; skyB = 0.18
            fogR = 0.20; fogG = 0.45; fogB = 0.24
            ambientLight = 500; sunLight = 760
        } else if clean.contains("night") || clean.contains("dark") || clean.contains("shadow") || clean.contains("midnight") || clean.contains("abyss") || isCaverns {
            skyR = 0.06; skyG = 0.08; skyB = 0.14
            fogR = 0.09; fogG = 0.12; fogB = 0.18
            ambientLight = 360; sunLight = 400
        } else if clean.contains("sunset") || clean.contains("golden") || clean.contains("orange") || clean.contains("amber") {
            skyR = 0.85; skyG = 0.45; skyB = 0.22
            fogR = 0.90; fogG = 0.55; fogB = 0.32
            ambientLight = 620; sunLight = 940
        } else if clean.contains("cyan") || clean.contains("aqua") || clean.contains("turquoise") || clean.contains("tropical") {
            skyR = 0.35; skyG = 0.78; skyB = 0.92
            fogR = 0.45; fogG = 0.85; fogB = 0.96
            ambientLight = 600; sunLight = 920
        }

        // 4. Village & Settlement Architecture Extraction
        var hasVillages = false
        var villageDensity: Float = 0.0
        var villageStyle = "medieval"
        var structureType = "none"

        let settlementKeywords = [
            "village", "villages", "vilage", "vilages", "town", "towns", "city", "cities", "settlement", "settlements",
            "hamlet", "hamlets", "kingdom", "kingdoms", "houses", "house", "cottage", "cottages", "cabins", "cabin",
            "castle", "castles", "fortress", "pyramid", "pyramids", "temple", "temples", "ruins", "ruin",
            "civilization", "civilisation", "colony", "colonies", "buildings", "dwellings", "camp", "camps",
            "outpost", "outposts", "spire", "spires", "peopled", "populated", "suburb", "neighborhood", "community",
            "empire", "stronghold", "bastion", "manor", "palace", "bazaar", "market", "huts", "shacks", "lodges"
        ]

        if settlementKeywords.contains(where: { clean.contains($0) }) {
            hasVillages = true
            structureType = "village"
            icon = "house.lodge.fill"

            // Density extraction: "full of villages", "everywhere", "dense", "many", "lots of", "infinite", "tons"
            let highDensityKeywords = ["full", "everywhere", "dense", "density", "many", "lots", "all over", "infinite", "pack", "packed", "tons", "crowded", "overflowing", "plenty", "max", "maximum", "billion", "million"]
            if highDensityKeywords.contains(where: { clean.contains($0) }) {
                villageDensity = 0.90
            } else {
                villageDensity = 0.65
            }

            // Style extraction
            if clean.contains("desert") || clean.contains("sand") || clean.contains("dune") || clean.contains("pyramid") || clean.contains("oasis") || clean.contains("egypt") {
                villageStyle = "desert"
                if clean.contains("pyramid") { structureType = "pyramid" }
                icon = "building.columns.fill"
            } else if clean.contains("castle") || clean.contains("fortress") || clean.contains("stone") || clean.contains("kingdom") || clean.contains("knights") || clean.contains("citadel") {
                villageStyle = "stone"
                structureType = "castle"
                icon = "shield.fill"
            } else if clean.contains("ruin") || clean.contains("abandoned") || clean.contains("ancient") || clean.contains("decay") || clean.contains("lost") || clean.contains("forgotten") {
                villageStyle = "ruins"
                structureType = "ruins"
                icon = "building.columns.fill"
            } else if clean.contains("cyber") || clean.contains("neon") || clean.contains("alien") || clean.contains("future") || clean.contains("sci-fi") || clean.contains("tech") {
                villageStyle = "cyber"
                structureType = "village"
                icon = "sparkles"
            } else {
                villageStyle = "medieval"
                structureType = "village"
            }

            // For village worlds, make terrain rolling and accessible so buildings sit smoothly
            if baseType == .standard {
                baseHeight = 6.0
                heightVariance = 4.0
                frequency = 0.02
                hasTrees = true
                treeStyle = "oak"
                waterLvl = 4
            }
        }

        // 4b. Waterfall & Mountain Cascade Extraction (Enhanced Natural Language Synthesis)
        var hasWaterfalls = false
        var waterfallDensity: Float = 0.0

        let waterfallKeywords = [
            "waterfall", "waterfalls", "water fall", "water falls", "water-fall", "water-falls",
            "waterfal", "waterfals", "waterfallls", "cascade", "cascades", "cascading", "cataract",
            "cataracts", "torrent", "torrents", "cliff water", "mountain water", "rapids", "falls",
            "stream", "streams", "river", "rivers", "creek", "creeks", "brook", "brooks",
            "mountain river", "alpine spring", "water flowing", "water pouring", "water plunge",
            "flowing water", "plunge pool", "river gorge", "canyon river", "gorge", "springs"
        ]

        let containsWaterfallKeyword = waterfallKeywords.contains(where: { clean.contains($0) })
        let containsWaterAndFlow = clean.contains("water") && (
            clean.contains("fall") || clean.contains("cliff") || clean.contains("mountain") ||
            clean.contains("flow") || clean.contains("pour") || clean.contains("drop") ||
            clean.contains("rock") || clean.contains("chute") || clean.contains("gorge")
        )

        if containsWaterfallKeyword || containsWaterAndFlow {
            hasWaterfalls = true
            icon = "water.waves"

            let highDensityKeywords = ["full", "everywhere", "dense", "density", "many", "lots", "all over", "infinite", "tons", "crowded", "overflowing", "huge", "massive", "giant"]
            if highDensityKeywords.contains(where: { clean.contains($0) }) {
                waterfallDensity = 0.95
            } else {
                waterfallDensity = 0.88
            }

            if !isFloating && !isCaverns {
                baseHeight = max(baseHeight, 14.0)
                heightVariance = max(heightVariance, 24.0)
                warpScale = max(warpScale, 0.026)
            }
            if waterLvl <= 0 {
                waterLvl = 6
            } else {
                waterLvl = max(waterLvl, 6)
            }
            if baseType == .flat {
                baseType = .standard
            }
        }

        // 5. Generate Memorable World Title
        let title = synthesizeWorldTitle(from: prompt, baseType: baseType, hasVillages: hasVillages, hasWaterfalls: hasWaterfalls)
        var summary = "Custom \(baseType.displayName) with \(surface.fullName) surface, \(deep.fullName) crust, and \(hasTrees ? "\(treeStyle) trees" : "barren terrain")."
        if hasVillages {
            summary = "Populated with sprawling procedural \(villageStyle) village settlements (\(Int(villageDensity * 100))% density), town hall, stone watchtower, houses with glass windows and pitched roofs, and connecting pathways."
        }
        if hasWaterfalls {
            summary += " Features towering cliff waterfalls cascading into deep stone plunge pools and winding rivers."
        }

        return CustomWorldType(
            name: title,
            promptDescription: prompt,
            baseWorldType: baseType,
            iconName: icon,
            summary: summary,
            surfaceBlock: surface,
            subsurfaceBlock: subsurface,
            deepBlock: deep,
            baseHeight: baseHeight,
            heightVariance: heightVariance,
            noiseFrequency: frequency,
            warpScale: warpScale,
            waterLevel: waterLvl,
            hasTrees: hasTrees,
            treeStyle: treeStyle,
            isFloatingIslands: isFloating,
            isSubterranean: isCaverns,
            skyRed: skyR,
            skyGreen: skyG,
            skyBlue: skyB,
            fogRed: fogR,
            fogGreen: fogG,
            fogBlue: fogB,
            ambientIntensity: ambientLight,
            sunIntensity: sunLight,
            hasVillages: hasVillages,
            villageDensity: villageDensity,
            villageStyle: villageStyle,
            structureType: structureType,
            hasWaterfalls: hasWaterfalls,
            waterfallDensity: waterfallDensity
        )
    }

    private func synthesizeWorldTitle(from prompt: String, baseType: WorldType, hasVillages: Bool, hasWaterfalls: Bool = false) -> String {
        let words = prompt.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 }
            .map { $0.capitalized }

        if hasWaterfalls {
            let waterfallNouns = ["Falls", "Cascade", "Gorge", "Rapids", "Chasm", "Torrent", "Cataract", "Valley"]
            if let firstInteresting = words.first(where: { !["with", "and", "the", "for", "that", "make", "world", "full", "lots", "many", "waterfall", "waterfalls"].contains($0.lowercased()) }) {
                return "\(firstInteresting) \(waterfallNouns.randomElement() ?? "Falls")"
            }
            return "Cascading \(waterfallNouns.randomElement() ?? "Falls")"
        }

        if hasVillages {
            let settlementNouns = ["Settlement", "Township", "Kingdom", "Haven", "Colony", "Province", "Dominion", "Valley"]
            if let firstInteresting = words.first(where: { !["with", "and", "the", "for", "that", "make", "world", "full", "lots", "many", "villages", "village", "like"].contains($0.lowercased()) }) {
                return "\(firstInteresting) \(settlementNouns.randomElement() ?? "Township")"
            }
            return "Village \(settlementNouns.randomElement() ?? "Settlement")"
        }

        let adjectives = ["Radiant", "Ancient", "Cosmic", "Mystic", "Shattered", "Verdant", "Obsidian", "Golden", "Neon", "Infinite", "Prismatic", "Abyssal"]
        let nouns = ["Dominion", "Expanse", "Sanctuary", "Wilds", "Realms", "Frontier", "Shores", "Peaks", "Isles", "Haven", "Caverns", "Valley"]

        if let firstInteresting = words.first(where: { !["with", "and", "the", "for", "that", "make", "world"].contains($0.lowercased()) }) {
            return "\(firstInteresting) \(nouns.randomElement() ?? "World")"
        }

        return "\(adjectives.randomElement() ?? "Custom") \(baseType.displayName)"
    }

}

// MARK: - AI Studio UI Sheet (AI World Generator)

struct AIStudioSheet: View {
    @ObservedObject var world: VoxelWorld
    @Environment(\.dismiss) private var dismiss

    @State private var worldPrompt: String = ""
    @State private var generatedWorld: CustomWorldType? = nil
    @State private var isSynthesizing: Bool = false
    @State private var studioToast: String? = nil

    @ObservedObject private var themeMgr = MenuThemeManager.shared

    init(world: VoxelWorld) {
        self.world = world
    }

    var body: some View {
        let theme = themeMgr.currentTheme

        GameMenuContainer(
            title: "AI WORLD GENERATOR",
            subtitle: "Synthesize Procedural Worlds With Natural Language",
            icon: "sparkles",
            onDismiss: { dismiss() }
        ) {
            GameCard(title: "DESCRIBE YOUR WORLD", icon: "pencil.and.outline") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Describe any biome, terrain style, atmosphere or planet. Zero lag, 100% offline.")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.white.opacity(0.80))

                    GameTextField(
                        placeholder: "e.g. Mountain valley with towering waterfalls and pine trees...",
                        text: $worldPrompt,
                        icon: "sparkles"
                    )

                    // Inspiration Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            Button {
                                if let sample = LightweightGameAI.sampleWorldPrompts.randomElement() {
                                    worldPrompt = sample
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "dice.fill")
                                    Text("Surprise Me")
                                }
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(theme.primaryAccent.opacity(0.25))
                                .foregroundColor(theme.primaryAccent)
                                .cornerRadius(14)
                            }
                            .buttonStyle(.plain)

                            ForEach(LightweightGameAI.sampleWorldPrompts.prefix(4), id: \.self) { sample in
                                Button {
                                    worldPrompt = sample
                                } label: {
                                    Text(sample.prefix(28) + "...")
                                        .font(.system(size: 9.5, design: .monospaced))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .background(theme.buttonBackground)
                                        .foregroundColor(.white.opacity(0.85))
                                        .cornerRadius(14)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    GameButton(
                        title: isSynthesizing ? "Synthesizing AI World..." : "Synthesize World Type",
                        subtitle: "Generates custom terrain parameters, atmosphere & spawn",
                        icon: isSynthesizing ? "hourglass" : "wand.and.stars",
                        color: theme.primaryAccent,
                        isProminent: true
                    ) {
                        synthesizeWorldAction()
                    }
                    .disabled(worldPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }

            // Synthesized Preview Card
            if let worldType = generatedWorld {
                GameCard(
                    title: worldType.name,
                    icon: worldType.iconName,
                    badge: "SYNTHESIZED"
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(worldType.summary)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.85))

                        if worldType.hasWaterfalls {
                            HStack(spacing: 6) {
                                Image(systemName: "water.waves")
                                Text("Scenic Mountain Waterfalls • Dense Cascades at Spawn")
                            }
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.cyan.opacity(0.2))
                            .foregroundColor(.cyan)
                            .cornerRadius(6)
                        }

                        if worldType.hasVillages {
                            HStack(spacing: 6) {
                                Image(systemName: "house.lodge.fill")
                                Text("Village Settlement World • \(Int(worldType.villageDensity * 100))% Density (\(worldType.villageStyle.capitalized))")
                            }
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yellow.opacity(0.2))
                            .foregroundColor(.yellow)
                            .cornerRadius(6)
                        }

                        HStack(spacing: 8) {
                            blockBadge(title: "Surface", block: worldType.surfaceBlock)
                            blockBadge(title: "Subsurface", block: worldType.subsurfaceBlock)
                            blockBadge(title: "Deep Crust", block: worldType.deepBlock)
                        }

                        HStack(spacing: 10) {
                            GameButton(
                                title: "Save World Type",
                                subtitle: "Save template to library",
                                icon: "square.and.arrow.down.fill",
                                color: theme.secondaryAccent
                            ) {
                                world.saveCustomWorldType(worldType)
                                showToast("Saved to World Types!")
                            }

                            GameButton(
                                title: "Play World Now",
                                subtitle: "Generate terrain & spawn",
                                icon: "play.fill",
                                color: theme.primaryAccent,
                                isProminent: true
                            ) {
                                world.saveCustomWorldType(worldType)
                                world.regenerateWithCustomWorld(worldType)
                                dismiss()
                            }
                        }
                    }
                }
            }

            // Saved Custom Worlds List
            if !world.customWorldTypes.isEmpty {
                GameCard(
                    title: "SAVED AI WORLDS (\(world.customWorldTypes.count))",
                    icon: "folder.fill"
                ) {
                    VStack(spacing: 8) {
                        ForEach(world.customWorldTypes) { custom in
                            HStack(spacing: 10) {
                                Image(systemName: custom.iconName)
                                    .foregroundColor(theme.primaryAccent)
                                    .font(.system(size: 16))
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(custom.name)
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                    Text("\(custom.baseWorldType.displayName) • \(custom.surfaceBlock.fullName)")
                                        .font(.system(size: 9.5, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.6))
                                }

                                Spacer()

                                GameSmallButton(title: "Play", icon: "play.fill", color: theme.primaryAccent, isProminent: true) {
                                    world.regenerateWithCustomWorld(custom)
                                    dismiss()
                                }

                                Button {
                                    world.deleteCustomWorldType(id: custom.id)
                                    showToast("Deleted \(custom.name)")
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 12))
                                        .foregroundColor(.red.opacity(0.8))
                                        .padding(6)
                                }
                            }
                            .padding(8)
                            .background(theme.buttonBackground.opacity(0.6))
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let toast = studioToast {
                Text(toast)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.85))
                    .cornerRadius(20)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private func blockBadge(title: String, block: BlockType) -> some View {
        VStack(spacing: 3) {
            Text(title.uppercased())
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
            Text(block.fullName)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.1))
                .cornerRadius(6)
        }
        .frame(maxWidth: .infinity)
    }

    private func synthesizeWorldAction() {
        isSynthesizing = true
        let synthesized = LightweightGameAI.shared.synthesizeWorld(prompt: worldPrompt)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.generatedWorld = synthesized
            self.isSynthesizing = false
            self.showToast("Synthesized '\(synthesized.name)'!")
        }
    }

    private func showToast(_ text: String) {
        withAnimation { studioToast = text }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if self.studioToast == text {
                withAnimation { self.studioToast = nil }
            }
        }
    }
}
