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
    let typeRaw: Int // -1 means broken (air), 0...12 means BlockType.rawValue
    let waterLevel: Int? // Optional flowing water height level (1..4)
    let isOpen: Bool? // Optional open/closed state for doors & trapdoors
    let direction: Int? // Optional orientation for directional blocks (e.g. roof 0..3)

    enum CodingKeys: String, CodingKey {
        case x, y, z, typeRaw, waterLevel, isOpen, direction
    }

    init(x: Int, y: Int, z: Int, typeRaw: Int, waterLevel: Int? = nil, isOpen: Bool? = nil, direction: Int? = nil) {
        self.x = x
        self.y = y
        self.z = z
        self.typeRaw = typeRaw
        self.waterLevel = waterLevel
        self.isOpen = isOpen
        self.direction = direction
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.x = (try? c.decode(Int.self, forKey: .x)) ?? 0
        self.y = (try? c.decode(Int.self, forKey: .y)) ?? 0
        self.z = (try? c.decode(Int.self, forKey: .z)) ?? 0
        self.typeRaw = (try? c.decode(Int.self, forKey: .typeRaw)) ?? -1
        self.waterLevel = try? c.decode(Int.self, forKey: .waterLevel)
        self.isOpen = try? c.decode(Bool.self, forKey: .isOpen)
        self.direction = try? c.decode(Int.self, forKey: .direction)
    }
}

struct SavedChunkData: Codable {
    let cx: Int
    let cz: Int
    // Packed 4 ints per block: [x, y, z, encodedState]
    // where encodedState = (typeRaw & 0xFF) | ((waterLevel & 0xF) << 8) | ((isOpen ? 1 : 0) << 12) | ((direction & 0x3) << 14)
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
    var customWorldType: CustomWorldType? = nil

    enum CodingKeys: String, CodingKey {
        case id, name, seed, archetypeName, savedAt, savedChunks, deltas, blocks, inventory, playerX, playerY, playerZ, yaw, pitch, customWorldType
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
        pitch: Float = -0.35,
        customWorldType: CustomWorldType? = nil
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
        self.customWorldType = customWorldType
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
        self.customWorldType = try? c.decode(CustomWorldType.self, forKey: .customWorldType)
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
    var doorButtonOffsetX: CGFloat = 0
    var doorButtonOffsetY: CGFloat = -180 // higher by default so it never interferes with controls

    var joystickScale: CGFloat = 1.0
    var actionScale: CGFloat = 1.0
    var hotbarScale: CGFloat = 1.0
    var controlOpacity: Double = 0.92
    var lookSensitivity: Float = 1.0
    var movementSpeedMultiplier: Float = 1.0
    var swapLeftRight: Bool = false

    static let `default` = ControlLayoutConfig()

    enum CodingKeys: String, CodingKey {
        case joystickOffsetX, joystickOffsetY
        case hotbarOffsetX, hotbarOffsetY
        case actionOffsetX, actionOffsetY
        case verticalOffsetX, verticalOffsetY
        case doorButtonOffsetX, doorButtonOffsetY
        case joystickScale, actionScale, hotbarScale
        case controlOpacity, lookSensitivity, movementSpeedMultiplier, swapLeftRight
    }

    init(
        joystickOffsetX: CGFloat = 0,
        joystickOffsetY: CGFloat = 0,
        hotbarOffsetX: CGFloat = 0,
        hotbarOffsetY: CGFloat = 0,
        actionOffsetX: CGFloat = 0,
        actionOffsetY: CGFloat = 0,
        verticalOffsetX: CGFloat = 0,
        verticalOffsetY: CGFloat = 0,
        doorButtonOffsetX: CGFloat = 0,
        doorButtonOffsetY: CGFloat = -180,
        joystickScale: CGFloat = 1.0,
        actionScale: CGFloat = 1.0,
        hotbarScale: CGFloat = 1.0,
        controlOpacity: Double = 0.92,
        lookSensitivity: Float = 1.0,
        movementSpeedMultiplier: Float = 1.0,
        swapLeftRight: Bool = false
    ) {
        self.joystickOffsetX = joystickOffsetX
        self.joystickOffsetY = joystickOffsetY
        self.hotbarOffsetX = hotbarOffsetX
        self.hotbarOffsetY = hotbarOffsetY
        self.actionOffsetX = actionOffsetX
        self.actionOffsetY = actionOffsetY
        self.verticalOffsetX = verticalOffsetX
        self.verticalOffsetY = verticalOffsetY
        self.doorButtonOffsetX = doorButtonOffsetX
        self.doorButtonOffsetY = doorButtonOffsetY
        self.joystickScale = joystickScale
        self.actionScale = actionScale
        self.hotbarScale = hotbarScale
        self.controlOpacity = controlOpacity
        self.lookSensitivity = lookSensitivity
        self.movementSpeedMultiplier = movementSpeedMultiplier
        self.swapLeftRight = swapLeftRight
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        joystickOffsetX = try container.decodeIfPresent(CGFloat.self, forKey: .joystickOffsetX) ?? 0
        joystickOffsetY = try container.decodeIfPresent(CGFloat.self, forKey: .joystickOffsetY) ?? 0
        hotbarOffsetX = try container.decodeIfPresent(CGFloat.self, forKey: .hotbarOffsetX) ?? 0
        hotbarOffsetY = try container.decodeIfPresent(CGFloat.self, forKey: .hotbarOffsetY) ?? 0
        actionOffsetX = try container.decodeIfPresent(CGFloat.self, forKey: .actionOffsetX) ?? 0
        actionOffsetY = try container.decodeIfPresent(CGFloat.self, forKey: .actionOffsetY) ?? 0
        verticalOffsetX = try container.decodeIfPresent(CGFloat.self, forKey: .verticalOffsetX) ?? 0
        verticalOffsetY = try container.decodeIfPresent(CGFloat.self, forKey: .verticalOffsetY) ?? 0
        doorButtonOffsetX = try container.decodeIfPresent(CGFloat.self, forKey: .doorButtonOffsetX) ?? 0
        doorButtonOffsetY = try container.decodeIfPresent(CGFloat.self, forKey: .doorButtonOffsetY) ?? -180

        joystickScale = try container.decodeIfPresent(CGFloat.self, forKey: .joystickScale) ?? 1.0
        actionScale = try container.decodeIfPresent(CGFloat.self, forKey: .actionScale) ?? 1.0
        hotbarScale = try container.decodeIfPresent(CGFloat.self, forKey: .hotbarScale) ?? 1.0
        controlOpacity = try container.decodeIfPresent(Double.self, forKey: .controlOpacity) ?? 0.92
        lookSensitivity = try container.decodeIfPresent(Float.self, forKey: .lookSensitivity) ?? 1.0
        let rawSpeed = try container.decodeIfPresent(Float.self, forKey: .movementSpeedMultiplier) ?? 1.0
        movementSpeedMultiplier = (rawSpeed < 0.4 || rawSpeed > 3.0) ? 1.0 : rawSpeed
        swapLeftRight = try container.decodeIfPresent(Bool.self, forKey: .swapLeftRight) ?? false
    }
}

// MARK: - Player Character Skins (Multiplayer & Avatar Customization)

enum SkinFeatureStyle: String, Codable, CaseIterable {
    case classic
    case visor
    case cybernetic
    case minerLamp
    case spaceVisor
    case wizardPoint
    case ninjaMask
    case horns
    case furHood
    case crown
    case pirateEyepatch
    case headphones
    case villagerRobe
    case catEars
    case sunglasses
    case superheroMask
}

enum CameraPerspective: Int, CaseIterable, Codable {
    case firstPerson = 0
    case thirdPersonBack = 1
    case thirdPersonFront = 2

    var displayName: String {
        switch self {
        case .firstPerson: return "1st Person View"
        case .thirdPersonBack: return "3rd Person (Back)"
        case .thirdPersonFront: return "3rd Person (Front)"
        }
    }
}

enum PlayerSkin: String, CaseIterable, Codable, Identifiable {
    case steve = "Steve"
    case alex = "Alex"
    case knight = "Knight"
    case robot = "Robot"
    case miner = "Miner"
    case astronaut = "Astronaut"
    case wizard = "Wizard"
    case zombie = "Zombie"
    case ninja = "Ninja"
    case pirate = "Pirate"
    case viking = "Viking"
    case cyborg = "Cyborg"
    case nether = "Nether"
    case arctic = "Arctic"

    var id: String { rawValue }

    var assetName: String {
        switch self {
        case .steve: return "steve"
        case .alex: return "alex"
        case .knight: return "knight"
        case .robot: return "robot"
        case .miner: return "miner"
        case .astronaut: return "astronaut"
        case .wizard: return "wizard"
        case .zombie: return "zombie"
        case .ninja: return "ninja"
        case .pirate: return "pirate"
        case .viking: return "viking"
        case .cyborg: return "cyborg"
        case .nether: return "nether"
        case .arctic: return "arctic"
        }
    }

    var displayName: String {
        switch self {
        case .steve: return "Classic Steve"
        case .alex: return "Alex"
        case .knight: return "Iron Knight"
        case .robot: return "Cyber Robot"
        case .miner: return "Cave Miner"
        case .astronaut: return "Astronaut"
        case .wizard: return "Mystic Mage"
        case .zombie: return "Zombie"
        case .ninja: return "Shadow Ninja"
        case .pirate: return "Sea Pirate"
        case .viking: return "Nordic Viking"
        case .cyborg: return "Cyberpunk"
        case .nether: return "Nether Lord"
        case .arctic: return "Arctic Ranger"
        }
    }

    var roleSubtitle: String {
        switch self {
        case .steve: return "Iconic Builder"
        case .alex: return "Wilderness Scout"
        case .knight: return "Steel Defender"
        case .robot: return "Android Unit"
        case .miner: return "Deep Spelunker"
        case .astronaut: return "Space Explorer"
        case .wizard: return "Spell Caster"
        case .zombie: return "Undead Walker"
        case .ninja: return "Stealth Assassin"
        case .pirate: return "Ocean Raider"
        case .viking: return "Fierce Warrior"
        case .cyborg: return "Neon Mercenary"
        case .nether: return "Infernal Guardian"
        case .arctic: return "Frozen Pioneer"
        }
    }

    var headColor: UIColor {
        switch self {
        case .steve: return UIColor(red: 0.85, green: 0.65, blue: 0.50, alpha: 1.0)
        case .alex: return UIColor(red: 0.92, green: 0.72, blue: 0.58, alpha: 1.0)
        case .knight: return UIColor(red: 0.75, green: 0.75, blue: 0.80, alpha: 1.0)
        case .robot: return UIColor(red: 0.35, green: 0.38, blue: 0.45, alpha: 1.0)
        case .miner: return UIColor(red: 0.88, green: 0.68, blue: 0.52, alpha: 1.0)
        case .astronaut: return UIColor(red: 0.96, green: 0.78, blue: 0.18, alpha: 1.0)
        case .wizard: return UIColor(red: 0.86, green: 0.78, blue: 0.72, alpha: 1.0)
        case .zombie: return UIColor(red: 0.32, green: 0.58, blue: 0.28, alpha: 1.0)
        case .ninja: return UIColor(red: 0.14, green: 0.14, blue: 0.17, alpha: 1.0)
        case .pirate: return UIColor(red: 0.82, green: 0.62, blue: 0.48, alpha: 1.0)
        case .viking: return UIColor(red: 0.86, green: 0.66, blue: 0.52, alpha: 1.0)
        case .cyborg: return UIColor(red: 0.84, green: 0.74, blue: 0.70, alpha: 1.0)
        case .nether: return UIColor(red: 0.16, green: 0.14, blue: 0.16, alpha: 1.0)
        case .arctic: return UIColor(red: 0.88, green: 0.75, blue: 0.68, alpha: 1.0)
        }
    }

    var hairColor: UIColor {
        switch self {
        case .steve: return UIColor(red: 0.28, green: 0.16, blue: 0.08, alpha: 1.0)
        case .alex: return UIColor(red: 0.85, green: 0.45, blue: 0.15, alpha: 1.0)
        case .knight: return UIColor(red: 0.55, green: 0.56, blue: 0.62, alpha: 1.0)
        case .robot: return UIColor(red: 0.22, green: 0.24, blue: 0.28, alpha: 1.0)
        case .miner: return UIColor(red: 0.98, green: 0.82, blue: 0.15, alpha: 1.0)
        case .astronaut: return UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1.0)
        case .wizard: return UIColor(red: 0.38, green: 0.18, blue: 0.62, alpha: 1.0)
        case .zombie: return UIColor(red: 0.20, green: 0.36, blue: 0.18, alpha: 1.0)
        case .ninja: return UIColor(red: 0.88, green: 0.15, blue: 0.20, alpha: 1.0)
        case .pirate: return UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0)
        case .viking: return UIColor(red: 0.78, green: 0.32, blue: 0.12, alpha: 1.0)
        case .cyborg: return UIColor(red: 0.10, green: 0.90, blue: 0.85, alpha: 1.0)
        case .nether: return UIColor(red: 0.95, green: 0.30, blue: 0.10, alpha: 1.0)
        case .arctic: return UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1.0)
        }
    }

    var torsoColor: UIColor {
        switch self {
        case .steve: return UIColor(red: 0.15, green: 0.68, blue: 0.72, alpha: 1.0)
        case .alex: return UIColor(red: 0.35, green: 0.58, blue: 0.25, alpha: 1.0)
        case .knight: return UIColor(red: 0.68, green: 0.70, blue: 0.75, alpha: 1.0)
        case .robot: return UIColor(red: 0.20, green: 0.22, blue: 0.28, alpha: 1.0)
        case .miner: return UIColor(red: 0.96, green: 0.45, blue: 0.10, alpha: 1.0)
        case .astronaut: return UIColor(red: 0.92, green: 0.92, blue: 0.95, alpha: 1.0)
        case .wizard: return UIColor(red: 0.45, green: 0.15, blue: 0.65, alpha: 1.0)
        case .zombie: return UIColor(red: 0.15, green: 0.55, blue: 0.60, alpha: 1.0)
        case .ninja: return UIColor(red: 0.18, green: 0.18, blue: 0.22, alpha: 1.0)
        case .pirate: return UIColor(red: 0.70, green: 0.15, blue: 0.15, alpha: 1.0)
        case .viking: return UIColor(red: 0.45, green: 0.32, blue: 0.20, alpha: 1.0)
        case .cyborg: return UIColor(red: 0.14, green: 0.15, blue: 0.20, alpha: 1.0)
        case .nether: return UIColor(red: 0.22, green: 0.14, blue: 0.16, alpha: 1.0)
        case .arctic: return UIColor(red: 0.35, green: 0.48, blue: 0.52, alpha: 1.0)
        }
    }

    var legsColor: UIColor {
        switch self {
        case .steve: return UIColor(red: 0.20, green: 0.28, blue: 0.68, alpha: 1.0)
        case .alex: return UIColor(red: 0.42, green: 0.30, blue: 0.18, alpha: 1.0)
        case .knight: return UIColor(red: 0.48, green: 0.50, blue: 0.55, alpha: 1.0)
        case .robot: return UIColor(red: 0.15, green: 0.16, blue: 0.20, alpha: 1.0)
        case .miner: return UIColor(red: 0.18, green: 0.24, blue: 0.38, alpha: 1.0)
        case .astronaut: return UIColor(red: 0.85, green: 0.85, blue: 0.88, alpha: 1.0)
        case .wizard: return UIColor(red: 0.25, green: 0.10, blue: 0.40, alpha: 1.0)
        case .zombie: return UIColor(red: 0.22, green: 0.20, blue: 0.45, alpha: 1.0)
        case .ninja: return UIColor(red: 0.14, green: 0.14, blue: 0.18, alpha: 1.0)
        case .pirate: return UIColor(red: 0.20, green: 0.22, blue: 0.28, alpha: 1.0)
        case .viking: return UIColor(red: 0.32, green: 0.28, blue: 0.24, alpha: 1.0)
        case .cyborg: return UIColor(red: 0.18, green: 0.20, blue: 0.26, alpha: 1.0)
        case .nether: return UIColor(red: 0.18, green: 0.16, blue: 0.18, alpha: 1.0)
        case .arctic: return UIColor(red: 0.28, green: 0.36, blue: 0.40, alpha: 1.0)
        }
    }

    var bootsColor: UIColor {
        switch self {
        case .steve: return UIColor(red: 0.30, green: 0.30, blue: 0.35, alpha: 1.0)
        case .alex: return UIColor(red: 0.25, green: 0.18, blue: 0.10, alpha: 1.0)
        case .knight: return UIColor(red: 0.35, green: 0.36, blue: 0.40, alpha: 1.0)
        case .robot: return UIColor(red: 0.10, green: 0.12, blue: 0.15, alpha: 1.0)
        case .miner: return UIColor(red: 0.25, green: 0.18, blue: 0.12, alpha: 1.0)
        case .astronaut: return UIColor(red: 0.38, green: 0.40, blue: 0.45, alpha: 1.0)
        case .wizard: return UIColor(red: 0.18, green: 0.08, blue: 0.28, alpha: 1.0)
        case .zombie: return UIColor(red: 0.20, green: 0.22, blue: 0.18, alpha: 1.0)
        case .ninja: return UIColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1.0)
        case .pirate: return UIColor(red: 0.15, green: 0.12, blue: 0.10, alpha: 1.0)
        case .viking: return UIColor(red: 0.22, green: 0.16, blue: 0.12, alpha: 1.0)
        case .cyborg: return UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1.0)
        case .nether: return UIColor(red: 0.12, green: 0.10, blue: 0.12, alpha: 1.0)
        case .arctic: return UIColor(red: 0.15, green: 0.18, blue: 0.22, alpha: 1.0)
        }
    }

    var accentColor: UIColor {
        switch self {
        case .steve: return UIColor(red: 0.45, green: 0.30, blue: 0.18, alpha: 1.0)
        case .alex: return UIColor(red: 0.85, green: 0.45, blue: 0.15, alpha: 1.0)
        case .knight: return UIColor(red: 0.95, green: 0.82, blue: 0.25, alpha: 1.0)
        case .robot: return UIColor(red: 0.10, green: 0.95, blue: 0.95, alpha: 1.0)
        case .miner: return UIColor(red: 1.0, green: 0.98, blue: 0.40, alpha: 1.0)
        case .astronaut: return UIColor(red: 0.20, green: 0.70, blue: 0.95, alpha: 1.0)
        case .wizard: return UIColor(red: 0.95, green: 0.85, blue: 0.30, alpha: 1.0)
        case .zombie: return UIColor(red: 0.25, green: 0.48, blue: 0.22, alpha: 1.0)
        case .ninja: return UIColor(red: 0.90, green: 0.18, blue: 0.22, alpha: 1.0)
        case .pirate: return UIColor(red: 0.95, green: 0.78, blue: 0.22, alpha: 1.0)
        case .viking: return UIColor(red: 0.72, green: 0.74, blue: 0.78, alpha: 1.0)
        case .cyborg: return UIColor(red: 1.0, green: 0.15, blue: 0.65, alpha: 1.0)
        case .nether: return UIColor(red: 1.0, green: 0.50, blue: 0.05, alpha: 1.0)
        case .arctic: return UIColor(red: 1.0, green: 0.65, blue: 0.10, alpha: 1.0)
        }
    }

    var eyeColor: UIColor {
        switch self {
        case .steve: return UIColor(red: 0.20, green: 0.40, blue: 0.85, alpha: 1.0)
        case .alex: return UIColor(red: 0.15, green: 0.65, blue: 0.25, alpha: 1.0)
        case .knight: return UIColor(red: 1.0, green: 0.85, blue: 0.20, alpha: 1.0)
        case .robot: return UIColor(red: 0.10, green: 0.95, blue: 0.95, alpha: 1.0)
        case .miner: return UIColor(red: 0.25, green: 0.20, blue: 0.15, alpha: 1.0)
        case .astronaut: return UIColor(red: 0.98, green: 0.85, blue: 0.25, alpha: 1.0)
        case .wizard: return UIColor(red: 0.85, green: 0.45, blue: 1.0, alpha: 1.0)
        case .zombie: return UIColor(red: 0.85, green: 0.20, blue: 0.15, alpha: 1.0)
        case .ninja: return UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1.0)
        case .pirate: return UIColor(red: 0.25, green: 0.60, blue: 0.85, alpha: 1.0)
        case .viking: return UIColor(red: 0.40, green: 0.80, blue: 1.0, alpha: 1.0)
        case .cyborg: return UIColor(red: 1.0, green: 0.10, blue: 0.60, alpha: 1.0)
        case .nether: return UIColor(red: 1.0, green: 0.85, blue: 0.10, alpha: 1.0)
        case .arctic: return UIColor(red: 1.0, green: 0.70, blue: 0.15, alpha: 1.0)
        }
    }

    var featureStyle: SkinFeatureStyle {
        switch self {
        case .steve, .alex, .zombie:
            return .classic
        case .knight:
            return .visor
        case .robot, .cyborg:
            return .cybernetic
        case .miner:
            return .minerLamp
        case .astronaut:
            return .spaceVisor
        case .wizard:
            return .wizardPoint
        case .ninja:
            return .ninjaMask
        case .pirate:
            return .classic
        case .viking, .nether:
            return .horns
        case .arctic:
            return .furHood
        }
    }

    var hasEyepatch: Bool {
        return self == .pirate
    }

    var hasBackpack: Bool {
        return self == .astronaut || self == .miner || self == .arctic
    }
}

// MARK: - Local Multiplayer Packet Protocol

struct MultiplayerPacket: Codable {
    enum Kind: String, Codable {
        case worldSnapshot
        case requestSnapshot
        case blockUpdate
        case playerPose
        case playerLeft
    }

    var kind: Kind
    var senderName: String
    var skinRaw: String? = nil
    var customSkin: CustomSkin? = nil
    // World Snapshot fields
    var worldID: UUID? = nil
    var worldName: String? = nil
    var seed: Int? = nil
    var worldTypeRaw: String? = nil
    var customWorldType: CustomWorldType? = nil
    var deltas: [SavedBlockDelta]? = nil
    // Single Block Update fields
    var blockDelta: SavedBlockDelta? = nil
    // Player Pose fields
    var px: Float? = nil
    var py: Float? = nil
    var pz: Float? = nil
    var yaw: Float? = nil
    var pitch: Float? = nil
}

struct DiscoveredLocalHost: Identifiable, Equatable {
    let id: String
    let peerID: MCPeerID
    let worldName: String
    let playerName: String
    let skin: PlayerSkin
    let isInGame: Bool
    let isHost: Bool

    static func == (lhs: DiscoveredLocalHost, rhs: DiscoveredLocalHost) -> Bool {
        lhs.id == rhs.id && lhs.worldName == rhs.worldName && lhs.isInGame == rhs.isInGame && lhs.isHost == rhs.isHost
    }
}

struct MultiplayerJoinPrompt: Identifiable {
    let id = UUID()
    let peerID: MCPeerID
    let playerName: String
    let worldName: String
    let isDirectInvitation: Bool
    var invitationHandler: ((Bool, MCSession?) -> Void)? = nil
}

