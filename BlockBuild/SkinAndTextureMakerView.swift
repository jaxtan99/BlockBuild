import SwiftUI
import SceneKit
import UIKit

// MARK: - Skin & Texture Maker Mode

enum MakerStudioMode: String, CaseIterable, Identifiable, CustomStringConvertible {
    case skin = "Skin Maker"
    case texture = "Texture Maker"

    var id: String { rawValue }
    var description: String { rawValue }

    var iconName: String {
        switch self {
        case .skin: return "person.crop.artframe"
        case .texture: return "cube.fill"
        }
    }
}

// MARK: - Drawing Tools

enum PixelDrawingTool: String, CaseIterable, Identifiable {
    case pencil = "Pencil"
    case bucket = "Fill"
    case eraser = "Eraser"
    case eyedropper = "Picker"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .pencil: return "pencil.tip"
        case .bucket: return "drop.fill"
        case .eraser: return "eraser.fill"
        case .eyedropper: return "eyedropper"
        }
    }
}

// MARK: - Character Skin Editable Parts (Standard 64x64 Minecraft UV Map)

enum SkinBodySection: String, CaseIterable, Identifiable {
    case head = "Head"
    case torso = "Torso"
    case rightArm = "Right Arm"
    case leftArm = "Left Arm"
    case rightLeg = "Right Leg"
    case leftLeg = "Left Leg"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .head: return "person.crop.circle"
        case .torso: return "tshirt.fill"
        case .rightArm, .leftArm: return "hand.raised.fill"
        case .rightLeg, .leftLeg: return "figure.walk"
        }
    }

    var parts: [SkinEditablePart] {
        SkinEditablePart.allCases.filter { $0.section == self }
    }
}

enum SkinEditablePart: String, CaseIterable, Identifiable, CustomStringConvertible {
    // 1. Head (All 6 faces)
    case headFront = "Head Front"
    case headBack = "Head Back"
    case headRight = "Head Right"
    case headLeft = "Head Left"
    case headTop = "Head Top"
    case headBottom = "Head Bottom"

    // 2. Torso (All 6 faces)
    case torsoFront = "Torso Front"
    case torsoBack = "Torso Back"
    case torsoRight = "Torso Right"
    case torsoLeft = "Torso Left"
    case torsoTop = "Torso Top (Shoulders)"
    case torsoBottom = "Torso Bottom (Waist)"

    // 3. Right Arm (All 6 faces)
    case rightArmFront = "R Arm Front"
    case rightArmBack = "R Arm Back"
    case rightArmOuter = "R Arm Outer"
    case rightArmInner = "R Arm Inner"
    case rightArmTop = "R Arm Shoulder"
    case rightArmBottom = "R Arm Hand"

    // 4. Left Arm (All 6 faces)
    case leftArmFront = "L Arm Front"
    case leftArmBack = "L Arm Back"
    case leftArmOuter = "L Arm Outer"
    case leftArmInner = "L Arm Inner"
    case leftArmTop = "L Arm Shoulder"
    case leftArmBottom = "L Arm Hand"

    // 5. Right Leg (All 6 faces)
    case rightLegFront = "R Leg Front"
    case rightLegBack = "R Leg Back"
    case rightLegOuter = "R Leg Outer"
    case rightLegInner = "R Leg Inner"
    case rightLegTop = "R Leg Top"
    case rightLegBottom = "R Leg Foot"

    // 6. Left Leg (All 6 faces)
    case leftLegFront = "L Leg Front"
    case leftLegBack = "L Leg Back"
    case leftLegOuter = "L Leg Outer"
    case leftLegInner = "L Leg Inner"
    case leftLegTop = "L Leg Top"
    case leftLegBottom = "L Leg Foot"

    var id: String { rawValue }
    var description: String { rawValue }

    var section: SkinBodySection {
        if rawValue.starts(with: "Head") { return .head }
        if rawValue.starts(with: "Torso") { return .torso }
        if rawValue.starts(with: "R Arm") { return .rightArm }
        if rawValue.starts(with: "L Arm") { return .leftArm }
        if rawValue.starts(with: "R Leg") { return .rightLeg }
        return .leftLeg
    }

    var shortFaceName: String {
        switch self {
        case .headFront, .torsoFront, .rightArmFront, .leftArmFront, .rightLegFront, .leftLegFront:
            return "Front"
        case .headBack, .torsoBack, .rightArmBack, .leftArmBack, .rightLegBack, .leftLegBack:
            return "Back"
        case .headRight:
            return "Right"
        case .headLeft:
            return "Left"
        case .headTop:
            return "Top (Hair)"
        case .headBottom:
            return "Bottom (Neck)"
        case .torsoRight:
            return "Right Side"
        case .torsoLeft:
            return "Left Side"
        case .torsoTop:
            return "Shoulders"
        case .torsoBottom:
            return "Waist"
        case .rightArmOuter, .leftArmOuter:
            return "Outer Side"
        case .rightArmInner, .leftArmInner:
            return "Inner Side"
        case .rightArmTop, .leftArmTop:
            return "Shoulder"
        case .rightArmBottom, .leftArmBottom:
            return "Hand/Palm"
        case .rightLegOuter, .leftLegOuter:
            return "Outer Side"
        case .rightLegInner, .leftLegInner:
            return "Inner Side"
        case .rightLegTop, .leftLegTop:
            return "Top (Hip)"
        case .rightLegBottom, .leftLegBottom:
            return "Bottom (Foot/Sole)"
        }
    }

    // Coordinates in 64x64 standard Minecraft skin PNG: (startX, startY, width, height)
    var uvRect: (x: Int, y: Int, w: Int, h: Int) {
        switch self {
        // Head (8x8x8 cube)
        case .headFront: return (8, 8, 8, 8)
        case .headBack: return (24, 8, 8, 8)
        case .headRight: return (0, 8, 8, 8)
        case .headLeft: return (16, 8, 8, 8)
        case .headTop: return (8, 0, 8, 8)
        case .headBottom: return (16, 0, 8, 8)

        // Torso (8 wide x 12 high x 4 deep)
        case .torsoFront: return (20, 20, 8, 12)
        case .torsoRight: return (16, 20, 4, 12)
        case .torsoBack: return (32, 20, 8, 12)
        case .torsoLeft: return (28, 20, 4, 12)
        case .torsoTop: return (20, 16, 8, 4)
        case .torsoBottom: return (28, 16, 8, 4)

        // Right Arm (4 wide x 12 high x 4 deep)
        case .rightArmFront: return (44, 20, 4, 12)
        case .rightArmOuter: return (40, 20, 4, 12)
        case .rightArmBack: return (52, 20, 4, 12)
        case .rightArmInner: return (48, 20, 4, 12)
        case .rightArmTop: return (44, 16, 4, 4)
        case .rightArmBottom: return (48, 16, 4, 4)

        // Left Arm (4 wide x 12 high x 4 deep, 64x64 layout)
        case .leftArmFront: return (36, 52, 4, 12)
        case .leftArmOuter: return (32, 52, 4, 12)
        case .leftArmBack: return (44, 52, 4, 12)
        case .leftArmInner: return (40, 52, 4, 12)
        case .leftArmTop: return (36, 48, 4, 4)
        case .leftArmBottom: return (40, 48, 4, 4)

        // Right Leg (4 wide x 12 high x 4 deep)
        case .rightLegFront: return (4, 20, 4, 12)
        case .rightLegOuter: return (0, 20, 4, 12)
        case .rightLegBack: return (12, 20, 4, 12)
        case .rightLegInner: return (8, 20, 4, 12)
        case .rightLegTop: return (4, 16, 4, 4)
        case .rightLegBottom: return (8, 16, 4, 4)

        // Left Leg (4 wide x 12 high x 4 deep, 64x64 layout)
        case .leftLegFront: return (20, 52, 4, 12)
        case .leftLegOuter: return (16, 52, 4, 12)
        case .leftLegBack: return (28, 52, 4, 12)
        case .leftLegInner: return (24, 52, 4, 12)
        case .leftLegTop: return (20, 48, 4, 4)
        case .leftLegBottom: return (24, 48, 4, 4)
        }
    }
}

