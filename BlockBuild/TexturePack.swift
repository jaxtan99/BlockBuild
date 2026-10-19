import SwiftUI
import SceneKit
import UIKit

// MARK: - Selectable Texture Packs

enum TexturePack: String, CaseIterable, Identifiable, Codable {
    case classic = "Classic"
    case medieval = "Medieval RPG"
    case cyber = "Cyber Neon"
    case pastel = "Cozy Pastel"
    case volcanic = "Dark Nether"
    case winter = "Winter Frost"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic: return "Classic Voxel"
        case .medieval: return "Medieval RPG"
        case .cyber: return "Cyber Neon"
        case .pastel: return "Cozy Pastel"
        case .volcanic: return "Dark Nether"
        case .winter: return "Winter Frost"
        }
    }

    var subtitle: String {
        switch self {
        case .classic: return "Original nostalgic 16-bit voxel look"
        case .medieval: return "Chiseled castle stone, aged dark oak & slate shingles"
        case .cyber: return "Carbon alloys, glowing cyan circuits & holo-shields"
        case .pastel: return "Soft, vibrant, candy-coated blocks & clean tones"
        case .volcanic: return "Obsidian basalt, crimson ash & smoldering embers"
        case .winter: return "Snow-frosted stone, frozen timber & glacial icicles"
        }
    }

    var iconName: String {
        switch self {
        case .classic: return "cube.fill"
        case .medieval: return "shield.fill"
        case .cyber: return "bolt.fill"
        case .pastel: return "paintpalette.fill"
        case .volcanic: return "flame.fill"
        case .winter: return "snowflake"
        }
    }

    var themeColor: Color {
        switch self {
        case .classic: return .green
        case .medieval: return .orange
        case .cyber: return .cyan
        case .pastel: return .pink
        case .volcanic: return .red
        case .winter: return .blue
        }
    }
}

// MARK: - Texture Pack Pixel Art Painter

enum TexturePackPainter {
    static func pixelColor(
        for type: BlockType,
        face: BlockFace,
        pack: TexturePack,
        x: Int,
        y: Int,
        size: Int,
        hash: Int,
        cobblePattern: [[Int]]
    ) -> UIColor {
        switch pack {
        case .classic:
            return classicColor(for: type, face: face, x: x, y: y, size: size, hash: hash, cobblePattern: cobblePattern)
        case .medieval:
            return medievalColor(for: type, face: face, x: x, y: y, size: size, hash: hash, cobblePattern: cobblePattern)
        case .cyber:
            return cyberColor(for: type, face: face, x: x, y: y, size: size, hash: hash, cobblePattern: cobblePattern)
        case .pastel:
            return pastelColor(for: type, face: face, x: x, y: y, size: size, hash: hash, cobblePattern: cobblePattern)
        case .volcanic:
            return volcanicColor(for: type, face: face, x: x, y: y, size: size, hash: hash, cobblePattern: cobblePattern)
        case .winter:
            return winterColor(for: type, face: face, x: x, y: y, size: size, hash: hash, cobblePattern: cobblePattern)
        }
    }