enum WorldType: String, CaseIterable, Identifiable, Codable {
    case standard = "standard"
    case flat = "flat"
    case skyIslands = "skyIslands"
    case amplified = "amplified"
    case desert = "desert"
    case caveLands = "caveLands"
    case oceanWorld = "oceanWorld"
    case seaIslands = "seaIslands"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .flat: return "Flat World"
        case .skyIslands: return "Sky Islands"
        case .amplified: return "Amplified Peaks"
        case .desert: return "Endless Desert"
        case .caveLands: return "Cave Lands"
        case .oceanWorld: return "Ocean World"
        case .seaIslands: return "Sea Islands"
        }
    }

    var subtitle: String {
        switch self {
        case .standard: return "Lush hills, lakes, beaches, oak forests & cozy cabins"
        case .flat: return "Endless level grass plane, perfect for creative building"
        case .skyIslands: return "Floating islands in the open void, no invisible barrier"
        case .amplified: return "Towering extreme mountains, massive sheer cliffs & high waterfalls"
        case .desert: return "Vast rolling golden sand dunes, sandstone strata & hidden oases"
        case .caveLands: return "Subterranean world of giant caverns, stone vaults & stalactites"
        case .oceanWorld: return "Endless deep ocean waters, submerged trenches & isolated sandbars"
        case .seaIslands: return "Tropical archipelago of lush islands, sandy beaches & crystal blue sea"
        }
    }

    var iconName: String {
        switch self {
        case .standard: return "globe.americas.fill"
        case .flat: return "square.fill"
        case .skyIslands: return "cloud.fill"
        case .amplified: return "mountain.2.fill"
        case .desert: return "sun.max.fill"
        case .caveLands: return "flashlight.on.fill"
        case .oceanWorld: return "water.waves"
        case .seaIslands: return "leaf.fill"
        }
    }

    static func from(archetypeName: String?) -> WorldType {
        guard let name = archetypeName?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            return .standard
        }
        if let direct = WorldType(rawValue: name) {
            return direct
        }
        for type in WorldType.allCases {
            if type.displayName.lowercased() == name.lowercased() {
                return type
            }
        }
        return .standard
    }
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
    // Infinite Procedural Voxel World Bounds (Dynamic infinite generation on X and Z)
    let worldSize: Int = 500
    let halfWorld: Int = 250
    let seaLevel: Int = 4

    // Chunk streaming config (each chunk is 10x10 columns, configurable view radius 2...16)
    let chunkSize: Int = 10
    @Published var renderDistance: Int = 4 {
        didSet {
            UserDefaults.standard.set(renderDistance, forKey: "blockbuild_render_distance")
            applyRenderDistance()
        }
    }

    // Current World Metadata & Saved Worlds
    @Published var currentWorldID: UUID = UUID()
    @Published var currentWorldName: String = "World"
    @Published var worldSeed: Int = Int.random(in: 1000...999_999)
    @Published var currentWorldType: WorldType = .standard
    @Published var currentArchetype: WorldArchetype = .alphaCliffs
    @Published var savedWorlds: [SavedWorld] = []
    @Published var playerCoordText: String = "X: 0  Y: 14  Z: 0"
    @Published var currentFPS: Int = 60
    private var fpsFrameCounter: Int = 0
    private var fpsTimeAccumulator: Float = 0.0

    // Inventory & Hotbar state (all 13 blocks)
    @Published var selectedBlock: BlockType = .grass {
        didSet {
            updateHeldBlockMaterial()
        }
    }
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
        .roof: 20,
        .roofCorner: 20,
        .slab: 20,
        .water: 15
    ]
    @Published var targetedBlockType: BlockType? = nil
    @Published var isTargetedBlockOpen: Bool = false
    @Published var statusToast: String = "Infinite World Ready!"
    @Published var isFlying: Bool = true
    @Published var isMusicEnabled: Bool = true

    // Customizable Control Layout State
    @Published var controlLayout: ControlLayoutConfig = .default {
        didSet {
            saveControlLayout()
        }
    }
    @Published var isEditingControls: Bool = false

    // Navigation state: Main Menu vs Active Gameplay
    @Published var isInGame: Bool = false
    @Published var selectedSkin: PlayerSkin = .steve
    @Published var currentTexturePack: TexturePack = .classic

    // MARK: - Shaders Engine State & Hardware Capability
    static var deviceHas6GBRAMOrHigher: Bool {
        // iOS devices with 6GB+ RAM (e.g. iPhone 12 Pro, 13 Pro, 14+, 15+) report ~5.5-5.8GB in physicalMemory
        ProcessInfo.processInfo.physicalMemory >= 5_500_000_000
    }

    static var defaultShaderForDevice: GameShaderPreset {
        deviceHas6GBRAMOrHigher ? .vibrant : .vanilla
    }

    @Published var currentShader: GameShaderPreset = {
        if let saved = UserDefaults.standard.string(forKey: "blockbuild_active_shader"),
           let preset = GameShaderPreset(rawValue: saved) {
            return preset
        }
        return defaultShaderForDevice
    }()

    /// Incremented whenever custom textures or texture packs update, forcing hotbar and inventory icons to refresh
    @Published var textureUpdateVersion: Int = 0

    var ambientLight: SCNLight? = nil
    var sunLight: SCNLight? = nil
    var sunNode: SCNNode? = nil

    // AI Game Studio State
    @Published var customWorldTypes: [CustomWorldType] = []
    @Published var activeCustomWorld: CustomWorldType? = nil
    @Published var customSkins: [CustomSkin] = []
    @Published var activeCustomSkin: CustomSkin? = nil

    // Camera Perspective (First Person ↔ Third Person Back ↔ Third Person Front)
    @Published var cameraPerspective: CameraPerspective = .firstPerson
    var localPlayerAvatarNode: SCNNode? = nil
    var firstPersonArmNode: SCNNode? = nil
    var firstPersonHeldBlockNode: SCNNode? = nil
    var walkAnimationAccumulator: Float = 0.0

    // Local Multiplayer State (Enabled by default, continuously signals nearby players)
    @Published var isMultiplayerEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isMultiplayerEnabled, forKey: "blockbuild_multiplayer_enabled")
        }
    }
    @Published var localPlayerName: String = ""
    @Published var isHostingMultiplayer: Bool = true
    @Published var connectedPlayerNames: [String] = []
    @Published var discoveredHosts: [DiscoveredLocalHost] = []
    @Published var activeJoinPrompt: MultiplayerJoinPrompt? = nil
    private var dismissedPromptKeys: Set<String> = []
    private var remotePlayerSkins: [String: PlayerSkin] = [:]
    private var remotePlayerCustomSkins: [String: CustomSkin] = [:]

    // Performance Stabilization & FPS Limit
    @Published var isPerformanceStabilizationEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isPerformanceStabilizationEnabled, forKey: "blockbuild_performance_stabilization")
            if isPerformanceStabilizationEnabled {
                setFPSLimit(60)
                setRenderDistance(2)
            }
        }
    }
    // Backward compatibility alias
    var isFpsStabilizationEnabled: Bool {
        get { isPerformanceStabilizationEnabled }
        set { isPerformanceStabilizationEnabled = newValue }
    }

    @Published var fpsLimit: Int = 60 {
        didSet {
            UserDefaults.standard.set(fpsLimit, forKey: "blockbuild_fps_limit")
        }
    }
    private var crosshairRaycastSkip: Int = 0
    private var coordTextTimeAccumulator: Float = 0

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
    private var modifiedBlocks: [BlockCoord: Int] = [:] // -1 = air, 0..12 = BlockType
    private var openToggleBlocks: Set<BlockCoord> = [] // Open doors
    private var blockOrientations: [BlockCoord: Int] = [:] // 0: North (-Z), 1: East (+X), 2: South (+Z), 3: West (-X)
    private var blockNodes: [BlockCoord: SCNNode] = [:]
    private var sharedGeometries: [BlockType: SCNBox] = [:]
    private var waterLevelGeometries: [Int: SCNBox] = [:] // Levels 1..4 with lowering heights
    private var waterMaskedGeometries: [Int: SCNBox] = [:] // Key: (level << 6) | 6-bit face visibility mask
    private var doorClosedGeo = SCNBox()
    private var doorOpenGeo = SCNBox()
    private var roofBaseGeo = SCNBox()
    private var roofStepGeo = SCNBox()
    private var roofCornerStepGeo = SCNBox()
    private var slabGeo = SCNBox()
    private var lastPlayerChunk: ChunkCoord? = nil

    // High-performance Minecraft-style chunk container nodes & exposed-block caches
    private var chunkNodes: [ChunkCoord: SCNNode] = [:]
    private var chunkExposedBlocks: [ChunkCoord: [BlockCoord: BlockType]] = [:]

    // Noise generators for current seed
    private var primaryNoise = SeededPerlinNoise(seed: 1)
    private var warpNoise = SeededPerlinNoise(seed: 2)
    private var ridgeNoise = SeededPerlinNoise(seed: 3)
    private var biomeNoise = SeededPerlinNoise(seed: 4)

    // Water Flow & Falling Sand Simulation Queues
    private var waterSpreadLevels: [BlockCoord: Int] = [:] // 4 = full height, 3..1 = lowering height toward lowest spot
    private var waterSourceBlocks: Set<BlockCoord> = [] // Uncut source blocks (bucket-placed springs and natural basin water)
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

    // SCNView reference & Screenshot Capture
    weak var sceneView: SCNView?
    private var activePhotoSaver: PhotoAlbumSaver?

    override init() {
        super.init()
        if let savedSkin = UserDefaults.standard.string(forKey: "blockbuild_selected_skin"),
           let skin = PlayerSkin(rawValue: savedSkin) {
            self.selectedSkin = skin
        }
        if let savedPack = UserDefaults.standard.string(forKey: "blockbuild_texture_pack"),
           let pack = TexturePack(rawValue: savedPack) {
            self.currentTexturePack = pack
            BlockType.activeTexturePack = pack
        }
        let savedDistance = UserDefaults.standard.integer(forKey: "blockbuild_render_distance")
        if savedDistance >= 2 && savedDistance <= 8 {
            self.renderDistance = savedDistance
        } else if savedDistance > 8 {
            self.renderDistance = 8
        } else {
            self.renderDistance = 4
        }
        loadControlLayout()
        loadCustomWorldTypes()
        loadCustomSkins()
        setupGeometries()
        setupScene()
        loadSavedWorldsList()

        // Prepare the latest world in background, but keep user in Main Menu (isInGame = false)
        if let latestWorld = savedWorlds.first {
            loadSavedWorld(latestWorld, enterGame: false)
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
                    loadSavedWorld(recovered, enterGame: false)
                } else {
                    startNewWorld(seed: worldSeed, customName: nil)
                    saveCurrentWorld(silent: true)
                }
            }
        }
        isInGame = false

        if UserDefaults.standard.object(forKey: "blockbuild_performance_stabilization") != nil {
            self.isPerformanceStabilizationEnabled = UserDefaults.standard.bool(forKey: "blockbuild_performance_stabilization")
        } else if UserDefaults.standard.object(forKey: "blockbuild_fps_stabilization") != nil {
            self.isPerformanceStabilizationEnabled = UserDefaults.standard.bool(forKey: "blockbuild_fps_stabilization")
        } else {
            self.isPerformanceStabilizationEnabled = true
        }

        let savedFPS = UserDefaults.standard.integer(forKey: "blockbuild_fps_limit")
        if [0, 30, 40, 60].contains(savedFPS) && UserDefaults.standard.object(forKey: "blockbuild_fps_limit") != nil {
            self.fpsLimit = savedFPS
        } else {
            self.fpsLimit = 60
        }

        if UserDefaults.standard.object(forKey: "blockbuild_fps_60_default_migrated") == nil {
            self.fpsLimit = 60
            UserDefaults.standard.set(60, forKey: "blockbuild_fps_limit")
            UserDefaults.standard.set(true, forKey: "blockbuild_fps_60_default_migrated")
        }

        if UserDefaults.standard.object(forKey: "blockbuild_multiplayer_enabled") != nil {
            self.isMultiplayerEnabled = UserDefaults.standard.bool(forKey: "blockbuild_multiplayer_enabled")
        } else {
            self.isMultiplayerEnabled = true
        }

        AlphaBackgroundMusic.shared.startIfNeeded()
        setupMultiplayer()
        setupAppLifecycleAutoSave()
    }

    func resetInputState() {
        moveInput = .zero
        verticalInput = 0.0
    }

    private func setupAppLifecycleAutoSave() {
        let center = NotificationCenter.default
        let saveHandler: (Notification) -> Void = { [weak self] _ in
            Task { @MainActor in
                self?.resetInputState()
                self?.saveCurrentWorld(silent: true)
            }
        }
        center.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main, using: saveHandler)
        center.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main, using: saveHandler)
        center.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main, using: saveHandler)
        center.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in
                self?.startMultiplayerServices()
            }
        }
    }

    // MARK: - Control Layout Persistence

    private func loadControlLayout() {
        if let data = UserDefaults.standard.data(forKey: controlLayoutKey),
           let decoded = try? JSONDecoder().decode(ControlLayoutConfig.self, from: data) {
            controlLayout = decoded
            if UserDefaults.standard.object(forKey: "blockbuild_speed_v31_migrated") == nil {
                controlLayout.movementSpeedMultiplier = 1.0
                UserDefaults.standard.set(true, forKey: "blockbuild_speed_v31_migrated")
                saveControlLayout()
            }
            if UserDefaults.standard.object(forKey: "blockbuild_door_btn_v2_migrated") == nil {
                if controlLayout.doorButtonOffsetY == -90 || controlLayout.doorButtonOffsetY == 0 {
                    controlLayout.doorButtonOffsetY = -180
                }
                UserDefaults.standard.set(true, forKey: "blockbuild_door_btn_v2_migrated")
                saveControlLayout()
            }
        }
    }

    func saveControlLayout() {
        if let data = try? JSONEncoder().encode(controlLayout) {
            UserDefaults.standard.set(data, forKey: controlLayoutKey)
        }
    }

    func finishEditingControls() {
        isEditingControls = false
        saveControlLayout()
        statusToast = "Controls saved!"
    }

    func resetControlLayout() {
        controlLayout = .default
        saveControlLayout()
        statusToast = "Control layout reset to default"
    }

    // MARK: - Geometries & Lowering Water / Door / Trapdoor Shapes

    private func setupGeometries() {
        for type in BlockType.allCases {
            let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
            box.materials = type.materials(for: currentTexturePack)
            sharedGeometries[type] = box
        }

        // Full block size water (1.0 x 1.0 x 1.0) like normal blocks
        let wBox = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        wBox.materials = BlockType.water.materials(for: currentTexturePack)
        for lvl in 1...4 {
            waterLevelGeometries[lvl] = wBox
        }

        // Door geometries (closed vs open)
        doorClosedGeo = SCNBox(width: 1.0, height: 1.0, length: 0.20, chamferRadius: 0.0)
        doorClosedGeo.materials = BlockType.door.materials(for: currentTexturePack)

        doorOpenGeo = SCNBox(width: 0.20, height: 1.0, length: 1.0, chamferRadius: 0.0)
        doorOpenGeo.materials = BlockType.door.materials(for: currentTexturePack)

        // Roof stepped geometries
        roofBaseGeo = SCNBox(width: 1.0, height: 0.50, length: 1.0, chamferRadius: 0.0)
        roofBaseGeo.materials = BlockType.roof.materials(for: currentTexturePack)

        roofStepGeo = SCNBox(width: 1.0, height: 0.50, length: 0.50, chamferRadius: 0.0)
        roofStepGeo.materials = BlockType.roof.materials(for: currentTexturePack)

        // Roof corner step geometry: quarter-cube (0.50 x 0.50 x 0.50) - half the top of normal stair
        roofCornerStepGeo = SCNBox(width: 0.50, height: 0.50, length: 0.50, chamferRadius: 0.0)
        roofCornerStepGeo.materials = BlockType.roofCorner.materials(for: currentTexturePack)

        // Slab geometry (1.0 x 0.50 x 1.0) - based off the roof block
        slabGeo = SCNBox(width: 1.0, height: 0.50, length: 1.0, chamferRadius: 0.0)
        slabGeo.materials = BlockType.slab.materials(for: currentTexturePack)
    }

    func roofAngle(for direction: Int) -> Float {
        switch direction {
        case 0: return 0.0           // North (-Z)
        case 1: return -.pi / 2.0    // East (+X)
        case 2: return .pi           // South (+Z)
        case 3: return .pi / 2.0     // West (-X)
        default: return 0.0
        }
    }

    func playerFacingDirection() -> Int {
        let dir = cameraForwardVector()
        if abs(dir.z) >= abs(dir.x) {
            return (dir.z <= 0) ? 0 : 2 // 0: North (-Z), 2: South (+Z)
        } else {
            return (dir.x > 0) ? 1 : 3  // 1: East (+X), 3: West (-X)
        }
    }

    private func waterHeight(forLevel level: Int) -> Float {
        return 1.0
    }

    private func setupScene() {
        scene.background.contents = currentShader.skyColor
        scene.fogStartDistance = 0.0
        scene.fogEndDistance = 0.0
        scene.fogColor = currentShader.fogColor

        let ambientNode = SCNNode()
        let ambLight = SCNLight()
        ambLight.type = .ambient
        ambLight.intensity = currentShader.ambientIntensity
        ambLight.color = currentShader.ambientColor
        ambientNode.light = ambLight
        ambientLight = ambLight
        scene.rootNode.addChildNode(ambientNode)

        let sNode = SCNNode()
        let sLight = SCNLight()
        sLight.type = .directional
        sLight.intensity = currentShader.sunIntensity
        sLight.color = currentShader.sunColor
        sLight.castsShadow = currentShader.castsShadows
        sNode.light = sLight
        sNode.eulerAngles = currentShader.sunEulerAngles
        sunLight = sLight
        sunNode = sNode
        scene.rootNode.addChildNode(sNode)

        let camera = SCNCamera()
        camera.fieldOfView = 74
        camera.zNear = 0.1
        camera.zFar = 800.0
        cameraNode.camera = camera
        updateCameraTransform()
        scene.rootNode.addChildNode(cameraNode)

        scene.rootNode.addChildNode(blocksRootNode)
        scene.rootNode.addChildNode(playersRootNode)
        applyRenderDistance()

        // Apply shader lighting & post-processing effects
        applyShaderPreset(currentShader, isInitial: true)

        // Build Local Player Avatar Node (for 3rd person views) & First Person Arm
        refreshLocalPlayerAvatarNode()

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

    // MARK: - Shaders Engine & Real-Time Performance Stabilization

    func applyShaderPreset(_ preset: GameShaderPreset, isInitial: Bool = false) {
        currentShader = preset
        UserDefaults.standard.set(preset.rawValue, forKey: "blockbuild_active_shader")

        // 1. Sky Color
        scene.background.contents = preset.skyColor

        // 2. Atmospheric Distance Fog (smooth distance fade matching Minecraft OptiFine/Iris fog culling)
        let dist = Float(renderDistance * 16)
        if preset == .vanilla {
            scene.fogStartDistance = 0.0
            scene.fogEndDistance = 0.0
            scene.fogColor = preset.fogColor
        } else {
            scene.fogStartDistance = CGFloat(max(8.0, dist * 0.40))
            scene.fogEndDistance = CGFloat(dist * 0.94)
            scene.fogColor = preset.fogColor
        }

        // 3. Sun Directional Light & Minecraft-style Stabilized Shadow Box
        if let sun = sunLight {
            sun.color = preset.sunColor
            sun.intensity = preset.sunIntensity
            sun.castsShadow = preset.castsShadows

            if preset.castsShadows {
                // Stabilized shadow map settings to guarantee zero lag:
                // - Tight orthographic projection focused directly around active player
                // - Fast 1024x1024 shadow map resolution
                // - Deferred shadow rendering mode
                // - Clamped sample count (2 or 4 samples for smooth anti-aliased shadows without GPU stall)
                sun.shadowMode = .deferred
                sun.orthographicScale = 28.0
                sun.zNear = 0.5
                sun.zFar = 60.0
                sun.shadowMapSize = CGSize(width: 1024, height: 1024)
                sun.shadowSampleCount = isPerformanceStabilizationEnabled ? 2 : 4
                sun.shadowRadius = 1.4
                sun.shadowColor = preset.shadowColor
                sun.shadowBias = 0.002
            }
        }
        if let sNode = sunNode {
            sNode.eulerAngles = preset.sunEulerAngles
            sNode.position = SCNVector3(playerPosition.x, playerPosition.y + 14.0, playerPosition.z)
        }

        // 4. Ambient Light
        if let amb = ambientLight {
            amb.color = preset.ambientColor
            amb.intensity = preset.ambientIntensity
        }

        // 5. Camera Post-Processing (HDR & Bloom)
        if let camera = cameraNode.camera {
            camera.wantsHDR = (preset != .vanilla)
            camera.bloomIntensity = preset.bloomIntensity
            camera.bloomThreshold = preset.bloomThreshold
            camera.bloomBlurRadius = isPerformanceStabilizationEnabled ? min(preset.bloomBlurRadius, 10.0) : preset.bloomBlurRadius
            camera.vignettingIntensity = preset.vignettingIntensity
            camera.vignettingPower = preset.vignettingPower
            camera.colorFringeStrength = preset.colorFringeStrength
        }

        // 6. Water Shaders (GPU surface modifier for wave shimmers)
        updateWaterShaderModifiers(preset: preset)

        if !isInitial {
            statusToast = "Applied \(preset.displayName)"
        }
    }

    private func updateWaterShaderModifiers(preset: GameShaderPreset) {
        let waterMat = sharedGeometries[.water]?.firstMaterial
        if preset.hasWaterWaves {
            let waterSurfaceShader = """
            #pragma body
            float wave = sin(_surface.diffuseTexcoord.x * 22.0 + u_time * 2.6) * cos(_surface.diffuseTexcoord.y * 22.0 + u_time * 2.0);
            _surface.specular = vec4(0.55, 0.70, 0.95, 1.0) * max(0.0, wave * 0.5 + 0.5);
            _surface.shininess = 28.0;
            """
            waterMat?.shaderModifiers = [.surface: waterSurfaceShader]
        } else {
            waterMat?.shaderModifiers = nil
        }
    }

    func setRenderDistance(_ distance: Int) {
        let clamped = max(2, min(8, distance))
        guard clamped != renderDistance else { return }
        renderDistance = clamped
    }

    func setFPSLimit(_ limit: Int) {
        let valid = [0, 30, 40, 60]
        let chosen = valid.contains(limit) ? limit : 60
        guard chosen != fpsLimit else { return }
        fpsLimit = chosen
    }

    func applyRenderDistance() {
        // Render distance strictly governs horizontal chunk streaming (X and Z)
        // and does NOT restrict or fog out the vertical Y axis (sky islands, mountain peaks, and void).
        cameraNode.camera?.zFar = 800.0
        scene.fogStartDistance = 0.0
        scene.fogEndDistance = 0.0
        updateStreamedChunks(force: true)
    }

    func toggleMusic() {
        isMusicEnabled.toggle()
        AlphaBackgroundMusic.shared.setEnabled(isMusicEnabled)
        statusToast = isMusicEnabled ? "Music: ON" : "Music: OFF"
    }

    // MARK: - Camera Perspective (1st Person & 3rd Person F5 Views)

    func toggleCameraPerspective() {
        let nextRaw = (cameraPerspective.rawValue + 1) % CameraPerspective.allCases.count
        cameraPerspective = CameraPerspective(rawValue: nextRaw) ?? .firstPerson
        updateCameraTransform()
        statusToast = cameraPerspective.displayName
    }

    func setupFirstPersonArm() {
        firstPersonArmNode?.removeFromParentNode()
        firstPersonArmNode = nil
        firstPersonHeldBlockNode = nil
    }

    func updateHeldBlockMaterial() {
        firstPersonHeldBlockNode?.geometry?.materials = selectedBlock.materials(for: currentTexturePack)
    }

    func punchFirstPersonArm() {
        guard let arm = firstPersonArmNode, cameraPerspective == .firstPerson else { return }
        let swing = SCNAction.sequence([
            SCNAction.rotateBy(x: -0.35, y: 0.15, z: 0.08, duration: 0.06),
            SCNAction.rotateBy(x: 0.35, y: -0.15, z: -0.08, duration: 0.08)
        ])
        arm.runAction(swing)
    }

    func refreshLocalPlayerAvatarNode() {
        localPlayerAvatarNode?.removeFromParentNode()
        let created = Self.makeBlockyPlayerAvatarNode(
            name: localPlayerName.isEmpty ? "Player" : localPlayerName,
            skin: selectedSkin,
            customSkin: activeCustomSkin
        )
        created.isHidden = (cameraPerspective == .firstPerson)
        scene.rootNode.addChildNode(created)
        localPlayerAvatarNode = created

        setupFirstPersonArm()
    }

    // MARK: - Infinite Procedural World Generation Engine

    func enterGame() {
        isInGame = true
        startMultiplayerServices()
    }

    func leaveToMainMenu() {
        saveCurrentWorld(silent: true)
        isInGame = false
        disconnectMultiplayer()
        stopMultiplayerServices()
        activeJoinPrompt = nil
        discoveredHosts.removeAll()
    }

    func setSkin(_ skin: PlayerSkin) {
        selectedSkin = skin
        activeCustomSkin = nil
        UserDefaults.standard.set(skin.rawValue, forKey: "blockbuild_selected_skin")
        UserDefaults.standard.removeObject(forKey: "blockbuild_active_custom_skin_id")
        refreshLocalPlayerAvatarNode()
        broadcastPlayerPoseIfNeeded()
        if isInGame {
            startMultiplayerServices()
        }
        statusToast = "Skin: \(skin.displayName)"
    }

    // MARK: - AI Game Studio Helpers

    func loadCustomWorldTypes() {
        if let data = UserDefaults.standard.data(forKey: "blockbuild_custom_world_types"),
           let decoded = try? JSONDecoder().decode([CustomWorldType].self, from: data) {
            self.customWorldTypes = decoded
        }
    }

    func saveCustomWorldType(_ type: CustomWorldType) {
        if let idx = customWorldTypes.firstIndex(where: { $0.id == type.id || $0.name.lowercased() == type.name.lowercased() }) {
            customWorldTypes[idx] = type
        } else {
            customWorldTypes.insert(type, at: 0)
        }
        persistCustomWorldTypes()
        statusToast = "Saved world type '\(type.name)'"
    }

    func deleteCustomWorldType(id: UUID) {
        customWorldTypes.removeAll(where: { $0.id == id })
        if activeCustomWorld?.id == id {
            activeCustomWorld = nil
        }
        persistCustomWorldTypes()
    }

    private func persistCustomWorldTypes() {
        if let encoded = try? JSONEncoder().encode(customWorldTypes) {
            UserDefaults.standard.set(encoded, forKey: "blockbuild_custom_world_types")
        }
    }

    func loadCustomSkins() {
        if let data = UserDefaults.standard.data(forKey: "blockbuild_custom_skins"),
           let decoded = try? JSONDecoder().decode([CustomSkin].self, from: data) {
            self.customSkins = decoded
        }
        if let activeID = UserDefaults.standard.string(forKey: "blockbuild_active_custom_skin_id"),
           let uuid = UUID(uuidString: activeID),
           let skin = customSkins.first(where: { $0.id == uuid }) {
            self.activeCustomSkin = skin
        }
    }

    func saveCustomSkin(_ skin: CustomSkin) {
        if let idx = customSkins.firstIndex(where: { $0.id == skin.id }) {
            customSkins[idx] = skin
        } else {
            customSkins.insert(skin, at: 0)
        }
        persistCustomSkins()
        statusToast = "Saved skin '\(skin.name)'"
    }

    func deleteCustomSkin(id: UUID) {
        customSkins.removeAll(where: { $0.id == id })
        if activeCustomSkin?.id == id {
            activeCustomSkin = nil
            UserDefaults.standard.removeObject(forKey: "blockbuild_active_custom_skin_id")
        }
        persistCustomSkins()
    }

    func equipCustomSkin(_ skin: CustomSkin) {
        activeCustomSkin = skin
        UserDefaults.standard.set(skin.id.uuidString, forKey: "blockbuild_active_custom_skin_id")
        refreshLocalPlayerAvatarNode()
        broadcastPlayerPoseIfNeeded()
        statusToast = "Equipped skin '\(skin.name)'"
    }

    func clearActiveCustomSkin() {
        activeCustomSkin = nil
        UserDefaults.standard.removeObject(forKey: "blockbuild_active_custom_skin_id")
        refreshLocalPlayerAvatarNode()
        broadcastPlayerPoseIfNeeded()
    }

    private func persistCustomSkins() {
        if let encoded = try? JSONEncoder().encode(customSkins) {
            UserDefaults.standard.set(encoded, forKey: "blockbuild_custom_skins")
        }
    }

    func regenerateWithCustomWorld(_ custom: CustomWorldType, customName: String? = nil) {
        saveCurrentWorld(silent: true)
        isHostingMultiplayer = true
        activeCustomWorld = custom
        let newSeed = Int.random(in: 1000...999_999)
        startNewWorld(seed: newSeed, type: custom.baseWorldType, customName: customName ?? custom.name)
        applyAtmosphere()
        saveCurrentWorld(silent: true)
        isInGame = true
        startMultiplayerServices()
        broadcastWorldSnapshotToPeers()
    }

    func applyAtmosphere() {
        if let custom = activeCustomWorld {
            scene.background.contents = UIColor(red: CGFloat(custom.skyRed), green: CGFloat(custom.skyGreen), blue: CGFloat(custom.skyBlue), alpha: 1.0)
            scene.fogColor = UIColor(red: CGFloat(custom.fogRed), green: CGFloat(custom.fogGreen), blue: CGFloat(custom.fogBlue), alpha: 1.0)
            scene.fogStartDistance = 15.0
            scene.fogEndDistance = CGFloat(Float(renderDistance * chunkSize) * 1.4)
        } else if currentWorldType == .caveLands {
            scene.background.contents = UIColor(red: 0.06, green: 0.08, blue: 0.12, alpha: 1.0)
            scene.fogColor = UIColor(red: 0.08, green: 0.10, blue: 0.15, alpha: 1.0)
            scene.fogStartDistance = 8.0
            scene.fogEndDistance = 28.0
        } else if currentWorldType == .desert {
            scene.background.contents = UIColor(red: 0.82, green: 0.78, blue: 0.65, alpha: 1.0)
            scene.fogColor = UIColor(red: 0.88, green: 0.82, blue: 0.70, alpha: 1.0)
            scene.fogStartDistance = 0.0
            scene.fogEndDistance = 0.0
        } else {
            scene.background.contents = UIColor(red: 0.60, green: 0.80, blue: 1.0, alpha: 1.0)
            scene.fogColor = UIColor(red: 0.65, green: 0.83, blue: 1.0, alpha: 1.0)
            scene.fogStartDistance = 0.0
            scene.fogEndDistance = 0.0
        }
    }

    func setTexturePack(_ pack: TexturePack) {
        guard currentTexturePack != pack else { return }
        currentTexturePack = pack
        UserDefaults.standard.set(pack.rawValue, forKey: "blockbuild_texture_pack")
        applyTexturePack()
    }

    func applyTexturePack() {
        BlockType.activeTexturePack = currentTexturePack
        textureUpdateVersion += 1
        objectWillChange.send()

        for type in BlockType.allCases {
            sharedGeometries[type]?.materials = type.materials(for: currentTexturePack)
        }

        doorClosedGeo.materials = BlockType.door.materials(for: currentTexturePack)
        doorOpenGeo.materials = BlockType.door.materials(for: currentTexturePack)
        roofBaseGeo.materials = BlockType.roof.materials(for: currentTexturePack)
        roofStepGeo.materials = BlockType.roof.materials(for: currentTexturePack)
        roofCornerStepGeo.materials = BlockType.roofCorner.materials(for: currentTexturePack)
        slabGeo.materials = BlockType.slab.materials(for: currentTexturePack)

        waterMaskedGeometries.removeAll()

        for (coord, node) in blockNodes {
            if blocks[coord] == .water {
                let mask = waterFaceMask(at: coord)
                node.geometry = maskedWaterGeometry(level: 4, faceMask: mask)
            }
        }

        updateWaterShaderModifiers(preset: currentShader)

        statusToast = "Applied \(currentTexturePack.displayName) Pack"
    }

    func regenerateNewWorld(type: WorldType = .standard, customName: String? = nil) {
        // Save the current world before generating a new one so no progress is lost
        saveCurrentWorld(silent: true)
        isHostingMultiplayer = true
        activeCustomWorld = nil
        let newSeed = Int.random(in: 1000...999_999)
        startNewWorld(seed: newSeed, type: type, customName: customName)
        saveCurrentWorld(silent: true)
        isInGame = true
        startMultiplayerServices()
        broadcastWorldSnapshotToPeers()
    }

    private func startNewWorld(seed: Int, type: WorldType = .standard, customName: String?) {
        clearAllWorldState()

        currentWorldID = UUID()
        worldSeed = seed
        currentWorldType = type
        currentArchetype = WorldArchetype(rawValue: abs(seed) % WorldArchetype.allCases.count) ?? .alphaCliffs

        let trimmed = customName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        currentWorldName = trimmed.isEmpty ? "\(activeCustomWorld?.name ?? type.displayName) #\(seed % 1000)" : trimmed

        configureNoiseGenerators(seed: seed)
        applyAtmosphere()

        if let custom = activeCustomWorld, custom.hasWaterfalls {
            // Spawn player by river bank facing North directly towards the waterfall gorge
            let spawnFloorY: Float = 6.0
            playerPosition = SCNVector3(3.5, spawnFloorY + 1.8, 4.0)
            yaw = 0.0 // Facing North straight at the waterfalls!
            pitch = -0.15
        } else if let custom = activeCustomWorld, custom.hasVillages {
            // Spawn player right on the Village Town Square Plaza facing North towards the Town Hall and Central Fountain
            let spawnFloorY: Float = 6.0
            playerPosition = SCNVector3(5.0, spawnFloorY + 1.8, 2.5)
            yaw = 0.0 // Facing North straight at the Town Hall
            pitch = -0.10
        } else if type == .skyIslands {
            let spawnGround = surfaceHeightAt(x: 0, z: 0)
            playerPosition = SCNVector3(0, Float(max(spawnGround, 22)) + 4.5, 0)
        } else if type == .flat {
            playerPosition = SCNVector3(0, 5.5, 0)
        } else if type == .desert {
            let spawnGround = surfaceHeightAt(x: 0, z: 0)
            playerPosition = SCNVector3(0, Float(max(spawnGround, seaLevel)) + 6.5, 0)
        } else if type == .amplified {
            let spawnGround = surfaceHeightAt(x: 0, z: 0)
            playerPosition = SCNVector3(0, Float(max(spawnGround, seaLevel)) + 6.5, 0)
        } else if type == .caveLands {
            let spawnGround = surfaceHeightAt(x: 0, z: 0)
            playerPosition = SCNVector3(0, Float(max(spawnGround, 4)) + 2.0, 0)
        } else if type == .oceanWorld {
            let spawnGround = surfaceHeightAt(x: 0, z: 0)
            playerPosition = SCNVector3(0, Float(max(spawnGround, 11)) + 2.0, 0)
        } else if type == .seaIslands {
            let spawnGround = surfaceHeightAt(x: 0, z: 0)
            playerPosition = SCNVector3(0, Float(max(spawnGround, 6)) + 2.5, 0)
        } else {
            let spawnGround = surfaceHeightAt(x: 0, z: 10)
            playerPosition = SCNVector3(0, Float(max(spawnGround, seaLevel)) + 6.5, 10)
        }
        yaw = 0.0
        pitch = -0.35

        updateStreamedChunks(force: true)
        resolveStuckPositionIfNeeded()
        updateCameraTransform()
        statusToast = "\(type.displayName) (\(type == .skyIslands ? "Open Void" : "Infinite"))"
    }

    private func configureNoiseGenerators(seed: Int) {
        primaryNoise = SeededPerlinNoise(seed: seed)
        warpNoise = SeededPerlinNoise(seed: seed &* 1664525 &+ 1013904223)
        ridgeNoise = SeededPerlinNoise(seed: seed &* 22695477 &+ 1)
        biomeNoise = SeededPerlinNoise(seed: seed &+ 7919)
    }

    private func surfaceHeightAt(x: Int, z: Int) -> Int {
        if let custom = activeCustomWorld {
            let fx = Float(x)
            let fz = Float(z)
            if custom.isFloatingIslands {
                let dist = sqrt(fx * fx + fz * fz)
                if dist < 26.0 { return Int(custom.baseHeight) }
                let wx = fx + warpNoise.noise(fx * custom.warpScale, fz * custom.warpScale) * 16.0
                let wz = fz + warpNoise.noise((fx + 97.0) * custom.warpScale, (fz - 53.0) * custom.warpScale) * 16.0
                let islandNoise = primaryNoise.fbm(x: wx * custom.noiseFrequency, y: wz * custom.noiseFrequency, octaves: 3)
                if islandNoise > -0.10 {
                    let ridge = ridgeNoise.noise(wx * 0.04, wz * 0.04)
                    return max(16, min(28, Int(custom.baseHeight + ridge * custom.heightVariance)))
                }
                return -100 // void
            } else if custom.isSubterranean {
                let wx = fx + warpNoise.noise(fx * custom.warpScale, fz * custom.warpScale) * 10.0
                let wz = fz + warpNoise.noise((fx + 43.0) * custom.warpScale, (fz - 31.0) * custom.warpScale) * 10.0
                let rawFloor = custom.baseHeight + primaryNoise.fbm(x: wx * custom.noiseFrequency, y: wz * custom.noiseFrequency, octaves: 3) * custom.heightVariance
                return max(3, min(10, Int(round(rawFloor))))
            } else if custom.baseWorldType == .flat || custom.heightVariance <= 0.01 {
                return Int(custom.baseHeight)
            } else {
                let wx = fx + warpNoise.noise(fx * custom.warpScale, fz * custom.warpScale) * 16.0
                let wz = fz + warpNoise.noise((fx + 77.0) * custom.warpScale, (fz - 43.0) * custom.warpScale) * 16.0
                let base = primaryNoise.fbm(x: wx * custom.noiseFrequency, y: wz * custom.noiseFrequency, octaves: 4, persistence: 0.55, lacunarity: 2.1)
                let ridge = 1.0 - abs(ridgeNoise.noise(wx * 0.035, wz * 0.035))
                let raw = custom.baseHeight + base * custom.heightVariance + (ridge * 4.0)
                return max(1, min(36, Int(round(raw))))
            }
        }

        switch currentWorldType {
        case .flat:
            return 4

        case .skyIslands:
            let fx = Float(x)
            let fz = Float(z)
            let dist = sqrt(fx * fx + fz * fz)
            if dist < 26.0 {
                return 22
            }
            let warpScale: Float = 0.025
            let wx = fx + warpNoise.noise(fx * warpScale, fz * warpScale) * 16.0
            let wz = fz + warpNoise.noise((fx + 97.0) * warpScale, (fz - 53.0) * warpScale) * 16.0
            let islandNoise = primaryNoise.fbm(x: wx * 0.032, y: wz * 0.032, octaves: 3)
            if islandNoise > -0.10 {
                let ridge = ridgeNoise.noise(wx * 0.04, wz * 0.04)
                return max(16, min(28, Int(22.0 + ridge * 6.0)))
            }
            return -100 // void

        case .amplified:
            let fx = Float(x)
            let fz = Float(z)
            let warpScale: Float = 0.02
            let wx = fx + warpNoise.noise(fx * warpScale, fz * warpScale) * 22.0
            let wz = fz + warpNoise.noise((fx + 83.0) * warpScale, (fz - 47.0) * warpScale) * 22.0
            let base = primaryNoise.fbm(x: wx * 0.022, y: wz * 0.022, octaves: 5, persistence: 0.6, lacunarity: 2.2)
            let ridge = 1.0 - abs(ridgeNoise.noise(wx * 0.035, wz * 0.035))
            let raw = 5.0 + base * 20.0 + (ridge * ridge * 12.0)
            return max(2, min(36, Int(round(raw))))

        case .desert:
            let fx = Float(x)
            let fz = Float(z)
            let warpScale: Float = 0.015
            let wx = fx + warpNoise.noise(fx * warpScale, fz * warpScale) * 12.0
            let wz = fz + warpNoise.noise((fx + 51.0) * warpScale, (fz - 73.0) * warpScale) * 12.0
            let dunes = primaryNoise.fbm(x: wx * 0.018, y: wz * 0.018, octaves: 4, persistence: 0.5, lacunarity: 2.0)
            let raw = 6.0 + dunes * 9.0
            return max(1, min(16, Int(round(raw))))

        case .caveLands:
            let fx = Float(x)
            let fz = Float(z)
            let warpScale: Float = 0.02
            let wx = fx + warpNoise.noise(fx * warpScale, fz * warpScale) * 10.0
            let wz = fz + warpNoise.noise((fx + 43.0) * warpScale, (fz - 31.0) * warpScale) * 10.0
            let rawFloor = 4.5 + primaryNoise.fbm(x: wx * 0.025, y: wz * 0.025, octaves: 3) * 3.5
            return max(3, min(10, Int(round(rawFloor))))

        case .oceanWorld:
            let fx = Float(x)
            let fz = Float(z)
            let dist = sqrt(fx * fx + fz * fz)
            if dist < 10.0 {
                return 11 // starting sandbar above ocean water level (10)
            }
            let seabed = 3.0 + primaryNoise.fbm(x: fx * 0.02, y: fz * 0.02, octaves: 3) * 3.0
            let stackNoise = ridgeNoise.noise(fx * 0.045, fz * 0.045)
            if stackNoise > 0.65 {
                return max(11, min(15, Int(11.0 + (stackNoise - 0.65) * 16.0)))
            }
            return max(2, min(7, Int(round(seabed))))

        case .seaIslands:
            let fx = Float(x)
            let fz = Float(z)
            let dist = sqrt(fx * fx + fz * fz)
            let isSpawnIsland = (dist < 22.0)
            let warpScale: Float = 0.02
            let wx = fx + warpNoise.noise(fx * warpScale, fz * warpScale) * 14.0
            let wz = fz + warpNoise.noise((fx + 61.0) * warpScale, (fz - 41.0) * warpScale) * 14.0
            let islandNoise = primaryNoise.fbm(x: wx * 0.035, y: wz * 0.035, octaves: 4)

            if isSpawnIsland || islandNoise > -0.05 {
                let hill = max(0.0, islandNoise + 0.05)
                let height = 6.0 + hill * 18.0
                return max(6, min(18, Int(round(height))))
            } else {
                let seabed = 2.0 + primaryNoise.fbm(x: wx * 0.02, y: wz * 0.02, octaves: 2) * 2.0
                return max(1, min(5, Int(round(seabed))))
            }

        case .standard:
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
    }

    private func generateCustomChunkData(
        chunk: ChunkCoord,
        minX: Int,
        maxX: Int,
        minZ: Int,
        maxZ: Int,
        custom: CustomWorldType,
        localBlocks: inout [BlockCoord: BlockType],
        heights: inout [Int: [Int: Int]],
        waterSourceBlocks: inout Set<BlockCoord>
    ) {
        if custom.isFloatingIslands {
            let warpScale = custom.warpScale
            for x in minX..<maxX {
                heights[x] = [:]
                for z in minZ..<maxZ {
                    let fx = Float(x)
                    let fz = Float(z)
                    let dist = sqrt(fx * fx + fz * fz)
                    let isSpawnIsland = (dist < 26.0)

                    let wx = fx + warpNoise.noise(fx * warpScale, fz * warpScale) * 16.0
                    let wz = fz + warpNoise.noise((fx + 97.0) * warpScale, (fz - 53.0) * warpScale) * 16.0
                    let islandNoise = primaryNoise.fbm(x: wx * custom.noiseFrequency, y: wz * custom.noiseFrequency, octaves: 3)

                    if isSpawnIsland || islandNoise > -0.10 {
                        let topY = isSpawnIsland ? Int(custom.baseHeight) : max(16, min(28, Int(custom.baseHeight + ridgeNoise.noise(wx * 0.04, wz * 0.04) * custom.heightVariance)))
                        let thickness = isSpawnIsland ? 7 : max(3, Int(4.0 + (islandNoise + 0.10) * 8.0))
                        let botY = max(8, topY - thickness)
                        heights[x]?[z] = topY

                        for y in botY...topY {
                            let c = BlockCoord(x: x, y: y, z: z)
                            if y == topY {
                                localBlocks[c] = custom.surfaceBlock
                            } else if y >= topY - 2 {
                                localBlocks[c] = custom.subsurfaceBlock
                            } else {
                                localBlocks[c] = custom.deepBlock
                            }
                        }
                    } else {
                        heights[x]?[z] = -100 // void
                    }
                }
            }
        } else if custom.isSubterranean {
            let ceilingY = 30
            for x in minX..<maxX {
                heights[x] = [:]
                for z in minZ..<maxZ {
                    let floorH = surfaceHeightAt(x: x, z: z)
                    heights[x]?[z] = floorH

                    for y in 0...floorH {
                        let c = BlockCoord(x: x, y: y, z: z)
                        localBlocks[c] = (y == floorH) ? custom.surfaceBlock : (y >= floorH - 2 ? custom.subsurfaceBlock : custom.deepBlock)
                    }

                    // Vault ceiling
                    for y in ceilingY...33 {
                        localBlocks[BlockCoord(x: x, y: y, z: z)] = custom.deepBlock
                    }
                }
            }
        } else if custom.baseWorldType == .flat || custom.heightVariance <= 0.01 {
            let flatH = max(1, Int(custom.baseHeight))
            for x in minX..<maxX {
                heights[x] = [:]
                for z in minZ..<maxZ {
                    heights[x]?[z] = flatH
                    for y in 0...flatH {
                        let c = BlockCoord(x: x, y: y, z: z)
                        localBlocks[c] = (y == flatH) ? custom.surfaceBlock : (y >= flatH - 2 ? custom.subsurfaceBlock : custom.deepBlock)
                    }
                }
            }
        } else {
            for x in minX..<maxX {
                heights[x] = [:]
                for z in minZ..<maxZ {
                    let h = surfaceHeightAt(x: x, z: z)
                    heights[x]?[z] = h

                    for y in 0...h {
                        let c = BlockCoord(x: x, y: y, z: z)
                        if y == h {
                            localBlocks[c] = custom.surfaceBlock
                        } else if y >= h - 2 {
                            localBlocks[c] = custom.subsurfaceBlock
                        } else {
                            localBlocks[c] = custom.deepBlock
                        }
                    }

                    if custom.waterLevel >= 0 && h < custom.waterLevel {
                        for y in (h + 1)...custom.waterLevel {
                            let wCoord = BlockCoord(x: x, y: y, z: z)
                            localBlocks[wCoord] = .water
                            waterSourceBlocks.insert(wCoord)
                        }
                    }
                }
            }
        }

        // Common chunk hash and settlement layout flags
        let chunkHash = abs((chunk.cx &* 73856093) ^ (chunk.cz &* 19349663) ^ (worldSeed &* 83492791)) % 100
        let isSpawnSettlement = custom.hasVillages && (abs(chunk.cx) <= 1 && abs(chunk.cz) <= 1)
        let densityThreshold = Int(max(0.20, custom.villageDensity) * 100.0)
        let isVillageChunk = isSpawnSettlement || (custom.hasVillages && chunkHash < densityThreshold) || (custom.structureType != "none" && chunkHash < 35)

        // Custom World Waterfalls & Alpine Gorges
        if custom.hasWaterfalls {
            // 1. Guaranteed Spectacular Waterfall Gorge at Spawn (Chunk cx: 0, cz: 1)
            if chunk.cx == 0 && chunk.cz == 1 {
                let cliffZ = minZ + 8
                let cliffTopY = 25
                let groundY = 6

                // Clear the gorge arena from minZ to cliffZ so waterfalls are completely open to view
                for x in minX..<maxX {
                    for z in minZ..<cliffZ {
                        for y in (groundY + 1)...32 {
                            localBlocks.removeValue(forKey: BlockCoord(x: x, y: y, z: z))
                        }
                        heights[x]?[z] = groundY
                    }
                }

                // Raise sheer rock cliff face across the north half of the chunk
                for x in minX..<maxX {
                    for z in cliffZ..<maxZ {
                        for y in 0...cliffTopY {
                            let c = BlockCoord(x: x, y: y, z: z)
                            localBlocks[c] = (y >= cliffTopY - 1) ? .stone : .smoothStone
                        }
                        heights[x]?[z] = cliffTopY
                    }
                }

                // Carve high clifftop water spring reservoir (x from minX+3 to minX+13, z from cliffZ+1 to cliffZ+4)
                for x in (minX + 3)...(minX + 13) {
                    for z in (cliffZ + 1)...(cliffZ + 4) {
                        for y in (cliffTopY - 2)...cliffTopY {
                            let c = BlockCoord(x: x, y: y, z: z)
                            if y == cliffTopY - 2 {
                                localBlocks[c] = .stone
                            } else {
                                localBlocks[c] = .water
                                waterSourceBlocks.insert(c)
                            }
                        }
                    }
                }

                // Multiple roaring waterfall chutes pouring down the cliff face:
                let chutes = [(minX + 4)...(minX + 6), (minX + 9)...(minX + 11)]
                for chute in chutes {
                    for x in chute {
                        // Open notch in cliff lip
                        localBlocks.removeValue(forKey: BlockCoord(x: x, y: cliffTopY, z: cliffZ))
                        localBlocks.removeValue(forKey: BlockCoord(x: x, y: cliffTopY - 1, z: cliffZ))

                        // Falling water curtain
                        for y in (groundY + 1)...(cliffTopY - 1) {
                            localBlocks.removeValue(forKey: BlockCoord(x: x, y: y, z: cliffZ - 1))
                            let wCoord = BlockCoord(x: x, y: y, z: cliffZ)
                            localBlocks[wCoord] = .water
                            waterSourceBlocks.insert(wCoord)
                        }
                    }
                }

                // Wide deep rocky plunge basin at base of waterfalls
                for x in (minX + 3)...(minX + 12) {
                    for z in (cliffZ - 5)...(cliffZ - 1) {
                        for y in (groundY - 2)...groundY {
                            let c = BlockCoord(x: x, y: y, z: z)
                            if y == groundY - 2 {
                                localBlocks[c] = .stone
                            } else {
                                localBlocks[c] = .water
                                waterSourceBlocks.insert(c)
                            }
                        }
                        heights[x]?[z] = groundY
                    }
                }

                // River stream flowing south across chunk (0, 1) toward spawn chunk (0, 0)
                for z in minZ..<(cliffZ - 5) {
                    for x in (minX + 6)...(minX + 10) {
                        for y in (groundY - 1)...groundY {
                            let c = BlockCoord(x: x, y: y, z: z)
                            if y == groundY - 1 {
                                localBlocks[c] = .sand
                            } else {
                                localBlocks[c] = .water
                                waterSourceBlocks.insert(c)
                            }
                        }
                        heights[x]?[z] = groundY
                    }
                }
            }

            // 1b. Chunk (0, 0) river connection & scenic viewing bank
            if chunk.cx == 0 && chunk.cz == 0 {
                let groundY = 6
                // Continue river channel from north border (z = 15) down south
                for z in 0..<16 {
                    for x in (minX + 6)...(minX + 10) {
                        for y in (groundY - 1)...groundY {
                            let c = BlockCoord(x: x, y: y, z: z)
                            if y == groundY - 1 {
                                localBlocks[c] = .sand
                            } else {
                                localBlocks[c] = .water
                                waterSourceBlocks.insert(c)
                            }
                        }
                        heights[x]?[z] = groundY
                    }
                    // Clear air above river
                    for x in (minX + 6)...(minX + 10) {
                        for y in (groundY + 1)...14 {
                            localBlocks.removeValue(forKey: BlockCoord(x: x, y: y, z: z))
                        }
                    }
                }
            }

            // 2. Procedural Mountain Cliff Waterfalls in other chunks
            let wfThreshold = Int(max(0.40, custom.waterfallDensity) * 75.0)
            if chunkHash < wfThreshold && !(chunk.cx == 0 && (chunk.cz == 0 || chunk.cz == 1)) {
                var placedWaterfalls = 0
                for x in (minX + 3)..<(maxX - 3) {
                    if placedWaterfalls >= 3 { break }
                    for z in (minZ + 3)..<(maxZ - 3) {
                        if placedWaterfalls >= 3 { break }
                        guard let h = heights[x]?[z], h >= 8 else { continue }

                        let neighbors = [
                            (x: x, z: z - 1),
                            (x: x, z: z + 1),
                            (x: x - 1, z: z),
                            (x: x + 1, z: z)
                        ]

                        if let target = neighbors.first(where: { (heights[$0.x]?[$0.z] ?? h) <= h - 3 }) {
                            let basinY = heights[target.x]?[target.z] ?? (h - 3)
                            let springCoord = BlockCoord(x: x, y: h, z: z)
                            localBlocks[springCoord] = .water
                            waterSourceBlocks.insert(springCoord)

                            for y in (basinY + 1)...h {
                                let airCoord = BlockCoord(x: target.x, y: y, z: target.z)
                                localBlocks.removeValue(forKey: airCoord)
                                let wCoord = BlockCoord(x: x, y: y, z: z)
                                localBlocks[wCoord] = .water
                                waterSourceBlocks.insert(wCoord)
                            }

                            for px in (target.x - 1)...(target.x + 1) {
                                for pz in (target.z - 1)...(target.z + 1) {
                                    let poolCoord = BlockCoord(x: px, y: basinY, z: pz)
                                    localBlocks[poolCoord] = .water
                                    waterSourceBlocks.insert(poolCoord)
                                }
                            }
                            placedWaterfalls += 1
                        }
                    }
                }

                // If terrain was flat in this chunk, generate an alpine waterfall bluff!
                if placedWaterfalls == 0 && (chunkHash % 3 == 0) {
                    let bluffX = minX + 8
                    let bluffZ = minZ + 8
                    let baseY = heights[bluffX]?[bluffZ] ?? 6
                    let topY = min(28, baseY + 7)
                    for bx in (bluffX - 2)...(bluffX + 2) {
                        for bz in (bluffZ - 2)...(bluffZ + 2) {
                            for y in baseY...topY {
                                localBlocks[BlockCoord(x: bx, y: y, z: bz)] = .stone
                            }
                        }
                    }
                    let spring = BlockCoord(x: bluffX, y: topY, z: bluffZ)
                    localBlocks[spring] = .water
                    waterSourceBlocks.insert(spring)
                    for y in (baseY + 1)...topY {
                        localBlocks.removeValue(forKey: BlockCoord(x: bluffX, y: y, z: bluffZ - 1))
                        let w = BlockCoord(x: bluffX, y: y, z: bluffZ)
                        localBlocks[w] = .water
                        waterSourceBlocks.insert(w)
                    }
                    for px in (bluffX - 1)...(bluffX + 1) {
                        let pool = BlockCoord(x: px, y: baseY, z: bluffZ - 1)
                        localBlocks[pool] = .water
                        waterSourceBlocks.insert(pool)
                    }
                }
            }
        }

        // Custom World Flora / Trees (suppressed in village chunks to keep architecture, squares & streets clean)
        if custom.hasTrees && custom.treeStyle != "none" && !isVillageChunk {
            let treeMinX = minX + 2
            let treeMaxX = maxX - 2
            let treeMinZ = minZ + 2
            let treeMaxZ = maxZ - 2
            for x in treeMinX..<treeMaxX {
                for z in treeMinZ..<treeMaxZ {
                    guard let h = heights[x]?[z], h > 0 && h < 30 else { continue }
                    if localBlocks[BlockCoord(x: x, y: h + 1, z: z)] != nil { continue }
                    let colHash = abs((x &* 73856093) ^ (z &* 19349663) ^ (worldSeed &* 83492791)) % 100
                    if colHash < 10 && (x % 3 == 0) && (z % 3 == 0) {
                        let trunkH = custom.treeStyle == "palm" ? 5 : 4
                        for ty in (h + 1)...(h + trunkH) {
                            localBlocks[BlockCoord(x: x, y: ty, z: z)] = .woodLog
                        }
                        let topY = h + trunkH
                        for lx in (x - 2)...(x + 2) {
                            for lz in (z - 2)...(z + 2) {
                                if abs(lx - x) <= 1 || abs(lz - z) <= 1 {
                                    localBlocks[BlockCoord(x: lx, y: topY, z: lz)] = .leaves
                                }
                            }
                        }
                        localBlocks[BlockCoord(x: x, y: topY + 1, z: z)] = .leaves
                    }
                }
            }
        }

        // Custom World Procedural Villages & Guaranteed Spawn Settlements
        if isVillageChunk {
            let style = custom.villageStyle
            let wallBlock: BlockType
            let cornerBlock: BlockType
            let roofBlock: BlockType
            let pathBlock: BlockType
            let foundationBlock: BlockType

            switch style {
            case "desert":
                wallBlock = .sand
                cornerBlock = .smoothStone
                roofBlock = .smoothStone
                pathBlock = .smoothStone
                foundationBlock = .stone
            case "stone", "castle":
                wallBlock = .stone
                cornerBlock = .smoothStone
                roofBlock = .stone
                pathBlock = .smoothStone
                foundationBlock = .stone
            case "cyber":
                wallBlock = .smoothStone
                cornerBlock = .glass
                roofBlock = .smoothStone
                pathBlock = .glass
                foundationBlock = .smoothStone
            case "ruins":
                wallBlock = .stone
                cornerBlock = .stone
                roofBlock = .dirt
                pathBlock = .stone
                foundationBlock = .stone
            default:
                wallBlock = .woodPlanks
                cornerBlock = .woodLog
                roofBlock = .woodPlanks
                pathBlock = .smoothStone
                foundationBlock = .stone
            }

            let baseFloorY = 6

            if isSpawnSettlement {
                // Guaranteed 3x3 Master Village Settlement around spawn point!
                if chunk.cx == 0 && chunk.cz == 0 {
                    // --- 1. Central Town Square & Grand Village Water Fountain ---
                    for x in minX..<maxX {
                        for z in minZ..<maxZ {
                            heights[x]?[z] = baseFloorY
                            for fy in 0...baseFloorY {
                                localBlocks[BlockCoord(x: x, y: fy, z: z)] = foundationBlock
                            }
                            for ay in (baseFloorY + 1)...(baseFloorY + 7) {
                                localBlocks.removeValue(forKey: BlockCoord(x: x, y: ay, z: z))
                            }
                            let isPath = (abs(x - (minX + 5)) <= 1 || abs(z - (minZ + 5)) <= 1)
                            localBlocks[BlockCoord(x: x, y: baseFloorY, z: z)] = isPath ? pathBlock : .woodPlanks
                        }
                    }

                    // Central Water Well & Fountain
                    let wMinX = minX + 3
                    let wMaxX = minX + 6
                    let wMinZ = minZ + 3
                    let wMaxZ = minZ + 6
                    for wx in wMinX...wMaxX {
                        for wz in wMinZ...wMaxZ {
                            let isRim = (wx == wMinX || wx == wMaxX || wz == wMinZ || wz == wMaxZ)
                            let c = BlockCoord(x: wx, y: baseFloorY, z: wz)
                            if isRim {
                                localBlocks[c] = .stone
                                localBlocks[BlockCoord(x: wx, y: baseFloorY + 1, z: wz)] = .stone
                            } else {
                                localBlocks[BlockCoord(x: wx, y: baseFloorY, z: wz)] = .water
                                waterSourceBlocks.insert(BlockCoord(x: wx, y: baseFloorY, z: wz))
                            }
                        }
                    }
                    // Canopy roof over well
                    for cx in [wMinX, wMaxX] {
                        for cz in [wMinZ, wMaxZ] {
                            for py in (baseFloorY + 2)...(baseFloorY + 4) {
                                localBlocks[BlockCoord(x: cx, y: py, z: cz)] = cornerBlock
                            }
                        }
                    }
                    for wx in (wMinX - 1)...(wMaxX + 1) {
                        for wz in (wMinZ - 1)...(wMaxZ + 1) {
                            localBlocks[BlockCoord(x: wx, y: baseFloorY + 5, z: wz)] = roofBlock
                        }
                    }

                    // 4 Corner Lamp Posts
                    let lampCoords = [
                        (minX + 2, minZ + 2), (maxX - 3, minZ + 2),
                        (minX + 2, maxZ - 3), (maxX - 3, maxZ - 3)
                    ]
                    for (lx, lz) in lampCoords {
                        localBlocks[BlockCoord(x: lx, y: baseFloorY + 1, z: lz)] = cornerBlock
                        localBlocks[BlockCoord(x: lx, y: baseFloorY + 2, z: lz)] = cornerBlock
                        localBlocks[BlockCoord(x: lx, y: baseFloorY + 3, z: lz)] = .glass
                        localBlocks[BlockCoord(x: lx, y: baseFloorY + 4, z: lz)] = .slab
                    }

                    // Plaza Benches
                    localBlocks[BlockCoord(x: minX + 2, y: baseFloorY + 1, z: minZ + 5)] = .slab
                    localBlocks[BlockCoord(x: maxX - 3, y: baseFloorY + 1, z: minZ + 5)] = .slab

                } else if chunk.cx == 0 && chunk.cz == 1 {
                    // --- 2. Grand Town Hall & Meeting Chamber ---
                    for x in minX..<maxX {
                        for z in minZ..<maxZ {
                            heights[x]?[z] = baseFloorY
                            for fy in 0...baseFloorY {
                                localBlocks[BlockCoord(x: x, y: fy, z: z)] = foundationBlock
                            }
                            for ay in (baseFloorY + 1)...(baseFloorY + 8) {
                                localBlocks.removeValue(forKey: BlockCoord(x: x, y: ay, z: z))
                            }
                            if abs(x - (minX + 5)) <= 1 {
                                localBlocks[BlockCoord(x: x, y: baseFloorY, z: z)] = pathBlock
                            }
                        }
                    }

                    let bMinX = minX + 2
                    let bMaxX = maxX - 3
                    let bMinZ = minZ + 2
                    let bMaxZ = maxZ - 2
                    let wallTopY = baseFloorY + 4
                    let roofPeakY = baseFloorY + 5

                    // Floor
                    for bx in bMinX...bMaxX {
                        for bz in bMinZ...bMaxZ {
                            localBlocks[BlockCoord(x: bx, y: baseFloorY, z: bz)] = .woodPlanks
                        }
                    }

                    // Walls & Windows
                    for bx in bMinX...bMaxX {
                        for bz in bMinZ...bMaxZ {
                            let isCorner = (bx == bMinX || bx == bMaxX) && (bz == bMinZ || bz == bMaxZ)
                            let isPerimeter = (bx == bMinX || bx == bMaxX || bz == bMinZ || bz == bMaxZ)

                            if isPerimeter {
                                for wy in (baseFloorY + 1)...wallTopY {
                                    let coord = BlockCoord(x: bx, y: wy, z: bz)
                                    if isCorner {
                                        localBlocks[coord] = cornerBlock
                                    } else if (bx == minX + 4 || bx == minX + 5) && bz == bMinZ && wy <= baseFloorY + 2 {
                                        // Grand double-door entrance facing South plaza!
                                        if wy == baseFloorY + 1 {
                                            localBlocks[coord] = .door
                                        } else {
                                            localBlocks.removeValue(forKey: coord)
                                        }
                                    } else if wy == baseFloorY + 2 || wy == baseFloorY + 3 {
                                        localBlocks[coord] = (bx % 2 == 0 || bz % 2 == 0) ? .glass : wallBlock
                                    } else {
                                        localBlocks[coord] = wallBlock
                                    }
                                }
                            }
                        }
                    }

                    // Pitched Stately Roof
                    for bx in (bMinX - 1)...(bMaxX + 1) {
                        for bz in (bMinZ - 1)...(bMaxZ + 1) {
                            localBlocks[BlockCoord(x: bx, y: roofPeakY, z: bz)] = roofBlock
                        }
                    }
                    for bx in bMinX...bMaxX {
                        for bz in bMinZ...bMaxZ {
                            localBlocks[BlockCoord(x: bx, y: roofPeakY + 1, z: bz)] = roofBlock
                        }
                    }

                    // Meeting Table Inside
                    localBlocks[BlockCoord(x: minX + 4, y: baseFloorY + 1, z: minZ + 4)] = .woodPlanks
                    localBlocks[BlockCoord(x: minX + 5, y: baseFloorY + 1, z: minZ + 4)] = .woodPlanks

                } else if chunk.cx == 1 && chunk.cz == 0 {
                    // --- 3. East Village Residential Cottages ---
                    for x in minX..<maxX {
                        for z in minZ..<maxZ {
                            heights[x]?[z] = baseFloorY
                            for fy in 0...baseFloorY {
                                localBlocks[BlockCoord(x: x, y: fy, z: z)] = foundationBlock
                            }
                            for ay in (baseFloorY + 1)...(baseFloorY + 7) {
                                localBlocks.removeValue(forKey: BlockCoord(x: x, y: ay, z: z))
                            }
                            if z == minZ + 5 {
                                localBlocks[BlockCoord(x: x, y: baseFloorY, z: z)] = pathBlock
                            }
                        }
                    }

                    // Cottage 1
                    let c1MinX = minX + 3
                    let c1MaxX = maxX - 2
                    let c1MinZ = minZ + 1
                    let c1MaxZ = minZ + 5
                    for bx in c1MinX...c1MaxX {
                        for bz in c1MinZ...c1MaxZ {
                            localBlocks[BlockCoord(x: bx, y: baseFloorY, z: bz)] = .woodPlanks
                            let isPerimeter = (bx == c1MinX || bx == c1MaxX || bz == c1MinZ || bz == c1MaxZ)
                            let isCorner = (bx == c1MinX || bx == c1MaxX) && (bz == c1MinZ || bz == c1MaxZ)
                            if isPerimeter {
                                for wy in (baseFloorY + 1)...(baseFloorY + 3) {
                                    let coord = BlockCoord(x: bx, y: wy, z: bz)
                                    if isCorner {
                                        localBlocks[coord] = cornerBlock
                                    } else if bx == c1MinX && bz == minZ + 3 && wy == baseFloorY + 1 {
                                        localBlocks[coord] = .door
                                    } else if wy == baseFloorY + 2 && (bz == minZ + 3 || bx == c1MinX + 2) {
                                        localBlocks[coord] = .glass
                                    } else {
                                        localBlocks[coord] = wallBlock
                                    }
                                }
                            }
                        }
                    }
                    for bx in (c1MinX - 1)...(c1MaxX + 1) {
                        for bz in (c1MinZ - 1)...(c1MaxZ + 1) {
                            localBlocks[BlockCoord(x: bx, y: baseFloorY + 4, z: bz)] = roofBlock
                        }
                    }

                } else if chunk.cx == -1 && chunk.cz == 0 {
                    // --- 4. West Guard Watchtower & Armory ---
                    for x in minX..<maxX {
                        for z in minZ..<maxZ {
                            heights[x]?[z] = baseFloorY
                            for fy in 0...baseFloorY {
                                localBlocks[BlockCoord(x: x, y: fy, z: z)] = foundationBlock
                            }
                            for ay in (baseFloorY + 1)...(baseFloorY + 10) {
                                localBlocks.removeValue(forKey: BlockCoord(x: x, y: ay, z: z))
                            }
                            if z == minZ + 5 {
                                localBlocks[BlockCoord(x: x, y: baseFloorY, z: z)] = pathBlock
                            }
                        }
                    }

                    let tMinX = minX + 2
                    let tMaxX = minX + 6
                    let tMinZ = minZ + 3
                    let tMaxZ = minZ + 7
                    let towerTopY = baseFloorY + 7

                    for tx in tMinX...tMaxX {
                        for tz in tMinZ...tMaxZ {
                            let isPerimeter = (tx == tMinX || tx == tMaxX || tz == tMinZ || tz == tMaxZ)
                            for wy in (baseFloorY + 1)...towerTopY {
                                let coord = BlockCoord(x: tx, y: wy, z: tz)
                                if isPerimeter {
                                    if wy == baseFloorY + 1 && tx == tMaxX && tz == minZ + 5 {
                                        localBlocks[coord] = .door
                                    } else if (wy == baseFloorY + 3 || wy == baseFloorY + 5) && (tx == tMinX + 2 || tz == tMinZ + 2) {
                                        localBlocks[coord] = .glass
                                    } else {
                                        localBlocks[coord] = .stone
                                    }
                                } else {
                                    localBlocks.removeValue(forKey: coord)
                                }
                            }
                        }
                    }
                    // Battlements & Crenellations
                    for tx in (tMinX - 1)...(tMaxX + 1) {
                        for tz in (tMinZ - 1)...(tMaxZ + 1) {
                            localBlocks[BlockCoord(x: tx, y: towerTopY, z: tz)] = .smoothStone
                            if (tx == tMinX - 1 || tx == tMaxX + 1 || tz == tMinZ - 1 || tz == tMaxZ + 1) && (tx + tz) % 2 == 0 {
                                localBlocks[BlockCoord(x: tx, y: towerTopY + 1, z: tz)] = .stone
                            }
                        }
                    }

                } else if chunk.cx == 0 && chunk.cz == -1 {
                    // --- 5. South Farmland & Granary ---
                    for x in minX..<maxX {
                        for z in minZ..<maxZ {
                            heights[x]?[z] = baseFloorY
                            for fy in 0...baseFloorY {
                                localBlocks[BlockCoord(x: x, y: fy, z: z)] = foundationBlock
                            }
                            for ay in (baseFloorY + 1)...(baseFloorY + 7) {
                                localBlocks.removeValue(forKey: BlockCoord(x: x, y: ay, z: z))
                            }
                            localBlocks[BlockCoord(x: x, y: baseFloorY, z: z)] = .dirt
                        }
                    }

                    // Central Irrigation Canal
                    for z in minZ..<maxZ {
                        let canalCoord = BlockCoord(x: minX + 5, y: baseFloorY, z: z)
                        localBlocks[canalCoord] = .water
                        waterSourceBlocks.insert(canalCoord)
                    }

                    // Green crops & tilled farm border
                    for x in (minX + 2)...(maxX - 3) {
                        for z in (minZ + 2)...(maxZ - 3) {
                            if x != minX + 5 {
                                localBlocks[BlockCoord(x: x, y: baseFloorY + 1, z: z)] = .slab
                            }
                        }
                    }

                } else {
                    // Diagonal settlement corners: connecting pathways and cottages
                    for x in minX..<maxX {
                        for z in minZ..<maxZ {
                            heights[x]?[z] = baseFloorY
                            for fy in 0...baseFloorY {
                                localBlocks[BlockCoord(x: x, y: fy, z: z)] = foundationBlock
                            }
                            for ay in (baseFloorY + 1)...(baseFloorY + 6) {
                                localBlocks.removeValue(forKey: BlockCoord(x: x, y: ay, z: z))
                            }
                            if x == minX + 5 || z == minZ + 5 {
                                localBlocks[BlockCoord(x: x, y: baseFloorY, z: z)] = pathBlock
                            }
                        }
                    }
                }

            } else {
                // Procedural Settlement Chunks throughout the infinite world!
                let centerX = minX + 5
                let centerZ = minZ + 5
                let groundH = max(3, min(24, heights[centerX]?[centerZ] ?? baseFloorY))

                // Ground leveling across structure footprint
                for bx in (minX + 2)...(maxX - 3) {
                    for bz in (minZ + 2)...(maxZ - 3) {
                        for fy in 0...groundH {
                            localBlocks[BlockCoord(x: bx, y: fy, z: bz)] = foundationBlock
                        }
                        for ay in (groundH + 1)...(groundH + 7) {
                            localBlocks.removeValue(forKey: BlockCoord(x: bx, y: ay, z: bz))
                        }
                    }
                }

                let structureVariant = (chunkHash + abs(chunk.cx * 3 + chunk.cz * 7)) % 4

                if structureVariant == 0 || structureVariant == 2 {
                    // Authentic Cottage
                    let bMinX = minX + 2
                    let bMaxX = minX + 6
                    let bMinZ = minZ + 2
                    let bMaxZ = minZ + 6
                    let wallTopY = groundH + 3
                    let roofPeakY = groundH + 4

                    for bx in bMinX...bMaxX {
                        for bz in bMinZ...bMaxZ {
                            localBlocks[BlockCoord(x: bx, y: groundH, z: bz)] = .woodPlanks
                            let isCorner = (bx == bMinX || bx == bMaxX) && (bz == bMinZ || bz == bMaxZ)
                            let isPerimeter = (bx == bMinX || bx == bMaxX || bz == bMinZ || bz == bMaxZ)
                            if isPerimeter {
                                for wy in (groundH + 1)...wallTopY {
                                    let coord = BlockCoord(x: bx, y: wy, z: bz)
                                    if isCorner {
                                        localBlocks[coord] = cornerBlock
                                    } else if wy == groundH + 1 && bx == bMinX + 2 && bz == bMinZ {
                                        localBlocks[coord] = .door
                                    } else if wy == groundH + 2 && (bx == bMinX + 2 || bz == bMinZ + 2) {
                                        localBlocks[coord] = .glass
                                    } else {
                                        localBlocks[coord] = wallBlock
                                    }
                                }
                            }
                        }
                    }
                    for bx in (bMinX - 1)...(bMaxX + 1) {
                        for bz in (bMinZ - 1)...(bMaxZ + 1) {
                            localBlocks[BlockCoord(x: bx, y: roofPeakY, z: bz)] = roofBlock
                        }
                    }
                } else if structureVariant == 1 {
                    // Stone Watchtower
                    let tMinX = minX + 3
                    let tMaxX = minX + 6
                    let tMinZ = minZ + 3
                    let tMaxZ = minZ + 6
                    let towerTopY = groundH + 6

                    for tx in tMinX...tMaxX {
                        for tz in tMinZ...tMaxZ {
                            let isPerimeter = (tx == tMinX || tx == tMaxX || tz == tMinZ || tz == tMaxZ)
                            for wy in (groundH + 1)...towerTopY {
                                let coord = BlockCoord(x: tx, y: wy, z: tz)
                                if isPerimeter {
                                    if wy == groundH + 1 && tx == tMinX + 1 && tz == tMinZ {
                                        localBlocks[coord] = .door
                                    } else if (wy == groundH + 3 || wy == groundH + 5) && (tx == tMinX + 1 || tz == tMinZ + 1) {
                                        localBlocks[coord] = .glass
                                    } else {
                                        localBlocks[coord] = .stone
                                    }
                                } else {
                                    localBlocks.removeValue(forKey: coord)
                                }
                            }
                        }
                    }
                    for tx in (tMinX - 1)...(tMaxX + 1) {
                        for tz in (tMinZ - 1)...(tMaxZ + 1) {
                            localBlocks[BlockCoord(x: tx, y: towerTopY, z: tz)] = .smoothStone
                            if (tx == tMinX - 1 || tx == tMaxX + 1 || tz == tMinZ - 1 || tz == tMaxZ + 1) && (tx + tz) % 2 == 0 {
                                localBlocks[BlockCoord(x: tx, y: towerTopY + 1, z: tz)] = .stone
                            }
                        }
                    }
                } else {
                    // Village Water Well & Plaza
                    let wMinX = minX + 3
                    let wMaxX = minX + 6
                    let wMinZ = minZ + 3
                    let wMaxZ = minZ + 6
                    for wx in wMinX...wMaxX {
                        for wz in wMinZ...wMaxZ {
                            let isRim = (wx == wMinX || wx == wMaxX || wz == wMinZ || wz == wMaxZ)
                            let coord = BlockCoord(x: wx, y: groundH, z: wz)
                            if isRim {
                                localBlocks[coord] = .stone
                                localBlocks[BlockCoord(x: wx, y: groundH + 1, z: wz)] = .stone
                            } else {
                                localBlocks[BlockCoord(x: wx, y: groundH, z: wz)] = .water
                                waterSourceBlocks.insert(BlockCoord(x: wx, y: groundH, z: wz))
                            }
                        }
                    }
                    for cx in [wMinX, wMaxX] {
                        for cz in [wMinZ, wMaxZ] {
                            for py in (groundH + 2)...(groundH + 4) {
                                localBlocks[BlockCoord(x: cx, y: py, z: cz)] = cornerBlock
                            }
                        }
                    }
                    for wx in (wMinX - 1)...(wMaxX + 1) {
                        for wz in (wMinZ - 1)...(wMaxZ + 1) {
                            localBlocks[BlockCoord(x: wx, y: groundH + 5, z: wz)] = roofBlock
                        }
                    }
                }

                // Connecting Village Pathways across chunk
                let pathZ = minZ + 1
                for px in minX..<maxX {
                    if let gh = heights[px]?[pathZ], gh >= 1 {
                        let pathCoord = BlockCoord(x: px, y: gh, z: pathZ)
                        if localBlocks[pathCoord] != .water && localBlocks[pathCoord] != .door {
                            localBlocks[pathCoord] = pathBlock
                        }
                        localBlocks.removeValue(forKey: BlockCoord(x: px, y: gh + 1, z: pathZ))
                        localBlocks.removeValue(forKey: BlockCoord(x: px, y: gh + 2, z: pathZ))
                    }
                }
            }
        }
    }

    private func generateChunkIfNeeded(_ chunk: ChunkCoord) {
        guard !generatedChunks.contains(chunk) else { return }
        generatedChunks.insert(chunk)

        let startX = chunk.cx * chunkSize
        let startZ = chunk.cz * chunkSize
        let endX = startX + chunkSize
        let endZ = startZ + chunkSize

        var localBlocks: [BlockCoord: BlockType] = [:]
        var heights: [Int: [Int: Int]] = [:]

        let minX = startX
        let maxX = endX
        let minZ = startZ
        let maxZ = endZ

        if let custom = activeCustomWorld {
            generateCustomChunkData(chunk: chunk, minX: minX, maxX: maxX, minZ: minZ, maxZ: maxZ, custom: custom, localBlocks: &localBlocks, heights: &heights, waterSourceBlocks: &waterSourceBlocks)
        } else if currentWorldType == .flat {
            for x in minX..<maxX {
                heights[x] = [:]
                for z in minZ..<maxZ {
                    heights[x]?[z] = 4
                    localBlocks[BlockCoord(x: x, y: 0, z: z)] = .stone
                    localBlocks[BlockCoord(x: x, y: 1, z: z)] = .dirt
                    localBlocks[BlockCoord(x: x, y: 2, z: z)] = .dirt
                    localBlocks[BlockCoord(x: x, y: 3, z: z)] = .dirt
                    localBlocks[BlockCoord(x: x, y: 4, z: z)] = .grass
                }
            }
        } else if currentWorldType == .skyIslands {
            let warpScale: Float = 0.025
            for x in minX..<maxX {
                heights[x] = [:]
                for z in minZ..<maxZ {
                    let fx = Float(x)
                    let fz = Float(z)
                    let dist = sqrt(fx * fx + fz * fz)
                    let isSpawnIsland = (dist < 26.0)

                    let wx = fx + warpNoise.noise(fx * warpScale, fz * warpScale) * 16.0
                    let wz = fz + warpNoise.noise((fx + 97.0) * warpScale, (fz - 53.0) * warpScale) * 16.0
                    let islandNoise = primaryNoise.fbm(x: wx * 0.032, y: wz * 0.032, octaves: 3)

                    if isSpawnIsland || islandNoise > -0.10 {
                        let topY = isSpawnIsland ? 22 : max(16, min(28, Int(22.0 + ridgeNoise.noise(wx * 0.04, wz * 0.04) * 6.0)))
                        let thickness = isSpawnIsland ? 7 : max(3, Int(4.0 + (islandNoise + 0.10) * 8.0))
                        let botY = max(8, topY - thickness)
                        heights[x]?[z] = topY

                        for y in botY...topY {
                            let c = BlockCoord(x: x, y: y, z: z)
                            if y == topY {
                                localBlocks[c] = .grass
                            } else if y >= topY - 2 {
                                localBlocks[c] = .dirt
                            } else if y == botY {
                                localBlocks[c] = .stone
                            } else {
                                localBlocks[c] = .smoothStone
                            }
                        }

                        // Waterfall cascading over floating island edge into the open void!
                        if !isSpawnIsland && islandNoise > 0.22 && (x % 9 == 0) && (z % 9 == 0) {
                            let wCoord = BlockCoord(x: x, y: topY, z: z)
                            localBlocks[wCoord] = .water
                            waterSourceBlocks.insert(wCoord)
                        }
                    } else {
                        heights[x]?[z] = -100 // open void
                    }
                }
            }
        } else if currentWorldType == .amplified {
            for x in minX..<maxX {
                heights[x] = [:]
                for z in minZ..<maxZ {
                    let h = surfaceHeightAt(x: x, z: z)
                    heights[x]?[z] = h

                    for y in 0...h {
                        let c = BlockCoord(x: x, y: y, z: z)
                        if y == h {
                            if h >= 25 {
                                localBlocks[c] = .smoothStone
                            } else if h == seaLevel || h == seaLevel - 1 {
                                localBlocks[c] = .sand
                            } else {
                                localBlocks[c] = .grass
                            }
                        } else if y >= h - 2 && h < 25 {
                            localBlocks[c] = .dirt
                        } else if y < h - 1 {
                            localBlocks[c] = .smoothStone
                        } else {
                            localBlocks[c] = .stone
                        }
                    }

                    // Water in alpine basins
                    if h < seaLevel {
                        for y in (h + 1)...seaLevel {
                            let wCoord = BlockCoord(x: x, y: y, z: z)
                            localBlocks[wCoord] = .water
                            waterSourceBlocks.insert(wCoord)
                        }
                    }

                    // Alpine cliff waterfall spring
                    let springNoise = abs(ridgeNoise.noise(Float(x) * 0.05, Float(z) * 0.05))
                    if h >= 22 && springNoise < 0.025 && (x % 8 == 0) && (z % 8 == 0) {
                        let wCoord = BlockCoord(x: x, y: h, z: z)
                        localBlocks[wCoord] = .water
                        waterSourceBlocks.insert(wCoord)
                    }
                }
            }
        } else if currentWorldType == .desert {
            for x in minX..<maxX {
                heights[x] = [:]
                for z in minZ..<maxZ {
                    let h = surfaceHeightAt(x: x, z: z)
                    heights[x]?[z] = h

                    for y in 0...h {
                        let c = BlockCoord(x: x, y: y, z: z)
                        if y == h {
                            if h == seaLevel + 1 {
                                localBlocks[c] = .grass // fertile oasis shore
                            } else {
                                localBlocks[c] = .sand
                            }
                        } else if y >= h - 3 {
                            localBlocks[c] = .sand
                        } else if y < h - 3 {
                            localBlocks[c] = (y % 2 == 0) ? .smoothStone : .stone
                        }
                    }

                    // Oasis pools
                    if h < seaLevel {
                        for y in (h + 1)...seaLevel {
                            let wCoord = BlockCoord(x: x, y: y, z: z)
                            localBlocks[wCoord] = .water
                            waterSourceBlocks.insert(wCoord)
                        }
                    }
                }
            }
        } else if currentWorldType == .caveLands {
            for x in minX..<maxX {
                heights[x] = [:]
                for z in minZ..<maxZ {
                    let floorH = surfaceHeightAt(x: x, z: z)
                    heights[x]?[z] = floorH

                    // Bedrock floor at y=0
                    localBlocks[BlockCoord(x: x, y: 0, z: z)] = .stone

                    // Undulating cavern floor
                    for y in 1...floorH {
                        let c = BlockCoord(x: x, y: y, z: z)
                        if y == floorH {
                            if floorH <= 4 {
                                localBlocks[c] = .stone
                            } else {
                                localBlocks[c] = (y % 3 == 0) ? .grass : .smoothStone
                            }
                        } else if y >= floorH - 2 && floorH > 4 {
                            localBlocks[c] = .dirt
                        } else {
                            localBlocks[c] = .smoothStone
                        }
                    }

                    // Water pools in low cavern basins
                    if floorH < 4 {
                        for y in (floorH + 1)...4 {
                            let wCoord = BlockCoord(x: x, y: y, z: z)
                            localBlocks[wCoord] = .water
                            waterSourceBlocks.insert(wCoord)
                        }
                    }

                    // Cavern ceiling at y=27...29, impenetrable bedrock roof at y=30
                    let ceilNoise = ridgeNoise.noise(Float(x) * 0.04, Float(z) * 0.04)
                    let ceilBot = max(26, min(29, Int(28.0 + ceilNoise * 2.0)))
                    for y in ceilBot...30 {
                        let c = BlockCoord(x: x, y: y, z: z)
                        localBlocks[c] = (y == 30) ? .stone : .smoothStone
                    }

                    // Stalagmites (rising from floor), Stalactites (hanging from ceiling), and Giant Pillars
                    let isSpawnCol = (abs(x) <= 1 && abs(z) <= 1)
                    let colNoise = isSpawnCol ? 0.0 : ridgeNoise.noise(Float(x) * 0.075, Float(z) * 0.075)
                    if colNoise > 0.55 {
                        // Full Cavern Pillar connecting floor to ceiling
                        for y in (floorH + 1)..<ceilBot {
                            localBlocks[BlockCoord(x: x, y: y, z: z)] = (y % 2 == 0) ? .smoothStone : .stone
                        }
                    } else if colNoise > 0.32 {
                        // Stalagmite rising from floor
                        let tipY = min(ceilBot - 3, floorH + Int(round((colNoise - 0.32) * 16.0)))
                        if tipY > floorH {
                            for y in (floorH + 1)...tipY {
                                localBlocks[BlockCoord(x: x, y: y, z: z)] = .stone
                            }
                        }
                    } else if colNoise < -0.32 {
                        // Stalactite hanging from ceiling
                        let tipY = max(floorH + 3, ceilBot - Int(round(abs(colNoise + 0.32) * 16.0)))
                        if tipY < ceilBot {
                            for y in tipY..<ceilBot {
                                localBlocks[BlockCoord(x: x, y: y, z: z)] = .stone
                            }
                        }
                    }
                }
            }
        } else if currentWorldType == .oceanWorld {
            let oceanWaterLevel = 10
            for x in minX..<maxX {
                heights[x] = [:]
                for z in minZ..<maxZ {
                    let h = surfaceHeightAt(x: x, z: z)
                    heights[x]?[z] = h

                    // Bedrock floor at y=0
                    localBlocks[BlockCoord(x: x, y: 0, z: z)] = .stone

                    // Seabed strata
                    for y in 1...h {
                        let c = BlockCoord(x: x, y: y, z: z)
                        if y == h {
                            localBlocks[c] = (h >= oceanWaterLevel) ? .sand : ((y % 2 == 0) ? .sand : .dirt)
                        } else if y >= h - 2 {
                            localBlocks[c] = .dirt
                        } else {
                            localBlocks[c] = .smoothStone
                        }
                    }

                    // Deep ocean water filling up to oceanWaterLevel
                    if h < oceanWaterLevel {
                        for y in (h + 1)...oceanWaterLevel {
                            let wCoord = BlockCoord(x: x, y: y, z: z)
                            localBlocks[wCoord] = .water
                            waterSourceBlocks.insert(wCoord)
                        }
                    }

                    // Starting wooden spawn platform at (0, 0)
                    if abs(x) <= 2 && abs(z) <= 2 {
                        let platY = oceanWaterLevel + 1
                        localBlocks[BlockCoord(x: x, y: platY, z: z)] = .woodPlanks
                        if abs(x) == 2 && abs(z) == 2 {
                            for py in (oceanWaterLevel - 2)...(platY + 1) {
                                localBlocks[BlockCoord(x: x, y: py, z: z)] = .woodLog
                            }
                        }
                    }
                }
            }
        } else if currentWorldType == .seaIslands {
            let islandWaterLevel = 6
            for x in minX..<maxX {
                heights[x] = [:]
                for z in minZ..<maxZ {
                    let h = surfaceHeightAt(x: x, z: z)
                    heights[x]?[z] = h

                    // Bedrock at y=0
                    localBlocks[BlockCoord(x: x, y: 0, z: z)] = .stone

                    // Island & Seabed strata
                    for y in 1...h {
                        let c = BlockCoord(x: x, y: y, z: z)
                        if y == h {
                            if h <= islandWaterLevel + 1 {
                                localBlocks[c] = .sand // Sandy beach
                            } else {
                                localBlocks[c] = .grass // Lush grassy hill
                            }
                        } else if y >= h - 2 {
                            localBlocks[c] = (h <= islandWaterLevel + 1) ? .sand : .dirt
                        } else {
                            localBlocks[c] = .smoothStone
                        }
                    }

                    // Ocean water around islands
                    if h < islandWaterLevel {
                        for y in (h + 1)...islandWaterLevel {
                            let wCoord = BlockCoord(x: x, y: y, z: z)
                            localBlocks[wCoord] = .water
                            waterSourceBlocks.insert(wCoord)
                        }
                    }
                }
            }
        } else {
            for x in minX..<maxX {
                heights[x] = [:]
                for z in minZ..<maxZ {
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
                            let wCoord = BlockCoord(x: x, y: y, z: z)
                            localBlocks[wCoord] = .water
                            waterSourceBlocks.insert(wCoord)
                        }
                    }
                }
            }
        }

        // 3. Deterministic Wooden Plank Structures (with Windows, Doors & Roofs!) - skipped on Flat & Custom Worlds
        if activeCustomWorld == nil && currentWorldType != .flat {
            let chunkHash = abs((chunk.cx &* 73856093) ^ (chunk.cz &* 19349663) ^ (worldSeed &* 83492791)) % 100
            if (chunk.cx == 0 && chunk.cz == 0) || chunkHash < 14 {
                let midX = startX + chunkSize / 2
                let midZ = startZ + chunkSize / 2
                let canBuildHere = true
                if canBuildHere, let rawBase = heights[midX]?[midZ], rawBase > 0 && rawBase < 30 {
                    let baseH = max(rawBase, seaLevel) + 1
                    if chunkHash % 2 == 0 {
                        // Wooden Plank Pier / Sky Bridge segment
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
                        // Wooden Cabin with Glass Windows, Door & Pitched Roof
                        let wallBlock: BlockType = (currentWorldType == .desert || currentWorldType == .caveLands) ? .smoothStone : .woodPlanks
                        let cornerPost: BlockType = (currentWorldType == .desert) ? .smoothStone : ((currentWorldType == .caveLands) ? .stone : .woodLog)

                        for dx in -2...2 {
                            for dz in -2...2 {
                                localBlocks[BlockCoord(x: midX + dx, y: baseH, z: midZ + dz)] = .woodPlanks
                                if abs(dx) == 2 && abs(dz) == 2 {
                                    for wy in (baseH + 1)...(baseH + 3) {
                                        localBlocks[BlockCoord(x: midX + dx, y: wy, z: midZ + dz)] = cornerPost
                                    }
                                } else if abs(dx) == 2 || abs(dz) == 2 {
                                    // Front doorway at (dx == 0, dz == 2)
                                    if dx == 0 && dz == 2 {
                                        localBlocks[BlockCoord(x: midX, y: baseH + 1, z: midZ + 2)] = .door
                                        localBlocks[BlockCoord(x: midX, y: baseH + 2, z: midZ + 2)] = .door
                                        localBlocks[BlockCoord(x: midX, y: baseH + 3, z: midZ + 2)] = wallBlock
                                    } else {
                                        localBlocks[BlockCoord(x: midX + dx, y: baseH + 1, z: midZ + dz)] = wallBlock
                                        localBlocks[BlockCoord(x: midX + dx, y: baseH + 2, z: midZ + dz)] = (dx == 0 || dz == 0) ? .glass : wallBlock
                                        localBlocks[BlockCoord(x: midX + dx, y: baseH + 3, z: midZ + dz)] = wallBlock
                                    }
                                }
                            }
                        }

                        // Complete pitched roof using EdgeRoof and SideRoof (corner) blocks, and top Slab block
                        for dx in -2...2 {
                            for dz in -2...2 {
                                let c = BlockCoord(x: midX + dx, y: baseH + 4, z: midZ + dz)
                                let isCorner = (abs(dx) == 2 && abs(dz) == 2)
                                if isCorner {
                                    localBlocks[c] = .roofCorner
                                    if dx < 0 && dz < 0 {
                                        blockOrientations[c] = 1
                                    } else if dx > 0 && dz < 0 {
                                        blockOrientations[c] = 2
                                    } else if dx > 0 && dz > 0 {
                                        blockOrientations[c] = 3
                                    } else {
                                        blockOrientations[c] = 0
                                    }
                                } else {
                                    localBlocks[c] = .roof
                                    if abs(dz) >= abs(dx) {
                                        blockOrientations[c] = (dz < 0) ? 2 : 0
                                    } else {
                                        blockOrientations[c] = (dx < 0) ? 1 : 3
                                    }
                                }
                            }
                        }
                        for dx in -1...1 {
                            for dz in -1...1 {
                                let c = BlockCoord(x: midX + dx, y: baseH + 5, z: midZ + dz)
                                let isCorner = (abs(dx) == 1 && abs(dz) == 1)
                                if isCorner {
                                    localBlocks[c] = .roofCorner
                                    if dx < 0 && dz < 0 {
                                        blockOrientations[c] = 1
                                    } else if dx > 0 && dz < 0 {
                                        blockOrientations[c] = 2
                                    } else if dx > 0 && dz > 0 {
                                        blockOrientations[c] = 3
                                    } else {
                                        blockOrientations[c] = 0
                                    }
                                } else {
                                    localBlocks[c] = .roof
                                    if abs(dz) >= abs(dx) {
                                        blockOrientations[c] = (dz < 0) ? 2 : 0
                                    } else {
                                        blockOrientations[c] = (dx < 0) ? 1 : 3
                                    }
                                }
                            }
                        }
                        let crestCoord = BlockCoord(x: midX, y: baseH + 6, z: midZ)
                        localBlocks[crestCoord] = .slab
                    }
                }
            }
        }

        // 4. Deterministic Trees (Tailored by World Type)
        if activeCustomWorld == nil {
        if currentWorldType == .desert {
            // Desert: Oasis Palm Trees & Desert Shrubs
            let treeMinX = startX + 2
            let treeMaxX = endX - 2
            let treeMinZ = startZ + 2
            let treeMaxZ = endZ - 2
            for x in treeMinX..<treeMaxX {
                for z in treeMinZ..<treeMaxZ {
                    guard let h = heights[x]?[z], (h == seaLevel + 1 || h == seaLevel + 2) else { continue }
                    if localBlocks[BlockCoord(x: x, y: h + 1, z: z)] != nil { continue }
                    let colHash = abs((x &* 73856093) ^ (z &* 19349663) ^ (worldSeed &* 83492791)) % 100
                    if colHash < 14 && (x % 3 == 0) && (z % 3 == 0) {
                        let trunkH = 5
                        for ty in (h + 1)...(h + trunkH) {
                            localBlocks[BlockCoord(x: x, y: ty, z: z)] = .woodLog
                        }
                        let topY = h + trunkH
                        for lx in (x - 2)...(x + 2) {
                            for lz in (z - 2)...(z + 2) {
                                if abs(lx - x) <= 1 || abs(lz - z) <= 1 {
                                    localBlocks[BlockCoord(x: lx, y: topY, z: lz)] = .leaves
                                }
                            }
                        }
                        localBlocks[BlockCoord(x: x, y: topY + 1, z: z)] = .leaves
                    }
                }
            }
        } else if currentWorldType == .skyIslands {
            // Sky Islands: Trees on floating islands
            let treeMinX = startX + 2
            let treeMaxX = endX - 2
            let treeMinZ = startZ + 2
            let treeMaxZ = endZ - 2
            for x in treeMinX..<treeMaxX {
                for z in treeMinZ..<treeMaxZ {
                    guard let h = heights[x]?[z], h >= 16 && h < 28 else { continue }
                    if localBlocks[BlockCoord(x: x, y: h + 1, z: z)] != nil { continue }

                    let colHash = abs((x &* 73856093) ^ (z &* 19349663) ^ (worldSeed &* 83492791)) % 100
                    if colHash < 9 && (x % 3 == 0) && (z % 3 == 0) {
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
        } else if currentWorldType == .seaIslands {
            // Sea Islands: Tropical Palm Trees along beaches & Lush Island Oaks on hills
            let treeMinX = startX + 2
            let treeMaxX = endX - 2
            let treeMinZ = startZ + 2
            let treeMaxZ = endZ - 2
            for x in treeMinX..<treeMaxX {
                for z in treeMinZ..<treeMaxZ {
                    guard let h = heights[x]?[z], h >= 6 && h < 18 else { continue }
                    if localBlocks[BlockCoord(x: x, y: h + 1, z: z)] != nil { continue }

                    let colHash = abs((x &* 73856093) ^ (z &* 19349663) ^ (worldSeed &* 83492791)) % 100
                    if h <= 8 {
                        // Palm Tree on sandy beach / coast
                        if colHash < 12 && (x % 3 == 0) && (z % 3 == 0) {
                            let trunkH = 5
                            for ty in (h + 1)...(h + trunkH) {
                                localBlocks[BlockCoord(x: x, y: ty, z: z)] = .woodLog
                            }
                            let topY = h + trunkH
                            for lx in (x - 2)...(x + 2) {
                                for lz in (z - 2)...(z + 2) {
                                    if abs(lx - x) <= 1 || abs(lz - z) <= 1 {
                                        localBlocks[BlockCoord(x: lx, y: topY, z: lz)] = .leaves
                                    }
                                }
                            }
                            localBlocks[BlockCoord(x: x, y: topY + 1, z: z)] = .leaves
                        }
                    } else {
                        // Lush Tropical Oak Tree on island hills
                        if colHash < 10 && (x % 3 == 0) && (z % 3 == 0) {
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
            }
        } else if currentWorldType == .caveLands {
            // Cave Lands: Subterranean Fungal Tree Columns
            let treeMinX = startX + 2
            let treeMaxX = endX - 2
            let treeMinZ = startZ + 2
            let treeMaxZ = endZ - 2
            for x in treeMinX..<treeMaxX {
                for z in treeMinZ..<treeMaxZ {
                    guard let h = heights[x]?[z], h >= 5 && h <= 9 else { continue }
                    if localBlocks[BlockCoord(x: x, y: h + 1, z: z)] != nil { continue }

                    let colHash = abs((x &* 73856093) ^ (z &* 19349663) ^ (worldSeed &* 83492791)) % 100
                    if colHash < 7 && (x % 4 == 0) && (z % 4 == 0) {
                        let trunkH = 4
                        for ty in (h + 1)...(h + trunkH) {
                            localBlocks[BlockCoord(x: x, y: ty, z: z)] = .woodLog
                        }
                        let topY = h + trunkH
                        for lx in (x - 1)...(x + 1) {
                            for lz in (z - 1)...(z + 1) {
                                let leafCoord = BlockCoord(x: lx, y: topY, z: lz)
                                if localBlocks[leafCoord] == nil {
                                    localBlocks[leafCoord] = .leaves
                                }
                            }
                        }
                        localBlocks[BlockCoord(x: x, y: topY + 1, z: z)] = .leaves
                    }
                }
            }
        } else if currentWorldType != .flat && currentWorldType != .oceanWorld {
            // Standard & Amplified Peaks Trees
            let maxTreeElevation = (currentWorldType == .amplified) ? 24 : 14
            let treeMinX = startX + 2
            let treeMaxX = endX - 2
            let treeMinZ = startZ + 2
            let treeMaxZ = endZ - 2
            for x in treeMinX..<treeMaxX {
                for z in treeMinZ..<treeMaxZ {
                    guard let h = heights[x]?[z], h > seaLevel && h < maxTreeElevation else { continue }
                    if localBlocks[BlockCoord(x: x, y: h + 1, z: z)] != nil { continue }

                    let colHash = abs((x &* 73856093) ^ (z &* 19349663) ^ (worldSeed &* 83492791)) % 100
                    let forest = biomeNoise.noise(Float(x) * 0.06, Float(z) * 0.06)
                    let treeChance = (currentArchetype == .alphaWoodlands) ? 11 : (forest > 0.0 ? 8 : 4)

                    if colHash < treeChance && (x % 3 == 0) && (z % 3 == 0) {
                        let treeH = (currentWorldType == .amplified ? 5 : 4) + (colHash % 2)
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

        // Minecraft-Style Pre-filtered Surface & Cavity Exposure Cache
        // By filtering candidate blocks once during generation, chunk loading iterates only
        // the ~120 exposed blocks instead of 2,500 buried underground blocks (95% less processing!)
        var exposed: [BlockCoord: BlockType] = [:]
        for (coord, type) in localBlocks {
            if let h = heights[coord.x]?[coord.z] {
                if coord.y < h - 2 && !type.isTransparent && currentWorldType != .caveLands {
                    continue
                }
            }
            if isBlockExposed(coord) {
                exposed[coord] = type
            }
        }
        chunkExposedBlocks[chunk] = exposed
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
        for dx in -renderDistance...renderDistance {
            for dz in -renderDistance...renderDistance {
                let c = ChunkCoord(cx: playerChunk.cx + dx, cz: playerChunk.cz + dz)
                desiredChunks.insert(c)
            }
        }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0

        // 1. Instant Subtree Chunk Unloading (Removes entire chunk node in 1 call, not 300 individual calls)
        let chunksToUnload = activeChunks.subtracting(desiredChunks)
        for c in chunksToUnload {
            if let chunkNode = chunkNodes.removeValue(forKey: c) {
                chunkNode.removeFromParentNode()
            }
            if let cBlocks = chunkBlocks[c] {
                for coord in cBlocks.keys {
                    blockNodes.removeValue(forKey: coord)
                }
            }
            activeChunks.remove(c)
        }

        // 2. Pre-generate terrain data if needed
        let chunksToLoad = desiredChunks.subtracting(activeChunks)
        for c in chunksToLoad {
            generateChunkIfNeeded(c)
        }

        // 3. Fast Chunk Subtree Loading (attaches to chunkNode; SceneKit culls 80 chunks instead of 20,000 nodes!)
        for c in chunksToLoad {
            activeChunks.insert(c)
            let chunkNode = SCNNode()
            chunkNode.name = "chunk_\(c.cx)_\(c.cz)"

            if let exposed = chunkExposedBlocks[c] {
                for (coord, type) in exposed {
                    if blockNodes[coord] == nil {
                        let node = createBlockNode(for: coord, type: type)
                        chunkNode.addChildNode(node)
                        blockNodes[coord] = node
                    }
                }
            } else if let cBlocks = chunkBlocks[c] {
                var exposed: [BlockCoord: BlockType] = [:]
                for (coord, type) in cBlocks {
                    if isBlockExposed(coord) {
                        exposed[coord] = type
                        if blockNodes[coord] == nil {
                            let node = createBlockNode(for: coord, type: type)
                            chunkNode.addChildNode(node)
                            blockNodes[coord] = node
                        }
                    }
                }
                chunkExposedBlocks[c] = exposed
            }

            blocksRootNode.addChildNode(chunkNode)
            chunkNodes[c] = chunkNode
        }

        // 4. Refresh seam water nodes bordering newly loaded chunks
        if !chunksToLoad.isEmpty {
            for c in chunksToLoad {
                refreshPerimeterWater(around: c)
            }
        }

        SCNTransaction.commit()
    }

    private func refreshPerimeterWater(around c: ChunkCoord) {
        let minX = c.cx * chunkSize - 1
        let maxX = (c.cx + 1) * chunkSize
        let minZ = c.cz * chunkSize - 1
        let maxZ = (c.cz + 1) * chunkSize

        for x in minX...maxX {
            checkBorderWaterColumn(x: x, z: minZ)
            checkBorderWaterColumn(x: x, z: maxZ)
        }
        for z in minZ...maxZ {
            checkBorderWaterColumn(x: minX, z: z)
            checkBorderWaterColumn(x: maxX, z: z)
        }
    }

    private func checkBorderWaterColumn(x: Int, z: Int) {
        let minY = max(0, seaLevel - 4)
        let maxY = min(60, seaLevel + 6)
        for y in minY...maxY {
            let coord = BlockCoord(x: x, y: y, z: z)
            if let node = blockNodes[coord], blocks[coord] == .water {
                if isBlockExposed(coord) {
                    configureNode(node, for: coord, type: .water)
                } else {
                    node.removeFromParentNode()
                    blockNodes.removeValue(forKey: coord)
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
                        if !visited.contains(next) {
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

    /// Automatically recedes and drains all downstream flowing water blocks when their feeding water source is scooped or plugged.
    private func drainUnsupportedWater(around origin: BlockCoord, broadcast: Bool) {
        var connectedFlowingWater: Set<BlockCoord> = []
        var boundarySources: Set<BlockCoord> = []
        var queue: [BlockCoord] = []

        let initialNeighbors = [
            BlockCoord(x: origin.x + 1, y: origin.y, z: origin.z),
            BlockCoord(x: origin.x - 1, y: origin.y, z: origin.z),
            BlockCoord(x: origin.x, y: origin.y, z: origin.z + 1),
            BlockCoord(x: origin.x, y: origin.y, z: origin.z - 1),
            BlockCoord(x: origin.x, y: origin.y - 1, z: origin.z),
            BlockCoord(x: origin.x, y: origin.y + 1, z: origin.z)
        ]

        for n in initialNeighbors {
            if blocks[n] == .water {
                if waterSourceBlocks.contains(n) {
                    boundarySources.insert(n)
                } else {
                    connectedFlowingWater.insert(n)
                    queue.append(n)
                }
            }
        }

        let maxSearch = 400
        var head = 0
        while head < queue.count && connectedFlowingWater.count < maxSearch {
            let curr = queue[head]
            head += 1

            let adjs = [
                BlockCoord(x: curr.x + 1, y: curr.y, z: curr.z),
                BlockCoord(x: curr.x - 1, y: curr.y, z: curr.z),
                BlockCoord(x: curr.x, y: curr.y, z: curr.z + 1),
                BlockCoord(x: curr.x, y: curr.y, z: curr.z - 1),
                BlockCoord(x: curr.x, y: curr.y - 1, z: curr.z),
                BlockCoord(x: curr.x, y: curr.y + 1, z: curr.z)
            ]

            for a in adjs {
                if blocks[a] == .water {
                    if waterSourceBlocks.contains(a) {
                        boundarySources.insert(a)
                    } else if !connectedFlowingWater.contains(a) {
                        connectedFlowingWater.insert(a)
                        queue.append(a)
                        if connectedFlowingWater.count >= maxSearch { break }
                    }
                }
            }
        }

        guard !connectedFlowingWater.isEmpty else { return }

        // Propagate valid water flow levels from all surviving source blocks
        var validLevels: [BlockCoord: Int] = [:]
        var pQueue: [(BlockCoord, Int)] = []

        for src in boundarySources {
            validLevels[src] = 4
            pQueue.append((src, 4))
        }

        var pHead = 0
        while pHead < pQueue.count {
            let (curr, currLevel) = pQueue[pHead]
            pHead += 1

            // 1. Water flowing straight down
            let below = BlockCoord(x: curr.x, y: curr.y - 1, z: curr.z)
            if curr.y > 0 && connectedFlowingWater.contains(below) {
                if (validLevels[below] ?? 0) < 4 {
                    validLevels[below] = 4
                    pQueue.append((below, 4))
                }
            }

            // 2. Water flowing horizontally
            if currLevel > 1 {
                let targets = bestFlowNeighborsTowardLowestSpot(from: curr)
                for t in targets {
                    if connectedFlowingWater.contains(t) {
                        let tBelow = BlockCoord(x: t.x, y: t.y - 1, z: t.z)
                        let hasDrop = (t.y > 0 && (blocks[tBelow] == nil || blocks[tBelow] == .water))
                        let targetLvl = hasDrop ? 4 : (currLevel - 1)
                        if targetLvl > (validLevels[t] ?? 0) {
                            validLevels[t] = targetLvl
                            pQueue.append((t, targetLvl))
                        }
                    }
                }
            }
        }

        var blocksToRefresh: Set<BlockCoord> = []
        for c in connectedFlowingWater {
            if let validLvl = validLevels[c] {
                if waterSpreadLevels[c] != validLvl {
                    waterSpreadLevels[c] = validLvl
                    blocksToRefresh.insert(c)
                }
            } else {
                blocks.removeValue(forKey: c)
                let chunk = chunkForBlock(c)
                chunkBlocks[chunk]?.removeValue(forKey: c)
                modifiedBlocks[c] = -1
                waterSpreadLevels.removeValue(forKey: c)
                waterSourceBlocks.remove(c)
                activeWaterFrontier.remove(c)

                if let node = blockNodes.removeValue(forKey: c) {
                    node.removeFromParentNode()
                }
                blocksToRefresh.insert(c)

                if broadcast {
                    broadcastBlockDelta(
                        SavedBlockDelta(x: c.x, y: c.y, z: c.z, typeRaw: -1, waterLevel: nil, isOpen: nil)
                    )
                }
            }
        }

        for c in blocksToRefresh {
            updateVisibilityAround(c)
        }

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

        let worldID = currentWorldID
        let worldName = currentWorldName
        let seed = worldSeed
        let archetypeTitle = activeCustomWorld?.name ?? currentWorldType.displayName
        let pPos = playerPosition
        let pYaw = yaw
        let pPitch = pitch
        let invSnapshot = inventory
        let chunkBlocksSnapshot = chunkBlocks
        let modifiedBlocksSnapshot = modifiedBlocks
        let waterSpreadLevelsSnapshot = waterSpreadLevels
        let openToggleBlocksSnapshot = openToggleBlocks
        let blockOrientationsSnapshot = blockOrientations
        let customSnapshot = activeCustomWorld

        hasUnsavedChanges = false

        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }

            var serializedChunks: [SavedChunkData] = []
            serializedChunks.reserveCapacity(chunkBlocksSnapshot.count)
            for (chunk, localBlocks) in chunkBlocksSnapshot {
                var packed: [Int] = []
                packed.reserveCapacity(localBlocks.count * 4)
                for (coord, type) in localBlocks {
                    let wLvl = (type == .water) ? (waterSpreadLevelsSnapshot[coord] ?? 4) : 0
                    let openBit = openToggleBlocksSnapshot.contains(coord) ? 1 : 0
                    let dir = (blockOrientationsSnapshot[coord] ?? 0) & 0x3
                    let encodedState = (type.rawValue & 0xFF) | ((wLvl & 0xF) << 8) | (openBit << 12) | (dir << 14)
                    packed.append(coord.x)
                    packed.append(coord.y)
                    packed.append(coord.z)
                    packed.append(encodedState)
                }
                serializedChunks.append(SavedChunkData(cx: chunk.cx, cz: chunk.cz, packedBlocks: packed))
            }

            let serializedDeltas = modifiedBlocksSnapshot.map { (coord, rawVal) in
                SavedBlockDelta(
                    x: coord.x,
                    y: coord.y,
                    z: coord.z,
                    typeRaw: rawVal,
                    waterLevel: (rawVal == BlockType.water.rawValue) ? (waterSpreadLevelsSnapshot[coord] ?? 4) : nil,
                    isOpen: openToggleBlocksSnapshot.contains(coord) ? true : nil,
                    direction: blockOrientationsSnapshot[coord]
                )
            }

            var serializedInventory: [Int: Int] = [:]
            for (type, count) in invSnapshot {
                serializedInventory[type.rawValue] = count
            }

            let snapshot = SavedWorld(
                id: worldID,
                name: worldName,
                seed: seed,
                archetypeName: archetypeTitle,
                savedAt: Date(),
                savedChunks: serializedChunks,
                deltas: serializedDeltas,
                blocks: nil,
                inventory: serializedInventory,
                playerX: pPos.x,
                playerY: pPos.y,
                playerZ: pPos.z,
                yaw: pYaw,
                pitch: pPitch,
                customWorldType: customSnapshot
            )

            DispatchQueue.main.async {
                if let idx = self.savedWorlds.firstIndex(where: { $0.id == worldID }) {
                    self.savedWorlds[idx] = snapshot
                } else {
                    self.savedWorlds.insert(snapshot, at: 0)
                }
                self.savedWorlds.sort { $0.savedAt > $1.savedAt }
                self.persistSavedWorlds()
                if !silent {
                    self.statusToast = "Saved '\(worldName)'!"
                }
            }
        }
    }

    func loadSavedWorld(_ saved: SavedWorld, enterGame: Bool = true) {
        clearAllWorldState()
        isHostingMultiplayer = true

        currentWorldID = saved.id
        currentWorldName = Self.cleanWorldName(saved.name, seed: saved.seed)
        if let customSaved = saved.customWorldType {
            activeCustomWorld = customSaved
            currentWorldType = customSaved.baseWorldType
            saveCustomWorldType(customSaved)
        } else if let customMatch = customWorldTypes.first(where: { $0.name == saved.archetypeName || $0.id.uuidString == saved.archetypeName }) {
            activeCustomWorld = customMatch
            currentWorldType = customMatch.baseWorldType
        } else {
            activeCustomWorld = nil
            currentWorldType = WorldType.from(archetypeName: saved.archetypeName)
        }
        currentArchetype = WorldArchetype(rawValue: abs(saved.seed) % WorldArchetype.allCases.count) ?? .alphaCliffs
        configureNoiseGenerators(seed: saved.seed)
        applyAtmosphere()

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
                    let dir = (encoded >> 14) & 0x3

                    if let bType = BlockType(rawValue: typeRaw) {
                        let coord = BlockCoord(x: x, y: y, z: z)
                        localBlocks[coord] = bType
                        blocks[coord] = bType
                        if bType == .water {
                            let lvl = (wLvl > 0) ? wLvl : 4
                            waterSpreadLevels[coord] = lvl
                            if lvl == 4 {
                                waterSourceBlocks.insert(coord)
                            }
                        }
                        if isOpen {
                            openToggleBlocks.insert(coord)
                        }
                        if bType == .roof || bType == .roofCorner {
                            blockOrientations[coord] = dir
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
            if let dir = d.direction {
                blockOrientations[coord] = dir
            }
            if d.typeRaw == BlockType.water.rawValue {
                let lvl = d.waterLevel ?? 4
                waterSpreadLevels[coord] = lvl
                if lvl == 4 {
                    waterSourceBlocks.insert(coord)
                }
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

        if enterGame {
            isInGame = true
            startMultiplayerServices()
        } else {
            isInGame = false
            stopMultiplayerServices()
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
        let worldsToSave = self.savedWorlds
        let primaryURL = self.saveFileURL
        let backupURL = self.backupFileURL

        DispatchQueue.global(qos: .utility).async {
            guard let data = try? JSONEncoder().encode(worldsToSave) else { return }
            // Primary file
            try? data.write(to: primaryURL, options: .atomic)
            // Redundant backup file so updates can never lose worlds
            try? data.write(to: backupURL, options: .atomic)
            // Redundant UserDefaults mirror
            DispatchQueue.main.async {
                UserDefaults.standard.set(data, forKey: "blockbuild_saved_worlds_v2")
            }
        }
    }

    // MARK: - Scene Node Management (Seamless Water Culling & Open/Closed Doors/Trapdoors)

    private func clearAllWorldState() {
        for (_, chunkNode) in chunkNodes {
            chunkNode.removeFromParentNode()
        }
        chunkNodes.removeAll()
        chunkExposedBlocks.removeAll()
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
        blockOrientations.removeAll()
        waterSpreadLevels.removeAll()
        waterSourceBlocks.removeAll()
        activeWaterFrontier.removeAll()
        activeSandBlocks.removeAll()
        lastPlayerChunk = nil
        blocksRootNode.childNodes.forEach { $0.removeFromParentNode() }
    }

    /// Computes a 6-bit face visibility mask for a water block at `coord` in SCNBox material order:
    /// Bit 0: Front (+Z), Bit 1: Right (+X), Bit 2: Back (-Z), Bit 3: Left (-X), Bit 4: Top (+Y), Bit 5: Bottom (-Y).
    /// With full block size (1.0 x 1.0 x 1.0), all interior faces between adjacent water blocks are seamlessly culled.
    private func waterFaceMask(at coord: BlockCoord) -> Int {
        var mask = 0

        // Top (+Y, bit 4): visible only when there is no water directly above
        let topCoord = BlockCoord(x: coord.x, y: coord.y + 1, z: coord.z)
        if blocks[topCoord] != .water {
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
                    // Full block size: adjacent water shares full height, hide shared interior face completely!
                    continue
                } else if neighborType.isTransparent {
                    // Neighbor is glass, door, or trapdoor: show water side face
                    mask |= (1 << bit)
                }
                // Neighbor is opaque solid block (grass, dirt, stone, sand, etc.): hide side face to prevent Z-fighting
            } else {
                // Neighbor is air: show water side face (e.g. waterfall edge or stream border)
                mask |= (1 << bit)
            }
        }

        return mask
    }

    private func maskedWaterGeometry(level: Int = 4, faceMask: Int) -> SCNBox {
        let cacheKey = faceMask & 0x3F
        if let cached = waterMaskedGeometries[cacheKey] {
            return cached
        }

        let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        let visibleMat = BlockType.water.materials(for: currentTexturePack).first!
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
        if currentWorldType == .caveLands && coord.y >= 30 {
            // Upper surface of cave ceiling is never visible to the player
            return false
        }
        if myType == .water {
            return waterFaceMask(at: coord) != 0
        }
        if myType.isTransparent {
            return true
        }
        // Direct neighbor checks without allocating temporary arrays:
        // Checking top face (y + 1) first exits immediately for ~90% of surface blocks!
        let x = coord.x
        let y = coord.y
        let z = coord.z

        let up = BlockCoord(x: x, y: y + 1, z: z)
        guard let bUp = blocks[up] else { return true }
        if bUp.isTransparent { return true }

        let north = BlockCoord(x: x, y: y, z: z - 1)
        guard let bNorth = blocks[north] else { return true }
        if bNorth.isTransparent { return true }

        let south = BlockCoord(x: x, y: y, z: z + 1)
        guard let bSouth = blocks[south] else { return true }
        if bSouth.isTransparent { return true }

        let east = BlockCoord(x: x + 1, y: y, z: z)
        guard let bEast = blocks[east] else { return true }
        if bEast.isTransparent { return true }

        let west = BlockCoord(x: x - 1, y: y, z: z)
        guard let bWest = blocks[west] else { return true }
        if bWest.isTransparent { return true }

        let down = BlockCoord(x: x, y: y - 1, z: z)
        guard let bDown = blocks[down] else { return true }
        if bDown.isTransparent { return true }

        return false
    }

    private func configureNode(_ node: SCNNode, for coord: BlockCoord, type: BlockType) {
        let fx = Float(coord.x)
        let fy = Float(coord.y)
        let fz = Float(coord.z)

        switch type {
        case .water:
            node.childNodes.forEach { $0.removeFromParentNode() }
            node.eulerAngles = SCNVector3(0, 0, 0)
            let mask = waterFaceMask(at: coord)
            node.geometry = maskedWaterGeometry(level: 4, faceMask: mask)
            node.position = SCNVector3(fx, fy, fz)
            node.renderingOrder = 10
            node.categoryBitMask = 2 // Water has no solid hitbox

        case .door:
            node.childNodes.forEach { $0.removeFromParentNode() }
            node.eulerAngles = SCNVector3(0, 0, 0)
            let isOpen = openToggleBlocks.contains(coord)
            node.geometry = isOpen ? doorOpenGeo : doorClosedGeo
            if isOpen {
                node.position = SCNVector3(fx - 0.40, fy, fz)
            } else {
                node.position = SCNVector3(fx, fy, fz + 0.40)
            }
            node.renderingOrder = 2
            node.categoryBitMask = 1

        case .roof:
            node.geometry = nil
            node.childNodes.forEach { $0.removeFromParentNode() }
            node.eulerAngles = SCNVector3(0, 0, 0)

            let baseNode = SCNNode(geometry: roofBaseGeo)
            baseNode.position = SCNVector3(0, -0.25, 0)
            baseNode.categoryBitMask = 1
            node.addChildNode(baseNode)

            let stepNode = SCNNode(geometry: roofStepGeo)
            stepNode.position = SCNVector3(0, 0.25, -0.25)
            stepNode.categoryBitMask = 1
            node.addChildNode(stepNode)

            let dir = blockOrientations[coord] ?? 0
            node.eulerAngles = SCNVector3(0, roofAngle(for: dir), 0)

            node.position = SCNVector3(fx, fy, fz)
            node.renderingOrder = 0
            node.categoryBitMask = 1

        case .roofCorner:
            node.geometry = nil
            node.childNodes.forEach { $0.removeFromParentNode() }
            node.eulerAngles = SCNVector3(0, 0, 0)

            let baseNode = SCNNode(geometry: roofBaseGeo)
            baseNode.position = SCNVector3(0, -0.25, 0)
            baseNode.categoryBitMask = 1
            node.addChildNode(baseNode)

            let cornerStepNode = SCNNode(geometry: roofCornerStepGeo)
            cornerStepNode.position = SCNVector3(0.25, 0.25, -0.25)
            cornerStepNode.categoryBitMask = 1
            node.addChildNode(cornerStepNode)

            let dir = blockOrientations[coord] ?? 0
            node.eulerAngles = SCNVector3(0, roofAngle(for: dir), 0)

            node.position = SCNVector3(fx, fy, fz)
            node.renderingOrder = 0
            node.categoryBitMask = 1

        case .slab:
            node.childNodes.forEach { $0.removeFromParentNode() }
            node.eulerAngles = SCNVector3(0, 0, 0)
            node.geometry = slabGeo
            node.position = SCNVector3(fx, fy - 0.25, fz)
            node.renderingOrder = 0
            node.categoryBitMask = 1

        default:
            node.childNodes.forEach { $0.removeFromParentNode() }
            node.eulerAngles = SCNVector3(0, 0, 0)
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
                    chunkExposedBlocks[chunk]?.removeValue(forKey: c)
                }
            } else if let existing = blockNodes.removeValue(forKey: c) {
                existing.removeFromParentNode()
                chunkExposedBlocks[chunk]?.removeValue(forKey: c)
            }
        }
    }

    private func createBlockNode(for coord: BlockCoord, type: BlockType) -> SCNNode {
        let node = SCNNode()
        node.name = "\(coord.x),\(coord.y),\(coord.z)"
        configureNode(node, for: coord, type: type)
        return node
    }

    private func spawnNode(for coord: BlockCoord, type: BlockType) {
        let node = createBlockNode(for: coord, type: type)
        let chunk = chunkForBlock(coord)
        if let chunkNode = chunkNodes[chunk] {
            chunkNode.addChildNode(node)
        } else {
            blocksRootNode.addChildNode(node)
        }
        blockNodes[coord] = node
        if chunkExposedBlocks[chunk] != nil {
            chunkExposedBlocks[chunk]?[coord] = type
        }
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
        punchFirstPersonArm()
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
        let wasWater = (blocks[coord] == .water)
        blocks.removeValue(forKey: coord)
        let chunk = chunkForBlock(coord)
        chunkBlocks[chunk]?.removeValue(forKey: coord)
        chunkExposedBlocks[chunk]?.removeValue(forKey: coord)
        modifiedBlocks[coord] = -1
        openToggleBlocks.remove(coord)
        blockOrientations.removeValue(forKey: coord)
        waterSpreadLevels.removeValue(forKey: coord)
        waterSourceBlocks.remove(coord)
        activeWaterFrontier.remove(coord)

        updateVisibilityAround(coord)
        triggerAdjacentPhysicsWakeup(around: coord)

        if broadcast {
            broadcastBlockDelta(
                SavedBlockDelta(x: coord.x, y: coord.y, z: coord.z, typeRaw: -1, waterLevel: nil, isOpen: nil)
            )
        }

        if wasWater {
            drainUnsupportedWater(around: coord, broadcast: broadcast)
        }
    }

    func placeSelectedBlock() {
        updateCrosshairTarget()
        punchFirstPersonArm()

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
        var dirToSet: Int? = nil
        if selectedBlock == .roof || selectedBlock == .roofCorner {
            dirToSet = playerFacingDirection()
        }
        placeBlockInternal(at: placeCoord, type: selectedBlock, direction: dirToSet, broadcast: true)

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

    private func placeBlockInternal(at placeCoord: BlockCoord, type: BlockType, direction: Int? = nil, broadcast: Bool) {
        let wasWater = (blocks[placeCoord] == .water)
        blocks[placeCoord] = type
        let chunk = chunkForBlock(placeCoord)
        chunkBlocks[chunk, default: [:]][placeCoord] = type
        modifiedBlocks[placeCoord] = type.rawValue
        openToggleBlocks.remove(placeCoord)

        if let dir = direction {
            blockOrientations[placeCoord] = dir
        } else if (type == .roof || type == .roofCorner) && blockOrientations[placeCoord] == nil {
            blockOrientations[placeCoord] = playerFacingDirection()
        }

        if type == .water {
            waterSpreadLevels[placeCoord] = 4
            waterSourceBlocks.insert(placeCoord)
            activeWaterFrontier.insert(placeCoord)
        } else {
            waterSpreadLevels.removeValue(forKey: placeCoord)
            waterSourceBlocks.remove(placeCoord)
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
                    isOpen: false,
                    direction: blockOrientations[placeCoord]
                )
            )
        }

        if wasWater && type != .water {
            drainUnsupportedWater(around: placeCoord, broadcast: broadcast)
        }
    }

    func creativeRefill() {
        for type in BlockType.allCases {
            inventory[type] = (inventory[type] ?? 0) + 20
        }
        saveCurrentWorld(silent: true)
        statusToast = "+20 of all \(BlockType.allCases.count) blocks added!"
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
        if blocks[block] == .slab {
            // Half-height slab (bottom half from fy - 0.5 to fy)
            return (fx - 0.5, fx + 0.5, fy - 0.5, fy, fz - 0.5, fz + 0.5)
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
                if currentWorldType == .skyIslands {
                    playerPosition.y = min(60.0, newY)
                } else {
                    let maxY: Float = (currentWorldType == .caveLands) ? 26.5 : ((currentWorldType == .amplified) ? 50.0 : 42.0)
                    playerPosition.y = max(0.5 + playerFeetOffset, min(maxY, newY))
                }
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

    private var lastPhysicsTimestamp: CFTimeInterval = 0

    func stepPhysics(dt: Float) {
        // Enforce single execution per frame to prevent duplicate loop speedups across world loads
        let now = CACurrentMediaTime()
        if lastPhysicsTimestamp > 0 && (now - lastPhysicsTimestamp) < 0.005 {
            return
        }
        lastPhysicsTimestamp = now

        // Clamping dt to 0.08s (12.5 FPS) prevents large physics tunneling while ensuring
        // player movement speed remains completely consistent even when framerate dips.
        let clampedDt = min(dt, 0.08)
        let mult = max(0.2, min(3.0, controlLayout.movementSpeedMultiplier))
        // Minecraft exact run speed: ~4.8 blocks (meters) per second
        let baseRunSpeed: Float = 4.8
        let baseFlySpeed: Float = 7.5
        let horizSpeed: Float = (isFlying ? baseFlySpeed : baseRunSpeed) * mult
        let flyVerticalSpeed: Float = 5.5 * mult

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
                    verticalVelocity = 2.8
                } else if verticalInput < -0.1 {
                    verticalVelocity = -2.6
                } else {
                    verticalVelocity = max(verticalVelocity - 6.5 * clampedDt, -2.0)
                }
            } else {
                if verticalInput > 0.1 && isPlayerGrounded(at: pos) {
                    verticalVelocity = 5.6
                }
                verticalVelocity -= 15.0 * clampedDt
            }

            let targetY = pos.y + verticalVelocity * clampedDt
            let (resolvedY, hitSolid) = resolveY(from: pos, targetY: targetY)
            pos.y = resolvedY
            if hitSolid {
                verticalVelocity = 0
            }

            if currentWorldType != .skyIslands {
                let bedrockMinY: Float = 0.5 + playerFeetOffset
                if pos.y < bedrockMinY {
                    pos.y = bedrockMinY
                    verticalVelocity = 0
                }
            }
        }

        if currentWorldType == .skyIslands {
            // NO INVISIBLE BARRIER:
            // The player is on sky islands and can fly beneath them into the open void.
            // In walking/falling mode, if falling deep into the void (below y < -50),
            // safely respawn at the spawn island.
            if !isFlying && pos.y < -50.0 {
                let spawnGround = surfaceHeightAt(x: 0, z: 0)
                pos = SCNVector3(0, Float(max(spawnGround, 22)) + 4.0, 0)
                verticalVelocity = 0
                statusToast = "Fell into the void! Respawned on Sky Island."
            }
        } else {
            // Infinite world: No horizontal clamping on X and Z!
            let maxY: Float = (currentWorldType == .caveLands) ? 26.5 : ((currentWorldType == .amplified) ? 50.0 : 42.0)
            pos.y = max(0.5 + playerFeetOffset, min(maxY, pos.y))
        }

        playerPosition = pos
        updateCameraTransform()

        // Limb walk cycle animation for 3rd person avatar views
        let horizDist = sqrt(vx * vx + vz * vz)
        if horizDist > 0.1 && (isFlying || isPlayerGrounded(at: pos)) {
            walkAnimationAccumulator += clampedDt * 8.5
            let angle = sin(walkAnimationAccumulator) * 0.45
            localPlayerAvatarNode?.childNode(withName: "leftLeg", recursively: true)?.eulerAngles.x = angle
            localPlayerAvatarNode?.childNode(withName: "rightLeg", recursively: true)?.eulerAngles.x = -angle
            localPlayerAvatarNode?.childNode(withName: "leftArm", recursively: true)?.eulerAngles.x = -angle
            localPlayerAvatarNode?.childNode(withName: "rightArm", recursively: true)?.eulerAngles.x = angle
        } else {
            localPlayerAvatarNode?.childNode(withName: "leftLeg", recursively: true)?.eulerAngles.x *= 0.85
            localPlayerAvatarNode?.childNode(withName: "rightLeg", recursively: true)?.eulerAngles.x *= 0.85
            localPlayerAvatarNode?.childNode(withName: "leftArm", recursively: true)?.eulerAngles.x *= 0.85
            localPlayerAvatarNode?.childNode(withName: "rightArm", recursively: true)?.eulerAngles.x *= 0.85
        }
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

        coordTextTimeAccumulator += clampedDt
        if coordTextTimeAccumulator >= (isFpsStabilizationEnabled ? 0.20 : 0.05) {
            coordTextTimeAccumulator = 0.0
            let ix = Int(round(playerPosition.x))
            let iy = Int(round(playerPosition.y))
            let iz = Int(round(playerPosition.z))
            let coordStr = "X:\(ix) Y:\(iy) Z:\(iz)"
            if playerCoordText != coordStr {
                playerCoordText = coordStr
            }
        }

        // Calculate real-time FPS smoothed over ~0.45s with exponential moving average
        fpsFrameCounter += 1
        fpsTimeAccumulator += dt
        if fpsTimeAccumulator >= 0.45 {
            let instantaneous = Int(round(Float(fpsFrameCounter) / fpsTimeAccumulator))
            fpsFrameCounter = 0
            fpsTimeAccumulator = 0.0
            let smoothed = Int(round(Double(currentFPS) * 0.70 + Double(instantaneous) * 0.30))
            let finalFPS = max(1, smoothed)
            if currentFPS != finalFPS {
                currentFPS = finalFPS
            }
        }

        if isFpsStabilizationEnabled {
            crosshairRaycastSkip += 1
            if crosshairRaycastSkip >= 2 {
                crosshairRaycastSkip = 0
                updateCrosshairTarget()
            }
        } else {
            updateCrosshairTarget()
        }
    }

    func updateCameraTransform() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0

        switch cameraPerspective {
        case .firstPerson:
            localPlayerAvatarNode?.isHidden = true
            firstPersonArmNode?.isHidden = true
            cameraNode.position = playerPosition
            cameraNode.eulerAngles = SCNVector3(pitch, yaw, 0)

        case .thirdPersonBack:
            localPlayerAvatarNode?.isHidden = false
            firstPersonArmNode?.isHidden = true
            localPlayerAvatarNode?.position = SCNVector3(playerPosition.x, playerPosition.y - playerFeetOffset, playerPosition.z)
            localPlayerAvatarNode?.eulerAngles = SCNVector3(0, yaw, 0)

            let dist: Float = 3.2
            let cosP = cos(pitch)
            let sinP = sin(pitch)
            let camX = playerPosition.x + sin(yaw) * cosP * dist
            let camY = playerPosition.y + sinP * dist + 0.35
            let camZ = playerPosition.z + cos(yaw) * cosP * dist
            cameraNode.position = SCNVector3(camX, camY, camZ)
            cameraNode.eulerAngles = SCNVector3(pitch, yaw, 0)

        case .thirdPersonFront:
            localPlayerAvatarNode?.isHidden = false
            firstPersonArmNode?.isHidden = true
            localPlayerAvatarNode?.position = SCNVector3(playerPosition.x, playerPosition.y - playerFeetOffset, playerPosition.z)
            localPlayerAvatarNode?.eulerAngles = SCNVector3(0, yaw, 0)

            let dist: Float = 3.0
            let camX = playerPosition.x - sin(yaw) * dist
            let camY = playerPosition.y + 0.25
            let camZ = playerPosition.z - cos(yaw) * dist
            cameraNode.position = SCNVector3(camX, camY, camZ)
            cameraNode.eulerAngles = SCNVector3(-pitch * 0.4, yaw + Float.pi, 0)
        }

        SCNTransaction.commit()

        // Keep directional shadow map centered above player for zero-lag stabilized shadows
        if let sNode = sunNode {
            sNode.position = SCNVector3(playerPosition.x, playerPosition.y + 14.0, playerPosition.z)
        }
    }

    func updateCrosshairTarget() {
        let maxReach: Float = 9.5
        let dir = cameraForwardVector()
        let start = cameraNode.presentation.worldPosition
        let end = SCNVector3(
            start.x + dir.x * maxReach,
            start.y + dir.y * maxReach,
            start.z + dir.z * maxReach
        )

        let options: [String: Any] = [
            SCNHitTestOption.searchMode.rawValue: SCNHitTestSearchMode.closest.rawValue,
            SCNHitTestOption.ignoreHiddenNodes.rawValue: true,
            SCNHitTestOption.categoryBitMask.rawValue: 7 // Hits solid blocks (1), water (2), compound child nodes
        ]

        let hits = blocksRootNode.hitTestWithSegment(from: start, to: end, options: options)
        if let hit = hits.first {
            // Find coordinate from hit node or its parents (for compound blocks like roof or door)
            var targetNode: SCNNode? = hit.node
            var parsedCoord: BlockCoord? = nil
            while let candidate = targetNode, candidate != blocksRootNode {
                if let name = candidate.name {
                    let parts = name.split(separator: ",").compactMap { Int($0) }
                    if parts.count == 3 {
                        parsedCoord = BlockCoord(x: parts[0], y: parts[1], z: parts[2])
                        break
                    }
                }
                targetNode = candidate.parent
            }

            if let hitCoord = parsedCoord {
                currentHitCoord = hitCoord
                targetedBlockType = blocks[hitCoord]
                isTargetedBlockOpen = openToggleBlocks.contains(hitCoord)

                let n = hit.worldNormal
                let absX = abs(n.x)
                let absY = abs(n.y)
                let absZ = abs(n.z)

                let nx: Int
                let ny: Int
                let nz: Int

                if absX >= absY && absX >= absZ {
                    nx = n.x >= 0 ? 1 : -1
                    ny = 0
                    nz = 0
                } else if absY >= absX && absY >= absZ {
                    nx = 0
                    ny = n.y >= 0 ? 1 : -1
                    nz = 0
                } else {
                    nx = 0
                    ny = 0
                    nz = n.z >= 0 ? 1 : -1
                }

                currentPlaceCoord = BlockCoord(
                    x: hitCoord.x + nx,
                    y: hitCoord.y + ny,
                    z: hitCoord.z + nz
                )

                if targetedBlockType == .water {
                    let aboveHasWater = (blocks[BlockCoord(x: hitCoord.x, y: hitCoord.y + 1, z: hitCoord.z)] == .water)
                    let lvl = aboveHasWater ? 4 : (waterSpreadLevels[hitCoord] ?? 4)
                    let h = waterHeight(forLevel: lvl)
                    selectionBoxNode.scale = SCNVector3(1, 1, 1)
                    selectionBoxNode.position = SCNVector3(Float(hitCoord.x), Float(hitCoord.y) - 0.5 + h * 0.5, Float(hitCoord.z))
                } else if targetedBlockType == .slab {
                    selectionBoxNode.scale = SCNVector3(1, 0.5, 1)
                    selectionBoxNode.position = SCNVector3(Float(hitCoord.x), Float(hitCoord.y) - 0.25, Float(hitCoord.z))
                } else {
                    selectionBoxNode.scale = SCNVector3(1, 1, 1)
                    selectionBoxNode.position = SCNVector3(Float(hitCoord.x), Float(hitCoord.y), Float(hitCoord.z))
                }
                selectionBoxNode.isHidden = false
                return
            }
        }

        currentHitCoord = nil
        currentPlaceCoord = nil
        targetedBlockType = nil
        isTargetedBlockOpen = false
        selectionBoxNode.scale = SCNVector3(1, 1, 1)
        selectionBoxNode.isHidden = true
    }

    func cameraForwardVector() -> SCNVector3 {
        let front = cameraNode.presentation.convertVector(SCNVector3(0, 0, -1), to: nil)
        let len = sqrt(front.x * front.x + front.y * front.y + front.z * front.z)
        if len > 0.0001 {
            return SCNVector3(front.x / len, front.y / len, front.z / len)
        }
        return cameraDirection()
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
        if localPlayerName.isEmpty {
            if let saved = UserDefaults.standard.string(forKey: "blockbuild_player_name"),
               !saved.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                localPlayerName = saved
            } else {
                let devName = UIDevice.current.name.trimmingCharacters(in: .whitespacesAndNewlines)
                let base = (devName.isEmpty || devName == "iPhone" || devName == "iPad") ? "Builder" : devName
                let tag = Int.random(in: 100...999)
                localPlayerName = "\(base.prefix(10))-\(tag)"
                UserDefaults.standard.set(localPlayerName, forKey: "blockbuild_player_name")
            }
        }

        let display = String(localPlayerName.prefix(24))
        peerID = MCPeerID(displayName: display)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        mcSession.delegate = self
        startMultiplayerServices()
    }

    func updateLocalPlayerName(_ newName: String) {
        let clean = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty, clean != localPlayerName else { return }
        localPlayerName = String(clean.prefix(24))
        UserDefaults.standard.set(localPlayerName, forKey: "blockbuild_player_name")
        setupMultiplayer()
    }

    func startMultiplayerServices() {
        stopMultiplayerServices()
        guard isMultiplayerEnabled else { return }

        // Continuous signal broadcasting for BlockBuild discovery on local network
        let safePlayerName = localPlayerName.isEmpty ? "Builder" : localPlayerName
        let safeWorldName = currentWorldName.isEmpty ? "BlockBuild World" : currentWorldName

        let discoveryInfo: [String: String] = [
            "playerName": String(safePlayerName.prefix(20)),
            "worldName": String(safeWorldName.prefix(24)),
            "skin": selectedSkin.rawValue,
            "isInGame": isInGame ? "1" : "0",
            "isHost": (isHostingMultiplayer && isInGame) ? "1" : "0"
        ]

        let adv = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: discoveryInfo,
            serviceType: serviceType
        )
        adv.delegate = self
        adv.startAdvertisingPeer()
        advertiser = adv

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

    func toggleMultiplayerEnabled(_ enabled: Bool) {
        isMultiplayerEnabled = enabled
        if enabled {
            startMultiplayerServices()
            statusToast = "Multiplayer enabled: Sending signals"
        } else {
            disconnectMultiplayer()
            stopMultiplayerServices()
            statusToast = "Multiplayer disabled"
        }
    }

    func toggleMultiplayerHosting(_ enabled: Bool) {
        isHostingMultiplayer = enabled
        startMultiplayerServices()
        statusToast = enabled ? "Hosting local world '\(currentWorldName)'" : "Stopped hosting"
    }

    func invitePeerToCurrentWorld(_ targetPeer: MCPeerID) {
        guard let brw = browser else { return }
        brw.invitePeer(targetPeer, to: mcSession, withContext: nil, timeout: 30)
        statusToast = "Sent invite to \(targetPeer.displayName)..."
    }

    func joinDiscoveredHost(_ host: DiscoveredLocalHost) {
        guard let brw = browser else {
            statusToast = "Multiplayer search not active"
            return
        }
        isHostingMultiplayer = false
        activeJoinPrompt = nil

        // Re-advertise as guest without resetting or destroying browser
        let safePlayerName = localPlayerName.isEmpty ? "Builder" : localPlayerName
        let safeWorldName = currentWorldName.isEmpty ? "BlockBuild World" : currentWorldName
        let discoveryInfo: [String: String] = [
            "playerName": String(safePlayerName.prefix(20)),
            "worldName": String(safeWorldName.prefix(24)),
            "skin": selectedSkin.rawValue,
            "isInGame": isInGame ? "1" : "0",
            "isHost": "0"
        ]
        advertiser?.stopAdvertisingPeer()
        let adv = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: discoveryInfo, serviceType: serviceType)
        adv.delegate = self
        adv.startAdvertisingPeer()
        advertiser = adv

        // Cleanly disconnect old connections so a fresh connection can establish
        if !mcSession.connectedPeers.isEmpty {
            mcSession.disconnect()
            let newSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
            newSession.delegate = self
            mcSession = newSession
        }

        statusToast = "Joining '\(host.worldName)' (\(host.playerName))..."
        brw.invitePeer(host.peerID, to: mcSession, withContext: nil, timeout: 30)
    }

    func checkAndTriggerJoinPrompt(for host: DiscoveredLocalHost) {
        guard isMultiplayerEnabled else { return }
        // 1. If WE are already in-game and hosting our own world, NEVER pop up join prompts to leave!
        guard !(isHostingMultiplayer && isInGame) else { return }
        // 2. Only show prompt if the discovered peer is ACTUALLY a host actively playing in a world!
        guard host.isHost && host.isInGame else { return }
        // 3. Don't pop up if we are already connected to them
        guard !connectedPlayerNames.contains(host.playerName) && !connectedPlayerNames.contains(host.id) else { return }
        // 4. Don't override an existing prompt
        guard activeJoinPrompt == nil else { return }
        // 5. Don't show if user dismissed prompt for this peer/world
        let promptKey = "\(host.id)_\(host.worldName)"
        guard !dismissedPromptKeys.contains(promptKey) else { return }

        self.activeJoinPrompt = MultiplayerJoinPrompt(
            peerID: host.peerID,
            playerName: host.playerName,
            worldName: host.worldName,
            isDirectInvitation: false,
            invitationHandler: nil
        )
    }

    func acceptActiveJoinPrompt(_ prompt: MultiplayerJoinPrompt) {
        activeJoinPrompt = nil
        let promptKey = "\(prompt.peerID.displayName)_\(prompt.worldName)"
        dismissedPromptKeys.insert(promptKey)

        if let handler = prompt.invitationHandler {
            // Direct invitation accepted
            isHostingMultiplayer = false
            handler(true, mcSession)
            statusToast = "Joining \(prompt.playerName)'s world..."
        } else {
            // Found nearby world broadcast prompt accepted
            if let host = discoveredHosts.first(where: { $0.peerID == prompt.peerID }) {
                joinDiscoveredHost(host)
            } else {
                let tempHost = DiscoveredLocalHost(
                    id: prompt.peerID.displayName,
                    peerID: prompt.peerID,
                    worldName: prompt.worldName,
                    playerName: prompt.playerName,
                    skin: .steve,
                    isInGame: true,
                    isHost: true
                )
                joinDiscoveredHost(tempHost)
            }
        }
    }

    func declineActiveJoinPrompt() {
        guard let prompt = activeJoinPrompt else { return }
        activeJoinPrompt = nil
        if let handler = prompt.invitationHandler {
            handler(false, nil)
        }
        let promptKey = "\(prompt.peerID.displayName)_\(prompt.worldName)"
        dismissedPromptKeys.insert(promptKey)
    }

    func disconnectMultiplayer() {
        mcSession.disconnect()
        connectedPlayerNames.removeAll()
        for (_, node) in remotePlayerNodes {
            node.removeFromParentNode()
        }
        remotePlayerNodes.removeAll()
        remotePlayerSkins.removeAll()
        remotePlayerCustomSkins.removeAll()
        if isInGame {
            startMultiplayerServices()
        } else {
            stopMultiplayerServices()
        }
        statusToast = "Disconnected from local session"
    }

    private func sendPacket(_ packet: MultiplayerPacket, reliable: Bool) {
        guard !mcSession.connectedPeers.isEmpty,
              let data = try? JSONEncoder().encode(packet) else { return }
        let mode: MCSessionSendDataMode = reliable ? .reliable : .unreliable
        do {
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: mode)
        } catch {
            print("[Multiplayer] broadcast packet error: \(error.localizedDescription)")
        }
    }

    private func sendPacketToPeer(_ packet: MultiplayerPacket, peer: MCPeerID, reliable: Bool) {
        guard let data = try? JSONEncoder().encode(packet) else { return }
        let mode: MCSessionSendDataMode = reliable ? .reliable : .unreliable
        do {
            try mcSession.send(data, toPeers: [peer], with: mode)
        } catch {
            print("[Multiplayer] sendPacketToPeer error: \(error.localizedDescription)")
        }
    }

    private func sendPacketToPeers(_ packet: MultiplayerPacket, peers: [MCPeerID], reliable: Bool) {
        guard !peers.isEmpty, let data = try? JSONEncoder().encode(packet) else { return }
        let mode: MCSessionSendDataMode = reliable ? .reliable : .unreliable
        do {
            try mcSession.send(data, toPeers: peers, with: mode)
        } catch {
            print("[Multiplayer] sendPacketToPeers error: \(error.localizedDescription)")
        }
    }

    private func broadcastWorldSnapshotToPeers() {
        for peer in mcSession.connectedPeers {
            sendWorldSnapshot(to: peer)
        }
    }

    private func sendWorldSnapshot(to peer: MCPeerID) {
        guard isInGame else { return }

        let serializedDeltas = modifiedBlocks.map { (coord, rawVal) in
            SavedBlockDelta(
                x: coord.x,
                y: coord.y,
                z: coord.z,
                typeRaw: rawVal,
                waterLevel: (rawVal == BlockType.water.rawValue) ? (waterSpreadLevels[coord] ?? 4) : nil,
                isOpen: openToggleBlocks.contains(coord) ? true : nil,
                direction: blockOrientations[coord]
            )
        }

        let chunkSize = 100
        let initialDeltas = serializedDeltas.isEmpty ? [] : Array(serializedDeltas.prefix(chunkSize))
        let initialPacket = MultiplayerPacket(
            kind: .worldSnapshot,
            senderName: localPlayerName,
            skinRaw: selectedSkin.rawValue,
            customSkin: nil,
            worldID: currentWorldID,
            worldName: currentWorldName,
            seed: worldSeed,
            worldTypeRaw: currentWorldType.rawValue,
            customWorldType: activeCustomWorld,
            deltas: initialDeltas,
            blockDelta: nil,
            px: playerPosition.x,
            py: playerPosition.y,
            pz: playerPosition.z,
            yaw: yaw,
            pitch: pitch
        )
        sendPacketToPeer(initialPacket, peer: peer, reliable: true)

        if serializedDeltas.count > chunkSize {
            Task { @MainActor in
                for startIndex in stride(from: chunkSize, to: serializedDeltas.count, by: chunkSize) {
                    try? await Task.sleep(nanoseconds: 40_000_000)
                    let endIndex = min(startIndex + chunkSize, serializedDeltas.count)
                    let chunk = Array(serializedDeltas[startIndex..<endIndex])
                    let deltaPacket = MultiplayerPacket(
                        kind: .worldSnapshot,
                        senderName: self.localPlayerName,
                        skinRaw: self.selectedSkin.rawValue,
                        customSkin: nil,
                        worldID: self.currentWorldID,
                        worldName: self.currentWorldName,
                        seed: self.worldSeed,
                        worldTypeRaw: self.currentWorldType.rawValue,
                        customWorldType: self.activeCustomWorld,
                        deltas: chunk,
                        blockDelta: nil,
                        px: self.playerPosition.x,
                        py: self.playerPosition.y,
                        pz: self.playerPosition.z,
                        yaw: self.yaw,
                        pitch: self.pitch
                    )
                    self.sendPacketToPeer(deltaPacket, peer: peer, reliable: true)
                }
            }
        }
    }

    private func broadcastBlockDelta(_ delta: SavedBlockDelta) {
        guard !mcSession.connectedPeers.isEmpty else { return }
        let packet = MultiplayerPacket(
            kind: .blockUpdate,
            senderName: localPlayerName,
            skinRaw: nil,
            customSkin: nil,
            worldID: currentWorldID,
            worldName: nil,
            seed: nil,
            worldTypeRaw: nil,
            customWorldType: nil,
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
            skinRaw: selectedSkin.rawValue,
            customSkin: nil,
            worldID: currentWorldID,
            worldName: nil,
            seed: nil,
            worldTypeRaw: nil,
            customWorldType: nil,
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
            if isInGame {
                sendWorldSnapshot(to: peer)
            }

        case .worldSnapshot:
            guard let seed = packet.seed else { return }
            // If already loaded into this world, simply merge additional delta chunks
            if isInGame && currentWorldID == packet.worldID {
                if let deltas = packet.deltas {
                    for d in deltas {
                        let coord = BlockCoord(x: d.x, y: d.y, z: d.z)
                        modifiedBlocks[coord] = d.typeRaw
                        if let dir = d.direction { blockOrientations[coord] = dir }
                        if let wLvl = d.waterLevel {
                            waterSpreadLevels[coord] = wLvl
                            if wLvl == 4 { waterSourceBlocks.insert(coord) }
                        }
                        if d.isOpen == true { openToggleBlocks.insert(coord) }
                    }
                    updateStreamedChunks(force: false)
                }
                return
            }

            saveCurrentWorld(silent: true)
            clearAllWorldState()

            currentWorldID = packet.worldID ?? UUID()
            currentWorldName = packet.worldName ?? "\(peer.displayName)'s World"
            worldSeed = seed

            if let downloadedCustomWorld = packet.customWorldType {
                // Download and save custom world type into local device storage
                saveCustomWorldType(downloadedCustomWorld)
                activeCustomWorld = downloadedCustomWorld
                currentWorldType = downloadedCustomWorld.baseWorldType
            } else {
                activeCustomWorld = nil
                currentWorldType = WorldType.from(archetypeName: packet.worldTypeRaw)
            }

            if let downloadedCustomSkin = packet.customSkin {
                if !customSkins.contains(where: { $0.id == downloadedCustomSkin.id }) {
                    saveCustomSkin(downloadedCustomSkin)
                }
            }

            applyAtmosphere()

            currentArchetype = WorldArchetype(rawValue: abs(seed) % WorldArchetype.allCases.count) ?? .alphaCliffs
            configureNoiseGenerators(seed: seed)

            if let deltas = packet.deltas {
                for d in deltas {
                    let coord = BlockCoord(x: d.x, y: d.y, z: d.z)
                    modifiedBlocks[coord] = d.typeRaw
                    if let dir = d.direction {
                        blockOrientations[coord] = dir
                    }
                    if let wLvl = d.waterLevel {
                        waterSpreadLevels[coord] = wLvl
                        if wLvl == 4 {
                            waterSourceBlocks.insert(coord)
                        }
                    }
                    if d.isOpen == true {
                        openToggleBlocks.insert(coord)
                    }
                }
            }

            if let hx = packet.px, let hy = packet.py, let hz = packet.pz {
                playerPosition = SCNVector3(hx + 1.2, hy + 0.5, hz + 1.2)
            } else if let custom = activeCustomWorld, custom.hasWaterfalls {
                playerPosition = SCNVector3(3.5, 7.8, 4.0)
            } else if let custom = activeCustomWorld, custom.hasVillages {
                playerPosition = SCNVector3(5.0, 7.8, 2.5)
            } else {
                playerPosition = SCNVector3(0, 10.5, 0)
            }
            lastPlayerChunk = nil
            updateStreamedChunks(force: true)
            resolveStuckPositionIfNeeded()
            updateCameraTransform()
            isInGame = true
            isHostingMultiplayer = false
            saveCurrentWorld(silent: true)
            if let custom = packet.customWorldType {
                statusToast = "Joined '\(currentWorldName)' (\(custom.name))!"
            } else {
                statusToast = "Joined '\(currentWorldName)' with \(peer.displayName)!"
            }

        case .blockUpdate:
            guard let d = packet.blockDelta else { return }
            let coord = BlockCoord(x: d.x, y: d.y, z: d.z)
            if d.typeRaw < 0 {
                removeBlockInternal(at: coord, broadcast: false)
            } else if let bType = BlockType(rawValue: d.typeRaw) {
                blocks[coord] = bType
                chunkBlocks[chunkForBlock(coord), default: [:]][coord] = bType
                modifiedBlocks[coord] = d.typeRaw
                if let dir = d.direction {
                    blockOrientations[coord] = dir
                }
                if let wLvl = d.waterLevel {
                    waterSpreadLevels[coord] = wLvl
                    if wLvl == 4 {
                        waterSourceBlocks.insert(coord)
                    }
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

            // Multi-device relay: Host relays block update to ALL other connected peers
            if isHostingMultiplayer {
                let others = mcSession.connectedPeers.filter { $0 != peer }
                if !others.isEmpty {
                    sendPacketToPeers(packet, peers: others, reliable: true)
                }
            }

        case .playerPose:
            guard let px = packet.px, let py = packet.py, let pz = packet.pz,
                  let pYaw = packet.yaw else { return }
            let skin = packet.skinRaw.flatMap { PlayerSkin(rawValue: $0) } ?? .steve
            let sender = packet.senderName.isEmpty ? peer.displayName : packet.senderName
            if let cSkin = packet.customSkin {
                if !customSkins.contains(where: { $0.id == cSkin.id }) {
                    saveCustomSkin(cSkin)
                }
            }
            updateRemotePlayerAvatar(name: sender, skin: skin, customSkin: packet.customSkin, x: px, y: py, z: pz, yaw: pYaw)

            // Multi-device relay: Host relays player pose to ALL other connected peers
            if isHostingMultiplayer {
                let others = mcSession.connectedPeers.filter { $0 != peer }
                if !others.isEmpty {
                    sendPacketToPeers(packet, peers: others, reliable: false)
                }
            }

        case .playerLeft:
            let leftName = packet.senderName
            if let node = remotePlayerNodes.removeValue(forKey: leftName) {
                node.removeFromParentNode()
            }
            remotePlayerSkins.removeValue(forKey: leftName)
            remotePlayerCustomSkins.removeValue(forKey: leftName)
            connectedPlayerNames.removeAll { $0 == leftName }
            statusToast = "\(leftName) left"
        }
    }

    private func updateRemotePlayerAvatar(name: String, skin: PlayerSkin, customSkin: CustomSkin? = nil, x: Float, y: Float, z: Float, yaw: Float) {
        let avatarNode: SCNNode
        let skinUnchanged = (remotePlayerSkins[name] == skin) && (remotePlayerCustomSkins[name]?.id == customSkin?.id)
        if let existing = remotePlayerNodes[name], skinUnchanged {
            avatarNode = existing
        } else {
            remotePlayerNodes[name]?.removeFromParentNode()
            let created = Self.makeBlockyPlayerAvatarNode(name: name, skin: skin, customSkin: customSkin)
            playersRootNode.addChildNode(created)
            remotePlayerNodes[name] = created
            remotePlayerSkins[name] = skin
            if let custom = customSkin {
                remotePlayerCustomSkins[name] = custom
            } else {
                remotePlayerCustomSkins.removeValue(forKey: name)
            }
            avatarNode = created
        }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.06
        avatarNode.position = SCNVector3(x, y - playerFeetOffset, z)
        avatarNode.eulerAngles = SCNVector3(0, yaw, 0)
        SCNTransaction.commit()
    }

    static func makeBlockyPlayerAvatarNode(name: String, skin: PlayerSkin, customSkin: CustomSkin? = nil) -> SCNNode {
        let root = SCNNode()
        let mgr = SkinTextureManager.shared

        // Container node for the entire body, rotated 180° around Y so that front of head and torso face forward (-Z look direction)
        let bodyNode = SCNNode()
        bodyNode.eulerAngles = SCNVector3(0, Float.pi, 0)
        root.addChildNode(bodyNode)

        // 1. Legs (Left & Right standard Minecraft limbs)
        let leftLegGeo = SCNBox(width: 0.22, height: 0.65, length: 0.22, chamferRadius: 0.0)
        leftLegGeo.materials = customSkin != nil ? mgr.leftLegMaterials(for: customSkin!) : mgr.leftLegMaterials(for: skin)
        let leftLegNode = SCNNode(geometry: leftLegGeo)
        leftLegNode.name = "leftLeg"
        leftLegNode.position = SCNVector3(-0.13, 0.325, 0)
        bodyNode.addChildNode(leftLegNode)

        let rightLegGeo = SCNBox(width: 0.22, height: 0.65, length: 0.22, chamferRadius: 0.0)
        rightLegGeo.materials = customSkin != nil ? mgr.rightLegMaterials(for: customSkin!) : mgr.rightLegMaterials(for: skin)
        let rightLegNode = SCNNode(geometry: rightLegGeo)
        rightLegNode.name = "rightLeg"
        rightLegNode.position = SCNVector3(0.13, 0.325, 0)
        bodyNode.addChildNode(rightLegNode)

        // 2. Torso
        let torsoGeo = SCNBox(width: 0.50, height: 0.65, length: 0.25, chamferRadius: 0.0)
        torsoGeo.materials = customSkin != nil ? mgr.torsoMaterials(for: customSkin!) : mgr.torsoMaterials(for: skin)
        let torsoNode = SCNNode(geometry: torsoGeo)
        torsoNode.name = "torso"
        torsoNode.position = SCNVector3(0, 0.975, 0)
        bodyNode.addChildNode(torsoNode)

        // 3. Arms (Left & Right)
        let leftArmGeo = SCNBox(width: 0.22, height: 0.65, length: 0.22, chamferRadius: 0.0)
        leftArmGeo.materials = customSkin != nil ? mgr.leftArmMaterials(for: customSkin!) : mgr.leftArmMaterials(for: skin)
        let leftArmNode = SCNNode(geometry: leftArmGeo)
        leftArmNode.name = "leftArm"
        leftArmNode.position = SCNVector3(-0.36, 0.975, 0)
        bodyNode.addChildNode(leftArmNode)

        let rightArmGeo = SCNBox(width: 0.22, height: 0.65, length: 0.22, chamferRadius: 0.0)
        rightArmGeo.materials = customSkin != nil ? mgr.rightArmMaterials(for: customSkin!) : mgr.rightArmMaterials(for: skin)
        let rightArmNode = SCNNode(geometry: rightArmGeo)
        rightArmNode.name = "rightArm"
        rightArmNode.position = SCNVector3(0.36, 0.975, 0)
        bodyNode.addChildNode(rightArmNode)

        // 4. Head
        let headGeo = SCNBox(width: 0.50, height: 0.50, length: 0.50, chamferRadius: 0.0)
        headGeo.materials = customSkin != nil ? mgr.headMaterials(for: customSkin!) : mgr.headMaterials(for: skin)
        let headNode = SCNNode(geometry: headGeo)
        headNode.name = "head"
        headNode.position = SCNVector3(0, 1.55, 0)
        bodyNode.addChildNode(headNode)

        // 5. 3D Billboard Floating Name Tag (User Name Directly On Top Of Player Head)
        let tagText = name
        let textGeo = SCNText(string: tagText, extrusionDepth: 0.10)
        textGeo.font = UIFont.monospacedSystemFont(ofSize: 2.2, weight: .black)
        textGeo.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        let textMat = SCNMaterial()
        textMat.diffuse.contents = UIColor.white
        textMat.emission.contents = UIColor(white: 0.95, alpha: 1.0)
        textGeo.materials = [textMat]

        let textNode = SCNNode(geometry: textGeo)
        let (minVec, maxVec) = textNode.boundingBox
        let scaleFactor: Float = 0.065
        let textCenterX = (minVec.x + maxVec.x) * 0.5 * scaleFactor

        // Place right directly above player head (head top is y = 1.80)
        let nametagY: Float = 1.88

        textNode.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        textNode.position = SCNVector3(-textCenterX, nametagY, 0)
        let billboard = SCNBillboardConstraint()
        billboard.freeAxes = .Y
        textNode.constraints = [billboard]
        root.addChildNode(textNode)

        return root
    }
}

// MARK: - Minecraft PNG Skin Texture Manager

final class SkinTextureManager: @unchecked Sendable {
    static let shared = SkinTextureManager()

    private var headMaterialsCache: [PlayerSkin: [SCNMaterial]] = [:]
    private var torsoMaterialsCache: [PlayerSkin: [SCNMaterial]] = [:]
    private var rightArmMaterialsCache: [PlayerSkin: [SCNMaterial]] = [:]
    private var leftArmMaterialsCache: [PlayerSkin: [SCNMaterial]] = [:]
    private var rightLegMaterialsCache: [PlayerSkin: [SCNMaterial]] = [:]
    private var leftLegMaterialsCache: [PlayerSkin: [SCNMaterial]] = [:]
    private var skinImageCache: [PlayerSkin: UIImage] = [:]
    private var frontAvatarCache: [PlayerSkin: UIImage] = [:]

    func skinImage(for skin: PlayerSkin) -> UIImage {
        if let cached = skinImageCache[skin] {
            return cached
        }
        let imageName = "skin_\(skin.assetName)"
        // 1. Try Assets.xcassets catalog
        if let img = UIImage(named: imageName) {
            skinImageCache[skin] = img
            return img
        }
        // 2. Try application bundle and project skins directory
        let searchPaths = [
            Bundle.main.path(forResource: imageName, ofType: "png"),
            Bundle.main.bundlePath + "/Skins/\(imageName).png",
            "/Users/jaxtan/projects/BlockBuild/BlockBuild/Skins/\(imageName).png"
        ]
        for path in searchPaths.compactMap({ $0 }) {
            if let img = UIImage(contentsOfFile: path) {
                skinImageCache[skin] = img
                return img
            }
        }
        // 3. Fallback: generate solid color image
        let fallback = generateSolidFallbackSkin(skin)
        skinImageCache[skin] = fallback
        return fallback
    }

    private func cropFace(from cg: CGImage, x: Int, y: Int, w: Int, h: Int, fallbackColor: UIColor = .clear) -> UIImage {
        let rect = CGRect(x: x, y: y, width: w, height: h)
        let croppedImage: UIImage? = cg.cropping(to: rect).map { UIImage(cgImage: $0) }

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: w, height: h), format: format)
        return renderer.image { ctx in
            fallbackColor.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
            croppedImage?.draw(in: CGRect(x: 0, y: 0, width: w, height: h))
        }
    }

    private func makePixelMat(from image: UIImage) -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = image
        mat.diffuse.magnificationFilter = .nearest
        mat.diffuse.minificationFilter = .nearest
        mat.diffuse.mipFilter = .none
        mat.isDoubleSided = false
        mat.lightingModel = .lambert
        return mat
    }

    func headMaterials(for skin: PlayerSkin) -> [SCNMaterial] {
        if let cached = headMaterialsCache[skin] { return cached }
        let img = skinImage(for: skin)
        guard let cg = img.cgImage else { return [] }
        // SCNBox materials: 0:Front, 1:Right, 2:Back, 3:Left, 4:Top, 5:Bottom
        let front = makePixelMat(from: cropFace(from: cg, x: 8, y: 8, w: 8, h: 8, fallbackColor: skin.headColor))
        let right = makePixelMat(from: cropFace(from: cg, x: 0, y: 8, w: 8, h: 8, fallbackColor: skin.hairColor))
        let back = makePixelMat(from: cropFace(from: cg, x: 24, y: 8, w: 8, h: 8, fallbackColor: skin.hairColor))
        let left = makePixelMat(from: cropFace(from: cg, x: 16, y: 8, w: 8, h: 8, fallbackColor: skin.hairColor))
        let top = makePixelMat(from: cropFace(from: cg, x: 8, y: 0, w: 8, h: 8, fallbackColor: skin.hairColor))
        let bottom = makePixelMat(from: cropFace(from: cg, x: 16, y: 0, w: 8, h: 8, fallbackColor: skin.headColor))
        let mats = [front, right, back, left, top, bottom]
        headMaterialsCache[skin] = mats
        return mats
    }

    func torsoMaterials(for skin: PlayerSkin) -> [SCNMaterial] {
        if let cached = torsoMaterialsCache[skin] { return cached }
        let img = skinImage(for: skin)
        guard let cg = img.cgImage else { return [] }
        let front = makePixelMat(from: cropFace(from: cg, x: 20, y: 20, w: 8, h: 12, fallbackColor: skin.torsoColor))
        let right = makePixelMat(from: cropFace(from: cg, x: 16, y: 20, w: 4, h: 12, fallbackColor: skin.torsoColor))
        let back = makePixelMat(from: cropFace(from: cg, x: 32, y: 20, w: 8, h: 12, fallbackColor: skin.torsoColor))
        let left = makePixelMat(from: cropFace(from: cg, x: 28, y: 20, w: 4, h: 12, fallbackColor: skin.torsoColor))
        let top = makePixelMat(from: cropFace(from: cg, x: 20, y: 16, w: 8, h: 4, fallbackColor: skin.torsoColor))
        let bottom = makePixelMat(from: cropFace(from: cg, x: 28, y: 16, w: 8, h: 4, fallbackColor: skin.torsoColor))
        let mats = [front, right, back, left, top, bottom]
        torsoMaterialsCache[skin] = mats
        return mats
    }

    func rightArmMaterials(for skin: PlayerSkin) -> [SCNMaterial] {
        if let cached = rightArmMaterialsCache[skin] { return cached }
        let img = skinImage(for: skin)
        guard let cg = img.cgImage else { return [] }
        let front = makePixelMat(from: cropFace(from: cg, x: 44, y: 20, w: 4, h: 12, fallbackColor: skin.torsoColor))
        let right = makePixelMat(from: cropFace(from: cg, x: 40, y: 20, w: 4, h: 12, fallbackColor: skin.torsoColor))
        let back = makePixelMat(from: cropFace(from: cg, x: 52, y: 20, w: 4, h: 12, fallbackColor: skin.torsoColor))
        let left = makePixelMat(from: cropFace(from: cg, x: 48, y: 20, w: 4, h: 12, fallbackColor: skin.torsoColor))
        // Shoulder top face (index 4)
        let top = makePixelMat(from: cropFace(from: cg, x: 44, y: 16, w: 4, h: 4, fallbackColor: skin.torsoColor))
        let bottom = makePixelMat(from: cropFace(from: cg, x: 48, y: 16, w: 4, h: 4, fallbackColor: skin.headColor))
        let mats = [front, right, back, left, top, bottom]
        rightArmMaterialsCache[skin] = mats
        return mats
    }

    func leftArmMaterials(for skin: PlayerSkin) -> [SCNMaterial] {
        if let cached = leftArmMaterialsCache[skin] { return cached }
        let img = skinImage(for: skin)
        guard let cg = img.cgImage else { return [] }
        let front = makePixelMat(from: cropFace(from: cg, x: 36, y: 52, w: 4, h: 12, fallbackColor: skin.torsoColor))
        let right = makePixelMat(from: cropFace(from: cg, x: 32, y: 52, w: 4, h: 12, fallbackColor: skin.torsoColor))
        let back = makePixelMat(from: cropFace(from: cg, x: 44, y: 52, w: 4, h: 12, fallbackColor: skin.torsoColor))
        let left = makePixelMat(from: cropFace(from: cg, x: 40, y: 52, w: 4, h: 12, fallbackColor: skin.torsoColor))
        // Shoulder top face (index 4)
        let top = makePixelMat(from: cropFace(from: cg, x: 36, y: 48, w: 4, h: 4, fallbackColor: skin.torsoColor))
        let bottom = makePixelMat(from: cropFace(from: cg, x: 40, y: 48, w: 4, h: 4, fallbackColor: skin.headColor))
        let mats = [front, right, back, left, top, bottom]
        leftArmMaterialsCache[skin] = mats
        return mats
    }

    func rightLegMaterials(for skin: PlayerSkin) -> [SCNMaterial] {
        if let cached = rightLegMaterialsCache[skin] { return cached }
        let img = skinImage(for: skin)
        guard let cg = img.cgImage else { return [] }
        let front = makePixelMat(from: cropFace(from: cg, x: 4, y: 20, w: 4, h: 12))
        let right = makePixelMat(from: cropFace(from: cg, x: 0, y: 20, w: 4, h: 12))
        let back = makePixelMat(from: cropFace(from: cg, x: 12, y: 20, w: 4, h: 12))
        let left = makePixelMat(from: cropFace(from: cg, x: 8, y: 20, w: 4, h: 12))
        let top = makePixelMat(from: cropFace(from: cg, x: 4, y: 16, w: 4, h: 4))
        let bottom = makePixelMat(from: cropFace(from: cg, x: 8, y: 16, w: 4, h: 4))
        let mats = [front, right, back, left, top, bottom]
        rightLegMaterialsCache[skin] = mats
        return mats
    }

    func leftLegMaterials(for skin: PlayerSkin) -> [SCNMaterial] {
        if let cached = leftLegMaterialsCache[skin] { return cached }
        let img = skinImage(for: skin)
        guard let cg = img.cgImage else { return [] }
        let front = makePixelMat(from: cropFace(from: cg, x: 20, y: 52, w: 4, h: 12))
        let right = makePixelMat(from: cropFace(from: cg, x: 16, y: 52, w: 4, h: 12))
        let back = makePixelMat(from: cropFace(from: cg, x: 28, y: 52, w: 4, h: 12))
        let left = makePixelMat(from: cropFace(from: cg, x: 24, y: 52, w: 4, h: 12))
        let top = makePixelMat(from: cropFace(from: cg, x: 20, y: 48, w: 4, h: 4))
        let bottom = makePixelMat(from: cropFace(from: cg, x: 24, y: 48, w: 4, h: 4))
        let mats = [front, right, back, left, top, bottom]
        leftLegMaterialsCache[skin] = mats
        return mats
    }

    func frontAvatarImage(for skin: PlayerSkin) -> UIImage {
        if let cached = frontAvatarCache[skin] { return cached }
        let img = skinImage(for: skin)
        guard let cg = img.cgImage else { return img }

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 16, height: 32), format: format)
        let result = renderer.image { _ in
            cropFace(from: cg, x: 8, y: 8, w: 8, h: 8).draw(in: CGRect(x: 4, y: 0, width: 8, height: 8))
            cropFace(from: cg, x: 44, y: 20, w: 4, h: 12).draw(in: CGRect(x: 0, y: 8, width: 4, height: 12))
            cropFace(from: cg, x: 20, y: 20, w: 8, h: 12).draw(in: CGRect(x: 4, y: 8, width: 8, height: 12))
            cropFace(from: cg, x: 36, y: 52, w: 4, h: 12).draw(in: CGRect(x: 12, y: 8, width: 4, height: 12))
            cropFace(from: cg, x: 4, y: 20, w: 4, h: 12).draw(in: CGRect(x: 4, y: 20, width: 4, height: 12))
            cropFace(from: cg, x: 20, y: 52, w: 4, h: 12).draw(in: CGRect(x: 8, y: 20, width: 4, height: 12))
        }
        frontAvatarCache[skin] = result
        return result
    }

    private func generateSolidFallbackSkin(_ skin: PlayerSkin) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 64, height: 64), format: format)
        return renderer.image { ctx in
            skin.headColor.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 64, height: 64))
        }
    }

    // MARK: - AI Custom Skin Support

    private var customSkinImageCache: [UUID: UIImage] = [:]
    private var customFrontAvatarCache: [UUID: UIImage] = [:]
    private var customHeadMaterialsCache: [UUID: [SCNMaterial]] = [:]
    private var customTorsoMaterialsCache: [UUID: [SCNMaterial]] = [:]
    private var customRightArmMaterialsCache: [UUID: [SCNMaterial]] = [:]
    private var customLeftArmMaterialsCache: [UUID: [SCNMaterial]] = [:]
    private var customRightLegMaterialsCache: [UUID: [SCNMaterial]] = [:]
    private var customLeftLegMaterialsCache: [UUID: [SCNMaterial]] = [:]

    func clearCustomSkinCache(for id: UUID) {
        customSkinImageCache.removeValue(forKey: id)
        customFrontAvatarCache.removeValue(forKey: id)
        customHeadMaterialsCache.removeValue(forKey: id)
        customTorsoMaterialsCache.removeValue(forKey: id)
        customRightArmMaterialsCache.removeValue(forKey: id)
        customLeftArmMaterialsCache.removeValue(forKey: id)
        customRightLegMaterialsCache.removeValue(forKey: id)
        customLeftLegMaterialsCache.removeValue(forKey: id)
    }

    func skinImage(for customSkin: CustomSkin) -> UIImage {
        if let cached = customSkinImageCache[customSkin.id] { return cached }
        if let img = UIImage(data: customSkin.pngData) {
            customSkinImageCache[customSkin.id] = img
            return img
        }
        let fallback = generateSolidFallbackSkin(.steve)
        customSkinImageCache[customSkin.id] = fallback
        return fallback
    }

    func frontAvatarImage(for customSkin: CustomSkin) -> UIImage {
        if let cached = customFrontAvatarCache[customSkin.id] { return cached }
        let img = skinImage(for: customSkin)
        guard let cg = img.cgImage else { return img }

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 16, height: 32), format: format)
        let result = renderer.image { _ in
            cropFace(from: cg, x: 8, y: 8, w: 8, h: 8).draw(in: CGRect(x: 4, y: 0, width: 8, height: 8))
            cropFace(from: cg, x: 44, y: 20, w: 4, h: 12).draw(in: CGRect(x: 0, y: 8, width: 4, height: 12))
            cropFace(from: cg, x: 20, y: 20, w: 8, h: 12).draw(in: CGRect(x: 4, y: 8, width: 8, height: 12))
            cropFace(from: cg, x: 36, y: 52, w: 4, h: 12).draw(in: CGRect(x: 12, y: 8, width: 4, height: 12))
            cropFace(from: cg, x: 4, y: 20, w: 4, h: 12).draw(in: CGRect(x: 4, y: 20, width: 4, height: 12))
            cropFace(from: cg, x: 20, y: 52, w: 4, h: 12).draw(in: CGRect(x: 8, y: 20, width: 4, height: 12))
        }
        customFrontAvatarCache[customSkin.id] = result
        return result
    }

    func headMaterials(for customSkin: CustomSkin) -> [SCNMaterial] {
        if let cached = customHeadMaterialsCache[customSkin.id] { return cached }
        let img = skinImage(for: customSkin)
        guard let cg = img.cgImage else { return [] }
        let front = makePixelMat(from: cropFace(from: cg, x: 8, y: 8, w: 8, h: 8, fallbackColor: customSkin.headColor))
        let right = makePixelMat(from: cropFace(from: cg, x: 0, y: 8, w: 8, h: 8, fallbackColor: customSkin.hairColor))
        let back = makePixelMat(from: cropFace(from: cg, x: 24, y: 8, w: 8, h: 8, fallbackColor: customSkin.hairColor))
        let left = makePixelMat(from: cropFace(from: cg, x: 16, y: 8, w: 8, h: 8, fallbackColor: customSkin.hairColor))
        let top = makePixelMat(from: cropFace(from: cg, x: 8, y: 0, w: 8, h: 8, fallbackColor: customSkin.hairColor))
        let bottom = makePixelMat(from: cropFace(from: cg, x: 16, y: 0, w: 8, h: 8, fallbackColor: customSkin.headColor))
        let mats = [front, right, back, left, top, bottom]
        customHeadMaterialsCache[customSkin.id] = mats
        return mats
    }

    func torsoMaterials(for customSkin: CustomSkin) -> [SCNMaterial] {
        if let cached = customTorsoMaterialsCache[customSkin.id] { return cached }
        let img = skinImage(for: customSkin)
        guard let cg = img.cgImage else { return [] }
        let front = makePixelMat(from: cropFace(from: cg, x: 20, y: 20, w: 8, h: 12, fallbackColor: customSkin.torsoColor))
        let right = makePixelMat(from: cropFace(from: cg, x: 16, y: 20, w: 4, h: 12, fallbackColor: customSkin.torsoColor))
        let back = makePixelMat(from: cropFace(from: cg, x: 32, y: 20, w: 8, h: 12, fallbackColor: customSkin.torsoColor))
        let left = makePixelMat(from: cropFace(from: cg, x: 28, y: 20, w: 4, h: 12, fallbackColor: customSkin.torsoColor))
        let top = makePixelMat(from: cropFace(from: cg, x: 20, y: 16, w: 8, h: 4, fallbackColor: customSkin.torsoColor))
        let bottom = makePixelMat(from: cropFace(from: cg, x: 28, y: 16, w: 8, h: 4, fallbackColor: customSkin.torsoColor))
        let mats = [front, right, back, left, top, bottom]
        customTorsoMaterialsCache[customSkin.id] = mats
        return mats
    }

    func rightArmMaterials(for customSkin: CustomSkin) -> [SCNMaterial] {
        if let cached = customRightArmMaterialsCache[customSkin.id] { return cached }
        let img = skinImage(for: customSkin)
        guard let cg = img.cgImage else { return [] }
        let front = makePixelMat(from: cropFace(from: cg, x: 44, y: 20, w: 4, h: 12, fallbackColor: customSkin.torsoColor))
        let right = makePixelMat(from: cropFace(from: cg, x: 40, y: 20, w: 4, h: 12, fallbackColor: customSkin.torsoColor))
        let back = makePixelMat(from: cropFace(from: cg, x: 52, y: 20, w: 4, h: 12, fallbackColor: customSkin.torsoColor))
        let left = makePixelMat(from: cropFace(from: cg, x: 48, y: 20, w: 4, h: 12, fallbackColor: customSkin.torsoColor))
        let top = makePixelMat(from: cropFace(from: cg, x: 44, y: 16, w: 4, h: 4, fallbackColor: customSkin.torsoColor))
        let bottom = makePixelMat(from: cropFace(from: cg, x: 48, y: 16, w: 4, h: 4, fallbackColor: customSkin.headColor))
        let mats = [front, right, back, left, top, bottom]
        customRightArmMaterialsCache[customSkin.id] = mats
        return mats
    }

    func leftArmMaterials(for customSkin: CustomSkin) -> [SCNMaterial] {
        if let cached = customLeftArmMaterialsCache[customSkin.id] { return cached }
        let img = skinImage(for: customSkin)
        guard let cg = img.cgImage else { return [] }
        let front = makePixelMat(from: cropFace(from: cg, x: 36, y: 52, w: 4, h: 12, fallbackColor: customSkin.torsoColor))
        let right = makePixelMat(from: cropFace(from: cg, x: 32, y: 52, w: 4, h: 12, fallbackColor: customSkin.torsoColor))
        let back = makePixelMat(from: cropFace(from: cg, x: 44, y: 52, w: 4, h: 12, fallbackColor: customSkin.torsoColor))
        let left = makePixelMat(from: cropFace(from: cg, x: 40, y: 52, w: 4, h: 12, fallbackColor: customSkin.torsoColor))
        let top = makePixelMat(from: cropFace(from: cg, x: 36, y: 48, w: 4, h: 4, fallbackColor: customSkin.torsoColor))
        let bottom = makePixelMat(from: cropFace(from: cg, x: 40, y: 48, w: 4, h: 4, fallbackColor: customSkin.headColor))
        let mats = [front, right, back, left, top, bottom]
        customLeftArmMaterialsCache[customSkin.id] = mats
        return mats
    }

    func rightLegMaterials(for customSkin: CustomSkin) -> [SCNMaterial] {
        if let cached = customRightLegMaterialsCache[customSkin.id] { return cached }
        let img = skinImage(for: customSkin)
        guard let cg = img.cgImage else { return [] }
        let front = makePixelMat(from: cropFace(from: cg, x: 4, y: 20, w: 4, h: 12, fallbackColor: customSkin.legsColor))
        let right = makePixelMat(from: cropFace(from: cg, x: 0, y: 20, w: 4, h: 12, fallbackColor: customSkin.legsColor))
        let back = makePixelMat(from: cropFace(from: cg, x: 12, y: 20, w: 4, h: 12, fallbackColor: customSkin.legsColor))
        let left = makePixelMat(from: cropFace(from: cg, x: 8, y: 20, w: 4, h: 12, fallbackColor: customSkin.legsColor))
        let top = makePixelMat(from: cropFace(from: cg, x: 4, y: 16, w: 4, h: 4, fallbackColor: customSkin.legsColor))
        let bottom = makePixelMat(from: cropFace(from: cg, x: 8, y: 16, w: 4, h: 4, fallbackColor: .black))
        let mats = [front, right, back, left, top, bottom]
        customRightLegMaterialsCache[customSkin.id] = mats
        return mats
    }

    func leftLegMaterials(for customSkin: CustomSkin) -> [SCNMaterial] {
        if let cached = customLeftLegMaterialsCache[customSkin.id] { return cached }
        let img = skinImage(for: customSkin)
        guard let cg = img.cgImage else { return [] }
        let front = makePixelMat(from: cropFace(from: cg, x: 20, y: 52, w: 4, h: 12, fallbackColor: customSkin.legsColor))
        let right = makePixelMat(from: cropFace(from: cg, x: 16, y: 52, w: 4, h: 12, fallbackColor: customSkin.legsColor))
        let back = makePixelMat(from: cropFace(from: cg, x: 28, y: 52, w: 4, h: 12, fallbackColor: customSkin.legsColor))
        let left = makePixelMat(from: cropFace(from: cg, x: 24, y: 52, w: 4, h: 12, fallbackColor: customSkin.legsColor))
        let top = makePixelMat(from: cropFace(from: cg, x: 20, y: 48, w: 4, h: 4, fallbackColor: customSkin.legsColor))
        let bottom = makePixelMat(from: cropFace(from: cg, x: 24, y: 48, w: 4, h: 4, fallbackColor: .black))
        let mats = [front, right, back, left, top, bottom]
        customLeftLegMaterialsCache[customSkin.id] = mats
        return mats
    }
}

