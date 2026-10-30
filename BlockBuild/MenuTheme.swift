import SwiftUI
import UIKit

// MARK: - Menu Themes

enum MenuTheme: String, CaseIterable, Identifiable, Codable {
    case stoneCraft = "Stone Craft"
    case obsidianNeon = "Obsidian Neon"
    case netherCrimson = "Nether Crimson"
    case diamondFrost = "Diamond Frost"
    case goldenSand = "Golden Sand"
    case emeraldForest = "Emerald Forest"
    case cyberRedstone = "Cyber Redstone"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var subtitle: String {
        switch self {
        case .stoneCraft: return "Chiseled slate stone, oak timber & torchlight gold"
        case .obsidianNeon: return "Deep obsidian bedrock with radiant cyan & violet glow"
        case .netherCrimson: return "Volcanic basalt, crimson fire & molten gold accents"
        case .diamondFrost: return "Glacial sapphire ice, diamond shimmer & pale frost"
        case .goldenSand: return "Sun-drenched desert sandstone & warm amber ore"
        case .emeraldForest: return "Lush spruce woodland, jade foliage & golden morning sun"
        case .cyberRedstone: return "Deep carbon alloy, radioactive redstone pulse & crimson spark"
        }
    }

    var iconName: String {
        switch self {
        case .stoneCraft: return "cube.fill"
        case .obsidianNeon: return "sparkles"
        case .netherCrimson: return "flame.fill"
        case .diamondFrost: return "snowflake"
        case .goldenSand: return "sun.max.fill"
        case .emeraldForest: return "leaf.fill"
        case .cyberRedstone: return "bolt.fill"
        }
    }

    var primaryAccent: Color {
        switch self {
        case .stoneCraft: return Color(red: 0.28, green: 0.76, blue: 0.38) // emerald green
        case .obsidianNeon: return Color(red: 0.00, green: 0.94, blue: 1.00) // neon cyan
        case .netherCrimson: return Color(red: 1.00, green: 0.26, blue: 0.26) // crimson red
        case .diamondFrost: return Color(red: 0.28, green: 0.86, blue: 1.00) // diamond cyan
        case .goldenSand: return Color(red: 0.98, green: 0.70, blue: 0.16) // amber gold
        case .emeraldForest: return Color(red: 0.16, green: 0.88, blue: 0.45) // jade emerald
        case .cyberRedstone: return Color(red: 1.00, green: 0.18, blue: 0.25) // glowing redstone
        }
    }

    var secondaryAccent: Color {
        switch self {
        case .stoneCraft: return Color(red: 0.94, green: 0.72, blue: 0.22) // torch gold
        case .obsidianNeon: return Color(red: 0.72, green: 0.22, blue: 1.00) // electric violet
        case .netherCrimson: return Color(red: 1.00, green: 0.74, blue: 0.00) // molten gold
        case .diamondFrost: return Color(red: 0.68, green: 0.88, blue: 1.00) // pale frost
        case .goldenSand: return Color(red: 1.00, green: 0.90, blue: 0.44) // sunbeam
        case .emeraldForest: return Color(red: 0.85, green: 0.95, blue: 0.35) // sunlit leaf
        case .cyberRedstone: return Color(red: 1.00, green: 0.58, blue: 0.12) // plasma orange
        }
    }

    var backgroundGradient: [Color] {
        switch self {
        case .stoneCraft:
            return [Color(red: 0.10, green: 0.11, blue: 0.13), Color(red: 0.15, green: 0.17, blue: 0.20)]
        case .obsidianNeon:
            return [Color(red: 0.04, green: 0.04, blue: 0.08), Color(red: 0.08, green: 0.08, blue: 0.15)]
        case .netherCrimson:
            return [Color(red: 0.11, green: 0.03, blue: 0.04), Color(red: 0.18, green: 0.05, blue: 0.07)]
        case .diamondFrost:
            return [Color(red: 0.04, green: 0.09, blue: 0.15), Color(red: 0.08, green: 0.15, blue: 0.24)]
        case .goldenSand:
            return [Color(red: 0.14, green: 0.10, blue: 0.05), Color(red: 0.22, green: 0.15, blue: 0.08)]
        case .emeraldForest:
            return [Color(red: 0.04, green: 0.11, blue: 0.07), Color(red: 0.07, green: 0.17, blue: 0.10)]
        case .cyberRedstone:
            return [Color(red: 0.08, green: 0.05, blue: 0.06), Color(red: 0.14, green: 0.07, blue: 0.08)]
        }
    }

