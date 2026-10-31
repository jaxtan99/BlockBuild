import SwiftUI
import SceneKit
import UIKit

// MARK: - Game Shader Preset
enum GameShaderPreset: String, CaseIterable, Identifiable, Codable {
    case vanilla = "vanilla"
    case vibrant = "vibrant"
    case sunset = "sunset"
    case cinematic = "cinematic"
    case celShaded = "celShaded"
    case nocturne = "nocturne"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .vanilla: return "Vanilla (Off)"
        case .vibrant: return "Vibrant BSL Shaders"
        case .sunset: return "Warm Sunset Shaders"
        case .cinematic: return "Cinematic RTX Shaders"
        case .celShaded: return "Comic / Cel Shaders"
        case .nocturne: return "Nocturne Mystic Shaders"
        }
    }

    var subtitle: String {
        switch self {
        case .vanilla:
            return "Standard crisp voxel lighting without post-processing effects"
        case .vibrant:
            return "Vivid BSL-style colors, HDR bloom, soft atmospheric haze & sunlight"
        case .sunset:
            return "Golden hour lighting with long warm shadows, amber dusk & glow"
        case .cinematic:
            return "High-contrast dynamic lighting, directional sun shadows & vignetting"
        case .celShaded:
            return "Stylized hand-drawn comic look with enhanced edges & pop-art palette"
        case .nocturne:
            return "Moody mystical ambiance with deep night shadows & glowing highlights"
        }
    }

    var iconName: String {
        switch self {
        case .vanilla: return "cube.transparent"
        case .vibrant: return "sun.max.fill"
        case .sunset: return "sunset.fill"
        case .cinematic: return "sparkles"
        case .celShaded: return "pencil.and.outline"
        case .nocturne: return "moon.stars.fill"
        }
    }

    var themeColor: Color {
        switch self {
        case .vanilla: return .gray
        case .vibrant: return .yellow
        case .sunset: return .orange
        case .cinematic: return .cyan
        case .celShaded: return .pink
        case .nocturne: return .indigo
        }
    }

    var skyColor: UIColor {
        switch self {
        case .vanilla:
            return UIColor(red: 0.60, green: 0.80, blue: 1.0, alpha: 1.0)
        case .vibrant:
            return UIColor(red: 0.40, green: 0.72, blue: 1.0, alpha: 1.0)
        case .sunset:
            return UIColor(red: 0.96, green: 0.55, blue: 0.38, alpha: 1.0)
        case .cinematic:
            return UIColor(red: 0.52, green: 0.75, blue: 0.98, alpha: 1.0)
        case .celShaded:
            return UIColor(red: 0.35, green: 0.78, blue: 0.98, alpha: 1.0)
        case .nocturne:
            return UIColor(red: 0.06, green: 0.08, blue: 0.18, alpha: 1.0)
        }
    }

    var fogColor: UIColor {
        switch self {
        case .vanilla:
            return UIColor(red: 0.65, green: 0.83, blue: 1.0, alpha: 1.0)
        case .vibrant:
            return UIColor(red: 0.55, green: 0.78, blue: 1.0, alpha: 1.0)
        case .sunset:
            return UIColor(red: 0.98, green: 0.62, blue: 0.42, alpha: 1.0)
        case .cinematic:
            return UIColor(red: 0.62, green: 0.78, blue: 0.95, alpha: 1.0)
        case .celShaded:
            return UIColor(red: 0.45, green: 0.80, blue: 1.0, alpha: 1.0)
        case .nocturne:
            return UIColor(red: 0.08, green: 0.12, blue: 0.22, alpha: 1.0)
        }
    }

    var sunColor: UIColor {
        switch self {
        case .vanilla:
            return UIColor(red: 1.0, green: 0.99, blue: 0.94, alpha: 1.0)
        case .vibrant:
            return UIColor(red: 1.0, green: 0.97, blue: 0.86, alpha: 1.0)
        case .sunset:
            return UIColor(red: 1.0, green: 0.68, blue: 0.32, alpha: 1.0)
        case .cinematic:
            return UIColor(white: 1.0, alpha: 1.0)
        case .celShaded:
            return UIColor(red: 1.0, green: 1.0, blue: 0.92, alpha: 1.0)
        case .nocturne:
            return UIColor(red: 0.58, green: 0.78, blue: 1.0, alpha: 1.0)
        }
    }

    var sunIntensity: CGFloat {
        switch self {
        case .vanilla: return 880
        case .vibrant: return 1150
        case .sunset: return 1200
        case .cinematic: return 1300
        case .celShaded: return 1400
        case .nocturne: return 580
        }
    }

    var sunEulerAngles: SCNVector3 {
        switch self {
        case .sunset:
            return SCNVector3(-0.42, 0.75, 0)
        case .nocturne:
            return SCNVector3(-Float.pi / 2.8, Float.pi / 3.2, 0)
        default:
            return SCNVector3(-Float.pi / 3.0, Float.pi / 4.0, 0)
        }
    }

    var castsShadows: Bool {
        switch self {
        case .vanilla: return false
        default: return true
        }
    }

    var shadowColor: UIColor {
        switch self {
        case .sunset:
            return UIColor(red: 0.22, green: 0.10, blue: 0.20, alpha: 0.50)
        case .nocturne:
            return UIColor.black.withAlphaComponent(0.65)
        default:
            return UIColor(red: 0.10, green: 0.14, blue: 0.22, alpha: 0.45)
        }
    }

    var ambientColor: UIColor {
        switch self {
        case .vanilla:
            return UIColor(white: 0.96, alpha: 1.0)
        case .vibrant:
            return UIColor(red: 0.82, green: 0.90, blue: 1.0, alpha: 1.0)
        case .sunset:
            return UIColor(red: 0.92, green: 0.65, blue: 0.55, alpha: 1.0)
        case .cinematic:
            return UIColor(white: 0.92, alpha: 1.0)
        case .celShaded:
            return UIColor(white: 0.98, alpha: 1.0)
        case .nocturne:
            return UIColor(red: 0.25, green: 0.35, blue: 0.55, alpha: 1.0)
        }
    }

    var ambientIntensity: CGFloat {
        switch self {
        case .vanilla: return 560
        case .vibrant: return 640
        case .sunset: return 480
        case .cinematic: return 520
        case .celShaded: return 660
        case .nocturne: return 360
        }
    }

    var bloomIntensity: CGFloat {
        switch self {
        case .vanilla: return 0.0
        case .vibrant: return 0.65
        case .sunset: return 0.85
        case .cinematic: return 0.45
        case .celShaded: return 0.35
        case .nocturne: return 0.90
        }
    }

    var bloomThreshold: CGFloat {
        switch self {
        case .nocturne: return 0.55
        case .sunset: return 0.65
        default: return 0.78
        }
    }

    var bloomBlurRadius: CGFloat {
        switch self {
        case .sunset: return 18.0
        case .nocturne: return 16.0
        default: return 12.0
        }
    }

    var vignettingIntensity: CGFloat {
        switch self {
        case .vanilla: return 0.0
        case .vibrant: return 0.25
        case .sunset: return 0.40
        case .cinematic: return 0.55
        case .celShaded: return 0.60
        case .nocturne: return 0.50
        }
    }

    var vignettingPower: CGFloat {
        switch self {
        case .celShaded: return 1.6
        case .cinematic: return 1.35
        default: return 1.15
        }
    }

    var colorFringeStrength: CGFloat {
        switch self {
        case .cinematic: return 0.8
        case .celShaded: return 1.2
        default: return 0.0
        }
    }

    var hasWaterWaves: Bool {
        switch self {
        case .vanilla: return false
        default: return true
        }
    }
}