// MARK: - MultipeerConnectivity Delegates

extension VoxelWorld: MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor in
            self.connectedPlayerNames = session.connectedPeers.map { $0.displayName }
            if state == .connected {
                self.statusToast = "\(peerID.displayName) connected!"
                // Dismiss any pending join prompt for this peer immediately
                if self.activeJoinPrompt?.peerID == peerID {
                    self.activeJoinPrompt = nil
                }
                if self.isHostingMultiplayer {
                    // Send world snapshot to the joined peer after small delay to let handshake finalize
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 200_000_000)
                        self.sendWorldSnapshot(to: peerID)
                    }
                } else {
                    // Send initial handshake with our skin and pose
                    let handshake = MultiplayerPacket(
                        kind: .playerPose,
                        senderName: self.localPlayerName,
                        skinRaw: self.selectedSkin.rawValue,
                        customSkin: self.activeCustomSkin,
                        worldID: self.currentWorldID,
                        px: self.playerPosition.x,
                        py: self.playerPosition.y,
                        pz: self.playerPosition.z,
                        yaw: self.yaw,
                        pitch: self.pitch
                    )
                    self.sendPacketToPeer(handshake, peer: peerID, reliable: true)

                    // Guest also schedules a requestSnapshot fallback
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        let req = MultiplayerPacket(
                            kind: .requestSnapshot,
                            senderName: self.localPlayerName,
                            skinRaw: self.selectedSkin.rawValue
                        )
                        self.sendPacketToPeer(req, peer: peerID, reliable: true)
                    }
                }
            } else if state == .notConnected {
                let leftName = peerID.displayName
                if let node = self.remotePlayerNodes.removeValue(forKey: leftName) {
                    node.removeFromParentNode()
                }
                self.remotePlayerSkins.removeValue(forKey: leftName)
                self.remotePlayerCustomSkins.removeValue(forKey: leftName)
                self.connectedPlayerNames.removeAll { $0 == leftName }
                self.statusToast = "\(leftName) left"

                // Host relays playerLeft packet so all other connected devices remove their avatar
                if self.isHostingMultiplayer {
                    let leftPacket = MultiplayerPacket(
                        kind: .playerLeft,
                        senderName: leftName
                    )
                    self.sendPacket(leftPacket, reliable: true)
                }
            }
        }
    }

    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let packet = try JSONDecoder().decode(MultiplayerPacket.self, from: data)
            Task { @MainActor in
                self.handleReceivedPacket(packet, from: peerID)
            }
        } catch {
            print("[Multiplayer] JSON decode error from \(peerID.displayName): \(error.localizedDescription)")
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
            guard self.isMultiplayerEnabled && self.isInGame else {
                invitationHandler(false, nil)
                return
            }

            // If we are currently in a world and hosting, auto-accept guest connections with zero annoying prompts
            if self.isHostingMultiplayer {
                self.activeJoinPrompt = nil
                self.statusToast = "\(peerID.displayName) connecting to your world..."
                invitationHandler(true, self.mcSession)
            } else {
                // Otherwise present the pop-up invitation asking if user would like to join
                self.activeJoinPrompt = MultiplayerJoinPrompt(
                    peerID: peerID,
                    playerName: peerID.displayName,
                    worldName: self.currentWorldName,
                    isDirectInvitation: true,
                    invitationHandler: invitationHandler
                )
            }
        }
    }

    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("[Multiplayer] Advertiser did not start: \(error.localizedDescription)")
    }

    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        let wName = info?["worldName"] ?? "\(peerID.displayName)'s World"
        let pName = info?["playerName"] ?? peerID.displayName
        let skin = info?["skin"].flatMap { PlayerSkin(rawValue: $0) } ?? .steve
        let inGame = (info?["isInGame"] == "1")
        let isHost = (info?["isHost"] == "1")

        Task { @MainActor in
            guard self.isMultiplayerEnabled else { return }
            let host = DiscoveredLocalHost(
                id: peerID.displayName,
                peerID: peerID,
                worldName: wName,
                playerName: pName,
                skin: skin,
                isInGame: inGame,
                isHost: isHost
            )
            if let idx = self.discoveredHosts.firstIndex(where: { $0.id == host.id }) {
                self.discoveredHosts[idx] = host
            } else {
                self.discoveredHosts.append(host)
            }

            self.checkAndTriggerJoinPrompt(for: host)
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        Task { @MainActor in
            self.discoveredHosts.removeAll { $0.id == peerID.displayName }
            if self.activeJoinPrompt?.peerID == peerID {
                self.activeJoinPrompt = nil
            }
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("[Multiplayer] Browser did not start: \(error.localizedDescription)")
    }
}