    var cardBackground: Color {
        switch self {
        case .stoneCraft: return Color(red: 0.17, green: 0.18, blue: 0.22).opacity(0.95)
        case .obsidianNeon: return Color(red: 0.10, green: 0.10, blue: 0.18).opacity(0.95)
        case .netherCrimson: return Color(red: 0.20, green: 0.07, blue: 0.09).opacity(0.95)
        case .diamondFrost: return Color(red: 0.10, green: 0.18, blue: 0.28).opacity(0.95)
        case .goldenSand: return Color(red: 0.24, green: 0.17, blue: 0.10).opacity(0.95)
        case .emeraldForest: return Color(red: 0.10, green: 0.20, blue: 0.14).opacity(0.95)
        case .cyberRedstone: return Color(red: 0.16, green: 0.10, blue: 0.12).opacity(0.95)
        }
    }

    var cardBorder: Color {
        switch self {
        case .stoneCraft: return Color(red: 0.35, green: 0.38, blue: 0.44)
        case .obsidianNeon: return Color(red: 0.00, green: 0.94, blue: 1.00).opacity(0.42)
        case .netherCrimson: return Color(red: 1.00, green: 0.30, blue: 0.30).opacity(0.45)
        case .diamondFrost: return Color(red: 0.30, green: 0.88, blue: 1.00).opacity(0.42)
        case .goldenSand: return Color(red: 0.98, green: 0.70, blue: 0.16).opacity(0.45)
        case .emeraldForest: return Color(red: 0.20, green: 0.75, blue: 0.40).opacity(0.45)
        case .cyberRedstone: return Color(red: 1.00, green: 0.22, blue: 0.28).opacity(0.48)
        }
    }

    var buttonBackground: Color {
        switch self {
        case .stoneCraft: return Color(red: 0.24, green: 0.26, blue: 0.31)
        case .obsidianNeon: return Color(red: 0.15, green: 0.15, blue: 0.26)
        case .netherCrimson: return Color(red: 0.28, green: 0.11, blue: 0.13)
        case .diamondFrost: return Color(red: 0.14, green: 0.24, blue: 0.36)
        case .goldenSand: return Color(red: 0.32, green: 0.23, blue: 0.14)
        case .emeraldForest: return Color(red: 0.14, green: 0.28, blue: 0.19)
        case .cyberRedstone: return Color(red: 0.26, green: 0.14, blue: 0.16)
        }
    }

    var headerGradient: LinearGradient {
        LinearGradient(colors: [primaryAccent, secondaryAccent], startPoint: .leading, endPoint: .trailing)
    }

    var alternateIconName: String? {
        switch self {
        case .stoneCraft: return nil // Default primary app icon
        case .obsidianNeon: return "AppIcon-ObsidianNeon"
        case .netherCrimson: return "AppIcon-NetherCrimson"
        case .diamondFrost: return "AppIcon-DiamondFrost"
        case .goldenSand: return "AppIcon-GoldenSand"
        case .emeraldForest: return "AppIcon-EmeraldForest"
        case .cyberRedstone: return "AppIcon-CyberRedstone"
        }
    }
}

// MARK: - Menu Theme Manager

final class MenuThemeManager: ObservableObject {
    static let shared = MenuThemeManager()

