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

    static let sampleSkinPrompts: [String] = [
        "Cyberpunk neon operative with dark tactical armor, glowing cyan visor, and purple circuits",
        "Ancient horned desert warlord with obsidian chestplate, golden trim, and glowing amber eyes",
        "Deep cavern spelunker with brass miner headlamp, leather backpack, and sturdy steel boots",
        "Mystic cosmic archmage with midnight purple robe, starry cowl, and radiant violet eyes",
        "Shadow shinobi assassin with charcoal ninja cowl, crimson warband, and stealth armor",
        "High-tech galactic astronaut with solar gold reflection visor and insulated white suit",
        "Frozen arctic survivor with heavy fur hood, ice-blue parkas, and frosted boots"
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

        // 5. Generate Memorable World Title
        let title = synthesizeWorldTitle(from: prompt, baseType: baseType, hasVillages: hasVillages)
        var summary = "Custom \(baseType.displayName) with \(surface.fullName) surface, \(deep.fullName) crust, and \(hasTrees ? "\(treeStyle) trees" : "barren terrain")."
        if hasVillages {
            summary = "Populated with sprawling procedural \(villageStyle) village settlements (\(Int(villageDensity * 100))% density), town hall, stone watchtower, houses with glass windows and pitched roofs, and connecting pathways."
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
            structureType: structureType
        )
    }

    private func synthesizeWorldTitle(from prompt: String, baseType: WorldType, hasVillages: Bool) -> String {
        let words = prompt.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 }
            .map { $0.capitalized }

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

    // MARK: - Character Skin AI Synthesizer

    func synthesizeSkin(prompt: String) -> CustomSkin {
        let clean = prompt.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // 1. Feature Style extraction
        var featureStyleRaw = "classic"
        var role = "AI Crafted Adventurer"

        if clean.contains("cat") || clean.contains("neko") || clean.contains("kitty") || clean.contains("kitten") || clean.contains("feline") {
            featureStyleRaw = "catEars"
            role = "Neko Adventurer"
        } else if clean.contains("sunglass") || clean.contains("glasses") || clean.contains("shades") || clean.contains("spectacles") || clean.contains("cool") {
            featureStyleRaw = "sunglasses"
            role = "Cool Operative"
        } else if clean.contains("superhero") || clean.contains("hero") || clean.contains("batman") || clean.contains("spiderman") || clean.contains("avenger") || clean.contains("robin") || clean.contains("cape") {
            featureStyleRaw = "superheroMask"
            role = "Masked Hero"
        } else if clean.contains("villager") || clean.contains("farmer") || clean.contains("merchant") || clean.contains("peasant") || clean.contains("baker") || clean.contains("blacksmith") {
            featureStyleRaw = "villagerRobe"
            role = "Village Inhabitant"
        } else if clean.contains("king") || clean.contains("queen") || clean.contains("crown") || clean.contains("monarch") || clean.contains("emperor") || clean.contains("prince") || clean.contains("princess") {
            featureStyleRaw = "crown"
            role = "Imperial Sovereign"
        } else if clean.contains("pirate") || clean.contains("corsair") || clean.contains("buccaneer") || clean.contains("eyepatch") || clean.contains("sailor") || clean.contains("captain") {
            featureStyleRaw = "pirateEyepatch"
            role = "High Seas Corsair"
        } else if clean.contains("gamer") || clean.contains("headphone") || clean.contains("streamer") || clean.contains("hoodie") || clean.contains("boy") || clean.contains("girl") || clean.contains("teen") {
            featureStyleRaw = "headphones"
            role = "Pro Streamer"
        } else if clean.contains("visor") || clean.contains("knight") || clean.contains("armor") || clean.contains("paladin") || clean.contains("crusader") || clean.contains("guard") || clean.contains("soldier") {
            featureStyleRaw = "visor"
            role = "Armored Vanguard"
        } else if clean.contains("cyber") || clean.contains("robot") || clean.contains("android") || clean.contains("synth") || clean.contains("mech") || clean.contains("cyborg") {
            featureStyleRaw = "cybernetic"
            role = "Cybernetic Agent"
        } else if clean.contains("ninja") || clean.contains("assassin") || clean.contains("shadow") || clean.contains("stealth") || clean.contains("mask") || clean.contains("samurai") || clean.contains("shinobi") {
            featureStyleRaw = "ninjaMask"
            role = "Shadow Shinobi"
        } else if clean.contains("space") || clean.contains("astronaut") || clean.contains("cosmonaut") || clean.contains("cosmic") || clean.contains("nasa") {
            featureStyleRaw = "spaceVisor"
            role = "Deep Space Explorer"
        } else if clean.contains("wizard") || clean.contains("mage") || clean.contains("sorcerer") || clean.contains("witch") || clean.contains("spell") || clean.contains("warlock") {
            featureStyleRaw = "wizardPoint"
            role = "Arcane Spellsinger"
        } else if clean.contains("horn") || clean.contains("viking") || clean.contains("demon") || clean.contains("beast") || clean.contains("barbarian") {
            featureStyleRaw = "horns"
            role = "Nordic Champion"
        } else if clean.contains("hood") || clean.contains("arctic") || clean.contains("snow") || clean.contains("fur") || clean.contains("ranger") {
            featureStyleRaw = "furHood"
            role = "Wilderness Ranger"
        } else if clean.contains("miner") || clean.contains("spelunk") || clean.contains("lamp") || clean.contains("firefighter") || clean.contains("builder") {
            featureStyleRaw = "minerLamp"
            role = "Deep Spelunker"
        }

        // 2. Color Palette Synthesizer
        var skinHex = "#D8A882" // warm tan
        var hairHex = "#4A3222" // deep brown
        var torsoHex = "#2E5894" // royal blue
        var legsHex = "#1F2D3D"  // dark navy
        var accentHex = "#F4C430" // gold
        var eyeHex = "#3273DC"   // bright blue

        // Detect Special Character Archetypes
        if clean.contains("creeper") {
            skinHex = "#4BAE4F"; hairHex = "#2E7D32"; torsoHex = "#388E3C"; legsHex = "#1B5E20"; accentHex = "#000000"; eyeHex = "#000000"
            role = "Overworld Creeper"
        } else if clean.contains("ender") || clean.contains("void") {
            skinHex = "#121214"; hairHex = "#0D0D10"; torsoHex = "#1A1A1E"; legsHex = "#0E0E12"; accentHex = "#CC00FF"; eyeHex = "#CC00FF"
            role = "Ender Voidwalker"
        } else if clean.contains("villager") || clean.contains("farmer") {
            skinHex = "#C68A5E"; hairHex = "#4A2E1B"; torsoHex = "#5E3B20"; legsHex = "#3E2512"; accentHex = "#2ECC71"; eyeHex = "#2ECC71"
        } else if clean.contains("king") || clean.contains("queen") || clean.contains("royal") {
            skinHex = "#F5D6C6"; hairHex = "#E4BE67"; torsoHex = "#7A1C1C"; legsHex = "#1F232A"; accentHex = "#FFD700"
        } else if clean.contains("pirate") || clean.contains("captain") {
            skinHex = "#D8A882"; hairHex = "#1A1A1A"; torsoHex = "#8B1E1E"; legsHex = "#1C1C1C"; accentHex = "#D4AF37"
        } else if clean.contains("doctor") || clean.contains("medic") || clean.contains("nurse") {
            torsoHex = "#FFFFFF"; legsHex = "#34495E"; accentHex = "#E74C3C"
            role = "Field Medic"
        } else if clean.contains("police") || clean.contains("cop") {
            torsoHex = "#1A365D"; legsHex = "#0F172A"; accentHex = "#F59E0B"
            role = "Law Enforcement"
        } else if clean.contains("firefighter") {
            torsoHex = "#D97706"; legsHex = "#1E293B"; accentHex = "#FEF08A"
            role = "Rescue Firefighter"
        }

        // Detect skin tone
        if clean.contains("pale") || clean.contains("white skin") || clean.contains("fair") {
            skinHex = "#F5D6C6"
        } else if clean.contains("tan") || clean.contains("bronze") {
            skinHex = "#C68A5E"
        } else if clean.contains("dark skin") || clean.contains("brown skin") {
            skinHex = "#663B23"
        } else if clean.contains("zombie") || clean.contains("undead") || clean.contains("ghoul") {
            skinHex = "#5E8752"
        } else if clean.contains("robot") || clean.contains("metal") || clean.contains("silver") || clean.contains("steel") {
            skinHex = "#A8B2BD"
        } else if clean.contains("alien") || clean.contains("blue skin") {
            skinHex = "#5898D4"
        } else if clean.contains("demon") || clean.contains("red skin") {
            skinHex = "#9E3838"
        }

        // Detect hair color
        if clean.contains("black hair") || clean.contains("dark hair") {
            hairHex = "#1A1A1A"
        } else if clean.contains("blonde") || clean.contains("gold hair") || clean.contains("yellow hair") {
            hairHex = "#E4BE67"
        } else if clean.contains("red hair") || clean.contains("ginger") {
            hairHex = "#A83E20"
        } else if clean.contains("silver hair") || clean.contains("white hair") || clean.contains("gray hair") {
            hairHex = "#E0E4E8"
        } else if clean.contains("blue hair") || clean.contains("cyan hair") {
            hairHex = "#2080D0"
        } else if clean.contains("pink hair") || clean.contains("purple hair") {
            hairHex = "#9C3AA8"
        }

        // Detect torso / outfit colors
        if clean.contains("red") || clean.contains("crimson") || clean.contains("scarlet") {
            torsoHex = "#A32020"; accentHex = "#FFD700"
        } else if clean.contains("green") || clean.contains("emerald") || clean.contains("forest") {
            torsoHex = "#286B38"; accentHex = "#D4AF37"
        } else if clean.contains("purple") || clean.contains("violet") || clean.contains("amethyst") {
            torsoHex = "#5B2A86"; accentHex = "#00FFFF"
        } else if clean.contains("gold") || clean.contains("yellow") {
            torsoHex = "#D4AF37"; accentHex = "#1E2A38"
        } else if clean.contains("black") || clean.contains("stealth") || clean.contains("shadow") || clean.contains("dark") {
            torsoHex = "#212124"; legsHex = "#151518"; accentHex = "#E02E2E"
        } else if clean.contains("white") || clean.contains("silver") || clean.contains("arctic") {
            torsoHex = "#E8ECEF"; legsHex = "#52616D"; accentHex = "#3298DC"
        } else if clean.contains("neon") || clean.contains("cyan") {
            torsoHex = "#101D28"; legsHex = "#0A131C"; accentHex = "#00F0FF"
        } else if clean.contains("orange") || clean.contains("amber") {
            torsoHex = "#C85A17"; accentHex = "#303030"
        }

        // Detect eye colors
        if clean.contains("red eye") || clean.contains("crimson eye") {
            eyeHex = "#E02020"
        } else if clean.contains("green eye") || clean.contains("emerald eye") {
            eyeHex = "#25C050"
        } else if clean.contains("gold eye") || clean.contains("amber eye") || clean.contains("yellow eye") {
            eyeHex = "#FFC814"
        } else if clean.contains("purple eye") || clean.contains("violet eye") {
            eyeHex = "#B040FF"
        } else if clean.contains("cyan eye") || clean.contains("glowing eye") {
            eyeHex = "#00FFFF"
        }

        // 3. Generate Authentic 64x64 Minecraft Texture Bitmap PNG
        let skinImage = generateSkinTextureBitmap(
            skinTone: UIColor(hex: skinHex) ?? .white,
            hairColor: UIColor(hex: hairHex) ?? .brown,
            torsoColor: UIColor(hex: torsoHex) ?? .blue,
            legsColor: UIColor(hex: legsHex) ?? .darkGray,
            accentColor: UIColor(hex: accentHex) ?? .yellow,
            eyeColor: UIColor(hex: eyeHex) ?? .cyan,
            featureStyle: featureStyleRaw
        )

        let pngData = skinImage.pngData() ?? Data()
        let name = synthesizeSkinTitle(from: prompt, role: role)

        return CustomSkin(
            name: name,
            promptDescription: prompt,
            roleSubtitle: role,
            headColorHex: skinHex,
            torsoColorHex: torsoHex,
            legsColorHex: legsHex,
            accentColorHex: accentHex,
            eyeColorHex: eyeHex,
            hairColorHex: hairHex,
            featureStyleRaw: featureStyleRaw,
            pngData: pngData
        )
    }

    private func synthesizeSkinTitle(from prompt: String, role: String) -> String {
        let words = prompt.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 }
            .map { $0.capitalized }

        if let firstInteresting = words.first(where: { !["with", "and", "the", "for", "that", "skin"].contains($0.lowercased()) }) {
            return "\(firstInteresting) \(role.components(separatedBy: " ").last ?? "Hero")"
        }
        return role
    }

    // MARK: - 64x64 RGBA Texture Generator

    private func generateSkinTextureBitmap(
        skinTone: UIColor,
        hairColor: UIColor,
        torsoColor: UIColor,
        legsColor: UIColor,
        accentColor: UIColor,
        eyeColor: UIColor,
        featureStyle: String
    ) -> UIImage {
        let size = CGSize(width: 64, height: 64)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            cg.interpolationQuality = .none

            // Helper to fill rectangle with optional subtle pixel noise
            func fill(_ rect: CGRect, color: UIColor, noiseVar: CGFloat = 0.05) {
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                color.getRed(&r, green: &g, blue: &b, alpha: &a)

                for px in Int(rect.minX)..<Int(rect.maxX) {
                    for py in Int(rect.minY)..<Int(rect.maxY) {
                        let hash = Double(abs((px &* 31) ^ (py &* 73))) / 100.0
                        let offset = CGFloat(sin(hash)) * noiseVar
                        let pr = max(0.0, min(1.0, r + offset))
                        let pg = max(0.0, min(1.0, g + offset))
                        let pb = max(0.0, min(1.0, b + offset))
                        cg.setFillColor(red: pr, green: pg, blue: pb, alpha: a)
                        cg.fill(CGRect(x: px, y: py, width: 1, height: 1))
                    }
                }
            }

            // --- 1. HEAD (64x64 layout) ---
            // Top: (8, 0, 8, 8)
            fill(CGRect(x: 8, y: 0, width: 8, height: 8), color: hairColor)
            // Bottom: (16, 0, 8, 8)
            fill(CGRect(x: 16, y: 0, width: 8, height: 8), color: skinTone)
            // Right: (0, 8, 8, 8)
            fill(CGRect(x: 0, y: 8, width: 8, height: 8), color: hairColor)
            // Left: (16, 8, 8, 8)
            fill(CGRect(x: 16, y: 8, width: 8, height: 8), color: hairColor)
            // Back: (24, 8, 8, 8)
            fill(CGRect(x: 24, y: 8, width: 8, height: 8), color: hairColor)

            // Front face: (8, 8, 8, 8)
            fill(CGRect(x: 8, y: 8, width: 8, height: 8), color: skinTone)
            // Hair fringe on forehead
            fill(CGRect(x: 8, y: 8, width: 8, height: 2), color: hairColor)
            fill(CGRect(x: 8, y: 10, width: 2, height: 1), color: hairColor)
            fill(CGRect(x: 14, y: 10, width: 2, height: 1), color: hairColor)

            // Eyes: at y = 12
            // Left eye: (9, 12) & (10, 12)
            fill(CGRect(x: 9, y: 12, width: 1, height: 1), color: .white, noiseVar: 0)
            fill(CGRect(x: 10, y: 12, width: 1, height: 1), color: eyeColor, noiseVar: 0)
            // Right eye: (13, 12) & (14, 12)
            fill(CGRect(x: 13, y: 12, width: 1, height: 1), color: eyeColor, noiseVar: 0)
            fill(CGRect(x: 14, y: 12, width: 1, height: 1), color: .white, noiseVar: 0)

            // Mouth: at (11, 14, 2, 1)
            var mouthR: CGFloat = 0, mouthG: CGFloat = 0, mouthB: CGFloat = 0, mouthA: CGFloat = 0
            skinTone.getRed(&mouthR, green: &mouthG, blue: &mouthB, alpha: &mouthA)
            let mouthColor = UIColor(red: max(0, mouthR - 0.20), green: max(0, mouthG - 0.15), blue: max(0, mouthB - 0.15), alpha: 1.0)
            fill(CGRect(x: 11, y: 14, width: 2, height: 1), color: mouthColor, noiseVar: 0)

            // Feature Style Overlays on Face
            if featureStyle == "catEars" {
                // Two cute cat ears on the hairline corners
                fill(CGRect(x: 8, y: 6, width: 2, height: 2), color: hairColor)
                fill(CGRect(x: 9, y: 7, width: 1, height: 1), color: accentColor)
                fill(CGRect(x: 14, y: 6, width: 2, height: 2), color: hairColor)
                fill(CGRect(x: 14, y: 7, width: 1, height: 1), color: accentColor)
            } else if featureStyle == "sunglasses" {
                // Dark sunglasses across eyes with reflective white shine
                fill(CGRect(x: 8, y: 11, width: 8, height: 2), color: .black)
                fill(CGRect(x: 9, y: 11, width: 1, height: 1), color: .white)
                fill(CGRect(x: 13, y: 11, width: 1, height: 1), color: .white)
            } else if featureStyle == "superheroMask" {
                // Superhero mask around eyes
                fill(CGRect(x: 8, y: 11, width: 8, height: 2), color: accentColor)
                fill(CGRect(x: 10, y: 12, width: 1, height: 1), color: eyeColor)
                fill(CGRect(x: 13, y: 12, width: 1, height: 1), color: eyeColor)
            } else if featureStyle == "visor" || featureStyle == "spaceVisor" {
                fill(CGRect(x: 9, y: 11, width: 6, height: 2), color: accentColor)
                fill(CGRect(x: 10, y: 12, width: 4, height: 1), color: .white)
            } else if featureStyle == "cybernetic" {
                fill(CGRect(x: 8, y: 11, width: 3, height: 3), color: accentColor)
                fill(CGRect(x: 9, y: 12, width: 1, height: 1), color: .white)
            } else if featureStyle == "ninjaMask" {
                fill(CGRect(x: 8, y: 13, width: 8, height: 3), color: torsoColor)
                fill(CGRect(x: 8, y: 9, width: 8, height: 2), color: accentColor)
            } else if featureStyle == "minerLamp" {
                fill(CGRect(x: 11, y: 8, width: 2, height: 2), color: .yellow)
                fill(CGRect(x: 8, y: 9, width: 8, height: 1), color: .darkGray)
            } else if featureStyle == "crown" {
                // Golden crown with ruby & sapphire jewels
                fill(CGRect(x: 8, y: 7, width: 8, height: 2), color: .yellow)
                fill(CGRect(x: 8, y: 6, width: 2, height: 1), color: .yellow)
                fill(CGRect(x: 11, y: 6, width: 2, height: 1), color: .yellow)
                fill(CGRect(x: 14, y: 6, width: 2, height: 1), color: .yellow)
                fill(CGRect(x: 9, y: 7, width: 1, height: 1), color: .red)
                fill(CGRect(x: 12, y: 7, width: 1, height: 1), color: .blue)
                fill(CGRect(x: 14, y: 7, width: 1, height: 1), color: .green)
            } else if featureStyle == "pirateEyepatch" {
                // Diagonal black strap and eyepatch over right eye
                fill(CGRect(x: 8, y: 10, width: 8, height: 1), color: .black)
                fill(CGRect(x: 12, y: 11, width: 3, height: 3), color: .black)
            } else if featureStyle == "headphones" {
                // Gaming headphones with colored ear cups on sides and band across top
                fill(CGRect(x: 7, y: 6, width: 10, height: 2), color: .darkGray)
                fill(CGRect(x: 7, y: 11, width: 2, height: 3), color: accentColor)
                fill(CGRect(x: 15, y: 11, width: 2, height: 3), color: accentColor)
            } else if featureStyle == "villagerRobe" {
                // Prominent unibrow and emerald robe pendant
                fill(CGRect(x: 9, y: 11, width: 6, height: 1), color: hairColor)
                fill(CGRect(x: 11, y: 12, width: 2, height: 2), color: skinTone)
                fill(CGRect(x: 22, y: 20, width: 4, height: 4), color: accentColor)
            }

            // --- 2. TORSO (64x64 layout) ---
            // Front: (20, 20, 8, 12)
            fill(CGRect(x: 20, y: 20, width: 8, height: 12), color: torsoColor)
            // Collar: (23, 20, 2, 2)
            fill(CGRect(x: 23, y: 20, width: 2, height: 2), color: skinTone)
            // Accent stripe / zipper / emblem
            fill(CGRect(x: 23, y: 22, width: 2, height: 7), color: accentColor)
            // Belt: at y = 30
            fill(CGRect(x: 20, y: 30, width: 8, height: 2), color: .black)
            fill(CGRect(x: 23, y: 30, width: 2, height: 2), color: accentColor)

            // Right torso: (16, 20, 4, 12)
            fill(CGRect(x: 16, y: 20, width: 4, height: 12), color: torsoColor)
            fill(CGRect(x: 16, y: 30, width: 4, height: 2), color: .black)
            // Back torso: (32, 20, 8, 12)
            fill(CGRect(x: 32, y: 20, width: 8, height: 12), color: torsoColor)
            fill(CGRect(x: 32, y: 30, width: 8, height: 2), color: .black)
            // Left torso: (28, 20, 4, 12)
            fill(CGRect(x: 28, y: 20, width: 4, height: 12), color: torsoColor)
            fill(CGRect(x: 28, y: 30, width: 4, height: 2), color: .black)
            // Top torso: (20, 16, 8, 4)
            fill(CGRect(x: 20, y: 16, width: 8, height: 4), color: torsoColor)
            // Bottom torso: (28, 16, 8, 4)
            fill(CGRect(x: 28, y: 16, width: 8, height: 4), color: torsoColor)

            // --- 3. RIGHT ARM ---
            // Front: (44, 20, 4, 12)
            fill(CGRect(x: 44, y: 20, width: 4, height: 9), color: torsoColor)
            fill(CGRect(x: 44, y: 29, width: 4, height: 3), color: skinTone) // hand
            // Right: (40, 20, 4, 12)
            fill(CGRect(x: 40, y: 20, width: 4, height: 9), color: torsoColor)
            fill(CGRect(x: 40, y: 29, width: 4, height: 3), color: skinTone)
            // Back: (52, 20, 4, 12)
            fill(CGRect(x: 52, y: 20, width: 4, height: 9), color: torsoColor)
            fill(CGRect(x: 52, y: 29, width: 4, height: 3), color: skinTone)
            // Left: (48, 20, 4, 12)
            fill(CGRect(x: 48, y: 20, width: 4, height: 9), color: torsoColor)
            fill(CGRect(x: 48, y: 29, width: 4, height: 3), color: skinTone)
            // Shoulder top: (44, 16, 4, 4)
            fill(CGRect(x: 44, y: 16, width: 4, height: 4), color: torsoColor)
            // Fist bottom: (48, 16, 4, 4)
            fill(CGRect(x: 48, y: 16, width: 4, height: 4), color: skinTone)

            // --- 4. LEFT ARM ---
            // Front: (36, 52, 4, 12)
            fill(CGRect(x: 36, y: 52, width: 4, height: 9), color: torsoColor)
            fill(CGRect(x: 36, y: 61, width: 4, height: 3), color: skinTone)
            // Right: (32, 52, 4, 12)
            fill(CGRect(x: 32, y: 52, width: 4, height: 9), color: torsoColor)
            fill(CGRect(x: 32, y: 61, width: 4, height: 3), color: skinTone)
            // Back: (44, 52, 4, 12)
            fill(CGRect(x: 44, y: 52, width: 4, height: 9), color: torsoColor)
            fill(CGRect(x: 44, y: 61, width: 4, height: 3), color: skinTone)
            // Left: (40, 52, 4, 12)
            fill(CGRect(x: 40, y: 52, width: 4, height: 9), color: torsoColor)
            fill(CGRect(x: 40, y: 61, width: 4, height: 3), color: skinTone)
            // Shoulder top: (36, 48, 4, 4)
            fill(CGRect(x: 36, y: 48, width: 4, height: 4), color: torsoColor)
            // Fist bottom: (40, 48, 4, 4)
            fill(CGRect(x: 40, y: 48, width: 4, height: 4), color: skinTone)

            // --- 5. RIGHT LEG ---
            // Front: (4, 20, 4, 12)
            fill(CGRect(x: 4, y: 20, width: 4, height: 8), color: legsColor)
            fill(CGRect(x: 4, y: 28, width: 4, height: 4), color: .black) // boots
            // Right: (0, 20, 4, 12)
            fill(CGRect(x: 0, y: 20, width: 4, height: 8), color: legsColor)
            fill(CGRect(x: 0, y: 28, width: 4, height: 4), color: .black)
            // Back: (12, 20, 4, 12)
            fill(CGRect(x: 12, y: 20, width: 4, height: 8), color: legsColor)
            fill(CGRect(x: 12, y: 28, width: 4, height: 4), color: .black)
            // Left: (8, 20, 4, 12)
            fill(CGRect(x: 8, y: 20, width: 4, height: 8), color: legsColor)
            fill(CGRect(x: 8, y: 28, width: 4, height: 4), color: .black)
            // Top: (4, 16, 4, 4)
            fill(CGRect(x: 4, y: 16, width: 4, height: 4), color: legsColor)
            // Sole bottom: (8, 16, 4, 4)
            fill(CGRect(x: 8, y: 16, width: 4, height: 4), color: .black)

            // --- 6. LEFT LEG ---
            // Front: (20, 52, 4, 12)
            fill(CGRect(x: 20, y: 52, width: 4, height: 8), color: legsColor)
            fill(CGRect(x: 20, y: 60, width: 4, height: 4), color: .black)
            // Right: (16, 52, 4, 12)
            fill(CGRect(x: 16, y: 52, width: 4, height: 8), color: legsColor)
            fill(CGRect(x: 16, y: 60, width: 4, height: 4), color: .black)
            // Back: (28, 52, 4, 12)
            fill(CGRect(x: 28, y: 52, width: 4, height: 8), color: legsColor)
            fill(CGRect(x: 28, y: 60, width: 4, height: 4), color: .black)
            // Left: (24, 52, 4, 12)
            fill(CGRect(x: 24, y: 52, width: 4, height: 8), color: legsColor)
            fill(CGRect(x: 24, y: 60, width: 4, height: 4), color: .black)
            // Top: (20, 48, 4, 4)
            fill(CGRect(x: 20, y: 48, width: 4, height: 4), color: legsColor)
            // Sole bottom: (24, 48, 4, 4)
            fill(CGRect(x: 24, y: 48, width: 4, height: 4), color: .black)
        }
    }
}