    // MARK: 1. Classic (Original Hand-Crafted)
    private static func classicColor(
        for type: BlockType,
        face: BlockFace,
        x: Int,
        y: Int,
        size: Int,
        hash: Int,
        cobblePattern: [[Int]]
    ) -> UIColor {
        switch type {
        case .stone:
            let level = cobblePattern[y & 15][x & 15]
            switch level {
            case 0: return UIColor(red: 0.24, green: 0.24, blue: 0.24, alpha: 1.0)
            case 1: return UIColor(red: 0.42, green: 0.42, blue: 0.42, alpha: 1.0)
            case 2: return UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1.0)
            default: return UIColor(red: 0.74, green: 0.74, blue: 0.74, alpha: 1.0)
            }

        case .smoothStone:
            let streak = ((x + y * 3 + (hash & 3)) % 7)
            if streak == 0 {
                return UIColor(red: 0.44, green: 0.44, blue: 0.44, alpha: 1.0)
            } else if streak == 1 || streak == 2 {
                return UIColor(red: 0.54, green: 0.54, blue: 0.54, alpha: 1.0)
            } else if streak == 6 {
                return UIColor(red: 0.62, green: 0.62, blue: 0.62, alpha: 1.0)
            } else {
                return UIColor(red: 0.50, green: 0.50, blue: 0.50, alpha: 1.0)
            }

        case .sand:
            let grain = (hash + x * 5 + y * 3) & 7
            if grain == 0 {
                return UIColor(red: 0.80, green: 0.75, blue: 0.52, alpha: 1.0)
            } else if grain == 1 || grain == 2 {
                return UIColor(red: 0.92, green: 0.88, blue: 0.66, alpha: 1.0)
            } else if grain == 3 {
                return UIColor(red: 0.84, green: 0.79, blue: 0.56, alpha: 1.0)
            } else {
                return UIColor(red: 0.88, green: 0.84, blue: 0.61, alpha: 1.0)
            }

        case .glass:
            let isOuterBorder = (x == 0 || x == 15 || y == 0 || y == 15)
            let isInnerCorner = ((x == 1 || x == 14) && (y == 1 || y == 14))
            let isShine1 = (x + y == 5 && x >= 2 && x <= 4)
            let isShine2 = (x + y == 6 && x >= 2 && x <= 4)
            let isShine3 = (x + y == 22 && x >= 10 && x <= 12)
            if isOuterBorder {
                return UIColor(red: 0.86, green: 0.96, blue: 1.0, alpha: 0.95)
            } else if isInnerCorner || isShine1 || isShine2 || isShine3 {
                return UIColor(red: 0.92, green: 0.99, blue: 1.0, alpha: 0.90)
            } else {
                return UIColor(red: 0.75, green: 0.92, blue: 1.0, alpha: 0.10)
            }

        case .door:
            let isBorder = (x <= 1 || x >= 14 || y <= 1 || y >= 14)
            let isMidRail = (y == 7 || y == 8)
            let isCenterMullion = (x == 7 || x == 8)
            if (x == 12 || x == 13) && (y == 8 || y == 9) {
                return UIColor(red: 0.92, green: 0.78, blue: 0.25, alpha: 1.0)
            }
            if y >= 2 && y <= 6 && !isBorder && !isCenterMullion {
                return UIColor(red: 0.75, green: 0.92, blue: 1.0, alpha: 0.15)
            }
            if isBorder || isMidRail || (y <= 6 && isCenterMullion) {
                return UIColor(red: 0.48, green: 0.34, blue: 0.17, alpha: 1.0)
            }
            if (x == 2 || x == 13 || y == 9 || y == 13) {
                return UIColor(red: 0.56, green: 0.41, blue: 0.22, alpha: 1.0)
            }
            return UIColor(red: 0.68, green: 0.52, blue: 0.29, alpha: 1.0)

        case .roof, .slab, .roofCorner:
            let mortarY = (y % 4 == 0)
            let stagger = (y / 4) % 2 == 1
            let stoneX = (x + (stagger ? 4 : 0)) % 8 == 0
            if mortarY || stoneX {
                return UIColor(red: 0.22, green: 0.22, blue: 0.24, alpha: 1.0)
            }
            let level = cobblePattern[y & 15][x & 15]
            switch level {
            case 0: return UIColor(red: 0.32, green: 0.32, blue: 0.34, alpha: 1.0)
            case 1: return UIColor(red: 0.44, green: 0.44, blue: 0.46, alpha: 1.0)
            case 2: return UIColor(red: 0.58, green: 0.58, blue: 0.60, alpha: 1.0)
            default: return UIColor(red: 0.70, green: 0.70, blue: 0.72, alpha: 1.0)
            }

        case .leaves:
            let pattern = ((x * 3 + y * 5) ^ (hash >> 2)) & 7
            if pattern == 0 || pattern == 1 {
                return UIColor(red: 0.14, green: 0.42, blue: 0.10, alpha: 1.0)
            } else if pattern == 2 || pattern == 3 {
                return UIColor(red: 0.28, green: 0.72, blue: 0.20, alpha: 1.0)
            } else {
                return UIColor(red: 0.20, green: 0.58, blue: 0.15, alpha: 1.0)
            }

        case .woodLog:
            if face == .top {
                if x == 0 || x == 15 || y == 0 || y == 15 {
                    return UIColor(red: 0.32, green: 0.21, blue: 0.10, alpha: 1.0)
                }
                let dist = max(abs(x - 7), abs(y - 7))
                if dist % 2 == 0 {
                    return UIColor(red: 0.69, green: 0.55, blue: 0.34, alpha: 1.0)
                } else {
                    return UIColor(red: 0.60, green: 0.46, blue: 0.26, alpha: 1.0)
                }
            } else {
                let col = (x + (y / 4)) % 4
                let n = CGFloat((hash % 10) - 5) / 255.0
                if col == 0 {
                    return UIColor(red: 0.26 + n, green: 0.17 + n, blue: 0.08 + n, alpha: 1.0)
                } else if col == 2 {
                    return UIColor(red: 0.46 + n, green: 0.32 + n, blue: 0.17 + n, alpha: 1.0)
                } else {
                    return UIColor(red: 0.38 + n, green: 0.26 + n, blue: 0.13 + n, alpha: 1.0)
                }
            }

        case .woodPlanks:
            let rowInPlank = y % 4
            let plankIndex = y / 4
            let seamX = (plankIndex % 2 == 0) ? 7 : 14

            if rowInPlank == 3 || x == seamX {
                return UIColor(red: 0.45, green: 0.32, blue: 0.16, alpha: 1.0)
            }
            if rowInPlank == 0 {
                return UIColor(red: 0.76, green: 0.60, blue: 0.36, alpha: 1.0)
            }
            let grain = ((x + plankIndex * 5 + (hash & 3)) % 4 == 0)
            if grain {
                return UIColor(red: 0.62, green: 0.47, blue: 0.26, alpha: 1.0)
            }
            return UIColor(red: 0.70, green: 0.54, blue: 0.31, alpha: 1.0)

        case .water:
            let subtleWave = ((x + y * 2) % 8 == 0)
            if subtleWave {
                return UIColor(red: 0.20, green: 0.44, blue: 0.94, alpha: 0.78)
            } else {
                return UIColor(red: 0.16, green: 0.38, blue: 0.90, alpha: 0.78)
            }

        case .grass:
            let fringeDepth = 2 + ((x * 5 + 3) % 3)
            if face == .top || y < fringeDepth {
                let gPattern = (hash + x * 3 + y * 7) & 7
                if gPattern == 0 {
                    return UIColor(red: 0.26, green: 0.64, blue: 0.18, alpha: 1.0)
                } else if gPattern == 1 || gPattern == 2 {
                    return UIColor(red: 0.36, green: 0.78, blue: 0.25, alpha: 1.0)
                } else {
                    return UIColor(red: 0.31, green: 0.71, blue: 0.21, alpha: 1.0)
                }
            }
            return classicDirtPixel(x: x, y: y, hash: hash)

        case .dirt:
            return classicDirtPixel(x: x, y: y, hash: hash)
        }
    }

    private static func classicDirtPixel(x: Int, y: Int, hash: Int) -> UIColor {
        let dPattern = (hash + x * 7 + y * 5) & 7
        if dPattern == 0 {
            return UIColor(red: 0.40, green: 0.28, blue: 0.17, alpha: 1.0)
        } else if dPattern == 1 {
            return UIColor(red: 0.60, green: 0.43, blue: 0.28, alpha: 1.0)
        } else if dPattern == 2 {
            return UIColor(red: 0.52, green: 0.46, blue: 0.38, alpha: 1.0)
        } else {
            return UIColor(red: 0.51, green: 0.36, blue: 0.22, alpha: 1.0)
        }
    }

    // MARK: 2. Medieval Fantasy RPG
    private static func medievalColor(
        for type: BlockType,
        face: BlockFace,
        x: Int,
        y: Int,
        size: Int,
        hash: Int,
        cobblePattern: [[Int]]
    ) -> UIColor {
        switch type {
        case .stone:
            let level = cobblePattern[y & 15][x & 15]
            let moss = ((x * 7 + y * 13 + hash) & 15) == 0
            if moss {
                return UIColor(red: 0.24, green: 0.32, blue: 0.18, alpha: 1.0)
            }
            switch level {
            case 0: return UIColor(red: 0.16, green: 0.16, blue: 0.17, alpha: 1.0) // deep dark iron-stone mortar
            case 1: return UIColor(red: 0.32, green: 0.31, blue: 0.33, alpha: 1.0)
            case 2: return UIColor(red: 0.46, green: 0.45, blue: 0.46, alpha: 1.0)
            default: return UIColor(red: 0.58, green: 0.57, blue: 0.56, alpha: 1.0)
            }

        case .smoothStone: // Chiseled ashlar castle wall blocks
            let row = y % 4
            let isMortarY = (row == 0)
            let stagger = (y / 4) % 2 == 1
            let isMortarX = (x + (stagger ? 4 : 0)) % 8 == 0
            if isMortarY || isMortarX {
                return UIColor(red: 0.20, green: 0.20, blue: 0.22, alpha: 1.0)
            }
            let grain = ((x * 3 + y * 7 + (hash & 3)) % 5)
            if grain == 0 {
                return UIColor(red: 0.42, green: 0.41, blue: 0.42, alpha: 1.0)
            } else if grain == 1 {
                return UIColor(red: 0.54, green: 0.53, blue: 0.53, alpha: 1.0)
            } else {
                return UIColor(red: 0.48, green: 0.47, blue: 0.48, alpha: 1.0)
            }

        case .sand:
            let grain = (hash + x * 3 + y * 7) & 7
            if grain == 0 {
                return UIColor(red: 0.72, green: 0.62, blue: 0.42, alpha: 1.0)
            } else if grain == 1 {
                return UIColor(red: 0.86, green: 0.78, blue: 0.56, alpha: 1.0)
            } else {
                return UIColor(red: 0.78, green: 0.70, blue: 0.48, alpha: 1.0)
            }

        case .glass: // Leaded cathedral lattice window with dark iron lead came
            let isBorder = (x == 0 || x == 15 || y == 0 || y == 15)
            let isLattice = ((x + y) % 6 == 0 || (x - y + 16) % 6 == 0)
            if isBorder || isLattice {
                return UIColor(red: 0.18, green: 0.18, blue: 0.20, alpha: 0.95)
            } else {
                return UIColor(red: 0.78, green: 0.88, blue: 0.72, alpha: 0.20)
            }

        case .door: // Heavy dungeon/keep oak door with forged iron reinforcement straps
            let isBorder = (x <= 1 || x >= 14 || y <= 1 || y >= 14)
            let isIronStrap = (y == 4 || y == 5 || y == 11 || y == 12)
            let isRivet = isIronStrap && (x == 3 || x == 12)
            let isHandle = (x == 11 || x == 12) && (y == 8 || y == 9)
            if isRivet {
                return UIColor(red: 0.55, green: 0.55, blue: 0.58, alpha: 1.0)
            }
            if isIronStrap || isHandle {
                return UIColor(red: 0.20, green: 0.20, blue: 0.22, alpha: 1.0)
            }
            if isBorder {
                return UIColor(red: 0.32, green: 0.22, blue: 0.13, alpha: 1.0)
            }
            return UIColor(red: 0.45, green: 0.32, blue: 0.19, alpha: 1.0)

        case .roof, .slab, .roofCorner: // Dark slate roof shingles with chipped edges
            let row = y % 4
            let stagger = (y / 4) % 2 == 1
            let seam = (x + (stagger ? 4 : 0)) % 8 == 0
            if row == 3 || seam {
                return UIColor(red: 0.16, green: 0.18, blue: 0.20, alpha: 1.0)
            }
            let level = cobblePattern[y & 15][x & 15]
            switch level {
            case 0: return UIColor(red: 0.26, green: 0.28, blue: 0.32, alpha: 1.0)
            case 1: return UIColor(red: 0.34, green: 0.36, blue: 0.40, alpha: 1.0)
            default: return UIColor(red: 0.44, green: 0.46, blue: 0.50, alpha: 1.0)
            }

        case .leaves: // Deep ancient forest oak canopy
            let pattern = ((x * 5 + y * 7) ^ (hash >> 1)) & 7
            if pattern <= 1 {
                return UIColor(red: 0.11, green: 0.32, blue: 0.08, alpha: 1.0)
            } else if pattern <= 3 {
                return UIColor(red: 0.22, green: 0.54, blue: 0.16, alpha: 1.0)
            } else {
                return UIColor(red: 0.16, green: 0.42, blue: 0.12, alpha: 1.0)
            }

        case .woodLog: // Weathered dark ancient timber
            if face == .top {
                if x == 0 || x == 15 || y == 0 || y == 15 {
                    return UIColor(red: 0.22, green: 0.14, blue: 0.08, alpha: 1.0)
                }
                let dist = max(abs(x - 7), abs(y - 7))
                return (dist % 2 == 0) ? UIColor(red: 0.55, green: 0.40, blue: 0.24, alpha: 1.0) : UIColor(red: 0.44, green: 0.32, blue: 0.18, alpha: 1.0)
            } else {
                let col = (x + (y / 3)) % 4
                return (col == 0) ? UIColor(red: 0.18, green: 0.12, blue: 0.06, alpha: 1.0) : UIColor(red: 0.34, green: 0.23, blue: 0.13, alpha: 1.0)
            }

        case .woodPlanks: // Hand-hewn dark oak timber with forged iron square studs
            let row = y % 4
            let plankIndex = y / 4
            let seamX = (plankIndex % 2 == 0) ? 7 : 14
            if row == 3 || x == seamX {
                return UIColor(red: 0.28, green: 0.18, blue: 0.10, alpha: 1.0)
            }
            let isNail = (row == 1) && (x == (seamX + 2) % 16 || x == (seamX + 14) % 16)
            if isNail {
                return UIColor(red: 0.18, green: 0.18, blue: 0.20, alpha: 1.0)
            }
            let grain = ((x * 3 + (hash & 3)) % 4 == 0)
            return grain ? UIColor(red: 0.46, green: 0.33, blue: 0.19, alpha: 1.0) : UIColor(red: 0.54, green: 0.39, blue: 0.23, alpha: 1.0)

        case .water:
            let wave = ((x * 2 + y * 3) % 7 == 0)
            return wave ? UIColor(red: 0.14, green: 0.30, blue: 0.65, alpha: 0.84) : UIColor(red: 0.10, green: 0.25, blue: 0.58, alpha: 0.84)

        case .grass: // Deep forest turf with jagged fringe
            let fringe = 3 + ((x * 7 + 1) % 3)
            if face == .top || y < fringe {
                let p = (hash + x * 3 + y * 5) & 7
                return (p <= 2) ? UIColor(red: 0.16, green: 0.48, blue: 0.12, alpha: 1.0) : UIColor(red: 0.24, green: 0.62, blue: 0.18, alpha: 1.0)
            }
            return medievalDirtPixel(x: x, y: y, hash: hash)

        case .dirt:
            return medievalDirtPixel(x: x, y: y, hash: hash)
        }
    }

    private static func medievalDirtPixel(x: Int, y: Int, hash: Int) -> UIColor {
        let p = (hash + x * 5 + y * 7) & 7
        if p == 0 {
            return UIColor(red: 0.28, green: 0.18, blue: 0.10, alpha: 1.0)
        } else if p <= 2 {
            return UIColor(red: 0.38, green: 0.26, blue: 0.16, alpha: 1.0)
        } else {
            return UIColor(red: 0.44, green: 0.30, blue: 0.18, alpha: 1.0)
        }
    }

    // MARK: 3. Cyber Neon (Sci-Fi Futuristic)
    private static func cyberColor(
        for type: BlockType,
        face: BlockFace,
        x: Int,
        y: Int,
        size: Int,
        hash: Int,
        cobblePattern: [[Int]]
    ) -> UIColor {
        switch type {
        case .stone: // Carbon plating with glowing cyan circuit veins
            let level = cobblePattern[y & 15][x & 15]
            if level == 0 {
                return UIColor(red: 0.05, green: 0.94, blue: 1.0, alpha: 1.0) // Glowing cyan circuit
            } else if level == 1 {
                return UIColor(red: 0.08, green: 0.42, blue: 0.52, alpha: 1.0)
            } else if level == 2 {
                return UIColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1.0)
            } else {
                return UIColor(red: 0.20, green: 0.22, blue: 0.28, alpha: 1.0)
            }

        case .smoothStone: // Titanium alloy plating with corner LED diodes
            let isBorder = (x == 0 || x == 15 || y == 0 || y == 15)
            let isCornerLight = ((x == 2 || x == 13) && (y == 2 || y == 13))
            if isCornerLight {
                return UIColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1.0) // Glowing diode
            }
            if isBorder {
                return UIColor(red: 0.14, green: 0.16, blue: 0.20, alpha: 1.0)
            }
            return UIColor(red: 0.30, green: 0.34, blue: 0.40, alpha: 1.0)

        case .sand: // Silvery crushed silicon substrate
            let g = (hash + x * 3 + y * 5) & 7
            return (g == 0) ? UIColor(red: 0.65, green: 0.75, blue: 0.85, alpha: 1.0) : UIColor(red: 0.48, green: 0.58, blue: 0.68, alpha: 1.0)

        case .glass: // Cyan holographic force shield
            let isBorder = (x == 0 || x == 15 || y == 0 || y == 15)
            let isScanline = (x + y) % 4 == 0
            if isBorder {
                return UIColor(red: 0.0, green: 0.92, blue: 1.0, alpha: 0.90)
            } else if isScanline {
                return UIColor(red: 0.10, green: 0.80, blue: 1.0, alpha: 0.30)
            } else {
                return UIColor(red: 0.05, green: 0.45, blue: 0.70, alpha: 0.12)
            }

        case .door: // Airtight sci-fi blast door with hazard stripes & biometric pad
            let isBorder = (x <= 1 || x >= 14 || y <= 1 || y >= 14)
            let isHazard = (y <= 3 || y >= 12) && ((x + y) % 4 < 2)
            let isPorthole = (x >= 6 && x <= 9 && y >= 5 && y <= 8)
            let isBiometric = (x == 12 && y == 8)
            if isBiometric {
                return UIColor(red: 0.0, green: 1.0, blue: 0.4, alpha: 1.0) // Green scan point
            }
            if isHazard {
                return UIColor(red: 0.96, green: 0.82, blue: 0.10, alpha: 1.0) // Yellow hazard stripe
            }
            if isPorthole {
                return UIColor(red: 0.05, green: 0.85, blue: 1.0, alpha: 0.45)
            }
            if isBorder {
                return UIColor(red: 0.15, green: 0.17, blue: 0.22, alpha: 1.0)
            }
            return UIColor(red: 0.26, green: 0.30, blue: 0.36, alpha: 1.0)

        case .roof, .slab, .roofCorner: // Photovoltaic solar array panels
            let cellX = (x % 4 == 0)
            let cellY = (y % 4 == 0)
            if cellX || cellY {
                return UIColor(red: 0.05, green: 0.85, blue: 0.95, alpha: 1.0) // Glowing grid bus
            }
            return UIColor(red: 0.06, green: 0.12, blue: 0.22, alpha: 1.0)

        case .leaves: // Crystalline holographic solar canopy
            let p = ((x * 3 + y * 7) ^ hash) & 7
            if p == 0 {
                return UIColor(red: 0.0, green: 1.0, blue: 0.85, alpha: 1.0)
            } else if p <= 2 {
                return UIColor(red: 0.0, green: 0.88, blue: 0.40, alpha: 1.0)
            } else {
                return UIColor(red: 0.04, green: 0.58, blue: 0.32, alpha: 1.0)
            }

        case .woodLog: // High-voltage conduit column
            if face == .top {
                let dist = max(abs(x - 7), abs(y - 7))
                if dist == 2 {
                    return UIColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1.0) // Glowing reactor core ring
                }
                return UIColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1.0)
            } else {
                let isCoreLine = (x == 7 || x == 8)
                if isCoreLine {
                    return UIColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1.0) // Glowing vertical conduit
                }
                return UIColor(red: 0.15, green: 0.17, blue: 0.22, alpha: 1.0)
            }

        case .woodPlanks: // Brushed steel grating floor
            let seam = (y % 4 == 3)
            let vent = (x % 2 == 0) && (y % 4 == 1)
            if seam {
                return UIColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1.0)
            }
            if vent {
                return UIColor(red: 0.08, green: 0.10, blue: 0.12, alpha: 1.0)
            }
            return UIColor(red: 0.38, green: 0.42, blue: 0.48, alpha: 1.0)

        case .water: // Luminescent energized plasma / coolant
            let p = ((x + y * 2) % 6 == 0)
            return p ? UIColor(red: 0.0, green: 0.85, blue: 0.98, alpha: 0.78) : UIColor(red: 0.0, green: 0.60, blue: 0.90, alpha: 0.78)

        case .grass: // Electric nano-turf
            let fringe = 2 + ((x * 3) % 3)
            if face == .top || y < fringe {
                let p = (hash + x * 3 + y * 5) & 7
                return (p == 0) ? UIColor(red: 0.0, green: 1.0, blue: 0.60, alpha: 1.0) : UIColor(red: 0.18, green: 0.88, blue: 0.28, alpha: 1.0)
            }
            return cyberDirtPixel(x: x, y: y, hash: hash)

        case .dirt:
            return cyberDirtPixel(x: x, y: y, hash: hash)
        }
    }

    private static func cyberDirtPixel(x: Int, y: Int, hash: Int) -> UIColor {
        let p = (hash + x * 7 + y * 3) & 7
        if p == 0 {
            return UIColor(red: 0.0, green: 0.50, blue: 0.60, alpha: 1.0) // Micro-circuit spark
        } else if p <= 2 {
            return UIColor(red: 0.10, green: 0.12, blue: 0.15, alpha: 1.0)
        } else {
            return UIColor(red: 0.18, green: 0.20, blue: 0.24, alpha: 1.0)
        }
    }

    // MARK: 4. Cozy Pastel (Warm, Clean & Minimalist)
    private static func pastelColor(
        for type: BlockType,
        face: BlockFace,
        x: Int,
        y: Int,
        size: Int,
        hash: Int,
        cobblePattern: [[Int]]
    ) -> UIColor {
        switch type {
        case .stone: // Rounded pastel river stones
            let level = cobblePattern[y & 15][x & 15]
            switch level {
            case 0: return UIColor(red: 0.60, green: 0.62, blue: 0.72, alpha: 1.0)
            case 1: return UIColor(red: 0.74, green: 0.76, blue: 0.84, alpha: 1.0)
            case 2: return UIColor(red: 0.82, green: 0.84, blue: 0.90, alpha: 1.0)
            default: return UIColor(red: 0.90, green: 0.92, blue: 0.96, alpha: 1.0)
            }

        case .smoothStone: // Cream plaster
            let soft = ((x + y) & 3)
            return (soft == 0) ? UIColor(red: 0.78, green: 0.80, blue: 0.84, alpha: 1.0) : UIColor(red: 0.84, green: 0.86, blue: 0.90, alpha: 1.0)

        case .sand: // Buttermilk soft sand
            let g = (hash + x + y) & 3
            return (g == 0) ? UIColor(red: 0.98, green: 0.92, blue: 0.76, alpha: 1.0) : UIColor(red: 0.95, green: 0.88, blue: 0.70, alpha: 1.0)

        case .glass: // Sparkling crystal glass with cute glints
            let isBorder = (x == 0 || x == 15 || y == 0 || y == 15)
            let isStar = (x == 4 && y == 4) || (x == 3 && y == 4) || (x == 5 && y == 4) || (x == 4 && y == 3) || (x == 4 && y == 5)
            if isBorder {
                return UIColor(red: 0.85, green: 0.94, blue: 1.0, alpha: 0.90)
            } else if isStar {
                return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95)
            } else {
                return UIColor(red: 0.80, green: 0.94, blue: 1.0, alpha: 0.12)
            }

        case .door: // Cute pastel cottage door
            let isBorder = (x <= 1 || x >= 14 || y <= 1 || y >= 14)
            let isWindow = (x >= 4 && x <= 11 && y >= 3 && y <= 6)
            let isMullion = (x == 7 || x == 8 || y == 4 || y == 5)
            let isKnob = (x == 12 && y == 8)
            if isKnob {
                return UIColor(red: 1.0, green: 0.82, blue: 0.35, alpha: 1.0) // Gold knob
            }
            if isWindow && !isMullion {
                return UIColor(red: 0.80, green: 0.95, blue: 1.0, alpha: 0.25)
            }
            if isBorder || isMullion {
                return UIColor(red: 0.60, green: 0.78, blue: 0.72, alpha: 1.0) // Soft sage mint
            }
            return UIColor(red: 0.94, green: 0.80, blue: 0.60, alpha: 1.0) // Soft peach honey

        case .roof, .slab, .roofCorner: // Terracotta peach scallop tiles
            let row = y % 4
            if row == 3 {
                return UIColor(red: 0.82, green: 0.48, blue: 0.42, alpha: 1.0)
            }
            return UIColor(red: 0.94, green: 0.64, blue: 0.54, alpha: 1.0)

        case .leaves: // Fluffy pastel apple-mint clusters
            let p = ((x * 3 + y * 5) ^ (hash >> 2)) & 7
            return (p <= 2) ? UIColor(red: 0.54, green: 0.88, blue: 0.48, alpha: 1.0) : UIColor(red: 0.42, green: 0.80, blue: 0.38, alpha: 1.0)

        case .woodLog: // Birch light wood
            if face == .top {
                let dist = max(abs(x - 7), abs(y - 7))
                return (dist % 2 == 0) ? UIColor(red: 0.94, green: 0.88, blue: 0.76, alpha: 1.0) : UIColor(red: 0.88, green: 0.80, blue: 0.68, alpha: 1.0)
            } else {
                let fleck = (y % 4 == 0) && (x >= 4 && x <= 7)
                return fleck ? UIColor(red: 0.55, green: 0.55, blue: 0.58, alpha: 1.0) : UIColor(red: 0.96, green: 0.96, blue: 0.94, alpha: 1.0)
            }

        case .woodPlanks: // Honey Nordic pine
            let seam = (y % 4 == 3)
            return seam ? UIColor(red: 0.84, green: 0.70, blue: 0.48, alpha: 1.0) : UIColor(red: 0.94, green: 0.82, blue: 0.62, alpha: 1.0)

        case .water: // Turquoise tropical lagoon
            let w = ((x + y) % 4 == 0)
            return w ? UIColor(red: 0.35, green: 0.85, blue: 0.95, alpha: 0.72) : UIColor(red: 0.24, green: 0.76, blue: 0.90, alpha: 0.72)

        case .grass: // Soft mint-matcha meadow
            let fringe = 2 + ((x * 2) % 2)
            if face == .top || y < fringe {
                let p = (hash + x * 3 + y * 3) & 7
                return (p <= 2) ? UIColor(red: 0.48, green: 0.88, blue: 0.42, alpha: 1.0) : UIColor(red: 0.38, green: 0.80, blue: 0.34, alpha: 1.0)
            }
            return pastelDirtPixel(x: x, y: y, hash: hash)

        case .dirt:
            return pastelDirtPixel(x: x, y: y, hash: hash)
        }
    }

    private static func pastelDirtPixel(x: Int, y: Int, hash: Int) -> UIColor {
        let p = (hash + x * 3 + y * 7) & 3
        return (p == 0) ? UIColor(red: 0.64, green: 0.48, blue: 0.36, alpha: 1.0) : UIColor(red: 0.56, green: 0.40, blue: 0.28, alpha: 1.0)
    }

    // MARK: 5. Dark Nether (Volcanic & Scorched)
    private static func volcanicColor(
        for type: BlockType,
        face: BlockFace,
        x: Int,
        y: Int,
        size: Int,
        hash: Int,
        cobblePattern: [[Int]]
    ) -> UIColor {
        switch type {
        case .stone: // Obsidian with fiery magma fissures
            let level = cobblePattern[y & 15][x & 15]
            if level == 0 {
                return UIColor(red: 1.0, green: 0.40, blue: 0.05, alpha: 1.0) // Molten magma crack
            } else if level == 1 {
                return UIColor(red: 0.68, green: 0.16, blue: 0.04, alpha: 1.0)
            } else if level == 2 {
                return UIColor(red: 0.16, green: 0.12, blue: 0.15, alpha: 1.0)
            } else {
                return UIColor(red: 0.26, green: 0.20, blue: 0.24, alpha: 1.0)
            }

        case .smoothStone: // Polished black basalt
            let streak = ((x * 2 + y * 3) % 5 == 0)
            return streak ? UIColor(red: 0.22, green: 0.18, blue: 0.22, alpha: 1.0) : UIColor(red: 0.14, green: 0.12, blue: 0.15, alpha: 1.0)

        case .sand: // Black volcanic obsidian sand
            let g = (hash + x * 3 + y * 5) & 7
            return (g == 0) ? UIColor(red: 0.65, green: 0.10, blue: 0.15, alpha: 1.0) : UIColor(red: 0.15, green: 0.12, blue: 0.14, alpha: 1.0)

        case .glass: // Smoked obsidian glass with ember highlights
            let isBorder = (x == 0 || x == 15 || y == 0 || y == 15)
            let isGlint = (x + y == 6) || (x + y == 22)
            if isBorder {
                return UIColor(red: 0.85, green: 0.32, blue: 0.10, alpha: 0.90)
            } else if isGlint {
                return UIColor(red: 1.0, green: 0.55, blue: 0.10, alpha: 0.65)
            } else {
                return UIColor(red: 0.25, green: 0.10, blue: 0.12, alpha: 0.22)
            }

        case .door: // Fortified dark iron Nether gate
            let isBorder = (x <= 1 || x >= 14 || y <= 1 || y >= 14)
            let isStrap = (y == 5 || y == 10)
            let isRivet = isStrap && (x % 3 == 0)
            if isRivet {
                return UIColor(red: 1.0, green: 0.45, blue: 0.10, alpha: 1.0) // Glowing rivet
            }
            if isBorder || isStrap {
                return UIColor(red: 0.22, green: 0.16, blue: 0.18, alpha: 1.0)
            }
            return UIColor(red: 0.35, green: 0.15, blue: 0.16, alpha: 1.0)

        case .roof, .slab, .roofCorner: // Obsidian tiles with magma mortar
            let isSeam = (y % 4 == 0)
            if isSeam {
                return UIColor(red: 0.85, green: 0.28, blue: 0.05, alpha: 1.0) // Glowing mortar
            }
            return UIColor(red: 0.18, green: 0.14, blue: 0.18, alpha: 1.0)

        case .leaves: // Fiery brimstone canopy
            let p = ((x * 3 + y * 7) ^ hash) & 7
            if p == 0 {
                return UIColor(red: 1.0, green: 0.65, blue: 0.10, alpha: 1.0) // Glowing spark
            } else if p <= 2 {
                return UIColor(red: 0.88, green: 0.22, blue: 0.08, alpha: 1.0)
            } else {
                return UIColor(red: 0.54, green: 0.10, blue: 0.12, alpha: 1.0)
            }

        case .woodLog: // Charred wood with smoldering cracks
            if face == .top {
                let dist = max(abs(x - 7), abs(y - 7))
                return (dist % 2 == 0) ? UIColor(red: 0.85, green: 0.30, blue: 0.08, alpha: 1.0) : UIColor(red: 0.20, green: 0.14, blue: 0.16, alpha: 1.0)
            } else {
                let isCrack = (x == 6 || x == 9) && (y % 3 == 0)
                if isCrack {
                    return UIColor(red: 1.0, green: 0.45, blue: 0.10, alpha: 1.0)
                }
                return UIColor(red: 0.16, green: 0.14, blue: 0.16, alpha: 1.0)
            }

        case .woodPlanks: // Warped crimson bloodwood planks
            let seam = (y % 4 == 3)
            return seam ? UIColor(red: 0.24, green: 0.10, blue: 0.14, alpha: 1.0) : UIColor(red: 0.48, green: 0.18, blue: 0.24, alpha: 1.0)

        case .water: // Bioluminescent abyssal violet fluid
            let w = ((x + y * 2) % 6 == 0)
            return w ? UIColor(red: 0.65, green: 0.15, blue: 0.85, alpha: 0.82) : UIColor(red: 0.45, green: 0.08, blue: 0.65, alpha: 0.82)

        case .grass: // Crimson Nether fungus
            let fringe = 2 + ((x * 5) % 3)
            if face == .top || y < fringe {
                let p = (hash + x * 3 + y * 5) & 7
                return (p == 0) ? UIColor(red: 1.0, green: 0.35, blue: 0.25, alpha: 1.0) : UIColor(red: 0.78, green: 0.14, blue: 0.18, alpha: 1.0)
            }
            return volcanicDirtPixel(x: x, y: y, hash: hash)

        case .dirt:
            return volcanicDirtPixel(x: x, y: y, hash: hash)
        }
    }

    private static func volcanicDirtPixel(x: Int, y: Int, hash: Int) -> UIColor {
        let p = (hash + x * 5 + y * 7) & 7
        return (p == 0) ? UIColor(red: 0.65, green: 0.15, blue: 0.05, alpha: 1.0) : UIColor(red: 0.20, green: 0.14, blue: 0.16, alpha: 1.0)
    }

    // MARK: 6. Winter Frost (Glacial & Alpine)
    private static func winterColor(
        for type: BlockType,
        face: BlockFace,
        x: Int,
        y: Int,
        size: Int,
        hash: Int,
        cobblePattern: [[Int]]
    ) -> UIColor {
        switch type {
        case .stone: // Glacial cobblestone with frost rime
            let level = cobblePattern[y & 15][x & 15]
            switch level {
            case 0: return UIColor(red: 0.38, green: 0.48, blue: 0.58, alpha: 1.0) // Icy mortar
            case 1: return UIColor(red: 0.52, green: 0.58, blue: 0.66, alpha: 1.0)
            case 2: return UIColor(red: 0.68, green: 0.74, blue: 0.82, alpha: 1.0)
            default: return UIColor(red: 0.90, green: 0.94, blue: 0.98, alpha: 1.0) // White frost dusting
            }

        case .smoothStone: // Permafrost stone with rime veins
            let rime = (x + y * 2) % 6 == 0
            return rime ? UIColor(red: 0.84, green: 0.90, blue: 0.96, alpha: 1.0) : UIColor(red: 0.54, green: 0.60, blue: 0.68, alpha: 1.0)

        case .sand: // Arctic quartz sand
            let g = (hash + x + y) & 3
            return (g == 0) ? UIColor(red: 0.92, green: 0.95, blue: 0.98, alpha: 1.0) : UIColor(red: 0.82, green: 0.86, blue: 0.92, alpha: 1.0)

        case .glass: // Frosted window with ice ferns
            let isBorder = (x == 0 || x == 15 || y == 0 || y == 15)
            let isFern = (x == y || x + y == 15 || (x + y) % 3 == 0)
            if isBorder || isFern {
                return UIColor(red: 0.92, green: 0.96, blue: 1.0, alpha: 0.85)
            }
            return UIColor(red: 0.70, green: 0.85, blue: 0.98, alpha: 0.15)

        case .door: // Alpine chalet door with snow top
            let isSnowTop = (y <= 2)
            let isBorder = (x <= 1 || x >= 14 || y >= 14)
            let isHandle = (x == 12 && y == 8)
            if isSnowTop {
                return UIColor(red: 0.94, green: 0.96, blue: 1.0, alpha: 1.0) // Snow on door header
            }
            if isHandle {
                return UIColor(red: 0.90, green: 0.78, blue: 0.30, alpha: 1.0)
            }
            if isBorder {
                return UIColor(red: 0.28, green: 0.32, blue: 0.38, alpha: 1.0)
            }
            return UIColor(red: 0.44, green: 0.48, blue: 0.54, alpha: 1.0)

        case .roof, .slab, .roofCorner: // Snow-capped cedar shakes
            let isSnow = (y % 4 <= 1)
            return isSnow ? UIColor(red: 0.92, green: 0.95, blue: 0.98, alpha: 1.0) : UIColor(red: 0.40, green: 0.36, blue: 0.34, alpha: 1.0)

        case .leaves: // Snow-encrusted evergreen pine needles
            let isSnow = (hash & 3 == 0)
            if isSnow {
                return UIColor(red: 0.94, green: 0.96, blue: 0.98, alpha: 1.0)
            }
            return UIColor(red: 0.18, green: 0.42, blue: 0.32, alpha: 1.0)

        case .woodLog: // Snowy pine
            if face == .top {
                let dist = max(abs(x - 7), abs(y - 7))
                return (dist % 2 == 0) ? UIColor(red: 0.80, green: 0.86, blue: 0.92, alpha: 1.0) : UIColor(red: 0.45, green: 0.48, blue: 0.52, alpha: 1.0)
            } else {
                let isSnowRidge = (y % 4 == 0) && (x % 3 == 0)
                if isSnowRidge {
                    return UIColor(red: 0.94, green: 0.96, blue: 0.98, alpha: 1.0)
                }
                return UIColor(red: 0.28, green: 0.30, blue: 0.34, alpha: 1.0)
            }

        case .woodPlanks: // Driftwood pale winter pine
            let seam = (y % 4 == 3)
            return seam ? UIColor(red: 0.48, green: 0.54, blue: 0.60, alpha: 1.0) : UIColor(red: 0.68, green: 0.74, blue: 0.80, alpha: 1.0)

        case .water: // Pale glacial alpine water
            let wave = ((x + y * 2) % 5 == 0)
            return wave ? UIColor(red: 0.50, green: 0.78, blue: 0.96, alpha: 0.75) : UIColor(red: 0.35, green: 0.65, blue: 0.90, alpha: 0.75)

        case .grass: // Snow-covered winter turf
            let fringe = 3 + ((x * 3) % 3)
            if face == .top || y < fringe {
                let icicle = (y == fringe - 1) && (x % 2 == 0)
                return icicle ? UIColor(red: 0.82, green: 0.90, blue: 0.98, alpha: 1.0) : UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1.0)
            }
            return winterDirtPixel(x: x, y: y, hash: hash)

        case .dirt:
            return winterDirtPixel(x: x, y: y, hash: hash)
        }
    }

    private static func winterDirtPixel(x: Int, y: Int, hash: Int) -> UIColor {
        let p = (hash + x * 5 + y * 3) & 7
        return (p == 0) ? UIColor(red: 0.80, green: 0.88, blue: 0.94, alpha: 1.0) : UIColor(red: 0.38, green: 0.34, blue: 0.32, alpha: 1.0)
    }
}