// MARK: - Retro Palette Colors

struct RetroPaletteColor: Identifiable {
    let id = UUID()
    let name: String
    let color: UIColor

    static let defaults: [RetroPaletteColor] = [
        // Skin & Face
        RetroPaletteColor(name: "Fair Skin", color: UIColor(red: 0.98, green: 0.82, blue: 0.72, alpha: 1.0)),
        RetroPaletteColor(name: "Peach Skin", color: UIColor(red: 0.92, green: 0.74, blue: 0.62, alpha: 1.0)),
        RetroPaletteColor(name: "Tan Skin", color: UIColor(red: 0.80, green: 0.60, blue: 0.45, alpha: 1.0)),
        RetroPaletteColor(name: "Bronze Skin", color: UIColor(red: 0.58, green: 0.40, blue: 0.28, alpha: 1.0)),
        RetroPaletteColor(name: "Deep Brown", color: UIColor(red: 0.38, green: 0.24, blue: 0.16, alpha: 1.0)),

        // Hair & Eyes
        RetroPaletteColor(name: "Dark Hair", color: UIColor(red: 0.18, green: 0.12, blue: 0.08, alpha: 1.0)),
        RetroPaletteColor(name: "Brown Hair", color: UIColor(red: 0.42, green: 0.28, blue: 0.16, alpha: 1.0)),
        RetroPaletteColor(name: "Blonde Hair", color: UIColor(red: 0.94, green: 0.84, blue: 0.44, alpha: 1.0)),
        RetroPaletteColor(name: "Ginger Hair", color: UIColor(red: 0.88, green: 0.45, blue: 0.18, alpha: 1.0)),
        RetroPaletteColor(name: "Cyan Eyes", color: UIColor(red: 0.00, green: 0.85, blue: 0.95, alpha: 1.0)),

        // Clothes & Tones
        RetroPaletteColor(name: "Classic Blue", color: UIColor(red: 0.05, green: 0.42, blue: 0.75, alpha: 1.0)),
        RetroPaletteColor(name: "Denim Navy", color: UIColor(red: 0.15, green: 0.24, blue: 0.48, alpha: 1.0)),
        RetroPaletteColor(name: "Forest Green", color: UIColor(red: 0.18, green: 0.58, blue: 0.26, alpha: 1.0)),
        RetroPaletteColor(name: "Crimson Red", color: UIColor(red: 0.85, green: 0.18, blue: 0.20, alpha: 1.0)),
        RetroPaletteColor(name: "Sun Yellow", color: UIColor(red: 0.96, green: 0.78, blue: 0.14, alpha: 1.0)),
        RetroPaletteColor(name: "Deep Purple", color: UIColor(red: 0.54, green: 0.20, blue: 0.78, alpha: 1.0)),
        RetroPaletteColor(name: "Orange Blaze", color: UIColor(red: 0.95, green: 0.48, blue: 0.12, alpha: 1.0)),

        // Minerals & Neutral
        RetroPaletteColor(name: "Pure White", color: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
        RetroPaletteColor(name: "Silver Gray", color: UIColor(red: 0.72, green: 0.74, blue: 0.78, alpha: 1.0)),
        RetroPaletteColor(name: "Slate Stone", color: UIColor(red: 0.40, green: 0.42, blue: 0.46, alpha: 1.0)),
        RetroPaletteColor(name: "Obsidian Black", color: UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1.0)),
        RetroPaletteColor(name: "Diamond Cyan", color: UIColor(red: 0.20, green: 0.92, blue: 0.92, alpha: 1.0)),
        RetroPaletteColor(name: "Gold Ingot", color: UIColor(red: 0.98, green: 0.84, blue: 0.20, alpha: 1.0)),
        RetroPaletteColor(name: "Emerald Gem", color: UIColor(red: 0.10, green: 0.88, blue: 0.42, alpha: 1.0))
    ]
}

// MARK: - Undo & Redo History Models

struct SkinHistoryFrame {
    let pixels: [[UIColor]]
    let section: SkinBodySection
    let part: SkinEditablePart
}

struct BlockHistoryFrame {
    let pixels: [[UIColor]]
    let blockType: BlockType
    let face: BlockFace
}

// MARK: - Main Skin & Texture Maker View

struct SkinAndTextureMakerView: View {
    @ObservedObject var world: VoxelWorld
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var themeMgr = MenuThemeManager.shared

    @State private var mode: MakerStudioMode = .skin

    // --- Skin Maker State ---
    @State private var selectedSkinPreset: PlayerSkin = .steve
    @State private var selectedBodySection: SkinBodySection = .head
    @State private var selectedPart: SkinEditablePart = .headFront
    @State private var skinPixels: [[UIColor]] = Array(repeating: Array(repeating: .clear, count: 64), count: 64)
    @State private var skinTool: PixelDrawingTool = .pencil
    @State private var selectedColor: UIColor = RetroPaletteColor.defaults[0].color
    @State private var customSkinName: String = "My Custom Skin"
    @State private var activeSkinID: UUID = UUID()
    @State private var previewCustomSkin: CustomSkin? = nil
    @State private var show3DModelSheet: Bool = false
    @State private var statusToast: String? = nil

    // Undo & Redo stacks for skin (stores past 64x64 pixel states with body part)
    @State private var skinUndoStack: [SkinHistoryFrame] = []
    @State private var skinRedoStack: [SkinHistoryFrame] = []

