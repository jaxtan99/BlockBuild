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
        // Custom texture prioritization for inventory and UI icons
        let img: UIImage
        if let customSide = Self.customTexture(for: self, face: .side) {
            img = customSide
        } else if let customTop = Self.customTexture(for: self, face: .top) {
            img = customTop
        } else if let customBottom = Self.customTexture(for: self, face: .bottom) {
            img = customBottom
        } else {
            img = Self.textureImage(for: self, face: .side, pack: pack)
        }
        Self.iconCache[key] = img
        return img
    }

    var materials: [SCNMaterial] {
        materials(for: Self.activeTexturePack)
    }

    // MARK: - Multi-Face Texture Support
    var editableFaces: [BlockFace] {
        switch self {
        case .woodLog:
            return [.side, .top]
        case .grass:
            return [.side, .top, .bottom]
        default:
            return [.side]
        }
    }

    func faceDisplayName(_ face: BlockFace) -> String {
        switch self {
        case .woodLog:
            switch face {
            case .side: return "Bark (Side)"
            case .top, .bottom: return "Rings (Top/Bottom)"
            }
        case .grass:
            switch face {
            case .side: return "Side (Dirt & Grass)"
            case .top: return "Top (Lush Grass)"
            case .bottom: return "Bottom (Dirt)"
            }
        default:
            return "All Sides"
        }
    }

    func faceIconName(_ face: BlockFace) -> String {
        switch face {
        case .side: return "square.lefthalf.filled"
        case .top: return "square.tophalf.filled"
        case .bottom: return "square.bottomhalf.filled"
        }
    }

    // MARK: - Custom User-Created Block Textures (Per Face & Persistent)
    private static var customBlockTextures: [BlockType: [BlockFace: UIImage]] = {
        var dict: [BlockType: [BlockFace: UIImage]] = [:]
        let dir = customTexturesDirectory
        for type in BlockType.allCases {
            for face in [BlockFace.side, BlockFace.top, BlockFace.bottom] {
                let fileURL = dir.appendingPathComponent("\(type.rawValue)_\(face.rawValue).png")
                if let data = try? Data(contentsOf: fileURL), let img = UIImage(data: data) {
                    if dict[type] == nil {
                        dict[type] = [:]
                    }
                    dict[type]?[face] = img
                }
            }
        }
        return dict
    }()

    private static var customTexturesDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("CustomBlockTextures", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static func saveCustomTextureToDisk(type: BlockType, face: BlockFace, image: UIImage) {
        guard let data = image.pngData() else { return }
        let fileURL = customTexturesDirectory.appendingPathComponent("\(type.rawValue)_\(face.rawValue).png")
        try? data.write(to: fileURL)
    }

    private static func removeCustomTextureFromDisk(type: BlockType, face: BlockFace?) {
        let dir = customTexturesDirectory
        if let face = face {
            let fileURL = dir.appendingPathComponent("\(type.rawValue)_\(face.rawValue).png")
            try? FileManager.default.removeItem(at: fileURL)
        } else {
            for f in [BlockFace.side, BlockFace.top, BlockFace.bottom] {
                let fileURL = dir.appendingPathComponent("\(type.rawValue)_\(f.rawValue).png")
                try? FileManager.default.removeItem(at: fileURL)
            }
        }
    }

    static func setCustomTexture(for type: BlockType, face: BlockFace = .side, image: UIImage) {
        if customBlockTextures[type] == nil {
            customBlockTextures[type] = [:]
        }
        customBlockTextures[type]?[face] = image
        saveCustomTextureToDisk(type: type, face: face, image: image)

        // For blocks that use one texture for all faces, mirror to top & bottom
        if type.editableFaces.count == 1 && face == .side {
            customBlockTextures[type]?[.top] = image
            customBlockTextures[type]?[.bottom] = image
            saveCustomTextureToDisk(type: type, face: .top, image: image)
            saveCustomTextureToDisk(type: type, face: .bottom, image: image)
        }
        materialCache.removeAll()
        iconCache.removeAll()
    }

    static func customTexture(for type: BlockType, face: BlockFace = .side) -> UIImage? {
        customBlockTextures[type]?[face]
    }

    static func clearCustomTexture(for type: BlockType, face: BlockFace? = nil) {
        if let face = face {
            customBlockTextures[type]?.removeValue(forKey: face)
            removeCustomTextureFromDisk(type: type, face: face)
        } else {
            customBlockTextures.removeValue(forKey: type)
            removeCustomTextureFromDisk(type: type, face: nil)
        }
        materialCache.removeAll()
        iconCache.removeAll()
    }

    static func textureImage(for type: BlockType, face: BlockFace, pack: TexturePack = .classic) -> UIImage {
        if let custom = customBlockTextures[type]?[face] {
            return custom
        }
        // Fallback for uniform blocks if only .side was saved
        if let customSide = customBlockTextures[type]?[.side], type != .woodLog && type != .grass {
            return customSide
        }
        return generateTexture(for: type, face: face, pack: pack)
    }

    static func baseTextureImage(for type: BlockType, face: BlockFace = .side, pack: TexturePack = .classic) -> UIImage {
        return textureImage(for: type, face: face, pack: pack)
    }

    func materials(for pack: TexturePack) -> [SCNMaterial] {
        let key = TextureCacheKey(block: self, pack: pack)
        if let cached = Self.materialCache[key] {
            return cached
        }

        let mats: [SCNMaterial]
        if self == .woodLog {
            let sideImg = Self.textureImage(for: .woodLog, face: .side, pack: pack)
            let topImg = Self.textureImage(for: .woodLog, face: .top, pack: pack)
            let sideMat = Self.makeMaterial(image: sideImg, type: self)
            let topMat = Self.makeMaterial(image: topImg, type: self)
            // SCNBox faces order: 0: +Z, 1: +X, 2: -Z, 3: -X, 4: +Y (top), 5: -Y (bottom)
            mats = [sideMat, sideMat, sideMat, sideMat, topMat, topMat]
        } else if self == .grass {
            let sideImg = Self.textureImage(for: .grass, face: .side, pack: pack)
            let topImg = Self.textureImage(for: .grass, face: .top, pack: pack)
            let botImg = Self.customBlockTextures[.grass]?[.bottom] ?? (Self.customBlockTextures[.dirt]?[.side] ?? Self.generateTexture(for: .dirt, face: .side, pack: pack))
            let sideMat = Self.makeMaterial(image: sideImg, type: self)
            let topMat = Self.makeMaterial(image: topImg, type: self)
            let bottomMat = Self.makeMaterial(image: botImg, type: self)
            mats = [sideMat, sideMat, sideMat, sideMat, topMat, bottomMat]
        } else {
            let img = Self.textureImage(for: self, face: .side, pack: pack)
            let mat = Self.makeMaterial(image: img, type: self)
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

enum BlockFace: String, CaseIterable, Identifiable, Codable {
    case side = "side"
    case top = "top"
    case bottom = "bottom"

    var id: String { rawValue }
}
