import Foundation
import SceneKit
import SwiftUI
import Combine
import AVFoundation
import MultipeerConnectivity
import UIKit

// MARK: - Procedural Minecraft Alpha / C418-Style Ambient Background Music

final class AlphaBackgroundMusic {
    static let shared = AlphaBackgroundMusic()
    private var audioPlayer: AVAudioPlayer?
    private(set) var isPlaying: Bool = false

    private init() {}

    func startIfNeeded() {
        if let player = audioPlayer {
            if !player.isPlaying {
                configureAudioSession()
                player.play()
                isPlaying = true
            }
            return
        }

        configureAudioSession()
        let wavData = Self.generateAmbientSoundtrackWAV()
        if let player = try? AVAudioPlayer(data: wavData) {
            player.numberOfLoops = -1
            player.volume = 0.65
            player.prepareToPlay()
            player.play()
            self.audioPlayer = player
            self.isPlaying = true
        }
    }

    func setEnabled(_ enabled: Bool) {
        if enabled {
            startIfNeeded()
        } else {
            audioPlayer?.pause()
            isPlaying = false
        }
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    private static func generateAmbientSoundtrackWAV() -> Data {
        let sampleRate = 24000
        let durationSeconds = 32.0
        let totalFrames = Int(Double(sampleRate) * durationSeconds)

        var left = [Float](repeating: 0, count: totalFrames)
        var right = [Float](repeating: 0, count: totalFrames)

        struct NoteEvent {
            let startBeat: Double
            let durationBeats: Double
            let midi: Int
            let velocity: Float
            let pan: Float
            let isPad: Bool
        }

        let notes: [NoteEvent] = [
            // Warm Ambient Pad Chords
            NoteEvent(startBeat: 0.0, durationBeats: 4.2, midi: 53, velocity: 0.16, pan: -0.2, isPad: true),
            NoteEvent(startBeat: 0.0, durationBeats: 4.2, midi: 60, velocity: 0.14, pan: 0.2, isPad: true),
            NoteEvent(startBeat: 0.0, durationBeats: 4.2, midi: 64, velocity: 0.13, pan: -0.15, isPad: true),
            NoteEvent(startBeat: 4.0, durationBeats: 4.2, midi: 55, velocity: 0.16, pan: 0.2, isPad: true),
            NoteEvent(startBeat: 4.0, durationBeats: 4.2, midi: 59, velocity: 0.14, pan: -0.2, isPad: true),
            NoteEvent(startBeat: 4.0, durationBeats: 4.2, midi: 64, velocity: 0.13, pan: 0.15, isPad: true),
            NoteEvent(startBeat: 8.0, durationBeats: 4.2, midi: 52, velocity: 0.16, pan: -0.25, isPad: true),
            NoteEvent(startBeat: 8.0, durationBeats: 4.2, midi: 59, velocity: 0.14, pan: 0.2, isPad: true),
            NoteEvent(startBeat: 8.0, durationBeats: 4.2, midi: 62, velocity: 0.13, pan: -0.1, isPad: true),
            NoteEvent(startBeat: 12.0, durationBeats: 4.2, midi: 45, velocity: 0.17, pan: 0.0, isPad: true),
            NoteEvent(startBeat: 12.0, durationBeats: 4.2, midi: 55, velocity: 0.14, pan: -0.25, isPad: true),
            NoteEvent(startBeat: 12.0, durationBeats: 4.2, midi: 60, velocity: 0.14, pan: 0.25, isPad: true),
            NoteEvent(startBeat: 16.0, durationBeats: 4.2, midi: 50, velocity: 0.16, pan: -0.15, isPad: true),
            NoteEvent(startBeat: 16.0, durationBeats: 4.2, midi: 57, velocity: 0.14, pan: 0.2, isPad: true),
            NoteEvent(startBeat: 16.0, durationBeats: 4.2, midi: 60, velocity: 0.13, pan: -0.2, isPad: true),
            NoteEvent(startBeat: 20.0, durationBeats: 4.2, midi: 43, velocity: 0.16, pan: 0.0, isPad: true),
            NoteEvent(startBeat: 20.0, durationBeats: 4.2, midi: 55, velocity: 0.14, pan: 0.2, isPad: true),
            NoteEvent(startBeat: 20.0, durationBeats: 4.2, midi: 59, velocity: 0.13, pan: -0.2, isPad: true),
            NoteEvent(startBeat: 24.0, durationBeats: 4.2, midi: 48, velocity: 0.17, pan: -0.1, isPad: true),
            NoteEvent(startBeat: 24.0, durationBeats: 4.2, midi: 55, velocity: 0.14, pan: 0.2, isPad: true),
            NoteEvent(startBeat: 24.0, durationBeats: 4.2, midi: 59, velocity: 0.13, pan: -0.2, isPad: true),
            NoteEvent(startBeat: 28.0, durationBeats: 4.0, midi: 45, velocity: 0.16, pan: 0.0, isPad: true),
            NoteEvent(startBeat: 28.0, durationBeats: 4.0, midi: 52, velocity: 0.14, pan: -0.2, isPad: true),
            NoteEvent(startBeat: 28.0, durationBeats: 4.0, midi: 60, velocity: 0.13, pan: 0.2, isPad: true),

            // Soft Felt Piano Melody
            NoteEvent(startBeat: 0.0, durationBeats: 3.4, midi: 53, velocity: 0.34, pan: -0.25, isPad: false),
            NoteEvent(startBeat: 0.5, durationBeats: 2.8, midi: 60, velocity: 0.30, pan: -0.1, isPad: false),
            NoteEvent(startBeat: 1.0, durationBeats: 2.8, midi: 64, velocity: 0.38, pan: 0.15, isPad: false),
            NoteEvent(startBeat: 2.0, durationBeats: 2.5, midi: 67, velocity: 0.42, pan: 0.25, isPad: false),
            NoteEvent(startBeat: 3.0, durationBeats: 2.0, midi: 69, velocity: 0.36, pan: 0.3, isPad: false),

            NoteEvent(startBeat: 4.0, durationBeats: 3.4, midi: 55, velocity: 0.34, pan: -0.2, isPad: false),
            NoteEvent(startBeat: 4.5, durationBeats: 2.8, midi: 59, velocity: 0.30, pan: 0.0, isPad: false),
            NoteEvent(startBeat: 5.0, durationBeats: 2.8, midi: 62, velocity: 0.38, pan: 0.18, isPad: false),
            NoteEvent(startBeat: 6.0, durationBeats: 2.6, midi: 71, velocity: 0.44, pan: 0.28, isPad: false),
            NoteEvent(startBeat: 7.0, durationBeats: 2.2, midi: 67, velocity: 0.36, pan: 0.12, isPad: false),

            NoteEvent(startBeat: 8.0, durationBeats: 3.4, midi: 52, velocity: 0.34, pan: -0.25, isPad: false),
            NoteEvent(startBeat: 8.5, durationBeats: 2.8, midi: 59, velocity: 0.30, pan: -0.05, isPad: false),
            NoteEvent(startBeat: 9.0, durationBeats: 2.8, midi: 64, velocity: 0.40, pan: 0.15, isPad: false),
            NoteEvent(startBeat: 10.5, durationBeats: 2.5, midi: 67, velocity: 0.38, pan: 0.25, isPad: false),

            NoteEvent(startBeat: 12.0, durationBeats: 3.5, midi: 45, velocity: 0.36, pan: -0.28, isPad: false),
            NoteEvent(startBeat: 12.5, durationBeats: 3.0, midi: 57, velocity: 0.32, pan: -0.1, isPad: false),
            NoteEvent(startBeat: 13.0, durationBeats: 2.8, midi: 64, velocity: 0.42, pan: 0.18, isPad: false),
            NoteEvent(startBeat: 14.0, durationBeats: 2.5, midi: 62, velocity: 0.38, pan: 0.1, isPad: false),
            NoteEvent(startBeat: 15.0, durationBeats: 2.2, midi: 60, velocity: 0.36, pan: 0.05, isPad: false),

            NoteEvent(startBeat: 16.0, durationBeats: 3.4, midi: 50, velocity: 0.35, pan: -0.22, isPad: false),
            NoteEvent(startBeat: 16.5, durationBeats: 2.8, midi: 57, velocity: 0.30, pan: -0.08, isPad: false),
            NoteEvent(startBeat: 17.0, durationBeats: 2.6, midi: 69, velocity: 0.44, pan: 0.22, isPad: false),
            NoteEvent(startBeat: 18.0, durationBeats: 2.5, midi: 72, velocity: 0.46, pan: 0.32, isPad: false),
            NoteEvent(startBeat: 19.0, durationBeats: 2.2, midi: 69, velocity: 0.38, pan: 0.20, isPad: false),

            NoteEvent(startBeat: 20.0, durationBeats: 3.4, midi: 43, velocity: 0.35, pan: -0.25, isPad: false),
            NoteEvent(startBeat: 20.5, durationBeats: 2.8, midi: 55, velocity: 0.30, pan: -0.1, isPad: false),
            NoteEvent(startBeat: 21.0, durationBeats: 2.6, midi: 67, velocity: 0.42, pan: 0.18, isPad: false),
            NoteEvent(startBeat: 22.0, durationBeats: 2.4, midi: 64, velocity: 0.38, pan: 0.12, isPad: false),
            NoteEvent(startBeat: 23.0, durationBeats: 2.2, midi: 62, velocity: 0.36, pan: 0.08, isPad: false),

            NoteEvent(startBeat: 24.0, durationBeats: 3.5, midi: 48, velocity: 0.36, pan: -0.25, isPad: false),
            NoteEvent(startBeat: 24.5, durationBeats: 3.0, midi: 55, velocity: 0.32, pan: -0.08, isPad: false),
            NoteEvent(startBeat: 25.0, durationBeats: 2.8, midi: 64, velocity: 0.42, pan: 0.16, isPad: false),
            NoteEvent(startBeat: 26.0, durationBeats: 2.6, midi: 67, velocity: 0.40, pan: 0.24, isPad: false),
            NoteEvent(startBeat: 27.0, durationBeats: 2.4, midi: 72, velocity: 0.42, pan: 0.30, isPad: false),

            NoteEvent(startBeat: 28.0, durationBeats: 3.6, midi: 45, velocity: 0.34, pan: -0.20, isPad: false),
            NoteEvent(startBeat: 28.5, durationBeats: 3.2, midi: 57, velocity: 0.30, pan: 0.0, isPad: false),
            NoteEvent(startBeat: 29.0, durationBeats: 2.8, midi: 67, velocity: 0.38, pan: 0.20, isPad: false),
            NoteEvent(startBeat: 30.0, durationBeats: 2.0, midi: 64, velocity: 0.35, pan: 0.12, isPad: false)
        ]

        let twoPi = Float.pi * 2.0
        let invSampleRate = 1.0 / Float(sampleRate)

        for note in notes {
            let freq = Float(440.0 * pow(2.0, Double(note.midi - 69) / 12.0))
            let startFrame = Int(note.startBeat * Double(sampleRate))
            let noteFrames = Int(note.durationBeats * Double(sampleRate))

            let leftGain = note.velocity * sqrt(max(0.0, min(1.0, (1.0 - note.pan) * 0.5)))
            let rightGain = note.velocity * sqrt(max(0.0, min(1.0, (1.0 + note.pan) * 0.5)))

            let omega1 = twoPi * freq * invSampleRate
            let omega2 = omega1 * 2.0
            let omega3 = omega1 * 3.0

            for i in 0..<noteFrames {
                let t = Float(i) * invSampleRate
                let dur = Float(note.durationBeats)

                let env: Float
                if note.isPad {
                    let attack = min(1.0, t / 0.85)
                    let release = min(1.0, max(0.0, (dur - t) / 0.95))
                    env = attack * attack * release
                } else {
                    let attack = min(1.0, t / 0.028)
                    let decay = exp(-t * 1.35)
                    let release = min(1.0, max(0.0, (dur - t) / 0.25))
                    env = attack * decay * release
                }

                let h1 = sin(omega1 * Float(i))
                let h2 = 0.24 * sin(omega2 * Float(i)) * exp(-t * 0.9)
                let h3 = (note.isPad ? 0.05 : 0.08) * sin(omega3 * Float(i)) * exp(-t * 2.2)
                let sample = (h1 + h2 + h3) * env

                let idx = (startFrame + i) % totalFrames
                left[idx] += sample * leftGain
                right[idx] += sample * rightGain
            }
        }

        let delay1 = Int(0.31 * Double(sampleRate))
        let delay2 = Int(0.47 * Double(sampleRate))
        for pass in 0..<2 {
            let feedback: Float = (pass == 0) ? 0.26 : 0.16
            let d = (pass == 0) ? delay1 : delay2
            for i in 0..<totalFrames {
                let dst = (i + d) % totalFrames
                left[dst] += right[i] * feedback
                right[dst] += left[i] * feedback
            }
        }

        var wav = Data(capacity: 44 + totalFrames * 4)
        let dataSize = UInt32(totalFrames * 4)
        let fileSize = 36 + dataSize
        let channels: UInt16 = 2
        let bitsPerSample: UInt16 = 16
        let byteRate = UInt32(sampleRate) * UInt32(channels) * UInt32(bitsPerSample / 8)
        let blockAlign = channels * (bitsPerSample / 8)

        wav.append("RIFF".data(using: .ascii)!)
        withUnsafeBytes(of: fileSize.littleEndian) { wav.append(contentsOf: $0) }
        wav.append("WAVE".data(using: .ascii)!)
        wav.append("fmt ".data(using: .ascii)!)
        withUnsafeBytes(of: UInt32(16).littleEndian) { wav.append(contentsOf: $0) }
        withUnsafeBytes(of: UInt16(1).littleEndian) { wav.append(contentsOf: $0) }
        withUnsafeBytes(of: channels.littleEndian) { wav.append(contentsOf: $0) }
        withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { wav.append(contentsOf: $0) }
        withUnsafeBytes(of: byteRate.littleEndian) { wav.append(contentsOf: $0) }
        withUnsafeBytes(of: blockAlign.littleEndian) { wav.append(contentsOf: $0) }
        withUnsafeBytes(of: bitsPerSample.littleEndian) { wav.append(contentsOf: $0) }
        wav.append("data".data(using: .ascii)!)
        withUnsafeBytes(of: dataSize.littleEndian) { wav.append(contentsOf: $0) }

        var pcmSamples = [Int16](repeating: 0, count: totalFrames * 2)
        for i in 0..<totalFrames {
            let lClamped = max(-0.98, min(0.98, left[i] * 0.65))
            let rClamped = max(-0.98, min(0.98, right[i] * 0.65))
            pcmSamples[i * 2] = Int16(lClamped * 32767.0)
            pcmSamples[i * 2 + 1] = Int16(rClamped * 32767.0)
        }
        pcmSamples.withUnsafeBytes { wav.append(contentsOf: $0) }

        return wav
    }
}

// MARK: - Data Structures & Persistence Models

struct BlockCoord: Hashable, Equatable, Codable {
    let x: Int
    let y: Int
    let z: Int
}

struct ChunkCoord: Hashable, Equatable {
    let cx: Int
    let cz: Int
}

struct SavedBlockDelta: Codable {
    let x: Int
    let y: Int
    let z: Int
    let typeRaw: Int // -1 means broken (air), 0...11 means BlockType.rawValue
    let waterLevel: Int? // Optional flowing water height level (1..4)
    let isOpen: Bool? // Optional open/closed state for doors & trapdoors