// MARK: - Clean World Screenshot Capture & Photo Library Integration

extension VoxelWorld {
    func registerSceneView(_ view: SCNView) {
        self.sceneView = view
    }

    func captureCleanScreenshot() {
        guard let scnView = sceneView else {
            statusToast = "Snapshot failed: 3D scene not ready"
            return
        }

        // Hide 3D block selection wireframe so the snapshot is 100% clean world only
        let wasSelectionHidden = selectionBoxNode.isHidden
        selectionBoxNode.isHidden = true

        let screenshotImage = scnView.snapshot()

        selectionBoxNode.isHidden = wasSelectionHidden

        let saver = PhotoAlbumSaver { [weak self] success, error in
            guard let self = self else { return }
            if success {
                self.statusToast = "Screenshot saved to Photos!"
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } else {
                let errStr = error?.localizedDescription ?? "Access denied or unknown error"
                self.statusToast = "Failed to save photo: \(errStr)"
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
            self.activePhotoSaver = nil
        }
        self.activePhotoSaver = saver
        saver.save(screenshotImage)
    }
}

// MARK: - Photo Album Screenshot Saver

final class PhotoAlbumSaver: NSObject {
    private var onComplete: (@MainActor (Bool, Error?) -> Void)?

    init(onComplete: (@MainActor (Bool, Error?) -> Void)?) {
        self.onComplete = onComplete
        super.init()
    }

    @MainActor
    func save(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(image(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer?) {
        Task { @MainActor in
            self.onComplete?(error == nil, error)
            self.onComplete = nil
        }
    }
}