    @Published var currentTheme: MenuTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "blockbuild_menu_theme")
            updateAppIcon(for: currentTheme)
        }
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: "blockbuild_menu_theme"),
           let theme = MenuTheme(rawValue: saved) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .stoneCraft
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.updateAppIcon(for: self.currentTheme)
        }
    }

    func updateAppIcon(for theme: MenuTheme) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        let targetIcon = theme.alternateIconName
        let currentIcon = UIApplication.shared.alternateIconName
        if currentIcon != targetIcon {
            UIApplication.shared.setAlternateIconName(targetIcon) { error in
                if let error = error {
                    print("[MenuTheme] Failed to set alternate app icon to \(targetIcon ?? "default"): \(error.localizedDescription)")
                } else {
                    print("[MenuTheme] App icon changed to: \(targetIcon ?? "default")")
                }
            }
        }
    }
}

// MARK: - Custom Game UI Components (No Apple List / Form)

struct GameMenuContainer<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    var icon: String? = nil
    var onDismiss: (() -> Void)? = nil
    @ViewBuilder let content: () -> Content

    @ObservedObject private var themeMgr = MenuThemeManager.shared

    var body: some View {
        let theme = themeMgr.currentTheme

        ZStack {
            // Themed Background
            LinearGradient(colors: theme.backgroundGradient, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            // Subtle scanline / vignette texture
            RadialGradient(
                colors: [Color.clear, Color.black.opacity(0.45)],
                center: .center,
                startRadius: 200,
                endRadius: 700
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Custom Navigation Bar
                HStack(spacing: 12) {
                    if let icon = icon {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.cardBackground)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(theme.cardBorder, lineWidth: 1))
                                .frame(width: 36, height: 36)
                            Image(systemName: icon)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(theme.primaryAccent)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title.uppercased())
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .foregroundStyle(theme.headerGradient)
                            .shadow(color: .black.opacity(0.8), radius: 2, y: 1)
                            .lineLimit(1)

                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.70))
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    if let onDismiss = onDismiss {
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            onDismiss()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(theme.cardBackground)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(theme.cardBorder, lineWidth: 1.5))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "xmark")
                                    .font(.system(size: 15, weight: .black))
                                    .foregroundColor(.white.opacity(0.95))
                            }
                            .frame(width: 48, height: 48)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 12)
                .background(
                    theme.cardBackground.opacity(0.85)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(theme.cardBorder.opacity(0.5)),
                            alignment: .bottom
                        )
                )

                // Scrollable Content
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 14) {
                        content()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
        }
    }
}

// MARK: - Game Card Panel

struct GameCard<Content: View>: View {
    var title: String? = nil
    var icon: String? = nil
    var badge: String? = nil
    @ViewBuilder let content: () -> Content

    @ObservedObject private var themeMgr = MenuThemeManager.shared

    var body: some View {
        let theme = themeMgr.currentTheme

        VStack(alignment: .leading, spacing: 10) {
            if title != nil || icon != nil || badge != nil {
                HStack(spacing: 8) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(theme.primaryAccent)
                    }

                    if let title = title {
                        Text(title.uppercased())
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(theme.secondaryAccent)
                    }

                    Spacer()

                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .foregroundColor(theme.primaryAccent)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2.5)
                            .background(theme.primaryAccent.opacity(0.18))
                            .cornerRadius(5)
                    }
                }
                .padding(.bottom, 2)
            }

            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.cardBorder, lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.35), radius: 4, y: 2)
    }
}

// MARK: - Game Button

struct GameButton: View {
    let title: String
    var subtitle: String? = nil
    var icon: String? = nil
    var color: Color? = nil
    var isDestructive: Bool = false
    var isProminent: Bool = false
    let action: () -> Void

    @ObservedObject private var themeMgr = MenuThemeManager.shared