    enum CodingKeys: String, CodingKey {
        case x, y, z, typeRaw, waterLevel, isOpen
    }

    init(x: Int, y: Int, z: Int, typeRaw: Int, waterLevel: Int? = nil, isOpen: Bool? = nil) {
        self.x = x
        self.y = y
        self.z = z
        self.typeRaw = typeRaw
        self.waterLevel = waterLevel
        self.isOpen = isOpen
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.x = (try? c.decode(Int.self, forKey: .x)) ?? 0
        self.y = (try? c.decode(Int.self, forKey: .y)) ?? 0
        self.z = (try? c.decode(Int.self, forKey: .z)) ?? 0
        self.typeRaw = (try? c.decode(Int.self, forKey: .typeRaw)) ?? -1
        self.waterLevel = try? c.decode(Int.self, forKey: .waterLevel)
        self.isOpen = try? c.decode(Bool.self, forKey: .isOpen)
    }
}

struct SavedChunkData: Codable {
    let cx: Int
    let cz: Int
    // Packed 4 ints per block: [x, y, z, encodedState]
    // where encodedState = (typeRaw & 0xFF) | ((waterLevel & 0xF) << 8) | ((isOpen ? 1 : 0) << 12)
    let packedBlocks: [Int]

    enum CodingKeys: String, CodingKey {
        case cx, cz, packedBlocks
    }

    init(cx: Int, cz: Int, packedBlocks: [Int]) {
        self.cx = cx
        self.cz = cz
        self.packedBlocks = packedBlocks
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.cx = (try? c.decode(Int.self, forKey: .cx)) ?? 0
        self.cz = (try? c.decode(Int.self, forKey: .cz)) ?? 0
        self.packedBlocks = (try? c.decode([Int].self, forKey: .packedBlocks)) ?? []
    }
}

struct SavedWorld: Identifiable, Codable {
    var id: UUID
    var name: String
    var seed: Int
    var archetypeName: String?
    var savedAt: Date
    var savedChunks: [SavedChunkData]?
    var deltas: [SavedBlockDelta]?
    var blocks: [SavedBlockDelta]?
    var inventory: [Int: Int]
    var playerX: Float
    var playerY: Float
    var playerZ: Float
    var yaw: Float
    var pitch: Float

    enum CodingKeys: String, CodingKey {
        case id, name, seed, archetypeName, savedAt, savedChunks, deltas, blocks, inventory, playerX, playerY, playerZ, yaw, pitch
    }

    init(
        id: UUID = UUID(),
        name: String,
        seed: Int,
        archetypeName: String?,
        savedAt: Date = Date(),
        savedChunks: [SavedChunkData]? = nil,
        deltas: [SavedBlockDelta]? = nil,
        blocks: [SavedBlockDelta]? = nil,
        inventory: [Int: Int] = [:],
        playerX: Float = 0,
        playerY: Float = 15,
        playerZ: Float = 12,
        yaw: Float = 0,
        pitch: Float = -0.35
    ) {
        self.id = id
        self.name = name
        self.seed = seed
        self.archetypeName = archetypeName
        self.savedAt = savedAt
        self.savedChunks = savedChunks
        self.deltas = deltas
        self.blocks = blocks
        self.inventory = inventory
        self.playerX = playerX
        self.playerY = playerY
        self.playerZ = playerZ
        self.yaw = yaw
        self.pitch = pitch
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        if let uuidStr = try? c.decode(String.self, forKey: .id), let parsed = UUID(uuidString: uuidStr) {
            self.id = parsed
        } else if let parsed = try? c.decode(UUID.self, forKey: .id) {
            self.id = parsed
        } else {
            self.id = UUID()
        }

        let decodedSeed = (try? c.decode(Int.self, forKey: .seed)) ?? Int.random(in: 1000...999_999)
        self.seed = decodedSeed

        let rawName = (try? c.decode(String.self, forKey: .name)) ?? "World #\(abs(decodedSeed) % 1000)"
        self.name = rawName

        self.archetypeName = try? c.decode(String.self, forKey: .archetypeName)

        if let date = try? c.decode(Date.self, forKey: .savedAt) {
            self.savedAt = date
        } else if let timeInterval = try? c.decode(Double.self, forKey: .savedAt) {
            self.savedAt = Date(timeIntervalSince1970: timeInterval)
        } else {
            self.savedAt = Date()
        }

        self.savedChunks = try? c.decode([SavedChunkData].self, forKey: .savedChunks)
        self.deltas = try? c.decode([SavedBlockDelta].self, forKey: .deltas)
        self.blocks = try? c.decode([SavedBlockDelta].self, forKey: .blocks)

        if let inv = try? c.decode([Int: Int].self, forKey: .inventory) {
            self.inventory = inv
        } else if let strInv = try? c.decode([String: Int].self, forKey: .inventory) {
            var converted: [Int: Int] = [:]
            for (k, v) in strInv {
                if let intK = Int(k) { converted[intK] = v }
            }
            self.inventory = converted
        } else {
            self.inventory = [:]
        }

        self.playerX = (try? c.decode(Float.self, forKey: .playerX)) ?? Float((try? c.decode(Double.self, forKey: .playerX)) ?? 0.0)
        self.playerY = (try? c.decode(Float.self, forKey: .playerY)) ?? Float((try? c.decode(Double.self, forKey: .playerY)) ?? 15.0)
        self.playerZ = (try? c.decode(Float.self, forKey: .playerZ)) ?? Float((try? c.decode(Double.self, forKey: .playerZ)) ?? 12.0)
        self.yaw = (try? c.decode(Float.self, forKey: .yaw)) ?? Float((try? c.decode(Double.self, forKey: .yaw)) ?? 0.0)
        self.pitch = (try? c.decode(Float.self, forKey: .pitch)) ?? Float((try? c.decode(Double.self, forKey: .pitch)) ?? -0.35)
    }
}

// MARK: - Customizable Control Layout Model

struct ControlLayoutConfig: Codable, Equatable {
    var joystickOffsetX: CGFloat = 0
    var joystickOffsetY: CGFloat = 0
    var hotbarOffsetX: CGFloat = 0
    var hotbarOffsetY: CGFloat = 0
    var actionOffsetX: CGFloat = 0
    var actionOffsetY: CGFloat = 0
    var verticalOffsetX: CGFloat = 0
    var verticalOffsetY: CGFloat = 0

    var joystickScale: CGFloat = 1.0
    var actionScale: CGFloat = 1.0
    var hotbarScale: CGFloat = 1.0
    var controlOpacity: Double = 0.92
    var lookSensitivity: Float = 1.0
    var swapLeftRight: Bool = false

    static let `default` = ControlLayoutConfig()
}

// MARK: - Local Multiplayer Packet Protocol

struct MultiplayerPacket: Codable {
    enum Kind: String, Codable {
        case worldSnapshot
        case requestSnapshot
        case blockUpdate
        case playerPose
    }

    var kind: Kind
    var senderName: String
    // World Snapshot fields
    var worldID: UUID?
    var worldName: String?
    var seed: Int?
    var deltas: [SavedBlockDelta]?
    // Single Block Update fields
    var blockDelta: SavedBlockDelta?
    // Player Pose fields
    var px: Float?
    var py: Float?
    var pz: Float?
    var yaw: Float?
    var pitch: Float?
}

struct DiscoveredLocalHost: Identifiable, Equatable {
    let id: String
    let peerID: MCPeerID
    let worldName: String
}

enum WorldArchetype: Int, CaseIterable {
    case alphaCliffs = 0
    case archipelago = 1
    case riverValley = 2
    case shatteredPeaks = 3
    case alphaWoodlands = 4

    var title: String {
        switch self {
        case .alphaCliffs: return "Monoliths & Cliffs"
        case .archipelago: return "Island Archipelago"
        case .riverValley: return "Winding River Canyons"
        case .shatteredPeaks: return "Shattered Mountain Peaks"
        case .alphaWoodlands: return "Rolling Woodlands"
        }
    }
}

// Seeded 2D Perlin / Gradient Noise with Domain Warping
struct SeededPerlinNoise {
    private var p: [Int] = Array(repeating: 0, count: 512)

    init(seed: Int) {
        var perm = Array(0..<256)
        var state = UInt64(bitPattern: Int64(seed == 0 ? 1337 : seed))
        for i in stride(from: 255, through: 1, by: -1) {
            state &+= 0x9E3779B97F4A7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
            z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
            z = z ^ (z >> 31)
            let j = Int(z % UInt64(i + 1))
            perm.swapAt(i, j)
        }
        for i in 0..<256 {
            p[i] = perm[i]
            p[256 + i] = perm[i]
        }
    }

    private func fade(_ t: Float) -> Float {
        return t * t * t * (t * (t * 6 - 15) + 10)
    }

    private func lerp(_ t: Float, _ a: Float, _ b: Float) -> Float {
        return a + t * (b - a)
    }

    private func grad(_ hash: Int, _ x: Float, _ y: Float) -> Float {
        let h = hash & 7
        let u = h < 4 ? x : y
        let v = h < 4 ? y : x
        return ((h & 1) != 0 ? -u : u) + ((h & 2) != 0 ? -2.0 * v : 2.0 * v)
    }

    func noise(_ x: Float, _ y: Float) -> Float {
        let xi = Int(floor(x)) & 255
        let yi = Int(floor(y)) & 255
        let xf = x - floor(x)
        let yf = y - floor(y)

        let u = fade(xf)
        let v = fade(yf)

        let aa = p[p[xi] + yi]
        let ab = p[p[xi] + yi + 1]
        let ba = p[p[xi + 1] + yi]
        let bb = p[p[xi + 1] + yi + 1]

        let x1 = lerp(u, grad(aa, xf, yf), grad(ba, xf - 1, yf))
        let x2 = lerp(u, grad(ab, xf, yf - 1), grad(bb, xf - 1, yf - 1))
        return lerp(v, x1, x2) * 0.5
    }

    func fbm(x: Float, y: Float, octaves: Int = 4, persistence: Float = 0.5, lacunarity: Float = 2.0) -> Float {
        var total: Float = 0
        var frequency: Float = 1.0
        var amplitude: Float = 1.0
        var maxValue: Float = 0

        for _ in 0..<octaves {
            total += noise(x * frequency, y * frequency) * amplitude
            maxValue += amplitude
            amplitude *= persistence
            frequency *= lacunarity
        }
        return total / maxValue
    }
}

// MARK: - Main VoxelWorld Engine

@MainActor
final class VoxelWorld: NSObject, ObservableObject {
    // 500 x 500 Block World Bounds (-250 ..< 250 on X and Z)
    let worldSize: Int = 500
    let halfWorld: Int = 250
    let seaLevel: Int = 4

    // Chunk streaming config (each chunk is 10x10 columns, view radius = 2 chunks around player)
    private let chunkSize: Int = 10
    private let activeChunkRadius: Int = 2

    // Current World Metadata & Saved Worlds
    @Published var currentWorldID: UUID = UUID()
    @Published var currentWorldName: String = "World"
    @Published var worldSeed: Int = Int.random(in: 1000...999_999)
    @Published var currentArchetype: WorldArchetype = .alphaCliffs
    @Published var savedWorlds: [SavedWorld] = []
    @Published var playerCoordText: String = "X: 0  Y: 14  Z: 0"
    @Published var currentFPS: Int = 60
    private var fpsFrameCounter: Int = 0
    private var fpsTimeAccumulator: Float = 0.0

    // Inventory & Hotbar state (all 12 blocks)
    @Published var selectedBlock: BlockType = .grass
    @Published var inventory: [BlockType: Int] = [
        .grass: 20,
        .dirt: 20,
        .stone: 20,
        .smoothStone: 20,
        .woodLog: 15,
        .woodPlanks: 20,
        .leaves: 15,
        .sand: 20,
        .glass: 20,
        .door: 10,
        .trapdoor: 10,
        .water: 15
    ]
    @Published var targetedBlockType: BlockType? = nil
    @Published var isTargetedBlockOpen: Bool = false
    @Published var statusToast: String = "500x500 World Ready!"
    @Published var isFlying: Bool = true
    @Published var isMusicEnabled: Bool = true

    // Customizable Control Layout State
    @Published var controlLayout: ControlLayoutConfig = .default {
        didSet {
            saveControlLayout()
        }
    }
    @Published var isEditingControls: Bool = false

    // Local Multiplayer State
    @Published var localPlayerName: String = UIDevice.current.name
    @Published var isHostingMultiplayer: Bool = true
    @Published var connectedPlayerNames: [String] = []
    @Published var discoveredHosts: [DiscoveredLocalHost] = []

    // Player 3D AABB Hitbox dimensions (relative to camera eye position)
    private let playerRadius: Float = 0.32
    private let playerFeetOffset: Float = 1.42
    private let playerHeadOffset: Float = 0.28