// MARK: - AI Studio UI Sheet

struct AIStudioSheet: View {
    @ObservedObject var world: VoxelWorld
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: StudioTab = .worlds
    @State private var worldPrompt: String = ""
    @State private var skinPrompt: String = ""
    @State private var generatedWorld: CustomWorldType? = nil
    @State private var generatedSkin: CustomSkin? = nil
    @State private var isSynthesizing: Bool = false
    @State private var studioToast: String? = nil

    enum StudioTab: String, CaseIterable, Identifiable {
        case worlds = "World Generator"
        case skins = "Skin Generator"
        var id: String { rawValue }
        var icon: String {
            switch self {
            case .worlds: return "globe.americas.fill"
            case .skins: return "person.crop.artframe"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Studio Mode", selection: $selectedTab) {
                    ForEach(StudioTab.allCases) { tab in
                        Label(tab.rawValue, systemImage: tab.icon).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

                if selectedTab == .worlds {
                    worldGeneratorView
                } else {
                    skinGeneratorView
                }
            }
            .background(Color(red: 0.08, green: 0.09, blue: 0.12).ignoresSafeArea())
            .navigationTitle("✨ AI Game Studio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .overlay(alignment: .bottom) {
                if let toast = studioToast {
                    Text(toast)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(20)
                        .overlay(Capsule().stroke(Color.purple.opacity(0.6), lineWidth: 1))
                        .padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }

    // MARK: - Worlds View

    private var worldGeneratorView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header Banner
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 44, height: 44)
                        Image(systemName: "sparkles")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("On-Device AI World Creator")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        Text("Describe any biome, atmosphere or planet. Zero lag, 100% offline.")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color.white.opacity(0.06))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.purple.opacity(0.3), lineWidth: 1))