    var body: some View {
        let theme = themeMgr.currentTheme
        let accent = isDestructive ? Color.red : (color ?? theme.primaryAccent)

        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 12) {
                if let icon = icon {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(accent.opacity(isProminent ? 0.30 : 0.18))
                            .frame(width: 32, height: 32)
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(isProminent ? .white : accent)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title.uppercased())
                        .font(.system(size: 12.5, weight: .black, design: .monospaced))
                        .foregroundColor(isDestructive ? .red : .white)
                        .lineLimit(1)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.70))
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.40))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                isProminent
                    ? LinearGradient(colors: [accent.opacity(0.90), accent.opacity(0.65)], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [theme.buttonBackground, theme.buttonBackground.opacity(0.75)], startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isProminent ? accent : theme.cardBorder.opacity(0.7), lineWidth: 1.2)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Game Slider Row (Large Stepper Buttons to Prevent List Collision)

struct GameSliderRow: View {
    let title: String
    let icon: String
    @Binding var value: Float
    let range: ClosedRange<Float>
    let step: Float
    let formatString: String

    @ObservedObject private var themeMgr = MenuThemeManager.shared

    var body: some View {
        let theme = themeMgr.currentTheme

        VStack(spacing: 6) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.90))

                Spacer()

                Text(String(format: formatString, value))
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(theme.primaryAccent)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(theme.primaryAccent.opacity(0.15))
                    .cornerRadius(5)
            }

            HStack(spacing: 12) {
                // Minus Stepper
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    value = max(range.lowerBound, value - step)
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(theme.buttonBackground)
                            .overlay(RoundedRectangle(cornerRadius: 7).stroke(theme.cardBorder, lineWidth: 1))
                            .frame(width: 38, height: 32)
                        Image(systemName: "minus")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Slider Track
                Slider(
                    value: Binding(
                        get: { value },
                        set: { value = min(max($0, range.lowerBound), range.upperBound) }
                    ),
                    in: range,
                    step: step
                )
                .tint(theme.primaryAccent)

                // Plus Stepper
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    value = min(range.upperBound, value + step)
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(theme.buttonBackground)
                            .overlay(RoundedRectangle(cornerRadius: 7).stroke(theme.cardBorder, lineWidth: 1))
                            .frame(width: 38, height: 32)
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Game Toggle Row

struct GameToggleRow: View {
    let title: String
    var subtitle: String? = nil
    let icon: String
    @Binding var isOn: Bool

    @ObservedObject private var themeMgr = MenuThemeManager.shared

    var body: some View {
        let theme = themeMgr.currentTheme

        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(isOn ? theme.primaryAccent.opacity(0.20) : Color.white.opacity(0.08))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isOn ? theme.primaryAccent : .white.opacity(0.6))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12.5, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.65))
                }
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(theme.primaryAccent)
        }
        .padding(.vertical, 3)
    }
}

// MARK: - Menu Theme Picker Component

struct MenuThemePickerView: View {
    @ObservedObject private var themeMgr = MenuThemeManager.shared