    // SceneKit objects
    let scene = SCNScene()
    let cameraNode = SCNNode()
    private let blocksRootNode = SCNNode()
    private let playersRootNode = SCNNode()
    private var selectionBoxNode = SCNNode()

    // Voxel storage & Chunk streaming state
    private var generatedChunks: Set<ChunkCoord> = []
    private var activeChunks: Set<ChunkCoord> = []
    private var chunkBlocks: [ChunkCoord: [BlockCoord: BlockType]] = [:]
    private var blocks: [BlockCoord: BlockType] = [:]
    private var modifiedBlocks: [BlockCoord: Int] = [:] // -1 = air, 0..11 = BlockType
    private var openToggleBlocks: Set<BlockCoord> = [] // Open doors and trapdoors
    private var blockNodes: [BlockCoord: SCNNode] = [:]
    private var sharedGeometries: [BlockType: SCNBox] = [:]
    private var waterLevelGeometries: [Int: SCNBox] = [:] // Levels 1..4 with lowering heights
    private var waterMaskedGeometries: [Int: SCNBox] = [:] // Key: (level << 6) | 6-bit face visibility mask
    private var doorClosedGeo = SCNBox()
    private var doorOpenGeo = SCNBox()
    private var trapdoorClosedGeo = SCNBox()
    private var trapdoorOpenGeo = SCNBox()
    private var lastPlayerChunk: ChunkCoord? = nil

    // Noise generators for current seed
    private var primaryNoise = SeededPerlinNoise(seed: 1)
    private var warpNoise = SeededPerlinNoise(seed: 2)
    private var ridgeNoise = SeededPerlinNoise(seed: 3)
    private var biomeNoise = SeededPerlinNoise(seed: 4)

    // Water Flow & Falling Sand Simulation Queues
    private var waterSpreadLevels: [BlockCoord: Int] = [:] // 4 = full height, 3..1 = lowering height toward lowest spot
    private var activeWaterFrontier: Set<BlockCoord> = []
    private var activeSandBlocks: Set<BlockCoord> = []
    private var waterTickAccumulator: Float = 0.0
    private var autoSaveAccumulator: Float = 0.0
    private var hasUnsavedChanges: Bool = false

    // Camera & Player state
    var playerPosition = SCNVector3(0, 15, 12)
    var yaw: Float = 0.0
    var pitch: Float = -0.35

    // Movement input state
    var moveInput: CGPoint = .zero
    var verticalInput: Float = 0.0
    private var verticalVelocity: Float = 0.0

    // Target raycast result
    private var currentHitCoord: BlockCoord? = nil
    private var currentPlaceCoord: BlockCoord? = nil

    // MultipeerConnectivity objects
    private let serviceType = "blockbuild"
    private var peerID: MCPeerID!
    private var mcSession: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private var remotePlayerNodes: [ String: SCNNode ] = [:]
    private var poseBroadcastAccumulator: Float = 0.0

    private let saveFileName = "blockbuild_saved_worlds_v2.json"
    private let controlLayoutKey = "blockbuild_control_layout_v1"

    override init() {
        super.init()
        loadControlLayout()
        setupGeometries()
        setupScene()
        loadSavedWorldsList()

        // Automatically restore the most recent saved world on launch/update so worlds are never lost!
        if let latestWorld = savedWorlds.first {
            loadSavedWorld(latestWorld)
        } else {
            // Check if any legacy save data exists before creating a brand new world
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let primaryExists = FileManager.default.fileExists(atPath: docs.appendingPathComponent("blockbuild_saved_worlds_v2.json").path)
            let backupExists = FileManager.default.fileExists(atPath: docs.appendingPathComponent("blockbuild_saved_worlds_backup.json").path)

            if !primaryExists && !backupExists {
                startNewWorld(seed: worldSeed, customName: nil)
                saveCurrentWorld(silent: true)
            } else {
                // If files existed on disk, attempt one more scan before generating a new world
                loadSavedWorldsList()
                if let recovered = savedWorlds.first {
                    loadSavedWorld(recovered)
                } else {
                    startNewWorld(seed: worldSeed, customName: nil)
                    saveCurrentWorld(silent: true)
                }
            }
        }

        AlphaBackgroundMusic.shared.startIfNeeded()
        setupMultiplayer()
        setupAppLifecycleAutoSave()
    }