                // Prompt Input Box
                VStack(alignment: .leading, spacing: 8) {
                    Text("DESCRIBE YOUR WORLD GENERATION TYPE")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(.purple)

                    HStack {
                        TextField("e.g. Floating islands with waterfalls and purple twilight...", text: $worldPrompt)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.white)

                        if !worldPrompt.isEmpty {
                            Button { worldPrompt = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.15), lineWidth: 1))

                    // Surprise Me Inspiration Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Button {
                                if let sample = LightweightGameAI.sampleWorldPrompts.randomElement() {
                                    worldPrompt = sample
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "dice.fill")
                                    Text("Surprise Me")
                                }
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.purple.opacity(0.25))
                                .foregroundColor(.purple)
                                .cornerRadius(16)
                            }

                            ForEach(LightweightGameAI.sampleWorldPrompts.prefix(4), id: \.self) { sample in
                                Button {
                                    worldPrompt = sample
                                } label: {
                                    Text(sample.prefix(32) + "...")
                                        .font(.system(size: 10, design: .monospaced))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.08))
                                        .foregroundColor(.white.opacity(0.85))
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                    .padding(.top, 2)

                    // Synthesize Button
                    Button {
                        synthesizeWorldAction()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: isSynthesizing ? "hourglass" : "wand.and.stars")
                            Text(isSynthesizing ? "Synthesizing AI World..." : "Synthesize World Type")
                                .font(.system(size: 13, weight: .black, design: .monospaced))
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(8)
                    }
                    .disabled(worldPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.top, 4)
                }
                .padding(14)
                .background(Color.white.opacity(0.04))
                .cornerRadius(12)

                // Synthesized Preview Card
                if let worldType = generatedWorld {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.purple.opacity(0.25))
                                    .frame(width: 36, height: 36)
                                Image(systemName: worldType.iconName)
                                    .foregroundColor(.purple)
                                    .font(.system(size: 16, weight: .bold))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(worldType.name)
                                    .font(.system(size: 15, weight: .black, design: .monospaced))
                                    .foregroundColor(.white)
                                Text("Archetype: \(worldType.baseWorldType.displayName)")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.yellow)
                            }
                            Spacer()
                            Text("SYNTHESIZED")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(4)
                        }

                        Text(worldType.summary)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.85))

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

                        // Block Preview Badges
                        HStack(spacing: 8) {
                            blockBadge(title: "Surface", block: worldType.surfaceBlock)
                            blockBadge(title: "Sub-surface", block: worldType.subsurfaceBlock)
                            blockBadge(title: "Deep Crust", block: worldType.deepBlock)
                        }

                        // Sky & Fog Preview Pill
                        HStack(spacing: 10) {
                            HStack(spacing: 6) {
                                Circle().fill(worldType.skyColor).frame(width: 14, height: 14)
                                Text("Sky Color")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            HStack(spacing: 6) {
                                Circle().fill(worldType.fogColor).frame(width: 14, height: 14)
                                Text("Atmospheric Fog")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(6)

                        // Action Buttons
                        HStack(spacing: 10) {
                            Button {
                                world.saveCustomWorldType(worldType)
                                showToast("Saved to World Types!")
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.down.fill")
                                    Text("Save World Type")
                                }
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.12))
                                .cornerRadius(8)
                            }

                            Button {
                                world.saveCustomWorldType(worldType)
                                world.regenerateWithCustomWorld(worldType)
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Play World Now")
                                }
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green.opacity(0.4), lineWidth: 1))
                }

                // Saved Custom Worlds List
                if !world.customWorldTypes.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SAVED AI WORLD GENERATION TYPES (\(world.customWorldTypes.count))")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))

                        ForEach(world.customWorldTypes) { custom in
                            HStack(spacing: 12) {
                                Image(systemName: custom.iconName)
                                    .foregroundColor(.cyan)
                                    .font(.system(size: 18))
                                    .frame(width: 28)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(custom.name)
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                    Text("\(custom.baseWorldType.displayName) • \(custom.surfaceBlock.fullName)")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Button {
                                    world.regenerateWithCustomWorld(custom)
                                    dismiss()
                                } label: {
                                    Text("PLAY")
                                        .font(.system(size: 10, weight: .black, design: .monospaced))
                                        .foregroundColor(.green)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.green.opacity(0.15))
                                        .cornerRadius(6)
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
                            .padding(10)
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(8)
                        }
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.02))
                    .cornerRadius(12)
                }
            }
            .padding(16)
        }
    }

    private func blockBadge(title: String, block: BlockType) -> some View {
        VStack(spacing: 3) {
            Text(title.uppercased())
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
            Text(block.fullName)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
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

    // MARK: - Skins View

    private var skinGeneratorView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header Banner
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.cyan, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 44, height: 44)
                        Image(systemName: "person.crop.artframe")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("On-Device AI Skin Synthesizer")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        Text("Generates authentic 64x64 pixel character skins from your prompts.")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color.white.opacity(0.06))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cyan.opacity(0.3), lineWidth: 1))

                // Prompt Input Box
                VStack(alignment: .leading, spacing: 8) {
                    Text("DESCRIBE YOUR CHARACTER SKIN")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(.cyan)

                    HStack {
                        TextField("e.g. Cyberpunk ninja with glowing red eyes and dark hood...", text: $skinPrompt)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.white)

                        if !skinPrompt.isEmpty {
                            Button { skinPrompt = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.15), lineWidth: 1))

                    // Surprise Me Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Button {
                                if let sample = LightweightGameAI.sampleSkinPrompts.randomElement() {
                                    skinPrompt = sample
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "dice.fill")
                                    Text("Surprise Me")
                                }
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.cyan.opacity(0.25))
                                .foregroundColor(.cyan)
                                .cornerRadius(16)
                            }

                            ForEach(LightweightGameAI.sampleSkinPrompts.prefix(4), id: \.self) { sample in
                                Button {
                                    skinPrompt = sample
                                } label: {
                                    Text(sample.prefix(32) + "...")
                                        .font(.system(size: 10, design: .monospaced))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.08))
                                        .foregroundColor(.white.opacity(0.85))
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                    .padding(.top, 2)

                    // Synthesize Skin Button
                    Button {
                        synthesizeSkinAction()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: isSynthesizing ? "hourglass" : "sparkles")
                            Text(isSynthesizing ? "Generating 64x64 Texture..." : "Generate AI Skin")
                                .font(.system(size: 13, weight: .black, design: .monospaced))
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .background(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(8)
                    }
                    .disabled(skinPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.top, 4)
                }
                .padding(14)
                .background(Color.white.opacity(0.04))
                .cornerRadius(12)

                // Synthesized Skin Preview Card
                if let skin = generatedSkin {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 14) {
                            // Front avatar render
                            CharacterAvatarPreview(customSkin: skin, size: 52)
                                .padding(8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(skin.name)
                                    .font(.system(size: 15, weight: .black, design: .monospaced))
                                    .foregroundColor(.white)
                                Text(skin.roleSubtitle)
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.cyan)
                                Text("Feature: \(skin.featureStyleRaw.capitalized)")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.yellow)
                            }
                            Spacer()
                            Text("SYNTHESIZED")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.cyan.opacity(0.2))
                                .foregroundColor(.cyan)
                                .cornerRadius(4)
                        }

                        // Color Palette Swatches
                        HStack(spacing: 8) {
                            paletteDot(title: "Skin", color: Color(skin.headColor))
                            paletteDot(title: "Torso", color: Color(skin.torsoColor))
                            paletteDot(title: "Legs", color: Color(skin.legsColor))
                            paletteDot(title: "Eyes", color: Color(skin.eyeColor))
                            paletteDot(title: "Accent", color: Color(skin.accentColor))
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(8)

                        // Action Buttons
                        HStack(spacing: 10) {
                            Button {
                                world.saveCustomSkin(skin)
                                showToast("Saved to Character Skins!")
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.down.fill")
                                    Text("Save Skin")
                                }
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.12))
                                .cornerRadius(8)
                            }

                            Button {
                                world.saveCustomSkin(skin)
                                world.equipCustomSkin(skin)
                                showToast("Equipped \(skin.name)!")
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Equip Now")
                                }
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.cyan)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cyan.opacity(0.4), lineWidth: 1))
                }

                // Saved Custom Skins Grid
                if !world.customSkins.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SAVED AI CHARACTER SKINS (\(world.customSkins.count))")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 10)], spacing: 10) {
                            ForEach(world.customSkins) { custom in
                                let isEquipped = (world.activeCustomSkin?.id == custom.id)
                                VStack(spacing: 8) {
                                    CharacterAvatarPreview(customSkin: custom, size: 42)
                                        .frame(height: 58)

                                    VStack(spacing: 2) {
                                        Text(custom.name)
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                        Text(custom.roleSubtitle)
                                            .font(.system(size: 9, design: .monospaced))
                                            .foregroundColor(.cyan)
                                            .lineLimit(1)
                                    }

                                    HStack(spacing: 6) {
                                        Button {
                                            world.equipCustomSkin(custom)
                                            showToast("Equipped \(custom.name)")
                                        } label: {
                                            Text(isEquipped ? "EQUIPPED" : "EQUIP")
                                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                                .foregroundColor(isEquipped ? .green : .white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(isEquipped ? Color.green.opacity(0.2) : Color.white.opacity(0.1))
                                                .cornerRadius(5)
                                        }

                                        Button {
                                            world.deleteCustomSkin(id: custom.id)
                                            showToast("Deleted \(custom.name)")
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.system(size: 11))
                                                .foregroundColor(.red.opacity(0.7))
                                                .padding(4)
                                        }
                                    }
                                }
                                .padding(10)
                                .background(Color.white.opacity(0.04))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(isEquipped ? Color.green.opacity(0.6) : Color.clear, lineWidth: 1.5)
                                )
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.02))
                    .cornerRadius(12)
                }
            }
            .padding(16)
        }
    }

    private func paletteDot(title: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Circle().fill(color).frame(width: 16, height: 16)
                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
            Text(title)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }

    private func synthesizeSkinAction() {
        isSynthesizing = true
        let synthesized = LightweightGameAI.shared.synthesizeSkin(prompt: skinPrompt)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.generatedSkin = synthesized
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