    // --- Texture Maker State ---
    @State private var selectedBlockType: BlockType = .woodLog
    @State private var selectedBlockFace: BlockFace = .side
    @State private var blockPixels: [[UIColor]] = Array(repeating: Array(repeating: .gray, count: 16), count: 16)
    @State private var blockTool: PixelDrawingTool = .pencil
    @State private var blockUndoStack: [BlockHistoryFrame] = []
    @State private var blockRedoStack: [BlockHistoryFrame] = []
    @State private var showBlock3DModelSheet: Bool = false
    @State private var hasLoadedInitialContent: Bool = false

    var body: some View {
        let theme = themeMgr.currentTheme

        GameMenuContainer(
            title: "SKIN & TEXTURE MAKER",
            subtitle: "Edit PNG Pixels • Inspect 3D Model After",
            icon: "paintpalette.fill",
            onDismiss: { dismiss() }
        ) {
            // Mode Switcher: Skin Maker vs Texture Maker
            GameSegmentedPicker(
                items: MakerStudioMode.allCases,
                selection: $mode,
                iconProvider: { $0.iconName }
            )
            .padding(.bottom, 4)

            if mode == .skin {
                skinMakerSection(theme: theme)
            } else {
                textureMakerSection(theme: theme)
            }

            if let toast = statusToast {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(toast)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.85))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.green.opacity(0.6), lineWidth: 1))
                .transition(.opacity)
            }
        }
        .onAppear {
            if !hasLoadedInitialContent {
                let skinImage = SkinTextureManager.shared.skinImage(for: selectedSkinPreset)
                skinPixels = extractPixelsFromImage(skinImage, width: 64, height: 64)
                activeSkinID = UUID()
                updatePreviewCustomSkin()

                let blockImage = BlockType.baseTextureImage(for: selectedBlockType, face: selectedBlockFace, pack: .classic)
                blockPixels = extractPixelsFromImage(blockImage, width: 16, height: 16)

                hasLoadedInitialContent = true
            }
        }
        .sheet(isPresented: $show3DModelSheet) {
            full3DModelInspectorSheet(theme: theme)
        }
        .sheet(isPresented: $showBlock3DModelSheet) {
            fullBlock3DModelInspectorSheet(theme: theme)
        }
    }

    // MARK: - Skin Maker Section

    @ViewBuilder
    private func skinMakerSection(theme: MenuTheme) -> some View {
        // Preset Skin Loader & Name Card
        GameCard(title: "CHARACTER BASE & NAME", icon: "person.text.rectangle") {
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    GameTextField(placeholder: "Custom Skin Name...", text: $customSkinName, icon: "pencil")
                }

                // Preset selector chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(PlayerSkin.allCases) { preset in
                            let isSelected = (selectedSkinPreset == preset)
                            Button {
                                selectedSkinPreset = preset
                                loadSkinFromPreset(preset)
                            } label: {
                                HStack(spacing: 5) {
                                    CharacterAvatarPreview(skin: preset, size: 20)
                                    Text(preset.displayName.uppercased())
                                        .font(.system(size: 9.5, weight: .black, design: .monospaced))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(isSelected ? theme.primaryAccent.opacity(0.85) : theme.buttonBackground)
                                .foregroundColor(isSelected ? .white : .white.opacity(0.75))
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(isSelected ? theme.primaryAccent : theme.cardBorder.opacity(0.5), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        // Blank Template Button
                        Button {
                            clearSkinToBlank()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "square.dashed")
                                Text("BLANK CANVAS")
                                    .font(.system(size: 9.5, weight: .black, design: .monospaced))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(theme.buttonBackground)
                            .foregroundColor(.white.opacity(0.75))
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(theme.cardBorder.opacity(0.5), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }

        // Body Part Selector & Tools Card
        GameCard(title: "SELECT BODY PART & SIDE TO PAINT", icon: "figure.walk") {
            VStack(spacing: 10) {
                // 1. Body Section Selector (Head, Torso, Right Arm, Left Arm, Right Leg, Left Leg)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(SkinBodySection.allCases) { section in
                            let isSelected = (selectedBodySection == section)
                            Button {
                                selectedBodySection = section
                                if !section.parts.contains(selectedPart) {
                                    selectedPart = section.parts.first ?? .headFront
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: section.iconName)
                                        .font(.system(size: 11, weight: .bold))
                                    Text(section.rawValue.uppercased())
                                        .font(.system(size: 10, weight: .black, design: .monospaced))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(isSelected ? theme.primaryAccent.opacity(0.9) : theme.buttonBackground)
                                .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(isSelected ? theme.primaryAccent : theme.cardBorder.opacity(0.5), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // 2. Specific Face Selector for the Active Body Part (Front, Back, Left, Right, Top, Bottom)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "cube.transparent")
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundColor(theme.secondaryAccent)
                        Text("\(selectedBodySection.rawValue.uppercased()) FACES (ALL 6 SIDES):")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .foregroundColor(theme.secondaryAccent)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(selectedBodySection.parts) { part in
                                let isSelected = (selectedPart == part)
                                Button {
                                    selectedPart = part
                                } label: {
                                    Text(part.shortFaceName.uppercased())
                                        .font(.system(size: 9.5, weight: .black, design: .monospaced))
                                        .padding(.horizontal, 9)
                                        .padding(.vertical, 5)
                                        .background(isSelected ? theme.secondaryAccent.opacity(0.9) : theme.buttonBackground)
                                        .foregroundColor(isSelected ? .black : .white.opacity(0.8))
                                        .cornerRadius(6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(isSelected ? theme.secondaryAccent : theme.cardBorder.opacity(0.5), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.vertical, 2)

                // Retro Color Palette Swatches
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("PALETTE")
                            .font(.system(size: 9.5, weight: .black, design: .monospaced))
                            .foregroundColor(theme.secondaryAccent)

                        Spacer()

                        // Color indicator
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(selectedColor))
                            .frame(width: 24, height: 16)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.white.opacity(0.6), lineWidth: 1))
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 5) {
                            ForEach(RetroPaletteColor.defaults) { item in
                                let isSelected = item.color.hexString == selectedColor.hexString
                                Button {
                                    selectedColor = item.color
                                } label: {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color(item.color))
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(isSelected ? Color.white : Color.black.opacity(0.4), lineWidth: isSelected ? 2.5 : 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }

        // The Pixel Canvas & Live 3D Model Card
        GameCard(title: "PIXEL CANVAS (\(selectedPart.description.uppercased()))", icon: "square.grid.3x3.fill", badge: "DRAG TO DRAW") {
            VStack(spacing: 12) {
                // Drawing Tools Row (Equal distribution, high hit target)
                HStack(spacing: 6) {
                    ForEach(PixelDrawingTool.allCases) { tool in
                        let isSelected = (skinTool == tool)
                        Button {
                            skinTool = tool
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: tool.iconName)
                                    .font(.system(size: 11, weight: .bold))
                                Text(tool.rawValue.uppercased())
                                    .font(.system(size: 9.5, weight: .black, design: .monospaced))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                            .background(isSelected ? theme.primaryAccent : theme.buttonBackground)
                            .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(isSelected ? Color.white.opacity(0.8) : theme.cardBorder.opacity(0.6), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Dedicated UNDO & REDO Toolbar (Large touchable buttons that always register)
                HStack(spacing: 8) {
                    Button {
                        undoSkinStroke()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                                .font(.system(size: 13, weight: .bold))
                            Text(skinUndoStack.isEmpty ? "UNDO" : "UNDO (\(skinUndoStack.count))")
                                .font(.system(size: 10.5, weight: .black, design: .monospaced))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(skinUndoStack.isEmpty ? theme.buttonBackground.opacity(0.5) : theme.primaryAccent.opacity(0.3))
                        .foregroundColor(skinUndoStack.isEmpty ? .white.opacity(0.35) : .white)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(skinUndoStack.isEmpty ? theme.cardBorder.opacity(0.3) : theme.primaryAccent.opacity(0.9), lineWidth: 1.2)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Button {
                        redoSkinStroke()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.uturn.forward.circle.fill")
                                .font(.system(size: 13, weight: .bold))
                            Text(skinRedoStack.isEmpty ? "REDO" : "REDO (\(skinRedoStack.count))")
                                .font(.system(size: 10.5, weight: .black, design: .monospaced))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(skinRedoStack.isEmpty ? theme.buttonBackground.opacity(0.5) : theme.secondaryAccent.opacity(0.3))
                        .foregroundColor(skinRedoStack.isEmpty ? .white.opacity(0.35) : .white)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(skinRedoStack.isEmpty ? theme.cardBorder.opacity(0.3) : theme.secondaryAccent.opacity(0.9), lineWidth: 1.2)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }

                let rect = selectedPart.uvRect

                // Interactive Pixel Grid Canvas
                PixelCanvasView(
                    gridWidth: rect.w,
                    gridHeight: rect.h,
                    pixelColor: { (x, y) in
                        let skinX = rect.x + x
                        let skinY = rect.y + y
                        guard skinX < 64 && skinY < 64 else { return .clear }
                        return skinPixels[skinY][skinX]
                    },
                    onPixelDraw: { (x, y) in
                        drawSkinPixel(partX: x, partY: y)
                    },
                    onStrokeStart: {
                        if skinTool != .eyedropper {
                            pushSkinUndo()
                        }
                    }
                )
                .frame(maxWidth: .infinity)
                .frame(height: 230)
                .background(Color.black.opacity(0.6))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(theme.cardBorder, lineWidth: 1.5))

                // 3D Model Inspector Bar & Action Buttons
                HStack(spacing: 8) {
                    Button {
                        updatePreviewCustomSkin()
                        show3DModelSheet = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "view.3d")
                                .font(.system(size: 13, weight: .bold))
                            Text("INSPECT 3D MODEL")
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(
                            LinearGradient(colors: [theme.primaryAccent, theme.secondaryAccent], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.4), lineWidth: 1))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    GameSmallButton(title: "Save Skin", icon: "square.and.arrow.down.fill", color: theme.secondaryAccent) {
                        saveCustomSkinAction()
                    }

                    GameSmallButton(title: "Equip Now", icon: "checkmark.seal.fill", color: theme.primaryAccent, isProminent: true) {
                        equipCustomSkinAction()
                    }
                }
            }
        }
    }

    // MARK: - Texture Maker Section

    @ViewBuilder
    private func textureMakerSection(theme: MenuTheme) -> some View {
        GameCard(title: "CHOOSE BLOCK & FACE TO MODIFY", icon: "cube.transparent") {
            VStack(spacing: 10) {
                // Block selector chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(BlockType.allCases) { block in
                            let isSelected = (selectedBlockType == block)
                            Button {
                                selectedBlockType = block
                                if !block.editableFaces.contains(selectedBlockFace) {
                                    selectedBlockFace = block.editableFaces.first ?? .side
                                }
                                loadBlockTexture(block, face: selectedBlockFace)
                            } label: {
                                HStack(spacing: 4) {
                                    Image(uiImage: block.iconImage)
                                        .interpolation(.none)
                                        .resizable()
                                        .frame(width: 14, height: 14)
                                        .cornerRadius(2)
                                    Text(block.fullName.uppercased())
                                        .font(.system(size: 9.5, weight: .black, design: .monospaced))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(isSelected ? theme.primaryAccent.opacity(0.85) : theme.buttonBackground)
                                .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(isSelected ? theme.primaryAccent : theme.cardBorder.opacity(0.5), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Face Switcher: Multi-side selector (e.g. Log Bark vs Rings, Grass Top vs Side vs Dirt)
                if selectedBlockType.editableFaces.count > 1 {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.split.diagonal.2x2")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(theme.secondaryAccent)
                            Text("SELECT FACE TO TEXTURE:")
                                .font(.system(size: 9.5, weight: .black, design: .monospaced))
                                .foregroundColor(theme.secondaryAccent)
                        }

                        HStack(spacing: 8) {
                            ForEach(selectedBlockType.editableFaces) { face in
                                let isFaceSelected = (selectedBlockFace == face)
                                Button {
                                    selectedBlockFace = face
                                    loadBlockTexture(selectedBlockType, face: face)
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: selectedBlockType.faceIconName(face))
                                            .font(.system(size: 11, weight: .bold))
                                        Text(selectedBlockType.faceDisplayName(face).uppercased())
                                            .font(.system(size: 10, weight: .black, design: .monospaced))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(isFaceSelected ? theme.secondaryAccent.opacity(0.9) : theme.buttonBackground)
                                    .foregroundColor(isFaceSelected ? .black : .white.opacity(0.85))
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(isFaceSelected ? theme.secondaryAccent : theme.cardBorder.opacity(0.6), lineWidth: 1.2)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }

                // Palette
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(RetroPaletteColor.defaults) { item in
                            let isSelected = item.color.hexString == selectedColor.hexString
                            Button {
                                selectedColor = item.color
                            } label: {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color(item.color))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(isSelected ? Color.white : Color.black.opacity(0.4), lineWidth: isSelected ? 2.5 : 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }

        // 16x16 Block Canvas Card
        let faceBadge = selectedBlockType.editableFaces.count > 1
            ? "\(selectedBlockType.fullName.uppercased()) • \(selectedBlockType.faceDisplayName(selectedBlockFace).uppercased())"
            : selectedBlockType.fullName.uppercased()

        GameCard(title: "16x16 BLOCK PIXEL CANVAS", icon: "square.grid.3x3.fill", badge: faceBadge) {
            VStack(spacing: 12) {
                // Drawing Tools Row (Equal distribution, high hit target)
                HStack(spacing: 6) {
                    ForEach(PixelDrawingTool.allCases) { tool in
                        let isSelected = (blockTool == tool)
                        Button {
                            blockTool = tool
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: tool.iconName)
                                    .font(.system(size: 11, weight: .bold))
                                Text(tool.rawValue.uppercased())
                                    .font(.system(size: 9.5, weight: .black, design: .monospaced))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                            .background(isSelected ? theme.primaryAccent : theme.buttonBackground)
                            .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(isSelected ? Color.white.opacity(0.8) : theme.cardBorder.opacity(0.6), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Dedicated UNDO & REDO Toolbar (Large touchable buttons that always register)
                HStack(spacing: 8) {
                    Button {
                        undoBlockStroke()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                                .font(.system(size: 13, weight: .bold))
                            Text(blockUndoStack.isEmpty ? "UNDO" : "UNDO (\(blockUndoStack.count))")
                                .font(.system(size: 10.5, weight: .black, design: .monospaced))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(blockUndoStack.isEmpty ? theme.buttonBackground.opacity(0.5) : theme.primaryAccent.opacity(0.3))
                        .foregroundColor(blockUndoStack.isEmpty ? .white.opacity(0.35) : .white)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(blockUndoStack.isEmpty ? theme.cardBorder.opacity(0.3) : theme.primaryAccent.opacity(0.9), lineWidth: 1.2)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Button {
                        redoBlockStroke()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.uturn.forward.circle.fill")
                                .font(.system(size: 13, weight: .bold))
                            Text(blockRedoStack.isEmpty ? "REDO" : "REDO (\(blockRedoStack.count))")
                                .font(.system(size: 10.5, weight: .black, design: .monospaced))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(blockRedoStack.isEmpty ? theme.buttonBackground.opacity(0.5) : theme.secondaryAccent.opacity(0.3))
                        .foregroundColor(blockRedoStack.isEmpty ? .white.opacity(0.35) : .white)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(blockRedoStack.isEmpty ? theme.cardBorder.opacity(0.3) : theme.secondaryAccent.opacity(0.9), lineWidth: 1.2)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }

                PixelCanvasView(
                    gridWidth: 16,
                    gridHeight: 16,
                    pixelColor: { (x, y) in
                        guard x < 16 && y < 16 else { return .gray }
                        return blockPixels[y][x]
                    },
                    onPixelDraw: { (x, y) in
                        drawBlockPixel(x: x, y: y)
                    },
                    onStrokeStart: {
                        if blockTool != .eyedropper {
                            pushBlockUndo()
                        }
                    }
                )
                .frame(maxWidth: .infinity)
                .frame(height: 230)
                .background(Color.black.opacity(0.6))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(theme.cardBorder, lineWidth: 1.5))

                HStack(spacing: 8) {
                    Button {
                        showBlock3DModelSheet = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "cube.fill")
                                .font(.system(size: 13, weight: .bold))
                            Text("INSPECT 3D BLOCK")
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(
                            LinearGradient(colors: [theme.primaryAccent, theme.secondaryAccent], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.4), lineWidth: 1))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    GameSmallButton(title: "Save & Apply Texture", icon: "checkmark.circle.fill", color: theme.primaryAccent, isProminent: true) {
                        applyBlockTextureAction()
                    }
                }
            }
        }
    }

    // MARK: - Full 3D Model Inspector Sheet

    @ViewBuilder
    private func full3DModelInspectorSheet(theme: MenuTheme) -> some View {
        GameMenuContainer(
            title: "3D CHARACTER MODEL INSPECTOR",
            subtitle: "Drag to Rotate 360° • Live Textured Skin",
            icon: "view.3d",
            onDismiss: { show3DModelSheet = false }
        ) {
            GameCard(title: customSkinName.uppercased(), icon: "person.fill", badge: "3D ROTATING MODEL") {
                VStack(spacing: 14) {
                    if let skin = previewCustomSkin {
                        Character3DModelPreviewView(customSkin: skin)
                            .frame(maxWidth: .infinity)
                            .frame(height: 320)
                            .background(Color.black.opacity(0.75))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.cardBorder, lineWidth: 1.5))
                    } else {
                        Color.black.frame(height: 320).cornerRadius(12)
                    }

                    Text("Touch and drag horizontally to spin the 3D character 360 degrees. Verify your painted head, torso, arms and legs!")
                        .font(.system(size: 10.5, design: .monospaced))
                        .foregroundColor(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)

                    HStack(spacing: 12) {
                        GameButton(title: "Equip This Skin", subtitle: "Wear in singleplayer & multiplayer", icon: "checkmark.seal.fill", color: theme.primaryAccent, isProminent: true) {
                            equipCustomSkinAction()
                            show3DModelSheet = false
                        }

                        GameButton(title: "Save to Skins", subtitle: "Add to your skin library", icon: "square.and.arrow.down.fill", color: theme.secondaryAccent) {
                            saveCustomSkinAction()
                            show3DModelSheet = false
                        }
                    }
                }
            }
        }
    }

    // MARK: - Full 3D Block Model Inspector Sheet

    @ViewBuilder
    private func fullBlock3DModelInspectorSheet(theme: MenuTheme) -> some View {
        GameMenuContainer(
            title: "3D BLOCK INSPECTOR",
            subtitle: "Drag to Rotate 360° • Perfect Cube Proportions",
            icon: "view.3d",
            onDismiss: { showBlock3DModelSheet = false }
        ) {
            let faceInfo = selectedBlockType.editableFaces.count > 1 ? "\(selectedBlockType.editableFaces.count) CUSTOM SIDES" : "UNIFORM"
            GameCard(title: selectedBlockType.fullName.uppercased(), icon: "cube.fill", badge: faceInfo) {
                VStack(spacing: 14) {
                    Block3DModelPreviewView(
                        blockType: selectedBlockType,
                        currentPack: world.currentTexturePack,
                        activeEditingFace: selectedBlockFace,
                        activeFaceImage: exportPNGDataFromBlockPixels()
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 320)
                    .background(Color.black.opacity(0.75))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.cardBorder, lineWidth: 1.5))

                    Text("Drag horizontally and vertically to rotate the block. Proportions are a true 1:1:1 geometric cube showing all custom faces (sides, top, and bottom) accurately.")
                        .font(.system(size: 10.5, design: .monospaced))
                        .foregroundColor(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)

                    HStack(spacing: 12) {
                        GameButton(title: "Apply This Texture", subtitle: "Render in your voxel world", icon: "checkmark.seal.fill", color: theme.primaryAccent, isProminent: true) {
                            applyBlockTextureAction()
                            showBlock3DModelSheet = false
                        }
                    }
                }
            }
        }
    }

    // MARK: - Pixel Manipulation Helpers

    private func pushSkinUndo() {
        if skinUndoStack.count >= 50 {
            skinUndoStack.removeFirst()
        }
        skinUndoStack.append(SkinHistoryFrame(pixels: skinPixels, section: selectedBodySection, part: selectedPart))
        skinRedoStack.removeAll()
    }

    private func undoSkinStroke() {
        guard let prev = skinUndoStack.popLast() else {
            let impact = UINotificationFeedbackGenerator()
            impact.notificationOccurred(.warning)
            showToast("Nothing to undo")
            return
        }
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        skinRedoStack.append(SkinHistoryFrame(pixels: skinPixels, section: selectedBodySection, part: selectedPart))
        skinPixels = prev.pixels
        selectedBodySection = prev.section
        selectedPart = prev.part
        updatePreviewCustomSkin()
        showToast("Undid edit on \(prev.part.shortFaceName)")
    }

    private func redoSkinStroke() {
        guard let next = skinRedoStack.popLast() else {
            let impact = UINotificationFeedbackGenerator()
            impact.notificationOccurred(.warning)
            showToast("Nothing to redo")
            return
        }
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        skinUndoStack.append(SkinHistoryFrame(pixels: skinPixels, section: selectedBodySection, part: selectedPart))
        skinPixels = next.pixels
        selectedBodySection = next.section
        selectedPart = next.part
        updatePreviewCustomSkin()
        showToast("Redid edit on \(next.part.shortFaceName)")
    }

    private func drawSkinPixel(partX: Int, partY: Int) {
        let rect = selectedPart.uvRect
        let skinX = rect.x + partX
        let skinY = rect.y + partY
        guard skinX < 64 && skinY < 64 else { return }

        switch skinTool {
        case .pencil:
            skinPixels[skinY][skinX] = selectedColor
        case .eraser:
            skinPixels[skinY][skinX] = .clear
        case .bucket:
            floodFillSkin(partX: partX, partY: partY, fillColor: selectedColor)
        case .eyedropper:
            let picked = skinPixels[skinY][skinX]
            if picked != .clear {
                selectedColor = picked
                skinTool = .pencil
            }
        }
        updatePreviewCustomSkin()
    }

    private func floodFillSkin(partX: Int, partY: Int, fillColor: UIColor) {
        let rect = selectedPart.uvRect
        let targetX = rect.x + partX
        let targetY = rect.y + partY
        let targetColor = skinPixels[targetY][targetX]
        if targetColor.hexString == fillColor.hexString { return }

        var queue: [(Int, Int)] = [(partX, partY)]
        var visited: Set<String> = []

        while !queue.isEmpty {
            let (cx, cy) = queue.removeFirst()
            let key = "\(cx),\(cy)"
            if visited.contains(key) { continue }
            visited.insert(key)

            let sx = rect.x + cx
            let sy = rect.y + cy
            if cx < 0 || cx >= rect.w || cy < 0 || cy >= rect.h { continue }

            if skinPixels[sy][sx].hexString == targetColor.hexString {
                skinPixels[sy][sx] = fillColor
                queue.append((cx + 1, cy))
                queue.append((cx - 1, cy))
                queue.append((cx, cy + 1))
                queue.append((cx, cy - 1))
            }
        }
    }

    private func pushBlockUndo() {
        if blockUndoStack.count >= 50 {
            blockUndoStack.removeFirst()
        }
        blockUndoStack.append(BlockHistoryFrame(pixels: blockPixels, blockType: selectedBlockType, face: selectedBlockFace))
        blockRedoStack.removeAll()
    }

    private func undoBlockStroke() {
        guard let prev = blockUndoStack.popLast() else {
            let impact = UINotificationFeedbackGenerator()
            impact.notificationOccurred(.warning)
            showToast("Nothing to undo")
            return
        }
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        blockRedoStack.append(BlockHistoryFrame(pixels: blockPixels, blockType: selectedBlockType, face: selectedBlockFace))
        blockPixels = prev.pixels
        selectedBlockType = prev.blockType
        selectedBlockFace = prev.face
        showToast("Undid edit on \(prev.face.rawValue.capitalized)")
    }

    private func redoBlockStroke() {
        guard let next = blockRedoStack.popLast() else {
            let impact = UINotificationFeedbackGenerator()
            impact.notificationOccurred(.warning)
            showToast("Nothing to redo")
            return
        }
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        blockUndoStack.append(BlockHistoryFrame(pixels: blockPixels, blockType: selectedBlockType, face: selectedBlockFace))
        blockPixels = next.pixels
        selectedBlockType = next.blockType
        selectedBlockFace = next.face
        showToast("Redid edit on \(next.face.rawValue.capitalized)")
    }

    private func drawBlockPixel(x: Int, y: Int) {
        guard x < 16 && y < 16 else { return }
        switch blockTool {
        case .pencil:
            blockPixels[y][x] = selectedColor
        case .eraser:
            blockPixels[y][x] = .gray
        case .bucket:
            floodFillBlock(startX: x, startY: y, fillColor: selectedColor)
        case .eyedropper:
            selectedColor = blockPixels[y][x]
            blockTool = .pencil
        }
    }

    private func floodFillBlock(startX: Int, startY: Int, fillColor: UIColor) {
        let targetColor = blockPixels[startY][startX]
        if targetColor.hexString == fillColor.hexString { return }
        var queue = [(startX, startY)]
        var visited: Set<String> = []

        while !queue.isEmpty {
            let (cx, cy) = queue.removeFirst()
            let key = "\(cx),\(cy)"
            if visited.contains(key) { continue }
            visited.insert(key)
            if cx < 0 || cx >= 16 || cy < 0 || cy >= 16 { continue }

            if blockPixels[cy][cx].hexString == targetColor.hexString {
                blockPixels[cy][cx] = fillColor
                queue.append((cx + 1, cy))
                queue.append((cx - 1, cy))
                queue.append((cx, cy + 1))
                queue.append((cx, cy - 1))
            }
        }
    }

    // MARK: - Preset Loading & PNG Serialization

    private func loadSkinFromPreset(_ preset: PlayerSkin) {
        pushSkinUndo()
        let image = SkinTextureManager.shared.skinImage(for: preset)
        skinPixels = extractPixelsFromImage(image, width: 64, height: 64)
        activeSkinID = UUID()
        updatePreviewCustomSkin()
    }

    private func clearSkinToBlank() {
        pushSkinUndo()
        let baseColor = UIColor(red: 0.95, green: 0.80, blue: 0.68, alpha: 1.0)
        var newGrid = Array(repeating: Array(repeating: UIColor.clear, count: 64), count: 64)
        for part in SkinEditablePart.allCases {
            let r = part.uvRect
            for y in r.y..<(r.y + r.h) {
                for x in r.x..<(r.x + r.w) {
                    if part == .headFront || part == .headBack || part == .headRight || part == .headLeft {
                        newGrid[y][x] = baseColor
                    } else if part == .rightLegBottom || part == .leftLegBottom {
                        newGrid[y][x] = UIColor(red: 0.25, green: 0.25, blue: 0.28, alpha: 1.0)
                    } else {
                        newGrid[y][x] = UIColor.darkGray
                    }
                }
            }
        }
        skinPixels = newGrid
        activeSkinID = UUID()
        updatePreviewCustomSkin()
    }

    private func loadBlockTexture(_ block: BlockType, face: BlockFace = .side) {
        let image = BlockType.baseTextureImage(for: block, face: face, pack: .classic)
        blockPixels = extractPixelsFromImage(image, width: 16, height: 16)
    }

    private func exportPNGDataFromBlockPixels() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = (selectedBlockType != .water && selectedBlockType != .glass && selectedBlockType != .door)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 16, height: 16), format: format)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            cg.interpolationQuality = .none
            for y in 0..<16 {
                for x in 0..<16 {
                    let color = blockPixels[y][x]
                    if color != .clear {
                        color.setFill()
                        cg.fill(CGRect(x: x, y: y, width: 1, height: 1))
                    }
                }
            }
        }
    }

    private func applyBlockTextureAction() {
        let newImage = exportPNGDataFromBlockPixels()
        BlockType.setCustomTexture(for: selectedBlockType, face: selectedBlockFace, image: newImage)
        world.applyTexturePack()
        let faceName = selectedBlockType.editableFaces.count > 1 ? " (\(selectedBlockType.faceDisplayName(selectedBlockFace)))" : ""
        showToast("Texture for \(selectedBlockType.fullName)\(faceName) Saved & Applied!")
    }

    private func extractPixelsFromImage(_ image: UIImage, width: Int, height: Int) -> [[UIColor]] {
        guard let cg = image.cgImage else {
            return Array(repeating: Array(repeating: .white, count: width), count: height)
        }
        var pixels = Array(repeating: Array(repeating: UIColor.clear, count: width), count: height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var rawData = [UInt8](repeating: 0, count: width * height * 4)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else {
            return pixels
        }

        context.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))

        for y in 0..<height {
            for x in 0..<width {
                let byteIndex = (bytesPerRow * y) + x * bytesPerPixel
                let r = CGFloat(rawData[byteIndex]) / 255.0
                let g = CGFloat(rawData[byteIndex + 1]) / 255.0
                let b = CGFloat(rawData[byteIndex + 2]) / 255.0
                let a = CGFloat(rawData[byteIndex + 3]) / 255.0
                pixels[y][x] = UIColor(red: r, green: g, blue: b, alpha: a)
            }
        }
        return pixels
    }

    private func exportPNGDataFromSkinPixels() -> Data {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 64, height: 64), format: format)
        let image = renderer.image { ctx in
            for y in 0..<64 {
                for x in 0..<64 {
                    let color = skinPixels[y][x]
                    if color != .clear {
                        color.setFill()
                        ctx.fill(CGRect(x: x, y: y, width: 1, height: 1))
                    }
                }
            }
        }
        return image.pngData() ?? Data()
    }

    private func updatePreviewCustomSkin() {
        let pngData = exportPNGDataFromSkinPixels()
        let skin = CustomSkin(
            id: activeSkinID,
            name: customSkinName,
            promptDescription: "User Created Skin",
            roleSubtitle: "Pixel Artist Creation",
            headColorHex: skinPixels[8][8].hexString,
            torsoColorHex: skinPixels[20][20].hexString,
            legsColorHex: skinPixels[20][4].hexString,
            accentColorHex: selectedColor.hexString,
            eyeColorHex: "#00E0FF",
            hairColorHex: skinPixels[0][8].hexString,
            featureStyleRaw: "classic",
            pngData: pngData
        )
        SkinTextureManager.shared.clearCustomSkinCache(for: activeSkinID)
        previewCustomSkin = skin
    }

    private func saveCustomSkinAction() {
        updatePreviewCustomSkin()
        guard let skin = previewCustomSkin else { return }
        world.saveCustomSkin(skin)
        showToast("Saved skin '\(skin.name)'!")
    }

    private func equipCustomSkinAction() {
        updatePreviewCustomSkin()
        guard let skin = previewCustomSkin else { return }
        world.saveCustomSkin(skin)
        world.equipCustomSkin(skin)
        showToast("Equipped '\(skin.name)'!")
    }

    private func showToast(_ text: String) {
        withAnimation {
            statusToast = text
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if statusToast == text {
                withAnimation { statusToast = nil }
            }
        }
    }
}

// MARK: - Touch Pixel Canvas View (Finger Drag Drawing Grid)

struct PixelCanvasView: View {
    let gridWidth: Int
    let gridHeight: Int
    let pixelColor: (Int, Int) -> UIColor
    let onPixelDraw: (Int, Int) -> Void
    var onStrokeStart: (() -> Void)? = nil

    @State private var isDrawingStroke: Bool = false
    @State private var lastDrawnCoord: String? = nil

    var body: some View {
        GeometryReader { geo in
            let cellWidth = geo.size.width / CGFloat(gridWidth)
            let cellHeight = geo.size.height / CGFloat(gridHeight)

            ZStack {
                // Subtle checkerboard pattern for transparency indication
                Canvas { context, size in
                    let step: CGFloat = 8
                    let rows = Int(size.height / step) + 1
                    let cols = Int(size.width / step) + 1
                    for r in 0..<rows {
                        for c in 0..<cols {
                            if (r + c) % 2 == 0 {
                                context.fill(
                                    Path(CGRect(x: CGFloat(c) * step, y: CGFloat(r) * step, width: step, height: step)),
                                    with: .color(Color.white.opacity(0.04))
                                )
                            }
                        }
                    }
                }

                // Pixels render canvas
                Canvas { context, size in
                    for y in 0..<gridHeight {
                        for x in 0..<gridWidth {
                            let color = pixelColor(x, y)
                            let rect = CGRect(
                                x: CGFloat(x) * cellWidth,
                                y: CGFloat(y) * cellHeight,
                                width: cellWidth,
                                height: cellHeight
                            )
                            if color != .clear {
                                context.fill(Path(rect), with: .color(Color(color)))
                            }

                            // Subtle grid border
                            context.stroke(
                                Path(rect),
                                with: .color(Color.white.opacity(0.12)),
                                lineWidth: 0.5
                            )
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let x = Int(value.location.x / cellWidth)
                        let y = Int(value.location.y / cellHeight)
                        guard x >= 0 && x < gridWidth && y >= 0 && y < gridHeight else { return }
                        if !isDrawingStroke {
                            isDrawingStroke = true
                            onStrokeStart?()
                        }
                        let key = "\(x),\(y)"
                        if lastDrawnCoord != key {
                            lastDrawnCoord = key
                            onPixelDraw(x, y)
                        }
                    }
                    .onEnded { _ in
                        isDrawingStroke = false
                        lastDrawnCoord = nil
                    }
            )
        }
    }
}

// MARK: - 3D Character Model Preview (SceneKit Interactive Scene)

struct Character3DModelPreviewView: UIViewRepresentable {
    let customSkin: CustomSkin

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        let scene = SCNScene()
        scnView.scene = scene
        scnView.backgroundColor = .clear
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = false

        // Camera positioned to frame entire character from head to feet
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.zNear = 0.1
        camera.zFar = 20.0
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0.90, 3.35)
        scene.rootNode.addChildNode(cameraNode)

        // Lighting: Ambient + Key Directional
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.color = UIColor(white: 0.70, alpha: 1.0)
        scene.rootNode.addChildNode(ambient)

        let keyLight = SCNNode()
        keyLight.light = SCNLight()
        keyLight.light?.type = .directional
        keyLight.light?.color = UIColor(white: 0.85, alpha: 1.0)
        keyLight.position = SCNVector3(1.5, 3.0, 3.0)
        keyLight.eulerAngles = SCNVector3(-0.5, 0.4, 0)
        scene.rootNode.addChildNode(keyLight)

        // Character Root Node
        let charRoot = SCNNode()
        charRoot.name = "charRoot"
        scene.rootNode.addChildNode(charRoot)

        // Attach pan gesture for interactive 360-degree rotation
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        scnView.addGestureRecognizer(panGesture)
        context.coordinator.charRoot = charRoot

        updateCharacterNode(in: charRoot)
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        if let charRoot = uiView.scene?.rootNode.childNode(withName: "charRoot", recursively: false) {
            context.coordinator.charRoot = charRoot
            updateCharacterNode(in: charRoot)
        }
    }

    private func updateCharacterNode(in parent: SCNNode) {
        parent.enumerateChildNodes { node, _ in
            node.removeFromParentNode()
        }
        let avatar = VoxelWorld.makeBlockyPlayerAvatarNode(
            name: customSkin.name,
            skin: .steve,
            customSkin: customSkin
        )
        // Adjust model origin so center of body is at (0, 0, 0)
        avatar.position = SCNVector3(0, 0, 0)
        parent.addChildNode(avatar)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject {
        weak var charRoot: SCNNode?
        private var currentAngleY: Float = 0.0

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let node = charRoot else { return }
            let translation = gesture.translation(in: gesture.view)
            let deltaY = Float(translation.x) * 0.015
            node.eulerAngles.y = currentAngleY + deltaY

            if gesture.state == .ended || gesture.state == .cancelled {
                currentAngleY = node.eulerAngles.y
            }
        }
    }
}

// MARK: - 3D Block Model Preview (SceneKit Interactive Block Scene)

struct Block3DModelPreviewView: UIViewRepresentable {
    let blockType: BlockType
    let currentPack: TexturePack
    let activeEditingFace: BlockFace
    let activeFaceImage: UIImage

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        let scene = SCNScene()
        scnView.scene = scene
        scnView.backgroundColor = .clear
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = false

        // Camera positioned at isometric vantage point
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.zNear = 0.1
        camera.zFar = 20.0
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 2.8)
        scene.rootNode.addChildNode(cameraNode)

        // Lighting
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.color = UIColor(white: 0.65, alpha: 1.0)
        scene.rootNode.addChildNode(ambient)

        let keyLight = SCNNode()
        keyLight.light = SCNLight()
        keyLight.light?.type = .directional
        keyLight.light?.color = UIColor(white: 0.85, alpha: 1.0)
        keyLight.position = SCNVector3(2.0, 3.5, 2.5)
        keyLight.eulerAngles = SCNVector3(-0.6, 0.45, 0)
        scene.rootNode.addChildNode(keyLight)

        // Block Container Node
        let blockRoot = SCNNode()
        blockRoot.name = "blockRoot"
        // Initial angled view showcasing both side and top faces
        blockRoot.eulerAngles = SCNVector3(0.42, 0.65, 0)
        scene.rootNode.addChildNode(blockRoot)

        // Interactive Pan Gesture (both Yaw and Pitch for inspecting all 6 faces)
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(BlockCoordinator.handlePan(_:)))
        scnView.addGestureRecognizer(panGesture)
        context.coordinator.blockRoot = blockRoot

        updateBlockNode(in: blockRoot)
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        if let blockRoot = uiView.scene?.rootNode.childNode(withName: "blockRoot", recursively: false) {
            context.coordinator.blockRoot = blockRoot
            updateBlockNode(in: blockRoot)
        }
    }

    private func updateBlockNode(in parent: SCNNode) {
        parent.enumerateChildNodes { node, _ in
            node.removeFromParentNode()
        }

        // True geometric cube (1.0 x 1.0 x 1.0) ensuring exact proportional block shape
        let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)

        // Generate accurate materials for all 6 faces
        let sideImage: UIImage = (activeEditingFace == .side)
            ? activeFaceImage
            : BlockType.textureImage(for: blockType, face: .side, pack: currentPack)

        let topImage: UIImage = (activeEditingFace == .top)
            ? activeFaceImage
            : BlockType.textureImage(for: blockType, face: .top, pack: currentPack)

        let botImage: UIImage = (activeEditingFace == .bottom)
            ? activeFaceImage
            : BlockType.textureImage(for: blockType, face: .bottom, pack: currentPack)

        let sideMat = makeMaterial(image: sideImage)
        let topMat = makeMaterial(image: topImage)
        let botMat = makeMaterial(image: botImage)

        // SCNBox materials: [Front(+Z), Right(+X), Back(-Z), Left(-X), Top(+Y), Bottom(-Y)]
        if blockType == .woodLog {
            box.materials = [sideMat, sideMat, sideMat, sideMat, topMat, topMat]
        } else if blockType == .grass {
            box.materials = [sideMat, sideMat, sideMat, sideMat, topMat, botMat]
        } else {
            box.materials = [sideMat, sideMat, sideMat, sideMat, topMat, botMat]
        }

        let cubeNode = SCNNode(geometry: box)
        parent.addChildNode(cubeNode)
    }

    private func makeMaterial(image: UIImage) -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = image
        mat.diffuse.magnificationFilter = .nearest
        mat.diffuse.minificationFilter = .nearest
        mat.diffuse.mipFilter = .none
        mat.lightingModel = .lambert
        return mat
    }

    func makeCoordinator() -> BlockCoordinator {
        BlockCoordinator()
    }

    final class BlockCoordinator: NSObject {
        weak var blockRoot: SCNNode?
        private var currentAngleX: Float = 0.42
        private var currentAngleY: Float = 0.65

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let node = blockRoot else { return }
            let translation = gesture.translation(in: gesture.view)
            let deltaY = Float(translation.x) * 0.015
            let deltaX = Float(translation.y) * 0.015
            node.eulerAngles.y = currentAngleY + deltaY
            node.eulerAngles.x = max(-Float.pi / 2.2, min(Float.pi / 2.2, currentAngleX + deltaX))

            if gesture.state == .ended || gesture.state == .cancelled {
                currentAngleX = node.eulerAngles.x
                currentAngleY = node.eulerAngles.y
            }
        }
    }
}