    private func setupAppLifecycleAutoSave() {
        let center = NotificationCenter.default
        let saveHandler: (Notification) -> Void = { [weak self] _ in
            Task { @MainActor in
                self?.saveCurrentWorld(silent: true)
            }
        }
        center.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main, using: saveHandler)
        center.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main, using: saveHandler)
        center.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main, using: saveHandler)
    }

    // MARK: - Control Layout Persistence

    private func loadControlLayout() {
        if let data = UserDefaults.standard.data(forKey: controlLayoutKey),
           let decoded = try? JSONDecoder().decode(ControlLayoutConfig.self, from: data) {
            controlLayout = decoded
        }
    }

    private func saveControlLayout() {
        if let data = try? JSONEncoder().encode(controlLayout) {
            UserDefaults.standard.set(data, forKey: controlLayoutKey)
        }
    }

    func resetControlLayout() {
        controlLayout = .default
        statusToast = "Control layout reset to default"
    }

    // MARK: - Geometries & Lowering Water / Door / Trapdoor Shapes

    private func setupGeometries() {
        for type in BlockType.allCases {
            let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
            box.materials = type.materials
            sharedGeometries[type] = box
        }

        // Water level geometries for levels 1..4 (Heights: 0.22, 0.44, 0.66, 0.88)
        for lvl in 1...4 {
            let h = CGFloat(waterHeight(forLevel: lvl))
            let wBox = SCNBox(width: 1.0, height: h, length: 1.0, chamferRadius: 0.0)
            wBox.materials = BlockType.water.materials
            waterLevelGeometries[lvl] = wBox
        }

        // Door geometries (closed vs open)
        doorClosedGeo = SCNBox(width: 1.0, height: 1.0, length: 0.20, chamferRadius: 0.0)
        doorClosedGeo.materials = BlockType.door.materials

        doorOpenGeo = SCNBox(width: 0.20, height: 1.0, length: 1.0, chamferRadius: 0.0)
        doorOpenGeo.materials = BlockType.door.materials

        // Trapdoor geometries (closed horizontal slab vs open vertical flap)
        trapdoorClosedGeo = SCNBox(width: 1.0, height: 0.20, length: 1.0, chamferRadius: 0.0)
        trapdoorClosedGeo.materials = BlockType.trapdoor.materials

        trapdoorOpenGeo = SCNBox(width: 1.0, height: 1.0, length: 0.20, chamferRadius: 0.0)
        trapdoorOpenGeo.materials = BlockType.trapdoor.materials
    }

    private func waterHeight(forLevel level: Int) -> Float {
        switch level {
        case 4: return 0.88
        case 3: return 0.66
        case 2: return 0.44
        case 1: return 0.22
        default: return (level >= 4) ? 0.88 : 0.22
        }
    }

    private func setupScene() {
        scene.background.contents = UIColor(red: 0.60, green: 0.80, blue: 1.0, alpha: 1.0)
        scene.fogStartDistance = 20.0
        scene.fogEndDistance = 32.0
        scene.fogColor = UIColor(red: 0.65, green: 0.83, blue: 1.0, alpha: 1.0)

        let ambientNode = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 560
        ambientLight.color = UIColor(white: 0.96, alpha: 1.0)
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)

        let sunNode = SCNNode()
        let sunLight = SCNLight()
        sunLight.type = .directional
        sunLight.intensity = 880
        sunLight.color = UIColor(red: 1.0, green: 0.99, blue: 0.94, alpha: 1.0)
        sunLight.castsShadow = false
        sunNode.light = sunLight
        sunNode.eulerAngles = SCNVector3(-Float.pi / 3.0, Float.pi / 4.0, 0)
        scene.rootNode.addChildNode(sunNode)

        let camera = SCNCamera()
        camera.fieldOfView = 74
        camera.zNear = 0.1
        camera.zFar = 95.0
        cameraNode.camera = camera
        updateCameraTransform()
        scene.rootNode.addChildNode(cameraNode)

        scene.rootNode.addChildNode(blocksRootNode)
        scene.rootNode.addChildNode(playersRootNode)

        let highlightGeo = SCNBox(width: 1.015, height: 1.015, length: 1.015, chamferRadius: 0.0)
        let highlightMat = SCNMaterial()
        highlightMat.diffuse.contents = UIColor(white: 1.0, alpha: 0.18)
        highlightMat.emission.contents = UIColor(white: 1.0, alpha: 0.28)
        highlightMat.isDoubleSided = true
        highlightGeo.materials = [highlightMat]
        selectionBoxNode = SCNNode(geometry: highlightGeo)
        selectionBoxNode.isHidden = true
        scene.rootNode.addChildNode(selectionBoxNode)
    }

    func toggleMusic() {
        isMusicEnabled.toggle()
        AlphaBackgroundMusic.shared.setEnabled(isMusicEnabled)
        statusToast = isMusicEnabled ? "Music: ON" : "Music: OFF"
    }

    // MARK: - 500x500 Procedural World Generation Engine

    func regenerateNewWorld(customName: String? = nil) {
        // Save the current world before generating a new one so no progress is lost
        saveCurrentWorld(silent: true)
        let newSeed = Int.random(in: 1000...999_999)
        startNewWorld(seed: newSeed, customName: customName)
        saveCurrentWorld(silent: true)
        broadcastWorldSnapshotToPeers()
    }

    private func startNewWorld(seed: Int, customName: String?) {
        clearAllWorldState()

        currentWorldID = UUID()
        worldSeed = seed
        currentArchetype = WorldArchetype(rawValue: abs(seed) % WorldArchetype.allCases.count) ?? .alphaCliffs

        let trimmed = customName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        currentWorldName = trimmed.isEmpty ? "World #\(seed % 1000)" : trimmed

        configureNoiseGenerators(seed: seed)

        let spawnGround = surfaceHeightAt(x: 0, z: 10)
        playerPosition = SCNVector3(0, Float(max(spawnGround, seaLevel)) + 6.5, 10)
        yaw = 0.0
        pitch = -0.35

        updateStreamedChunks(force: true)
        resolveStuckPositionIfNeeded()
        updateCameraTransform()
        statusToast = "\(currentArchetype.title) (500x500)"
    }

    private func configureNoiseGenerators(seed: Int) {
        primaryNoise = SeededPerlinNoise(seed: seed)
        warpNoise = SeededPerlinNoise(seed: seed &* 1664525 &+ 1013904223)
        ridgeNoise = SeededPerlinNoise(seed: seed &* 22695477 &+ 1)
        biomeNoise = SeededPerlinNoise(seed: seed &+ 7919)
    }

    private func surfaceHeightAt(x: Int, z: Int) -> Int {
        let fx = Float(x)
        let fz = Float(z)

        let warpScale: Float = 0.025
        let wx = fx + warpNoise.noise(fx * warpScale, fz * warpScale) * 18.0
        let wz = fz + warpNoise.noise((fx + 97.0) * warpScale, (fz - 53.0) * warpScale) * 18.0

        switch currentArchetype {
        case .alphaCliffs:
            let base = primaryNoise.fbm(x: wx * 0.032, y: wz * 0.032, octaves: 4, persistence: 0.55, lacunarity: 2.1)
            let cliffSelector = biomeNoise.noise(fx * 0.04, fz * 0.04)
            let cliffBoost: Float = cliffSelector > 0.08 ? 6.5 : 0.0
            let raw = 4.8 + base * 9.5 + cliffBoost
            return max(1, min(16, Int(round(raw))))

        case .archipelago:
            let islands = primaryNoise.fbm(x: wx * 0.045, y: wz * 0.045, octaves: 4, persistence: 0.5, lacunarity: 2.2)
            let ridge = 1.0 - abs(ridgeNoise.noise(fx * 0.035, fz * 0.035))
            let raw = 3.2 + islands * 9.0 + (ridge * ridge * 3.2)
            return max(1, min(14, Int(round(raw))))

        case .riverValley:
            let hills = primaryNoise.fbm(x: wx * 0.03, y: wz * 0.03, octaves: 4)
            let riverRibbon = abs(ridgeNoise.noise(wx * 0.022, wz * 0.022))
            let riverCarve: Float = riverRibbon < 0.065 ? (0.065 - riverRibbon) * 95.0 : 0.0
            let raw = 6.2 + hills * 8.5 - riverCarve
            return max(1, min(15, Int(round(raw))))

        case .shatteredPeaks:
            let r = 1.0 - abs(ridgeNoise.noise(wx * 0.04, wz * 0.04))
            let detail = primaryNoise.fbm(x: fx * 0.06, y: fz * 0.06, octaves: 3)
            let raw = 2.5 + (r * r * r) * 13.0 + detail * 4.5
            return max(1, min(17, Int(round(raw))))

        case .alphaWoodlands:
            let rolling = primaryNoise.fbm(x: wx * 0.028, y: wz * 0.028, octaves: 4, persistence: 0.48, lacunarity: 2.0)
            let pond = biomeNoise.noise(fx * 0.05, fz * 0.05)
            let raw = 5.0 + rolling * 7.5 + pond * 2.5
            return max(1, min(13, Int(round(raw))))
        }
    }

    private func generateChunkIfNeeded(_ chunk: ChunkCoord) {
        guard !generatedChunks.contains(chunk) else { return }
        generatedChunks.insert(chunk)

        let startX = chunk.cx * chunkSize
        let startZ = chunk.cz * chunkSize
        let endX = startX + chunkSize
        let endZ = startZ + chunkSize

        guard endX > -halfWorld && startX < halfWorld && endZ > -halfWorld && startZ < halfWorld else {
            return
        }

        var localBlocks: [BlockCoord: BlockType] = [:]
        var heights: [Int: [Int: Int]] = [:]

        for x in max(-halfWorld, startX)..<min(halfWorld, endX) {
            heights[x] = [:]
            for z in max(-halfWorld, startZ)..<min(halfWorld, endZ) {
                let h = surfaceHeightAt(x: x, z: z)
                heights[x]?[z] = h

                // 1. Grass & Dirt hills + Sand beaches + Cobblestone cliffs + Smooth Stone underground strata
                for y in 0...h {
                    if y == h && (h == seaLevel || h == seaLevel - 1) {
                        localBlocks[BlockCoord(x: x, y: y, z: z)] = .sand
                    } else if y == h && h > seaLevel && h <= 11 {
                        localBlocks[BlockCoord(x: x, y: y, z: z)] = .grass
                    } else if y >= h - 2 && h > seaLevel && h <= 11 {
                        localBlocks[BlockCoord(x: x, y: y, z: z)] = .dirt
                    } else if y < h - 1 {
                        localBlocks[BlockCoord(x: x, y: y, z: z)] = .smoothStone
                    } else {
                        localBlocks[BlockCoord(x: x, y: y, z: z)] = .stone
                    }
                }

                // 2. Water filling basins up to seaLevel
                if h < seaLevel {
                    for y in (h + 1)...seaLevel {
                        localBlocks[BlockCoord(x: x, y: y, z: z)] = .water
                    }
                }
            }
        }

        // 3. Deterministic Wooden Plank Structures (with Windows, Doors & Trapdoors!)
        let chunkHash = abs((chunk.cx &* 73856093) ^ (chunk.cz &* 19349663) ^ (worldSeed &* 83492791)) % 100
        if (chunk.cx == 0 && chunk.cz == 0) || chunkHash < 14 {
            let midX = startX + chunkSize / 2
            let midZ = startZ + chunkSize / 2
            if midX >= -halfWorld + 3 && midX < halfWorld - 3 && midZ >= -halfWorld + 3 && midZ < halfWorld - 3 {
                let baseH = max(heights[midX]?[midZ] ?? seaLevel, seaLevel) + 1
                if chunkHash % 2 == 0 {
                    // Wooden Plank Pier / Bridge segment
                    for dx in -3...3 {
                        for dz in -1...1 {
                            localBlocks[BlockCoord(x: midX + dx, y: baseH, z: midZ + dz)] = .woodPlanks
                        }
                    }
                    for dy in (baseH - 2)...(baseH + 1) where dy > 0 {
                        localBlocks[BlockCoord(x: midX - 3, y: dy, z: midZ - 1)] = .woodLog
                        localBlocks[BlockCoord(x: midX + 3, y: dy, z: midZ + 1)] = .woodLog
                    }
                } else {
                    // Alpha Wooden Cabin with Glass Windows, Door & Roof Trapdoor
                    for dx in -2...2 {
                        for dz in -2...2 {
                            localBlocks[BlockCoord(x: midX + dx, y: baseH, z: midZ + dz)] = .woodPlanks
                            if abs(dx) == 2 && abs(dz) == 2 {
                                for wy in (baseH + 1)...(baseH + 3) {
                                    localBlocks[BlockCoord(x: midX + dx, y: wy, z: midZ + dz)] = .woodLog
                                }
                            } else if abs(dx) == 2 || abs(dz) == 2 {
                                // Front doorway at (dx == 0, dz == 2)
                                if dx == 0 && dz == 2 {
                                    localBlocks[BlockCoord(x: midX, y: baseH + 1, z: midZ + 2)] = .door
                                    localBlocks[BlockCoord(x: midX, y: baseH + 2, z: midZ + 2)] = .door
                                    localBlocks[BlockCoord(x: midX, y: baseH + 3, z: midZ + 2)] = .woodPlanks
                                } else {
                                    localBlocks[BlockCoord(x: midX + dx, y: baseH + 1, z: midZ + dz)] = .woodPlanks
                                    localBlocks[BlockCoord(x: midX + dx, y: baseH + 2, z: midZ + dz)] = (dx == 0 || dz == 0) ? .glass : .woodPlanks
                                    localBlocks[BlockCoord(x: midX + dx, y: baseH + 3, z: midZ + dz)] = .woodPlanks
                                }
                            }
                            if abs(dx) <= 1 && abs(dz) <= 1 {
                                localBlocks[BlockCoord(x: midX + dx, y: baseH + 4, z: midZ + dz)] = (dx == 0 && dz == 0) ? .trapdoor : .woodPlanks
                            }
                        }
                    }
                }
            }
        }

        // 4. Deterministic Alpha Trees
        for x in max(-halfWorld + 2, startX + 2)..<min(halfWorld - 2, endX - 2) {
            for z in max(-halfWorld + 2, startZ + 2)..<min(halfWorld - 2, endZ - 2) {
                guard let h = heights[x]?[z], h > seaLevel && h < 14 else { continue }
                if localBlocks[BlockCoord(x: x, y: h + 1, z: z)] != nil { continue }

                let colHash = abs((x &* 73856093) ^ (z &* 19349663) ^ (worldSeed &* 83492791)) % 100
                let forest = biomeNoise.noise(Float(x) * 0.06, Float(z) * 0.06)
                let treeChance = (currentArchetype == .alphaWoodlands) ? 11 : (forest > 0.0 ? 8 : 4)

                if colHash < treeChance && (x % 3 == 0) && (z % 3 == 0) {
                    let treeH = 4 + (colHash % 2)
                    let topY = h + treeH
                    for ly in (topY - 1)...(topY + 1) {
                        let rad = (ly == topY + 1) ? 1 : 2
                        for lx in (x - rad)...(x + rad) {
                            for lz in (z - rad)...(z + rad) {
                                if rad == 2 && abs(lx - x) == 2 && abs(lz - z) == 2 { continue }
                                let leafCoord = BlockCoord(x: lx, y: ly, z: lz)
                                if localBlocks[leafCoord] == nil {
                                    localBlocks[leafCoord] = .leaves
                                }
                            }
                        }
                    }
                    for ty in (h + 1)...topY {
                        localBlocks[BlockCoord(x: x, y: ty, z: z)] = .woodLog
                    }
                }
            }
        }

        // Apply any player/water delta modifications that belong to this chunk
        for (coord, rawVal) in modifiedBlocks {
            if chunkForBlock(coord) == chunk {
                if rawVal < 0 {
                    localBlocks.removeValue(forKey: coord)
                } else if let bType = BlockType(rawValue: rawVal) {
                    localBlocks[coord] = bType
                }
            }
        }

        chunkBlocks[chunk] = localBlocks
        for (coord, type) in localBlocks {
            blocks[coord] = type
        }
    }

    private func chunkForBlock(_ coord: BlockCoord) -> ChunkCoord {
        let cx = Int(floor(Float(coord.x) / Float(chunkSize)))
        let cz = Int(floor(Float(coord.z) / Float(chunkSize)))
        return ChunkCoord(cx: cx, cz: cz)
    }

    private func updateStreamedChunks(force: Bool = false) {
        let playerChunk = ChunkCoord(
            cx: Int(floor(playerPosition.x / Float(chunkSize))),
            cz: Int(floor(playerPosition.z / Float(chunkSize)))
        )

        if !force, playerChunk == lastPlayerChunk {
            return
        }
        lastPlayerChunk = playerChunk

        var desiredChunks: Set<ChunkCoord> = []
        for dx in -activeChunkRadius...activeChunkRadius {
            for dz in -activeChunkRadius...activeChunkRadius {
                let c = ChunkCoord(cx: playerChunk.cx + dx, cz: playerChunk.cz + dz)
                if c.cx * chunkSize < halfWorld && (c.cx + 1) * chunkSize > -halfWorld &&
                   c.cz * chunkSize < halfWorld && (c.cz + 1) * chunkSize > -halfWorld {
                    desiredChunks.insert(c)
                }
            }
        }

        let chunksToUnload = activeChunks.subtracting(desiredChunks)
        for c in chunksToUnload {
            if let cBlocks = chunkBlocks[c] {
                for coord in cBlocks.keys {
                    if let node = blockNodes.removeValue(forKey: coord) {
                        node.removeFromParentNode()
                    }
                }
            }
            activeChunks.remove(c)
        }

        let chunksToLoad = desiredChunks.subtracting(activeChunks)
        var generatedAnyNewChunk = false
        for c in chunksToLoad {
            if !generatedChunks.contains(c) {
                generatedAnyNewChunk = true
            }
            generateChunkIfNeeded(c)
        }
        if generatedAnyNewChunk {
            hasUnsavedChanges = true
        }

        for c in chunksToLoad {
            activeChunks.insert(c)
            if let cBlocks = chunkBlocks[c] {
                for (coord, type) in cBlocks {
                    if isBlockExposed(coord) && blockNodes[coord] == nil {
                        spawnNode(for: coord, type: type)
                    }
                }
            }
        }

        // Refresh existing water nodes when new chunks stream in so chunk borders never show internal water seams
        if !chunksToLoad.isEmpty {
            for (coord, type) in blocks where type == .water && blockNodes[coord] != nil {
                if isBlockExposed(coord) {
                    if let node = blockNodes[coord] {
                        configureNode(node, for: coord, type: .water)
                    }
                } else if let node = blockNodes.removeValue(forKey: coord) {
                    node.removeFromParentNode()
                }
            }
        }
    }

    // MARK: - Slope-Seeking Lowering Water & Falling Sand Physics

    private func triggerWaterFlow(at coord: BlockCoord, initialLevel: Int) {
        waterSpreadLevels[coord] = max(waterSpreadLevels[coord] ?? 0, initialLevel)
        activeWaterFrontier.insert(coord)
    }

    private func triggerAdjacentPhysicsWakeup(around coord: BlockCoord) {
        let neighbors = [
            BlockCoord(x: coord.x, y: coord.y + 1, z: coord.z),
            BlockCoord(x: coord.x + 1, y: coord.y, z: coord.z),
            BlockCoord(x: coord.x - 1, y: coord.y, z: coord.z),
            BlockCoord(x: coord.x, y: coord.y, z: coord.z + 1),
            BlockCoord(x: coord.x, y: coord.y, z: coord.z - 1)
        ]
        for n in neighbors {
            if blocks[n] == .water {
                let lvl = waterSpreadLevels[n] ?? 4
                waterSpreadLevels[n] = lvl
                activeWaterFrontier.insert(n)
            } else if blocks[n] == .sand {
                activeSandBlocks.insert(n)
            }
        }
    }

    /// Finds the cardinal neighbor coordinates that lead via the shortest path to a lower drop-off within 4 steps.
    private func bestFlowNeighborsTowardLowestSpot(from start: BlockCoord) -> [BlockCoord] {
        let dirs = [
            (dx: 1, dz: 0),
            (dx: -1, dz: 0),
            (dx: 0, dz: 1),
            (dx: 0, dz: -1)
        ]

        var validNeighbors: [(coord: BlockCoord, distToDrop: Int)] = []

        for d in dirs {
            let first = BlockCoord(x: start.x + d.dx, y: start.y, z: start.z + d.dz)
            guard first.x >= -halfWorld && first.x < halfWorld &&
                  first.z >= -halfWorld && first.z < halfWorld else { continue }

            // Can water enter `first`?
            if let existing = blocks[first], existing != .water {
                continue
            }

            // BFS up to distance 4 to find shortest path to a drop-off (where y - 1 is empty or water)
            var queue: [(BlockCoord, Int)] = [(first, 1)]
            var visited: Set<BlockCoord> = [start, first]
            var foundDropDist = 999

            while !queue.isEmpty {
                let (curr, dist) = queue.removeFirst()
                let belowCurr = BlockCoord(x: curr.x, y: curr.y - 1, z: curr.z)
                if curr.y > 0 && (blocks[belowCurr] == nil || blocks[belowCurr] == .water) {
                    foundDropDist = dist
                    break
                }
                if dist < 4 {
                    for nd in dirs {
                        let next = BlockCoord(x: curr.x + nd.dx, y: curr.y, z: curr.z + nd.dz)
                        if !visited.contains(next),
                           next.x >= -halfWorld && next.x < halfWorld &&
                           next.z >= -halfWorld && next.z < halfWorld {
                            if let b = blocks[next], b != .water {
                                continue
                            }
                            visited.insert(next)
                            queue.append((next, dist + 1))
                        }
                    }
                }
            }

            validNeighbors.append((first, foundDropDist))
        }

        guard let minDist = validNeighbors.map({ $0.distToDrop }).min() else {
            return []
        }
        // If there is a nearby drop-off (minDist <= 4), flow exclusively toward the lowest spot(s)!
        // Otherwise spread evenly across flat ground while lowering water height.
        return validNeighbors.filter { $0.distToDrop == minDist }.map { $0.coord }
    }

    private func stepWaterAndSandPhysics() {
        // 1. Step Falling Sand blocks first
        if !activeSandBlocks.isEmpty {
            let sandBatch = activeSandBlocks
            activeSandBlocks.removeAll()
            for coord in sandBatch {
                guard blocks[coord] == .sand, coord.y > 0 else { continue }
                let below = BlockCoord(x: coord.x, y: coord.y - 1, z: coord.z)
                if blocks[below] == nil || blocks[below] == .water {
                    // Move sand down 1 block
                    blocks.removeValue(forKey: coord)
                    chunkBlocks[chunkForBlock(coord)]?.removeValue(forKey: coord)
                    modifiedBlocks[coord] = -1
                    waterSpreadLevels.removeValue(forKey: coord)

                    blocks[below] = .sand
                    chunkBlocks[chunkForBlock(below), default: [:]][below] = .sand
                    modifiedBlocks[below] = BlockType.sand.rawValue
                    waterSpreadLevels.removeValue(forKey: below)

                    updateVisibilityAround(coord)
                    updateVisibilityAround(below)
                    activeSandBlocks.insert(below)
                    triggerAdjacentPhysicsWakeup(around: coord)
                }
            }
        }

        // 2. Step Lowering Water Flow toward lowest spot
        guard !activeWaterFrontier.isEmpty else { return }

        let currentBatch = activeWaterFrontier
        activeWaterFrontier.removeAll()

        for coord in currentBatch {
            guard blocks[coord] == .water else { continue }
            let above = BlockCoord(x: coord.x, y: coord.y + 1, z: coord.z)
            let level = (blocks[above] == .water) ? 4 : (waterSpreadLevels[coord] ?? 4)

            // Flow straight down if space below is empty (or lower water) and above bedrock y=0
            let below = BlockCoord(x: coord.x, y: coord.y - 1, z: coord.z)
            if coord.y > 0 {
                if blocks[below] == nil {
                    placeFlowingWaterBlock(at: below, level: 4)
                    continue
                } else if blocks[below] == .water {
                    if (waterSpreadLevels[below] ?? 4) < 4 {
                        placeFlowingWaterBlock(at: below, level: 4)
                    }
                    continue
                }
            }

            // Resting on ground: flow level-by-level (4 -> 3 -> 2 -> 1) toward lowest spot
            guard level > 1 else { continue }
            let targets = bestFlowNeighborsTowardLowestSpot(from: coord)
            for hCoord in targets {
                let hBelow = BlockCoord(x: hCoord.x, y: hCoord.y - 1, z: hCoord.z)
                let hasOpenDropBelow = (hCoord.y > 0 && (blocks[hBelow] == nil || blocks[hBelow] == .water))
                let targetLevel = hasOpenDropBelow ? 4 : (level - 1)

                if blocks[hCoord] == nil {
                    placeFlowingWaterBlock(at: hCoord, level: targetLevel)
                } else if blocks[hCoord] == .water {
                    let currentLvl = waterSpreadLevels[hCoord] ?? 4
                    if currentLvl < targetLevel {
                        placeFlowingWaterBlock(at: hCoord, level: targetLevel)
                    }
                }
            }
        }
    }

    private func placeFlowingWaterBlock(at coord: BlockCoord, level: Int) {
        blocks[coord] = .water
        let chunk = chunkForBlock(coord)
        chunkBlocks[chunk, default: [:]][coord] = .water
        modifiedBlocks[coord] = BlockType.water.rawValue
        waterSpreadLevels[coord] = level
        activeWaterFrontier.insert(coord)
        updateVisibilityAround(coord)
        hasUnsavedChanges = true
    }

    // MARK: - Saving & Loading Whole Worlds (Auto-Saves & Restores Old Worlds Across Every Update)

    private var saveFileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("blockbuild_saved_worlds_v2.json")
    }

    private var backupFileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("blockbuild_saved_worlds_backup.json")
    }

    private static func cleanWorldName(_ raw: String, seed: Int) -> String {
        let cleaned = raw
            .replacingOccurrences(of: "Alpha World", with: "World")
            .replacingOccurrences(of: "Alpha #", with: "World #")
            .replacingOccurrences(of: "Alpha ", with: "")
            .replacingOccurrences(of: "alpha ", with: "")
            .replacingOccurrences(of: "Alpha", with: "World")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? "World #\(seed % 1000)" : cleaned
    }

    func loadSavedWorldsList() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var allDiscoveredWorlds: [UUID: SavedWorld] = [:]

        // 1. Scan all primary and legacy save files across all past updates
        let candidateFileNames = [
            "blockbuild_saved_worlds_v2.json",
            "blockbuild_saved_worlds_backup.json",
            "blockbuild_saved_worlds_v1.json",
            "blockbuild_saved_worlds.json",
            "saved_worlds.json"
        ]

        for fileName in candidateFileNames {
            let fileURL = docs.appendingPathComponent(fileName)
            guard let data = try? Data(contentsOf: fileURL), !data.isEmpty else { continue }

            if let list = try? JSONDecoder().decode([SavedWorld].self, from: data) {
                for w in list {
                    if let existing = allDiscoveredWorlds[w.id] {
                        if w.savedAt >= existing.savedAt {
                            allDiscoveredWorlds[w.id] = w
                        }
                    } else {
                        allDiscoveredWorlds[w.id] = w
                    }
                }
            } else if let single = try? JSONDecoder().decode(SavedWorld.self, from: data) {
                if let existing = allDiscoveredWorlds[single.id] {
                    if single.savedAt >= existing.savedAt {
                        allDiscoveredWorlds[single.id] = single
                    }
                } else {
                    allDiscoveredWorlds[single.id] = single
                }
            }
        }

        // 2. Also check UserDefaults backup mirrors across past updates
        let candidateUDKeys = [
            "blockbuild_saved_worlds_v2",
            "blockbuild_saved_worlds",
            "saved_worlds",
            "saved_worlds_v1"
        ]
        for key in candidateUDKeys {
            guard let data = UserDefaults.standard.data(forKey: key), !data.isEmpty else { continue }
            if let list = try? JSONDecoder().decode([SavedWorld].self, from: data) {
                for w in list {
                    if let existing = allDiscoveredWorlds[w.id] {
                        if w.savedAt >= existing.savedAt {
                            allDiscoveredWorlds[w.id] = w
                        }
                    } else {
                        allDiscoveredWorlds[w.id] = w
                    }
                }
            }
        }

        // 3. Sanitize names and clean any "Alpha" out
        let sanitized = allDiscoveredWorlds.values.map { world -> SavedWorld in
            var copy = world
            let clean = Self.cleanWorldName(world.name, seed: world.seed)
            copy.name = clean
            if let arch = world.archetypeName, arch.contains("Alpha") {
                copy.archetypeName = arch.replacingOccurrences(of: "Alpha ", with: "").replacingOccurrences(of: "Alpha", with: "")
            }
            return copy
        }

        savedWorlds = sanitized.sorted { $0.savedAt > $1.savedAt }

        if !savedWorlds.isEmpty {
            persistSavedWorlds()
        }
    }

    func saveCurrentWorld(customName: String? = nil, silent: Bool = false) {
        if let name = customName?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            currentWorldName = Self.cleanWorldName(name, seed: worldSeed)
        } else {
            currentWorldName = Self.cleanWorldName(currentWorldName, seed: worldSeed)
        }

        // Serialize all blocks across every generated chunk so the whole world is saved across app updates!
        var serializedChunks: [SavedChunkData] = []
        serializedChunks.reserveCapacity(chunkBlocks.count)
        for (chunk, localBlocks) in chunkBlocks {
            var packed: [Int] = []
            packed.reserveCapacity(localBlocks.count * 4)
            for (coord, type) in localBlocks {
                let wLvl = (type == .water) ? (waterSpreadLevels[coord] ?? 4) : 0
                let openBit = openToggleBlocks.contains(coord) ? 1 : 0
                let encodedState = (type.rawValue & 0xFF) | ((wLvl & 0xF) << 8) | (openBit << 12)
                packed.append(coord.x)
                packed.append(coord.y)
                packed.append(coord.z)
                packed.append(encodedState)
            }
            serializedChunks.append(SavedChunkData(cx: chunk.cx, cz: chunk.cz, packedBlocks: packed))
        }

        let serializedDeltas = modifiedBlocks.map { (coord, rawVal) in
            SavedBlockDelta(
                x: coord.x,
                y: coord.y,
                z: coord.z,
                typeRaw: rawVal,
                waterLevel: (rawVal == BlockType.water.rawValue) ? (waterSpreadLevels[coord] ?? 4) : nil,
                isOpen: openToggleBlocks.contains(coord) ? true : nil
            )
        }

        var serializedInventory: [Int: Int] = [:]
        for (type, count) in inventory {
            serializedInventory[type.rawValue] = count
        }

        let snapshot = SavedWorld(
            id: currentWorldID,
            name: currentWorldName,
            seed: worldSeed,
            archetypeName: currentArchetype.title,
            savedAt: Date(),
            savedChunks: serializedChunks,
            deltas: serializedDeltas,
            blocks: nil,
            inventory: serializedInventory,
            playerX: playerPosition.x,
            playerY: playerPosition.y,
            playerZ: playerPosition.z,
            yaw: yaw,
            pitch: pitch
        )

        if let idx = savedWorlds.firstIndex(where: { $0.id == currentWorldID }) {
            savedWorlds[idx] = snapshot
        } else {
            savedWorlds.insert(snapshot, at: 0)
        }

        savedWorlds.sort { $0.savedAt > $1.savedAt }
        persistSavedWorlds()
        hasUnsavedChanges = false
        if !silent {
            statusToast = "Saved '\(currentWorldName)'!"
        }
    }

    func loadSavedWorld(_ saved: SavedWorld) {
        clearAllWorldState()

        currentWorldID = saved.id
        currentWorldName = Self.cleanWorldName(saved.name, seed: saved.seed)
        worldSeed = saved.seed
        currentArchetype = WorldArchetype(rawValue: abs(saved.seed) % WorldArchetype.allCases.count) ?? .alphaCliffs
        configureNoiseGenerators(seed: saved.seed)

        // 1. Restore full saved chunks (the whole world block-for-block) if present
        if let savedChunks = saved.savedChunks {
            for chunkData in savedChunks {
                let chunk = ChunkCoord(cx: chunkData.cx, cz: chunkData.cz)
                generatedChunks.insert(chunk)
                var localBlocks: [BlockCoord: BlockType] = [:]
                let packed = chunkData.packedBlocks
                var i = 0
                while i + 3 < packed.count {
                    let x = packed[i]
                    let y = packed[i + 1]
                    let z = packed[i + 2]
                    let encoded = packed[i + 3]
                    i += 4

                    let typeRaw = encoded & 0xFF
                    let wLvl = (encoded >> 8) & 0xF
                    let isOpen = ((encoded >> 12) & 0x1) == 1

                    if let bType = BlockType(rawValue: typeRaw) {
                        let coord = BlockCoord(x: x, y: y, z: z)
                        localBlocks[coord] = bType
                        blocks[coord] = bType
                        if bType == .water {
                            waterSpreadLevels[coord] = (wLvl > 0) ? wLvl : 4
                        }
                        if isOpen {
                            openToggleBlocks.insert(coord)
                        }
                    }
                }
                chunkBlocks[chunk] = localBlocks
            }
        }

        // 2. Restore deltas as well so modifications in any chunk are tracked
        let deltasToRestore = saved.deltas ?? saved.blocks ?? []
        for d in deltasToRestore {
            let coord = BlockCoord(x: d.x, y: d.y, z: d.z)
            modifiedBlocks[coord] = d.typeRaw
            if d.typeRaw == BlockType.water.rawValue {
                waterSpreadLevels[coord] = d.waterLevel ?? 4
            }
            if d.isOpen == true {
                openToggleBlocks.insert(coord)
            }
            let chunk = chunkForBlock(coord)
            if generatedChunks.contains(chunk) {
                if d.typeRaw < 0 {
                    blocks.removeValue(forKey: coord)
                    chunkBlocks[chunk]?.removeValue(forKey: coord)
                } else if let bType = BlockType(rawValue: d.typeRaw) {
                    blocks[coord] = bType
                    chunkBlocks[chunk, default: [:]][coord] = bType
                }
            }
        }

        var restoredInv: [BlockType: Int] = [:]
        for type in BlockType.allCases {
            // Preserve saved counts and give 20 of any newly introduced block types on upgrade
            restoredInv[type] = saved.inventory[type.rawValue] ?? 20
        }
        inventory = restoredInv

        playerPosition = SCNVector3(saved.playerX, saved.playerY, saved.playerZ)
        yaw = saved.yaw
        pitch = saved.pitch

        updateStreamedChunks(force: true)
        resolveStuckPositionIfNeeded()
        updateCameraTransform()
        updateCrosshairTarget()

        // If this world was saved by an older version before full-world chunk persistence, upgrade its save immediately
        if saved.savedChunks == nil || saved.name != currentWorldName {
            saveCurrentWorld(silent: true)
        }

        statusToast = "Loaded '\(currentWorldName)'"
    }

    func deleteSavedWorld(_ saved: SavedWorld) {
        savedWorlds.removeAll { $0.id == saved.id }
        persistSavedWorlds()
        statusToast = "Deleted '\(saved.name)'"
    }

    private func persistSavedWorlds() {
        guard !savedWorlds.isEmpty else { return }
        guard let data = try? JSONEncoder().encode(savedWorlds) else { return }

        // Primary file
        try? data.write(to: saveFileURL, options: .atomic)
        // Redundant backup file so updates can never lose worlds
        try? data.write(to: backupFileURL, options: .atomic)
        // Redundant UserDefaults mirror
        UserDefaults.standard.set(data, forKey: "blockbuild_saved_worlds_v2")
    }

    // MARK: - Scene Node Management (Seamless Water Culling & Open/Closed Doors/Trapdoors)

    private func clearAllWorldState() {
        for (_, node) in blockNodes {
            node.removeFromParentNode()
        }
        blockNodes.removeAll()
        blocks.removeAll()
        chunkBlocks.removeAll()
        generatedChunks.removeAll()
        activeChunks.removeAll()
        modifiedBlocks.removeAll()
        openToggleBlocks.removeAll()
        waterSpreadLevels.removeAll()
        activeWaterFrontier.removeAll()
        activeSandBlocks.removeAll()
        lastPlayerChunk = nil
    }

    /// Computes a 6-bit face visibility mask for a water block at `coord` in SCNBox material order:
    /// Bit 0: Front (+Z), Bit 1: Right (+X), Bit 2: Back (-Z), Bit 3: Left (-X), Bit 4: Top (+Y), Bit 5: Bottom (-Y).
    /// Bridges the vertical step face between adjacent stepping water levels so there are zero clear holes/gaps,
    /// while hiding interior faces between adjacent water blocks of equal/greater height.
    private func waterFaceMask(at coord: BlockCoord) -> Int {
        var mask = 0

        let aboveCoord = BlockCoord(x: coord.x, y: coord.y + 1, z: coord.z)
        let aboveHasWater = (blocks[aboveCoord] == .water)
        let myLevel = aboveHasWater ? 4 : (waterSpreadLevels[coord] ?? 4)

        // Top (+Y, bit 4): visible only when there is no water directly above
        if !aboveHasWater {
            mask |= (1 << 4)
        }

        // Bottom (-Y, bit 5): visible only if air is directly below (never draw against seabed or water below)
        let bottomCoord = BlockCoord(x: coord.x, y: coord.y - 1, z: coord.z)
        if blocks[bottomCoord] == nil {
            mask |= (1 << 5)
        }

        // Side faces: Front (+Z, bit 0), Right (+X, bit 1), Back (-Z, bit 2), Left (-X, bit 3)
        let sideChecks: [(BlockCoord, Int)] = [
            (BlockCoord(x: coord.x, y: coord.y, z: coord.z + 1), 0),
            (BlockCoord(x: coord.x + 1, y: coord.y, z: coord.z), 1),
            (BlockCoord(x: coord.x, y: coord.y, z: coord.z - 1), 2),
            (BlockCoord(x: coord.x - 1, y: coord.y, z: coord.z), 3)
        ]

        for (nCoord, bit) in sideChecks {
            if let neighborType = blocks[nCoord] {
                if neighborType == .water {
                    // Check neighbor's effective water height level
                    let nAboveWater = (blocks[BlockCoord(x: nCoord.x, y: nCoord.y + 1, z: nCoord.z)] == .water)
                    let nLevel = nAboveWater ? 4 : (waterSpreadLevels[nCoord] ?? 4)

                    // If my water level is taller than neighbor's water level,
                    // render the side face to cleanly bridge the step with NO clear see-through gap!
                    if myLevel > nLevel {
                        mask |= (1 << bit)
                    }
                    // If myLevel <= nLevel, neighbor water covers or matches our water side, so hide face to eliminate seams
                } else if neighborType.isTransparent {
                    // Neighbor is glass, door, or trapdoor: show water side face
                    mask |= (1 << bit)
                }
                // Neighbor is opaque solid block (grass, dirt, stone, sand, etc.): hide side face to prevent Z-fighting
            } else {
                // Neighbor is air: show water side face (e.g. edge of stream or waterfall)
                mask |= (1 << bit)
            }
        }

        return mask
    }

    private func maskedWaterGeometry(level: Int, faceMask: Int) -> SCNBox {
        let clampedLevel = max(1, min(4, level))
        let cacheKey = (clampedLevel << 6) | (faceMask & 0x3F)
        if let cached = waterMaskedGeometries[cacheKey] {
            return cached
        }

        let h = CGFloat(waterHeight(forLevel: clampedLevel))
        let box = SCNBox(width: 1.0, height: h, length: 1.0, chamferRadius: 0.0)
        let visibleMat = BlockType.water.materials.first!
        let hiddenMat = BlockType.invisibleMaterial

        var mats: [SCNMaterial] = []
        mats.reserveCapacity(6)
        for bit in 0..<6 {
            if (faceMask & (1 << bit)) != 0 {
                mats.append(visibleMat)
            } else {
                mats.append(hiddenMat)
            }
        }
        box.materials = mats
        waterMaskedGeometries[cacheKey] = box
        return box
    }

    private func isBlockExposed(_ coord: BlockCoord) -> Bool {
        guard let myType = blocks[coord] else { return false }
        if myType == .water {
            return waterFaceMask(at: coord) != 0
        }
        if myType.isTransparent {
            return true
        }
        let neighbors = [
            BlockCoord(x: coord.x + 1, y: coord.y, z: coord.z),
            BlockCoord(x: coord.x - 1, y: coord.y, z: coord.z),
            BlockCoord(x: coord.x, y: coord.y + 1, z: coord.z),
            BlockCoord(x: coord.x, y: coord.y - 1, z: coord.z),
            BlockCoord(x: coord.x, y: coord.y, z: coord.z + 1),
            BlockCoord(x: coord.x, y: coord.y, z: coord.z - 1)
        ]
        for n in neighbors {
            guard let neighborType = blocks[n] else {
                return true
            }
            if neighborType.isTransparent {
                return true
            }
        }
        return false
    }

    private func configureNode(_ node: SCNNode, for coord: BlockCoord, type: BlockType) {
        let fx = Float(coord.x)
        let fy = Float(coord.y)
        let fz = Float(coord.z)

        switch type {
        case .water:
            let aboveHasWater = (blocks[BlockCoord(x: coord.x, y: coord.y + 1, z: coord.z)] == .water)
            let lvl = aboveHasWater ? 4 : (waterSpreadLevels[coord] ?? 4)
            let h = waterHeight(forLevel: lvl)
            let mask = waterFaceMask(at: coord)
            node.geometry = maskedWaterGeometry(level: lvl, faceMask: mask)
            node.position = SCNVector3(fx, fy - 0.5 + h * 0.5, fz)
            node.renderingOrder = 10
            node.categoryBitMask = 2 // Water has no solid hitbox

        case .door:
            let isOpen = openToggleBlocks.contains(coord)
            node.geometry = isOpen ? doorOpenGeo : doorClosedGeo
            if isOpen {
                node.position = SCNVector3(fx - 0.40, fy, fz)
            } else {
                node.position = SCNVector3(fx, fy, fz + 0.40)
            }
            node.renderingOrder = 2
            node.categoryBitMask = 1

        case .trapdoor:
            let isOpen = openToggleBlocks.contains(coord)
            node.geometry = isOpen ? trapdoorOpenGeo : trapdoorClosedGeo
            if isOpen {
                node.position = SCNVector3(fx, fy, fz - 0.40)
            } else {
                node.position = SCNVector3(fx, fy - 0.40, fz)
            }
            node.renderingOrder = 2
            node.categoryBitMask = 1

        default:
            node.geometry = sharedGeometries[type]
            node.position = SCNVector3(fx, fy, fz)
            node.renderingOrder = (type == .glass) ? 5 : 0
            node.categoryBitMask = type.hasHitbox ? 1 : 2
        }
    }

    private func updateVisibilityAround(_ coord: BlockCoord) {
        let affected = [
            coord,
            BlockCoord(x: coord.x + 1, y: coord.y, z: coord.z),
            BlockCoord(x: coord.x - 1, y: coord.y, z: coord.z),
            BlockCoord(x: coord.x, y: coord.y + 1, z: coord.z),
            BlockCoord(x: coord.x, y: coord.y - 1, z: coord.z),
            BlockCoord(x: coord.x, y: coord.y, z: coord.z + 1),
            BlockCoord(x: coord.x, y: coord.y, z: coord.z - 1)
        ]

        for c in affected {
            let chunk = chunkForBlock(c)
            guard activeChunks.contains(chunk) else { continue }

            if let type = blocks[c] {
                if isBlockExposed(c) {
                    if let existing = blockNodes[c] {
                        configureNode(existing, for: c, type: type)
                    } else {
                        spawnNode(for: c, type: type)
                    }
                } else if let existing = blockNodes.removeValue(forKey: c) {
                    existing.removeFromParentNode()
                }
            } else if let existing = blockNodes.removeValue(forKey: c) {
                existing.removeFromParentNode()
            }
        }
    }

    private func spawnNode(for coord: BlockCoord, type: BlockType) {
        let node = SCNNode()
        node.name = "\(coord.x),\(coord.y),\(coord.z)"
        configureNode(node, for: coord, type: type)
        blocksRootNode.addChildNode(node)
        blockNodes[coord] = node
    }

    // MARK: - Breaking, Placing & Opening/Closing Doors & Trapdoors

    func toggleTargetedDoorOrTrapdoor() {
        updateCrosshairTarget()
        guard let coord = currentHitCoord, let type = blocks[coord], type.isToggleable else {
            return
        }

        let newOpenState = !openToggleBlocks.contains(coord)
        setDoorOrTrapdoorState(at: coord, isOpen: newOpenState, broadcast: true)

        // If it's a 2-block tall wooden door, also toggle its upper/lower companion door block
        if type == .door {
            let above = BlockCoord(x: coord.x, y: coord.y + 1, z: coord.z)
            let below = BlockCoord(x: coord.x, y: coord.y - 1, z: coord.z)
            if blocks[above] == .door {
                setDoorOrTrapdoorState(at: above, isOpen: newOpenState, broadcast: true)
            }
            if blocks[below] == .door {
                setDoorOrTrapdoorState(at: below, isOpen: newOpenState, broadcast: true)
            }
        }

        statusToast = "\(newOpenState ? "Opened" : "Closed") \(type.fullName)"
        saveCurrentWorld(silent: true)
        updateCrosshairTarget()
    }

    private func setDoorOrTrapdoorState(at coord: BlockCoord, isOpen: Bool, broadcast: Bool) {
        guard let type = blocks[coord] else { return }
        if isOpen {
            openToggleBlocks.insert(coord)
        } else {
            openToggleBlocks.remove(coord)
        }
        modifiedBlocks[coord] = type.rawValue
        updateVisibilityAround(coord)
        if broadcast {
            broadcastBlockDelta(
                SavedBlockDelta(
                    x: coord.x,
                    y: coord.y,
                    z: coord.z,
                    typeRaw: type.rawValue,
                    waterLevel: nil,
                    isOpen: isOpen
                )
            )
        }
    }

    func breakTargetedBlock() {
        updateCrosshairTarget()
        guard let coord = currentHitCoord, let brokenType = blocks[coord] else {
            statusToast = "Look at a block or water to break/scoop"
            return
        }

        removeBlockInternal(at: coord, broadcast: true)

        if brokenType == .water {
            let currentCount = inventory[.water] ?? 0
            inventory[.water] = currentCount + 1
            statusToast = "+1 Water Bucket! (Total: \(currentCount + 1))"
        } else {
            // If breaking one half of a 2-block door, also remove the other half cleanly
            if brokenType == .door {
                let above = BlockCoord(x: coord.x, y: coord.y + 1, z: coord.z)
                let below = BlockCoord(x: coord.x, y: coord.y - 1, z: coord.z)
                if blocks[above] == .door {
                    removeBlockInternal(at: above, broadcast: true)
                } else if blocks[below] == .door {
                    removeBlockInternal(at: below, broadcast: true)
                }
            }

            let currentCount = inventory[brokenType] ?? 0
            inventory[brokenType] = currentCount + 1
            statusToast = "+1 \(brokenType.fullName)!"
        }

        saveCurrentWorld(silent: true)
        updateCrosshairTarget()
    }

    private func removeBlockInternal(at coord: BlockCoord, broadcast: Bool) {
        blocks.removeValue(forKey: coord)
        let chunk = chunkForBlock(coord)
        chunkBlocks[chunk]?.removeValue(forKey: coord)
        modifiedBlocks[coord] = -1
        openToggleBlocks.remove(coord)
        waterSpreadLevels.removeValue(forKey: coord)

        updateVisibilityAround(coord)
        triggerAdjacentPhysicsWakeup(around: coord)

        if broadcast {
            broadcastBlockDelta(
                SavedBlockDelta(x: coord.x, y: coord.y, z: coord.z, typeRaw: -1, waterLevel: nil, isOpen: nil)
            )
        }
    }

    func placeSelectedBlock() {
        updateCrosshairTarget()

        // If holding Water bucket:
        if selectedBlock == .water {
            let available = inventory[.water] ?? 0
            if available == 0 {
                // Empty bucket: if looking at water, scoop it up!
                if let hitCoord = currentHitCoord, blocks[hitCoord] == .water {
                    removeBlockInternal(at: hitCoord, broadcast: true)
                    inventory[.water] = 1
                    statusToast = "+1 Water Bucket! (Total: 1)"
                    saveCurrentWorld(silent: true)
                    updateCrosshairTarget()
                    return
                } else {
                    statusToast = "Empty bucket! Tap BREAK on water to fill bucket."
                    return
                }
            }
        }

        guard let placeCoord = currentPlaceCoord else {
            statusToast = "Look at a block face to place"
            return
        }

        guard placeCoord.x >= -halfWorld && placeCoord.x < halfWorld &&
              placeCoord.z >= -halfWorld && placeCoord.z < halfWorld else {
            statusToast = "Reached 500x500 world border!"
            return
        }

        if selectedBlock.hasHitbox && !selectedBlock.isToggleable &&
           doesPlayerIntersectBlock(at: placeCoord, playerPos: playerPosition) {
            statusToast = "Too close to player hitbox!"
            return
        }

        let available = inventory[selectedBlock] ?? 0
        guard available > 0 else {
            statusToast = "Out of \(selectedBlock.displayName)! Break blocks or tap +Blocks."
            return
        }

        inventory[selectedBlock] = available - 1
        placeBlockInternal(at: placeCoord, type: selectedBlock, broadcast: true)

        // When placing a Wooden Door, automatically place upper half if space above is free
        if selectedBlock == .door {
            let above = BlockCoord(x: placeCoord.x, y: placeCoord.y + 1, z: placeCoord.z)
            if blocks[above] == nil || blocks[above] == .water {
                placeBlockInternal(at: above, type: .door, broadcast: true)
            }
        }

        if selectedBlock == .water {
            statusToast = "Placed Water! (\(inventory[.water] ?? 0) left)"
        } else {
            statusToast = "Placed \(selectedBlock.fullName)"
        }

        saveCurrentWorld(silent: true)
        updateCrosshairTarget()
    }

    private func placeBlockInternal(at placeCoord: BlockCoord, type: BlockType, broadcast: Bool) {
        blocks[placeCoord] = type
        let chunk = chunkForBlock(placeCoord)
        chunkBlocks[chunk, default: [:]][placeCoord] = type
        modifiedBlocks[placeCoord] = type.rawValue
        openToggleBlocks.remove(placeCoord)

        if type == .water {
            waterSpreadLevels[placeCoord] = 4
            activeWaterFrontier.insert(placeCoord)
        } else {
            waterSpreadLevels.removeValue(forKey: placeCoord)
        }

        if type == .sand {
            activeSandBlocks.insert(placeCoord)
        }

        updateVisibilityAround(placeCoord)

        if broadcast {
            broadcastBlockDelta(
                SavedBlockDelta(
                    x: placeCoord.x,
                    y: placeCoord.y,
                    z: placeCoord.z,
                    typeRaw: type.rawValue,
                    waterLevel: (type == .water) ? 4 : nil,
                    isOpen: false
                )
            )
        }
    }

    func creativeRefill() {
        for type in BlockType.allCases {
            inventory[type] = (inventory[type] ?? 0) + 20
        }
        saveCurrentWorld(silent: true)
        statusToast = "+20 of all 10 blocks added!"
    }

    // MARK: - 3D AABB Hitbox Collision Engine (All blocks except Water & Open Doors/Trapdoors)

    private func hasSolidHitbox(at coord: BlockCoord) -> Bool {
        guard let type = blocks[coord] else { return false }
        if !type.hasHitbox { return false }
        if type.isToggleable && openToggleBlocks.contains(coord) {
            // Open doors & open trapdoors let the player pass right through!
            return false
        }
        return true
    }

    private func blockBounds(for block: BlockCoord) -> (minX: Float, maxX: Float, minY: Float, maxY: Float, minZ: Float, maxZ: Float) {
        let fx = Float(block.x)
        let fy = Float(block.y)
        let fz = Float(block.z)
        if blocks[block] == .trapdoor && !openToggleBlocks.contains(block) {
            // Closed trapdoor is a thin bottom slab (height 0.20)
            return (fx - 0.5, fx + 0.5, fy - 0.5, fy - 0.30, fz - 0.5, fz + 0.5)
        }
        if blocks[block] == .door && !openToggleBlocks.contains(block) {
            // Closed door panel (length 0.20 at front edge)
            return (fx - 0.5, fx + 0.5, fy - 0.5, fy + 0.5, fz + 0.30, fz + 0.5)
        }
        return (fx - 0.5, fx + 0.5, fy - 0.5, fy + 0.5, fz - 0.5, fz + 0.5)
    }

    private func doesPlayerIntersectBlock(at block: BlockCoord, playerPos: SCNVector3) -> Bool {
        let pMinX = playerPos.x - playerRadius
        let pMaxX = playerPos.x + playerRadius
        let pMinY = playerPos.y - playerFeetOffset
        let pMaxY = playerPos.y + playerHeadOffset
        let pMinZ = playerPos.z - playerRadius
        let pMaxZ = playerPos.z + playerRadius

        let b = blockBounds(for: block)

        return pMaxX > b.minX && pMinX < b.maxX &&
               pMaxY > b.minY && pMinY < b.maxY &&
               pMaxZ > b.minZ && pMinZ < b.maxZ
    }

    private func intersectsAnySolidBlock(at pos: SCNVector3) -> Bool {
        let minBX = Int(floor(pos.x - playerRadius + 0.5))
        let maxBX = Int(floor(pos.x + playerRadius + 0.5))
        let minBY = Int(floor(pos.y - playerFeetOffset + 0.5))
        let maxBY = Int(floor(pos.y + playerHeadOffset + 0.5))
        let minBZ = Int(floor(pos.z - playerRadius + 0.5))
        let maxBZ = Int(floor(pos.z + playerRadius + 0.5))

        for bx in minBX...maxBX {
            for by in minBY...maxBY {
                for bz in minBZ...maxBZ {
                    let coord = BlockCoord(x: bx, y: by, z: bz)
                    if hasSolidHitbox(at: coord) && doesPlayerIntersectBlock(at: coord, playerPos: pos) {
                        return true
                    }
                }
            }
        }
        return false
    }

    private func resolveStuckPositionIfNeeded() {
        var safety = 0
        while intersectsAnySolidBlock(at: playerPosition) && safety < 40 {
            playerPosition.y += 0.5
            safety += 1
        }
    }

    private func resolveX(from currentPos: SCNVector3, targetX: Float) -> Float {
        let dx = targetX - currentPos.x
        guard abs(dx) > 0.00001 else { return currentPos.x }

        var resolvedX = targetX
        let eps: Float = 0.001
        let minBY = Int(floor(currentPos.y - playerFeetOffset + eps + 0.5))
        let maxBY = Int(floor(currentPos.y + playerHeadOffset - eps + 0.5))
        let minBZ = Int(floor(currentPos.z - playerRadius + eps + 0.5))
        let maxBZ = Int(floor(currentPos.z + playerRadius - eps + 0.5))
        let minBX = Int(floor(min(currentPos.x, resolvedX) - playerRadius + 0.5))
        let maxBX = Int(floor(max(currentPos.x, resolvedX) + playerRadius + 0.5))

        for bx in minBX...maxBX {
            for by in minBY...maxBY {
                for bz in minBZ...maxBZ {
                    let coord = BlockCoord(x: bx, y: by, z: bz)
                    guard hasSolidHitbox(at: coord) else { continue }
                    let testPos = SCNVector3(resolvedX, currentPos.y, currentPos.z)
                    if doesPlayerIntersectBlock(at: coord, playerPos: testPos) {
                        let b = blockBounds(for: coord)
                        if dx > 0 {
                            resolvedX = min(resolvedX, b.minX - playerRadius - 0.0002)
                        } else {
                            resolvedX = max(resolvedX, b.maxX + playerRadius + 0.0002)
                        }
                    }
                }
            }
        }
        return resolvedX
    }

    private func resolveZ(from currentPos: SCNVector3, targetZ: Float) -> Float {
        let dz = targetZ - currentPos.z
        guard abs(dz) > 0.00001 else { return currentPos.z }

        var resolvedZ = targetZ
        let eps: Float = 0.001
        let minBX = Int(floor(currentPos.x - playerRadius + eps + 0.5))
        let maxBX = Int(floor(currentPos.x + playerRadius - eps + 0.5))
        let minBY = Int(floor(currentPos.y - playerFeetOffset + eps + 0.5))
        let maxBY = Int(floor(currentPos.y + playerHeadOffset - eps + 0.5))
        let minBZ = Int(floor(min(currentPos.z, resolvedZ) - playerRadius + 0.5))
        let maxBZ = Int(floor(max(currentPos.z, resolvedZ) + playerRadius + 0.5))

        for bx in minBX...maxBX {
            for by in minBY...maxBY {
                for bz in minBZ...maxBZ {
                    let coord = BlockCoord(x: bx, y: by, z: bz)
                    guard hasSolidHitbox(at: coord) else { continue }
                    let testPos = SCNVector3(currentPos.x, currentPos.y, resolvedZ)
                    if doesPlayerIntersectBlock(at: coord, playerPos: testPos) {
                        let b = blockBounds(for: coord)
                        if dz > 0 {
                            resolvedZ = min(resolvedZ, b.minZ - playerRadius - 0.0002)
                        } else {
                            resolvedZ = max(resolvedZ, b.maxZ + playerRadius + 0.0002)
                        }
                    }
                }
            }
        }
        return resolvedZ
    }

    private func resolveY(from currentPos: SCNVector3, targetY: Float) -> (y: Float, hitSolid: Bool) {
        let dy = targetY - currentPos.y
        guard abs(dy) > 0.00001 else { return (currentPos.y, false) }

        var resolvedY = targetY
        var hit = false
        let eps: Float = 0.001
        let minBX = Int(floor(currentPos.x - playerRadius + eps + 0.5))
        let maxBX = Int(floor(currentPos.x + playerRadius - eps + 0.5))
        let minBZ = Int(floor(currentPos.z - playerRadius + eps + 0.5))
        let maxBZ = Int(floor(currentPos.z + playerRadius - eps + 0.5))
        let minBY = Int(floor(min(currentPos.y, resolvedY) - playerFeetOffset + 0.5))
        let maxBY = Int(floor(max(currentPos.y, resolvedY) + playerHeadOffset + 0.5))

        for bx in minBX...maxBX {
            for by in minBY...maxBY {
                for bz in minBZ...maxBZ {
                    let coord = BlockCoord(x: bx, y: by, z: bz)
                    guard hasSolidHitbox(at: coord) else { continue }
                    let testPos = SCNVector3(currentPos.x, resolvedY, currentPos.z)
                    if doesPlayerIntersectBlock(at: coord, playerPos: testPos) {
                        let b = blockBounds(for: coord)
                        hit = true
                        if dy > 0 {
                            resolvedY = min(resolvedY, b.minY - playerHeadOffset - 0.0002)
                        } else {
                            resolvedY = max(resolvedY, b.maxY + playerFeetOffset + 0.0002)
                        }
                    }
                }
            }
        }
        return (resolvedY, hit)
    }

    private func isPlayerGrounded(at pos: SCNVector3) -> Bool {
        let probePos = SCNVector3(pos.x, pos.y - 0.06, pos.z)
        let (_, hit) = resolveY(from: pos, targetY: probePos.y)
        return hit
    }

    private func isPlayerInWater(at pos: SCNVector3) -> Bool {
        let feetCoord = BlockCoord(
            x: Int(round(pos.x)),
            y: Int(round(pos.y - playerFeetOffset + 0.3)),
            z: Int(round(pos.z))
        )
        let bodyCoord = BlockCoord(
            x: Int(round(pos.x)),
            y: Int(round(pos.y - 0.5)),
            z: Int(round(pos.z))
        )
        return blocks[feetCoord] == .water || blocks[bodyCoord] == .water
    }

    // MARK: - Camera, Instant Vertical Input, Movement & Physics Loop

    func setVerticalInput(_ value: Float) {
        let previous = verticalInput
        verticalInput = value
        if value != 0 && previous == 0 {
            if isFlying {
                let instantStep: Float = value * 10.5 * (1.0 / 60.0)
                let (newY, _) = resolveY(from: playerPosition, targetY: playerPosition.y + instantStep)
                playerPosition.y = max(0.5 + playerFeetOffset, min(42.0, newY))
                updateCameraTransform()
            } else {
                if value > 0.1 {
                    if isPlayerInWater(at: playerPosition) {
                        verticalVelocity = 4.8
                    } else if isPlayerGrounded(at: playerPosition) {
                        verticalVelocity = 7.4
                    }
                }
            }
        }
    }

    func rotateCamera(deltaYaw: Float, deltaPitch: Float) {
        let sens = controlLayout.lookSensitivity
        yaw -= deltaYaw * sens
        pitch = max(-Float.pi / 2.05, min(Float.pi / 2.05, pitch - deltaPitch * sens))
        updateCameraTransform()
    }

    func stepPhysics(dt: Float) {
        let clampedDt = min(dt, 0.1)
        let horizSpeed: Float = isFlying ? 9.8 : 5.8
        let flyVerticalSpeed: Float = 10.5

        let forwardX = -sin(yaw)
        let forwardZ = -cos(yaw)
        let rightX = cos(yaw)
        let rightZ = -sin(yaw)

        let moveForward = Float(moveInput.y)
        let moveRight = Float(moveInput.x)

        let vx = (forwardX * moveForward + rightX * moveRight) * horizSpeed
        let vz = (forwardZ * moveForward + rightZ * moveRight) * horizSpeed

        var pos = playerPosition

        // 1. Resolve X-axis movement against all solid block hitboxes
        let targetX = pos.x + vx * clampedDt
        pos.x = resolveX(from: pos, targetX: targetX)

        // 2. Resolve Z-axis movement against all solid block hitboxes
        let targetZ = pos.z + vz * clampedDt
        pos.z = resolveZ(from: pos, targetZ: targetZ)

        // 3. Resolve Y-axis movement against all solid block hitboxes
        if isFlying {
            verticalVelocity = 0
            let targetY = pos.y + verticalInput * flyVerticalSpeed * clampedDt
            let (resolvedY, _) = resolveY(from: pos, targetY: targetY)
            pos.y = resolvedY
        } else {
            let inWater = isPlayerInWater(at: pos)
            if inWater {
                if verticalInput > 0.1 {
                    verticalVelocity = 4.8
                } else if verticalInput < -0.1 {
                    verticalVelocity = -4.2
                } else {
                    verticalVelocity = max(verticalVelocity - 7.5 * clampedDt, -2.2)
                }
            } else {
                if verticalInput > 0.1 && isPlayerGrounded(at: pos) {
                    verticalVelocity = 7.4
                }
                verticalVelocity -= 18.0 * clampedDt
            }

            let targetY = pos.y + verticalVelocity * clampedDt
            let (resolvedY, hitSolid) = resolveY(from: pos, targetY: targetY)
            pos.y = resolvedY
            if hitSolid {
                verticalVelocity = 0
            }

            let bedrockMinY: Float = 0.5 + playerFeetOffset
            if pos.y < bedrockMinY {
                pos.y = bedrockMinY
                verticalVelocity = 0
            }
        }

        let bound = Float(halfWorld - 1)
        pos.x = max(-bound, min(bound, pos.x))
        pos.z = max(-bound, min(bound, pos.z))
        pos.y = max(0.5 + playerFeetOffset, min(42.0, pos.y))

        if abs(pos.x - playerPosition.x) > 0.01 || abs(pos.y - playerPosition.y) > 0.01 || abs(pos.z - playerPosition.z) > 0.01 {
            hasUnsavedChanges = true
        }

        playerPosition = pos
        updateCameraTransform()
        updateStreamedChunks(force: false)

        // Step flowing water & falling sand simulation every 0.20 seconds
        waterTickAccumulator += clampedDt
        if waterTickAccumulator >= 0.20 {
            waterTickAccumulator = 0.0
            stepWaterAndSandPhysics()
        }

        // Periodic background auto-save every 8 seconds if player moved or water flowed
        autoSaveAccumulator += clampedDt
        if autoSaveAccumulator >= 8.0 {
            autoSaveAccumulator = 0.0
            if hasUnsavedChanges {
                saveCurrentWorld(silent: true)
            }
        }

        // Broadcast multiplayer pose at ~15 Hz when connected to local peers
        poseBroadcastAccumulator += clampedDt
        if poseBroadcastAccumulator >= 0.066 {
            poseBroadcastAccumulator = 0.0
            broadcastPlayerPoseIfNeeded()
        }

        let ix = Int(round(playerPosition.x))
        let iy = Int(round(playerPosition.y))
        let iz = Int(round(playerPosition.z))
        let coordStr = "X:\(ix) Y:\(iy) Z:\(iz)"
        if playerCoordText != coordStr {
            playerCoordText = coordStr
        }

        // Calculate real-time FPS smoothed over ~0.35s
        fpsFrameCounter += 1
        fpsTimeAccumulator += clampedDt
        if fpsTimeAccumulator >= 0.35 {
            let calculated = Int(round(Float(fpsFrameCounter) / fpsTimeAccumulator))
            fpsFrameCounter = 0
            fpsTimeAccumulator = 0.0
            if currentFPS != calculated {
                currentFPS = calculated
            }
        }

        updateCrosshairTarget()
    }

    func updateCameraTransform() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0
        cameraNode.position = playerPosition
        cameraNode.eulerAngles = SCNVector3(pitch, yaw, 0)
        SCNTransaction.commit()
    }

    func updateCrosshairTarget() {
        let maxReach: Float = 8.5
        let dir = cameraDirection()
        let start = playerPosition
        let end = SCNVector3(
            start.x + dir.x * maxReach,
            start.y + dir.y * maxReach,
            start.z + dir.z * maxReach
        )

        let options: [String: Any] = [
            SCNHitTestOption.searchMode.rawValue: SCNHitTestSearchMode.closest.rawValue,
            SCNHitTestOption.ignoreHiddenNodes.rawValue: true,
            SCNHitTestOption.categoryBitMask.rawValue: 3 // Hits both solid blocks (1) and water (2)
        ]

        let hits = blocksRootNode.hitTestWithSegment(from: start, to: end, options: options)
        if let hit = hits.first,
           let name = hit.node.name {
            let parts = name.split(separator: ",").compactMap { Int($0) }
            if parts.count == 3 {
                let hitCoord = BlockCoord(x: parts[0], y: parts[1], z: parts[2])
                currentHitCoord = hitCoord
                targetedBlockType = blocks[hitCoord]
                isTargetedBlockOpen = openToggleBlocks.contains(hitCoord)

                let n = hit.worldNormal
                let nx = Int(round(n.x))
                let ny = Int(round(n.y))
                let nz = Int(round(n.z))
                currentPlaceCoord = BlockCoord(
                    x: hitCoord.x + nx,
                    y: hitCoord.y + ny,
                    z: hitCoord.z + nz
                )

                selectionBoxNode.position = SCNVector3(Float(hitCoord.x), Float(hitCoord.y), Float(hitCoord.z))
                selectionBoxNode.isHidden = false
                return
            }
        }

        currentHitCoord = nil
        currentPlaceCoord = nil
        targetedBlockType = nil
        isTargetedBlockOpen = false
        selectionBoxNode.isHidden = true
    }

    private func cameraDirection() -> SCNVector3 {
        let cosPitch = cos(pitch)
        let x = -sin(yaw) * cosPitch
        let y = sin(pitch)
        let z = -cos(yaw) * cosPitch
        return SCNVector3(x, y, z)
    }

    // MARK: - Local Multiplayer (MultipeerConnectivity)

    private func setupMultiplayer() {
        let cleanName = localPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let display = cleanName.isEmpty ? "Builder-\(Int.random(in: 10...99))" : String(cleanName.prefix(24))
        localPlayerName = display
        peerID = MCPeerID(displayName: display)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        mcSession.delegate = self

        startMultiplayerServices()
    }

    func startMultiplayerServices() {
        stopMultiplayerServices()

        if isHostingMultiplayer {
            let adv = MCNearbyServiceAdvertiser(
                peer: peerID,
                discoveryInfo: ["worldName": currentWorldName],
                serviceType: serviceType
            )
            adv.delegate = self
            adv.startAdvertisingPeer()
            advertiser = adv
        }

        let brw = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        brw.delegate = self
        brw.startBrowsingForPeers()
        browser = brw
    }

    func stopMultiplayerServices() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        browser?.stopBrowsingForPeers()
        browser = nil
    }

    func toggleMultiplayerHosting(_ enabled: Bool) {
        isHostingMultiplayer = enabled
        startMultiplayerServices()
        statusToast = enabled ? "Hosting local world '\(currentWorldName)'" : "Stopped hosting"
    }

    func joinDiscoveredHost(_ host: DiscoveredLocalHost) {
        guard let brw = browser else { return }
        brw.invitePeer(host.peerID, to: mcSession, withContext: nil, timeout: 15)
        statusToast = "Joining '\(host.worldName)' (\(host.peerID.displayName))..."
    }

    func disconnectMultiplayer() {
        mcSession.disconnect()
        connectedPlayerNames.removeAll()
        for (_, node) in remotePlayerNodes {
            node.removeFromParentNode()
        }
        remotePlayerNodes.removeAll()
        startMultiplayerServices()
        statusToast = "Disconnected from local session"
    }

    private func sendPacket(_ packet: MultiplayerPacket, reliable: Bool) {
        guard !mcSession.connectedPeers.isEmpty,
              let data = try? JSONEncoder().encode(packet) else { return }
        let mode: MCSessionSendDataMode = reliable ? .reliable : .unreliable
        try? mcSession.send(data, toPeers: mcSession.connectedPeers, with: mode)
    }

    private func broadcastWorldSnapshotToPeers() {
        guard !mcSession.connectedPeers.isEmpty else { return }
        let serializedDeltas = modifiedBlocks.map { (coord, rawVal) in
            SavedBlockDelta(
                x: coord.x,
                y: coord.y,
                z: coord.z,
                typeRaw: rawVal,
                waterLevel: (rawVal == BlockType.water.rawValue) ? (waterSpreadLevels[coord] ?? 4) : nil,
                isOpen: openToggleBlocks.contains(coord) ? true : nil
            )
        }
        let packet = MultiplayerPacket(
            kind: .worldSnapshot,
            senderName: localPlayerName,
            worldID: currentWorldID,
            worldName: currentWorldName,
            seed: worldSeed,
            deltas: serializedDeltas,
            blockDelta: nil,
            px: playerPosition.x,
            py: playerPosition.y,
            pz: playerPosition.z,
            yaw: yaw,
            pitch: pitch
        )
        sendPacket(packet, reliable: true)
    }

    private func broadcastBlockDelta(_ delta: SavedBlockDelta) {
        guard !mcSession.connectedPeers.isEmpty else { return }
        let packet = MultiplayerPacket(
            kind: .blockUpdate,
            senderName: localPlayerName,
            worldID: currentWorldID,
            worldName: nil,
            seed: nil,
            deltas: nil,
            blockDelta: delta,
            px: nil,
            py: nil,
            pz: nil,
            yaw: nil,
            pitch: nil
        )
        sendPacket(packet, reliable: true)
    }

    private func broadcastPlayerPoseIfNeeded() {
        guard !mcSession.connectedPeers.isEmpty else { return }
        let packet = MultiplayerPacket(
            kind: .playerPose,
            senderName: localPlayerName,
            worldID: currentWorldID,
            worldName: nil,
            seed: nil,
            deltas: nil,
            blockDelta: nil,
            px: playerPosition.x,
            py: playerPosition.y,
            pz: playerPosition.z,
            yaw: yaw,
            pitch: pitch
        )
        sendPacket(packet, reliable: false)
    }

    private func handleReceivedPacket(_ packet: MultiplayerPacket, from peer: MCPeerID) {
        switch packet.kind {
        case .requestSnapshot:
            if isHostingMultiplayer {
                broadcastWorldSnapshotToPeers()
            }

        case .worldSnapshot:
            guard let seed = packet.seed else { return }
            saveCurrentWorld(silent: true)
            clearAllWorldState()

            currentWorldID = packet.worldID ?? UUID()
            currentWorldName = packet.worldName ?? "\(peer.displayName)'s World"
            worldSeed = seed
            currentArchetype = WorldArchetype(rawValue: abs(seed) % WorldArchetype.allCases.count) ?? .alphaCliffs
            configureNoiseGenerators(seed: seed)

            if let deltas = packet.deltas {
                for d in deltas {
                    let coord = BlockCoord(x: d.x, y: d.y, z: d.z)
                    modifiedBlocks[coord] = d.typeRaw
                    if let wLvl = d.waterLevel {
                        waterSpreadLevels[coord] = wLvl
                    }
                    if d.isOpen == true {
                        openToggleBlocks.insert(coord)
                    }
                }
            }

            updateStreamedChunks(force: true)
            resolveStuckPositionIfNeeded()
            updateCameraTransform()
            saveCurrentWorld(silent: true)
            statusToast = "Joined '\(currentWorldName)' with \(peer.displayName)!"

        case .blockUpdate:
            guard let d = packet.blockDelta else { return }
            let coord = BlockCoord(x: d.x, y: d.y, z: d.z)
            if d.typeRaw < 0 {
                removeBlockInternal(at: coord, broadcast: false)
            } else if let bType = BlockType(rawValue: d.typeRaw) {
                blocks[coord] = bType
                chunkBlocks[chunkForBlock(coord), default: [:]][coord] = bType
                modifiedBlocks[coord] = d.typeRaw
                if let wLvl = d.waterLevel {
                    waterSpreadLevels[coord] = wLvl
                    activeWaterFrontier.insert(coord)
                }
                if let isOpen = d.isOpen {
                    if isOpen {
                        openToggleBlocks.insert(coord)
                    } else {
                        openToggleBlocks.remove(coord)
                    }
                }
                if bType == .sand {
                    activeSandBlocks.insert(coord)
                }
                updateVisibilityAround(coord)
            }
            saveCurrentWorld(silent: true)

        case .playerPose:
            guard let px = packet.px, let py = packet.py, let pz = packet.pz,
                  let pYaw = packet.yaw else { return }
            updateRemotePlayerAvatar(name: peer.displayName, x: px, y: py, z: pz, yaw: pYaw)
        }
    }

    private func updateRemotePlayerAvatar(name: String, x: Float, y: Float, z: Float, yaw: Float) {
        let avatarNode: SCNNode
        if let existing = remotePlayerNodes[name] {
            avatarNode = existing
        } else {
            let created = Self.makeBlockyPlayerAvatarNode(name: name)
            playersRootNode.addChildNode(created)
            remotePlayerNodes[name] = created
            avatarNode = created
        }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.06
        avatarNode.position = SCNVector3(x, y - playerFeetOffset, z)
        avatarNode.eulerAngles = SCNVector3(0, yaw, 0)
        SCNTransaction.commit()
    }

    private static func makeBlockyPlayerAvatarNode(name: String) -> SCNNode {
        let root = SCNNode()

        // Classic Alpha Steve-style blocky avatar (total height ~1.75 blocks)
        let legsGeo = SCNBox(width: 0.50, height: 0.65, length: 0.28, chamferRadius: 0.0)
        let legsMat = SCNMaterial()
        legsMat.diffuse.contents = UIColor(red: 0.20, green: 0.28, blue: 0.68, alpha: 1.0)
        legsGeo.materials = [legsMat]
        let legsNode = SCNNode(geometry: legsGeo)
        legsNode.position = SCNVector3(0, 0.325, 0)
        root.addChildNode(legsNode)

        let torsoGeo = SCNBox(width: 0.55, height: 0.65, length: 0.30, chamferRadius: 0.0)
        let torsoMat = SCNMaterial()
        torsoMat.diffuse.contents = UIColor(red: 0.15, green: 0.68, blue: 0.72, alpha: 1.0)
        torsoGeo.materials = [torsoMat]
        let torsoNode = SCNNode(geometry: torsoGeo)
        torsoNode.position = SCNVector3(0, 0.975, 0)
        root.addChildNode(torsoNode)

        let headGeo = SCNBox(width: 0.50, height: 0.50, length: 0.50, chamferRadius: 0.0)
        let headMat = SCNMaterial()
        headMat.diffuse.contents = UIColor(red: 0.85, green: 0.65, blue: 0.50, alpha: 1.0)
        headGeo.materials = [headMat]
        let headNode = SCNNode(geometry: headGeo)
        headNode.position = SCNVector3(0, 1.55, 0)
        root.addChildNode(headNode)

        let textGeo = SCNText(string: name, extrusionDepth: 0.2)
        textGeo.font = UIFont.monospacedSystemFont(ofSize: 3.5, weight: .bold)
        textGeo.firstMaterial?.diffuse.contents = UIColor.white
        textGeo.firstMaterial?.emission.contents = UIColor.white
        let textNode = SCNNode(geometry: textGeo)
        let (minVec, maxVec) = textNode.boundingBox
        let textWidth = maxVec.x - minVec.x
        textNode.scale = SCNVector3(0.08, 0.08, 0.08)
        textNode.position = SCNVector3(-textWidth * 0.04, 1.95, 0)
        let billboard = SCNBillboardConstraint()
        billboard.freeAxes = .Y
        textNode.constraints = [billboard]
        root.addChildNode(textNode)

        return root
    }
}