    var body: some View {
        VStack(spacing: 8) {
            ForEach(MenuTheme.allCases) { theme in
                let isSelected = themeMgr.currentTheme == theme

                Button {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    themeMgr.currentTheme = theme
                } label: {
                    HStack(spacing: 12) {
                        // Custom Themed App Icon Preview
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(theme.cardBackground)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(theme.cardBorder, lineWidth: 1.5))
                                .frame(width: 44, height: 44)

                            let iconAssetName = theme.alternateIconName ?? "AppIcon-StoneCraft"
                            if let uiImg = UIImage(named: iconAssetName) {
                                Image(uiImage: uiImg)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 44, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(theme.cardBorder, lineWidth: 1))
                            } else {
                                Image(systemName: theme.iconName)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(theme.primaryAccent)
                            }
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(theme.displayName.uppercased())
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundColor(.white)

                                Spacer()

                                if isSelected {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12, weight: .bold))
                                        Text("ACTIVE")
                                            .font(.system(size: 9, weight: .black, design: .monospaced))
                                    }
                                    .foregroundColor(theme.primaryAccent)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 2.5)
                                    .background(theme.primaryAccent.opacity(0.18))
                                    .cornerRadius(6)
                                }
                            }

                            Text(theme.subtitle)
                                .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.70))
                                .lineLimit(1)

                            HStack(spacing: 8) {
                                // Theme palette swatches preview
                                HStack(spacing: 4) {
                                    ForEach(0..<4) { idx in
                                        let swatchColor: Color = {
                                            switch idx {
                                            case 0: return theme.primaryAccent
                                            case 1: return theme.secondaryAccent
                                            case 2: return theme.buttonBackground
                                            default: return theme.cardBorder
                                            }
                                        }()
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(swatchColor)
                                            .frame(width: 12, height: 5)
                                    }
                                }

                                // Custom App Icon indicator badge
                                HStack(spacing: 3) {
                                    Image(systemName: "app.badge.fill")
                                        .font(.system(size: 8))
                                    Text("CUSTOM APP ICON")
                                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                                }
                                .foregroundColor(theme.secondaryAccent)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1.5)
                                .background(theme.secondaryAccent.opacity(0.15))
                                .cornerRadius(4)
                            }
                            .padding(.top, 2)
                        }
                    }
                    .padding(10)
                    .background(
                        isSelected
                            ? theme.primaryAccent.opacity(0.15)
                            : theme.cardBackground.opacity(0.60)
                    )
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? theme.primaryAccent : theme.cardBorder.opacity(0.6), lineWidth: isSelected ? 2 : 1)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Game Text Field

struct GameTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var onSubmit: (() -> Void)? = nil

    @ObservedObject private var themeMgr = MenuThemeManager.shared

    var body: some View {
        let theme = themeMgr.currentTheme

        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(theme.primaryAccent)
            }

            TextField(placeholder, text: $text)
                .font(.system(size: 12.5, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onSubmit { onSubmit?() }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.45))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .background(theme.buttonBackground.opacity(0.70))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(theme.cardBorder.opacity(0.85), lineWidth: 1)
        )
    }
}

// MARK: - Game Small Action Button

struct GameSmallButton: View {
    let title: String
    var icon: String? = nil
    var color: Color? = nil
    var isDestructive: Bool = false
    var isProminent: Bool = false
    let action: () -> Void

    @ObservedObject private var themeMgr = MenuThemeManager.shared

    var body: some View {
        let theme = themeMgr.currentTheme
        let accent = isDestructive ? Color.red : (color ?? theme.primaryAccent)

        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 5) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 10, weight: .bold))
                }
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .black, design: .monospaced))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                isProminent
                    ? accent.opacity(0.90)
                    : (isDestructive ? Color.red.opacity(0.25) : theme.buttonBackground)
            )
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(accent.opacity(isProminent ? 1.0 : 0.6), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Game Segmented Picker

struct GameSegmentedPicker<T: Hashable & CustomStringConvertible>: View {
    let items: [T]
    @Binding var selection: T
    var iconProvider: ((T) -> String)? = nil

    @ObservedObject private var themeMgr = MenuThemeManager.shared

    var body: some View {
        let theme = themeMgr.currentTheme

        HStack(spacing: 6) {
            ForEach(items, id: \.self) { item in
                let isSelected = (selection == item)

                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    selection = item
                } label: {
                    HStack(spacing: 5) {
                        if let iconName = iconProvider?(item) {
                            Image(systemName: iconName)
                                .font(.system(size: 11, weight: .bold))
                        }
                        Text(item.description.uppercased())
                            .font(.system(size: 10.5, weight: .black, design: .monospaced))
                    }
                    .foregroundColor(isSelected ? .white : .white.opacity(0.65))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(
                        isSelected
                            ? theme.primaryAccent.opacity(0.85)
                            : theme.buttonBackground.opacity(0.55)
                    )
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSelected ? theme.primaryAccent : theme.cardBorder.opacity(0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(theme.cardBackground.opacity(0.8))
        .cornerRadius(9)
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(theme.cardBorder.opacity(0.5), lineWidth: 1)
        )
    }
}
