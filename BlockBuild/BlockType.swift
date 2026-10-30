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

    struct TextureCacheKey: Hashable {
        let block: BlockType
        let pack: TexturePack
    }

    private static var iconCache: [TextureCacheKey: UIImage] = [:]
    private static var materialCache: [TextureCacheKey: [SCNMaterial]] = [:]
    static var activeTexturePack: TexturePack = .classic

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
        iconImage(for: Self.activeTexturePack)
    }

    func iconImage(for pack: TexturePack) -> UIImage {
        let key = TextureCacheKey(block: self, pack: pack)
        if let cached = Self.iconCache[key] {
            return cached
        }
        let img = Self.generateTexture(for: self, face: .side, pack: pack)
        Self.iconCache[key] = img
        return img
    }

    var materials: [SCNMaterial] {
        materials(for: Self.activeTexturePack)
    }

    // MARK: - Custom User-Created Block Textures
    private static var customBlockTextures: [BlockType: UIImage] = [:]

    static func setCustomTexture(for type: BlockType, image: UIImage) {
        customBlockTextures[type] = image
        materialCache.removeAll()
    }

    static func customTexture(for type: BlockType) -> UIImage? {
        customBlockTextures[type]
    }

    static func clearCustomTexture(for type: BlockType) {
        customBlockTextures.removeValue(forKey: type)
        materialCache.removeAll()
    }

    static func baseTextureImage(for type: BlockType, pack: TexturePack = .classic) -> UIImage {
        if let custom = customBlockTextures[type] {
            return custom
        }
        return generateTexture(for: type, face: .side, pack: pack)
    }

    func materials(for pack: TexturePack) -> [SCNMaterial] {
        let key = TextureCacheKey(block: self, pack: pack)
        if let cached = Self.materialCache[key] {
            return cached
        }

        if let customImage = Self.customBlockTextures[self] {
            let mat = Self.makeMaterial(image: customImage, type: self)
            let mats = [mat]
            Self.materialCache[key] = mats
            return mats
        }
        let mats: [SCNMaterial]
        if self == .woodLog {
            let sideMat = Self.makeMaterial(image: Self.generateTexture(for: .woodLog, face: .side, pack: pack), type: self)
            let topMat = Self.makeMaterial(image: Self.generateTexture(for: .woodLog, face: .top, pack: pack), type: self)
            mats = [sideMat, sideMat, sideMat, sideMat, topMat, topMat]
        } else if self == .grass {
            let sideMat = Self.makeMaterial(image: Self.generateTexture(for: .grass, face: .side, pack: pack), type: self)
            let topMat = Self.makeMaterial(image: Self.generateTexture(for: .grass, face: .top, pack: pack), type: self)
            let bottomMat = Self.makeMaterial(image: Self.generateTexture(for: .dirt, face: .side, pack: pack), type: self)
            mats = [sideMat, sideMat, sideMat, sideMat, topMat, bottomMat]
        } else {
            let mat = Self.makeMaterial(image: Self.generateTexture(for: self, face: .side, pack: pack), type: self)
            mats = [mat]
        }
        Self.materialCache[key] = mats
        return mats
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

    private static func generateTexture(for type: BlockType, face: BlockFace, pack: TexturePack) -> UIImage {
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
                    let color = TexturePackPainter.pixelColor(
                        for: type,
                        face: face,
                        pack: pack,
                        x: x,
                        y: y,
                        size: size,
                        hash: hash,
                        cobblePattern: cobblePattern
                    )
                    cgContext.setFillColor(color.cgColor)
                    cgContext.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }
    }
}

enum BlockFace {
    case side
    case top
}