// MARK: - MultipeerConnectivity Delegates

extension VoxelWorld: MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor in
            self.connectedPlayerNames = session.connectedPeers.map { $0.displayName }
            if state == .connected {
                self.statusToast = "\(peerID.displayName) connected!"
                if self.isHostingMultiplayer {
                    self.broadcastWorldSnapshotToPeers()
                } else {
                    let req = MultiplayerPacket(
                        kind: .requestSnapshot,
                        senderName: self.localPlayerName,
                        worldID: nil,
                        worldName: nil,
                        seed: nil,
                        deltas: nil,
                        blockDelta: nil,
                        px: nil,
                        py: nil,
                        pz: nil,
                        yaw: nil,
                        pitch: nil
                    )
                    self.sendPacket(req, reliable: true)
                }
            } else if state == .notConnected {
                if let node = self.remotePlayerNodes.removeValue(forKey: peerID.displayName) {
                    node.removeFromParentNode()
                }
                self.statusToast = "\(peerID.displayName) left"
            }
        }
    }

    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let packet = try? JSONDecoder().decode(MultiplayerPacket.self, from: data) else { return }
        Task { @MainActor in
            self.handleReceivedPacket(packet, from: peerID)
        }
    }

    nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}

    nonisolated func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        Task { @MainActor in
            invitationHandler(true, self.mcSession)
        }
    }

    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        let wName = info?["worldName"] ?? "\(peerID.displayName)'s World"
        Task { @MainActor in
            let host = DiscoveredLocalHost(id: peerID.displayName, peerID: peerID, worldName: wName)
            if !self.discoveredHosts.contains(where: { $0.id == host.id }) {
                self.discoveredHosts.append(host)
            }
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        Task { @MainActor in
            self.discoveredHosts.removeAll { $0.id == peerID.displayName }
        }
    }
}
