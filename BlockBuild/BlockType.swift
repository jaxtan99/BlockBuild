import SwiftUI
import SceneKit
import UIKit

enum BlockType: Int, CaseIterable, Identifiable, Codable {
    case stone = 0
    case woodLog = 1
    case woodPlanks = 2
    case leaves = 3
    case water = 4
    case smoothStone = 5
    case sand = 6
    case glass = 7
    case door = 8
    case roof = 9
    case grass = 10
    case dirt = 11
    case slab = 12
    case roofCorner = 13

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .stone: return "Cobble"
        case .woodLog: return "Logs"
        case .woodPlanks: return "Planks"
        case .leaves: return "Leaves"
        case .water: return "Water"
        case .smoothStone: return "Stone"
        case .sand: return "Sand"
        case .glass: return "Glass"
        case .door: return "Door"
        case .roof: return "EdgeRoof"
        case .grass: return "Grass"
        case .dirt: return "Dirt"
        case .slab: return "Slab"
        case .roofCorner: return "SideRoof"
        }
    }

    var fullName: String {
        switch self {
        case .stone: return "Cobblestone"
        case .woodLog: return "Logs"
        case .woodPlanks: return "Planks"
        case .leaves: return "Leaves"
        case .water: return "Water"
        case .smoothStone: return "Stone"
        case .sand: return "Sand"
        case .glass: return "Glass"
        case .door: return "Door"
        case .roof: return "EdgeRoof"
        case .grass: return "Grass"
        case .dirt: return "Dirt"
        case .slab: return "Slab"
        case .roofCorner: return "SideRoof"
        }
    }

    /// Blocks that do not fully occlude neighbor faces (transparent or non-full-cube geometry)
    var isTransparent: Bool {
        switch self {
        case .water, .glass, .door, .roof, .slab, .roofCorner:
            return true
        default:
            return false
        }
    }

    /// All blocks other than water have solid 3D collision hitboxes
    var hasHitbox: Bool {
        return self != .water
    }

    /// Doors can be toggled open/closed
    var isToggleable: Bool {
        return self == .door
    }

    private static var iconCache: [BlockType: UIImage] = [:]
    private static var materialCache: [BlockType: [SCNMaterial]] = [:]

    /// Completely invisible material used to hide interior faces between adjacent water blocks
    static let invisibleMaterial: SCNMaterial = {
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.clear
        mat.transparency = 0.0
        mat.writesToDepthBuffer = false
        mat.colorBufferWriteMask = []
        return mat
    }()

    var iconImage: UIImage {
        if let cached = Self.iconCache[self] {
            return cached
        }
        let img = Self.generateTexture(for: self, face: .side)
        Self.iconCache[self] = img
        return img
    }

    var materials: [SCNMaterial] {
        if let cached = Self.materialCache[self] {
            return cached
        }
        let mats: [SCNMaterial]
        if self == .woodLog {
            let sideMat = Self.makeMaterial(image: Self.generateTexture(for: .woodLog, face: .side), type: self)
            let topMat = Self.makeMaterial(image: Self.generateTexture(for: .woodLog, face: .top), type: self)
            mats = [sideMat, sideMat, sideMat, sideMat, topMat, topMat]
        } else if self == .grass {
            let sideMat = Self.makeMaterial(image: Self.generateTexture(for: .grass, face: .side), type: self)
            let topMat = Self.makeMaterial(image: Self.generateTexture(for: .grass, face: .top), type: self)
            let bottomMat = Self.makeMaterial(image: Self.generateTexture(for: .dirt, face: .side), type: self)
            mats = [sideMat, sideMat, sideMat, sideMat, topMat, bottomMat]
        } else {
            let mat = Self.makeMaterial(image: Self.generateTexture(for: self, face: .side), type: self)
            mats = [mat]
        }
        Self.materialCache[self] = mats
        return mats
    }

    private enum Face {
        case side
        case top
    }

    private static func makeMaterial(image: UIImage, type: BlockType) -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = image
        mat.diffuse.magnificationFilter = .nearest
        mat.diffuse.minificationFilter = .nearest
        mat.diffuse.mipFilter = .none

        switch type {
        case .water:
            // Constant shading + no depth-buffer occlusion eliminates reflection glare and Z-fighting between adjacent water blocks
            mat.lightingModel = .constant
            mat.transparency = 0.74
            mat.isDoubleSided = false
            mat.writesToDepthBuffer = false
            mat.transparencyMode = .aOne
        case .glass:
            mat.lightingModel = .lambert
            mat.isDoubleSided = false
            mat.writesToDepthBuffer = true
            mat.transparencyMode = .aOne
        case .door:
            mat.lightingModel = .lambert
            mat.isDoubleSided = true
            mat.writesToDepthBuffer = true
            mat.transparencyMode = .aOne
        default:
            mat.lightingModel = .lambert
            mat.isDoubleSided = false
            mat.writesToDepthBuffer = true
        }
        return mat
    }

    private static let cobblePattern: [[Int]] = [
        [0,2,3,2,0,1,2,3,2,0,2,3,1,0,2,1],
        [2,3,3,1,0,2,3,3,1,0,3,2,1,0,3,2],
        [1,2,1,0,1,2,2,1,0,1,2,1,0,1,2,1],
        [0,0,0,1,2,3,1,0,0,2,3,2,1,0,0,0],
        [1,2,3,2,1,0,0,1,2,3,3,1,0,1,2,3],
        [2,3,3,1,0,1,2,3,3,2,1,0,1,3,3,2],
        [1,1,0,0,2,3,3,2,1,0,0,2,3,2,1,0],
        [0,2,3,2,1,2,1,0,0,1,2,3,3,1,0,1],
        [2,3,3,1,0,0,0,1,2,3,3,2,1,0,2,3],
        [1,2,1,0,1,2,3,2,1,2,1,0,0,2,3,2],
        [0,0,1,2,3,3,2,1,0,0,1,2,3,2,1,0],
        [1,2,3,3,2,1,0,0,1,2,3,3,1,0,1,2],
        [2,3,2,1,0,1,2,3,2,1,2,1,0,2,3,3],
        [1,0,0,1,2,3,3,1,0,0,0,1,2,3,2,1],
        [0,1,2,3,2,1,1,0,1,2,3,2,1,1,0,0],
        [1,2,3,1,0,0,2,3,2,1,2,1,0,1,2,2]
    ]

    private static func generateTexture(for type: BlockType, face: Face) -> UIImage {
        let size = 16
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        // All solid blocks including Grass, Dirt, Leaves, Stone, Sand, Wood, and Cobble Roof are 100% opaque (no alpha channel)
        format.opaque = (type != .water && type != .glass && type != .door)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size), format: format)

        return renderer.image { ctx in
            let cgContext = ctx.cgContext
            cgContext.interpolationQuality = .none

            for y in 0..<size {
                for x in 0..<size {
                    let hash = ((x &* 73856093) ^ (y &* 19349663) ^ (type.rawValue &* 83492791)) & 0xFF
                    let color = pixelColor(for: type, face: face, x: x, y: y, size: size, hash: hash)
                    cgContext.setFillColor(color.cgColor)
                    cgContext.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }
    }

    private static func pixelColor(for type: BlockType, face: Face, x: Int, y: Int, size: Int, hash: Int) -> UIColor {
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
            // Clean, uniform water texture without harsh contrast bands so adjacent water blocks blend seamlessly
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
            return Self.dirtPixel(x: x, y: y, hash: hash)

        case .dirt:
            return Self.dirtPixel(x: x, y: y, hash: hash)
        }
    }

    private static func dirtPixel(x: Int, y: Int, hash: Int) -> UIColor {
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
}
