import SwiftUI
import SceneKit
import UIKit

struct ContentView: View {
    @StateObject private var world = VoxelWorld()
    @State private var joystickOffset: CGSize = .zero
    @State private var showingWorldsSheet = false
    @State private var showingMultiplayerSheet = false
    @State private var showingSettingsSheet = false
    @State private var showingSkinsSheet = false

    // Temporary drag states while dragging HUD elements in Edit Controls mode
    @State private var dragJoyDelta: CGSize = .zero
    @State private var dragHotbarDelta: CGSize = .zero
    @State private var dragActionDelta: CGSize = .zero
    @State private var dragVerticalDelta: CGSize = .zero
    @State private var dragDoorDelta: CGSize = .zero

    var body: some View {
        ZStack {
            if !world.isInGame {
                MainMenuView(
                    world: world,
                    showingWorldsSheet: $showingWorldsSheet,
                    showingSkinsSheet: $showingSkinsSheet,
                    showingMultiplayerSheet: $showingMultiplayerSheet,
                    showingSettingsSheet: $showingSettingsSheet
                )
            } else {
                inGameWorldView
            }

            // Top interactive pop-up banner when nearby signal is detected or invitation received
            if let prompt = world.activeJoinPrompt {
                multiplayerJoinBanner(prompt)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(999)
            }
        }
        .ignoresSafeArea()
        .defersSystemGestures(on: .all)
        .onAppear {
            lockOrientationHorizontal()
        }
        .alert(
            world.activeJoinPrompt?.isDirectInvitation == true ? "Multiplayer Invitation" : "Nearby World Detected",
            isPresented: Binding(
                get: { world.activeJoinPrompt != nil },
                set: { if !$0 { world.declineActiveJoinPrompt() } }
            ),
            presenting: world.activeJoinPrompt
        ) { prompt in
            Button("Join World") {
                dismissAllSheets()
                world.acceptActiveJoinPrompt(prompt)
            }
            Button("Decline", role: .cancel) {
                world.declineActiveJoinPrompt()
            }
        } message: { prompt in
            if prompt.isDirectInvitation {
                Text("\(prompt.playerName) invited you to join '\(prompt.worldName)'. Would you like to join?")
            } else {
                Text("\(prompt.playerName) is hosting '\(prompt.worldName)' on the same Wi-Fi. Would you like to join?")
            }
        }
        .sheet(isPresented: $showingWorldsSheet) {
            SavedWorldsSheet(world: world)
        }
        .sheet(isPresented: $showingMultiplayerSheet) {
            LocalMultiplayerSheet(world: world)
        }
        .sheet(isPresented: $showingSettingsSheet) {
            InGameSettingsSheet(
                world: world,
                showingSkinsSheet: $showingSkinsSheet,
                showingWorldsSheet: $showingWorldsSheet
            )
        }
        .sheet(isPresented: $showingSkinsSheet) {
            CharacterSkinsSheet(world: world)
        }
        .onChange(of: showingSettingsSheet) { _ in
            world.resetInputState()
            joystickOffset = .zero
        }
        .onChange(of: showingSkinsSheet) { _ in
            world.resetInputState()
            joystickOffset = .zero
        }
        .onChange(of: showingWorldsSheet) { _ in
            world.resetInputState()
            joystickOffset = .zero
        }
        .onChange(of: showingMultiplayerSheet) { _ in
            world.resetInputState()
            joystickOffset = .zero
        }
    }

    private func dismissAllSheets() {
        showingWorldsSheet = false
        showingMultiplayerSheet = false
        showingSettingsSheet = false
        showingSkinsSheet = false
    }

    private func multiplayerJoinBanner(_ prompt: MultiplayerJoinPrompt) -> some View {
        VStack {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.25))
                        .frame(width: 36, height: 36)
                    Image(systemName: "person.2.wave.2.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16, weight: .bold))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(prompt.isDirectInvitation ? "MULTIPLAYER INVITATION" : "NEARBY WORLD SIGNAL")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                    Text("\(prompt.playerName) wants to play '\(prompt.worldName)'!")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                Spacer()

                Button {
                    dismissAllSheets()
                    world.acceptActiveJoinPrompt(prompt)
                } label: {
                    Text("Join World")
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.green)
                        .cornerRadius(8)
                }

                Button {
                    world.declineActiveJoinPrompt()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.65))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.black.opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.green.opacity(0.75), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.7), radius: 10, y: 5)
            )
            .padding(.horizontal, 24)
            .padding(.top, 10)

            Spacer()
        }
    }

    private var inGameWorldView: some View {
        ZStack {
            // 1. 3D Voxel World View + Look Drag Gesture
            VoxelSceneView(world: world)
                .ignoresSafeArea()

            // 2. True Center Crosshair (Dead-center on full screen, locked to camera line-of-sight)
            ZStack {
                // Fixed Crosshair Reticle
                ZStack {
                    Circle()
                        .stroke(Color.black.opacity(0.85), lineWidth: 1.5)
                        .frame(width: 8, height: 8)
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 18, height: 2)
                        .shadow(color: .black.opacity(0.9), radius: 1)
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 2, height: 18)
                        .shadow(color: .black.opacity(0.9), radius: 1)
                }

                // Targeted block label positioned below crosshair with offset so crosshair never shifts
                if let target = world.targetedBlockType {
                    HStack(spacing: 4) {
                        Text(target.fullName)
                        if target == .water {
                            Text("(BREAK TO SCOOP)")
                                .foregroundColor(.cyan)
                        } else if target.isToggleable {
                            Text(world.isTargetedBlockOpen ? "(OPEN)" : "(CLOSED)")
                                .foregroundColor(.yellow)
                        }
                    }
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.68))
                    .cornerRadius(6)
                    .offset(y: 30)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // 3. Horizontal (Landscape) HUD Overlay
            VStack {
                // Sleek Single-Row Landscape Top Bar
                HStack(spacing: 6) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("BLOCKBUILD")
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                                .foregroundColor(.green)
                            Text("• \(world.currentWorldName)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text("(\(world.playerCoordText))")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.cyan)
                            Text("\(world.currentFPS) FPS")
                                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                                .foregroundColor(world.currentFPS >= 50 ? .green : (world.currentFPS >= 30 ? .yellow : .red))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(Color.black.opacity(0.55))
                                .cornerRadius(4)
                        }
                        Text(world.statusToast)
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.yellow)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.62))
                    .cornerRadius(8)

                    Spacer()

                    // 1. Flying Mode
                    Button {
                        world.isFlying.toggle()
                        world.statusToast = world.isFlying ? "Mode: Creative Fly" : "Mode: Walk & Jump"
                    } label: {
                        Label(world.isFlying ? "Fly" : "Walk", systemImage: world.isFlying ? "airplane" : "figure.walk")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 7)
                            .background(world.isFlying ? Color.blue.opacity(0.82) : Color.gray.opacity(0.82))
                            .cornerRadius(8)
                    }

                    // 2. Multiplayer
                    Button {
                        showingMultiplayerSheet = true
                    } label: {
                        Label(
                            world.connectedPlayerNames.isEmpty ? "Multiplayer" : "Co-Op (\(world.connectedPlayerNames.count + 1))",
                            systemImage: "person.2.wave.2.fill"
                        )
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 7)
                        .background(world.connectedPlayerNames.isEmpty ? Color.pink.opacity(0.85) : Color.green.opacity(0.88))
                        .cornerRadius(8)
                    }

                    // 3. Music
                    Button {
                        world.toggleMusic()
                    } label: {
                        Label(world.isMusicEnabled ? "Music" : "Mute", systemImage: world.isMusicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 7)
                            .background(world.isMusicEnabled ? Color.teal.opacity(0.85) : Color.gray.opacity(0.75))
                            .cornerRadius(8)
                    }

                    // 4. Settings (hidden while customizing HUD controls)
                    if !world.isEditingControls {
                        Button {
                            showingSettingsSheet = true
                        } label: {
                            Label("Settings", systemImage: "gearshape.fill")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 7)
                                .background(Color.indigo.opacity(0.85))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 6)

                // Interactive HUD Control Layout Customizer Panel
                if world.isEditingControls {
                    ControlLayoutEditorBanner(world: world)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer()

                // Bottom Landscape Row: Customizable Controls (Supports Left/Right Swap, Dragging & Scaling)
                HStack(alignment: .bottom, spacing: 10) {
                    if world.controlLayout.swapLeftRight {
                        rightActionCluster
                        Spacer()
                        centerHotbarCluster
                        Spacer()
                        leftJoystickCluster
                    } else {
                        leftJoystickCluster
                        Spacer()
                        centerHotbarCluster
                        Spacer()
                        rightActionCluster
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 10)
            }
        }
    }

    // MARK: - Modular Customizable HUD Clusters

    private var leftJoystickCluster: some View {
        ZStack {
            Circle()
                .stroke(world.isEditingControls ? Color.cyan : Color.white.opacity(0.45), lineWidth: world.isEditingControls ? 3.5 : 3)
                .background(Circle().fill(Color.black.opacity(0.35)))
                .frame(width: 108, height: 108)

            Circle()
                .fill(Color.white.opacity(0.85))
                .frame(width: 42, height: 42)
                .offset(joystickOffset)

            if world.isEditingControls {
                Text("DRAG\nSTICK")
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.cyan)
            }

            if !world.isEditingControls {
                JoystickTouchOverlay(maxRadius: 38.0) { move, offset in
                    joystickOffset = offset
                    world.moveInput = move
                } onEnd: {
                    withAnimation(.spring(response: 0.2)) {
                        joystickOffset = .zero
                    }
                    world.resetInputState()
                }
                .frame(width: 108, height: 108)
            }
        }
        .scaleEffect(world.controlLayout.joystickScale)
        .opacity(world.controlLayout.controlOpacity)
        .offset(
            x: world.controlLayout.joystickOffsetX + dragJoyDelta.width,
            y: world.controlLayout.joystickOffsetY + dragJoyDelta.height
        )
        .gesture(
            world.isEditingControls ?
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    dragJoyDelta = value.translation
                }
                .onEnded { value in
                    world.controlLayout.joystickOffsetX += value.translation.width
                    world.controlLayout.joystickOffsetY += value.translation.height
                    dragJoyDelta = .zero
                }
            : nil
        )
    }

    private var centerHotbarCluster: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(BlockType.allCases) { block in
                    let isSelected = (world.selectedBlock == block)
                    let count = world.inventory[block] ?? 0

                    Button {
                        if !world.isEditingControls {
                            world.selectedBlock = block
                        }
                    } label: {
                        VStack(spacing: 2) {
                            ZStack(alignment: .bottomTrailing) {
                                Image(uiImage: block.iconImage)
                                    .interpolation(.none)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(3)

                                Text("\(count)")
                                    .font(.system(size: 10, weight: .black, design: .monospaced))
                                    .foregroundColor(count > 0 ? .white : .red)
                                    .shadow(color: .black, radius: 1, x: 1, y: 1)
                                    .offset(x: 3, y: 3)
                            }

                            Text(block.displayName)
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(isSelected ? .yellow : .white.opacity(0.85))
                                .lineLimit(1)
                        }
                        .frame(width: 50, height: 50)
                        .background(isSelected ? Color.white.opacity(0.30) : Color.black.opacity(0.65))
                        .cornerRadius(7)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(isSelected ? Color.yellow : Color.white.opacity(0.35), lineWidth: isSelected ? 2.2 : 1.0)
                        )
                    }
                    .disabled(world.isEditingControls)
                }
            }
            .padding(6)
        }
        .frame(maxWidth: 460)
        .background(Color.black.opacity(0.78))
        .cornerRadius(11)
        .overlay(
            RoundedRectangle(cornerRadius: 11)
                .stroke(world.isEditingControls ? Color.cyan : Color.clear, lineWidth: 2.5)
        )
        .scaleEffect(world.controlLayout.hotbarScale)
        .opacity(world.controlLayout.controlOpacity)
        .offset(
            x: world.controlLayout.hotbarOffsetX + dragHotbarDelta.width,
            y: world.controlLayout.hotbarOffsetY + dragHotbarDelta.height
        )
        .simultaneousGesture(
            world.isEditingControls ?
            DragGesture()
                .onChanged { val in
                    dragHotbarDelta = val.translation
                }
                .onEnded { val in
                    world.controlLayout.hotbarOffsetX += val.translation.width
                    world.controlLayout.hotbarOffsetY += val.translation.height
                    dragHotbarDelta = .zero
                }
            : nil
        )
    }

    private var doorActionButton: some View {
        Button {
            if !world.isEditingControls {
                world.toggleTargetedDoorOrTrapdoor()
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: world.isTargetedBlockOpen ? "door.left.hand.closed" : "door.left.hand.open")
                    .font(.system(size: 13, weight: .bold))
                Text(world.isEditingControls ? "DRAG DOOR BTN" : (world.isTargetedBlockOpen ? "CLOSE DOOR" : "OPEN DOOR"))
                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
            }
            .foregroundColor(.black)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(world.isEditingControls ? Color.cyan : Color.yellow)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(world.isEditingControls ? Color.white : Color.clear, lineWidth: 2)
            )
        }
        .scaleEffect(world.controlLayout.actionScale)
        .opacity(world.controlLayout.controlOpacity)
        .offset(
            x: world.controlLayout.doorButtonOffsetX + dragDoorDelta.width,
            y: world.controlLayout.doorButtonOffsetY + dragDoorDelta.height
        )
        .gesture(
            world.isEditingControls ?
            DragGesture()
                .onChanged { val in
                    dragDoorDelta = val.translation
                }
                .onEnded { val in
                    world.controlLayout.doorButtonOffsetX += val.translation.width
                    world.controlLayout.doorButtonOffsetY += val.translation.height
                    dragDoorDelta = .zero
                }
            : nil
        )
    }

    private var rightActionCluster: some View {
        ZStack(alignment: world.controlLayout.swapLeftRight ? .bottomLeading : .bottomTrailing) {
            // Contextual OPEN/CLOSE button (independently movable, higher by default so it never interferes with controls)
            if (world.targetedBlockType?.isToggleable == true && !world.isEditingControls) || world.isEditingControls {
                doorActionButton
            }

            VStack(alignment: world.controlLayout.swapLeftRight ? .leading : .trailing, spacing: 9) {

            // UP / DOWN Buttons (independently draggable in Edit Controls mode)
            HStack(spacing: 8) {
                HoldButton(
                    label: "UP",
                    systemImage: "arrow.up",
                    color: .white.opacity(0.28),
                    isEditing: world.isEditingControls
                ) { pressed in
                    if pressed {
                        world.setVerticalInput(1.0)
                    } else if world.verticalInput > 0 {
                        world.setVerticalInput(0.0)
                    }
                }

                HoldButton(
                    label: "DOWN",
                    systemImage: "arrow.down",
                    color: .white.opacity(0.28),
                    isEditing: world.isEditingControls
                ) { pressed in
                    if pressed {
                        world.setVerticalInput(-1.0)
                    } else if world.verticalInput < 0 {
                        world.setVerticalInput(0.0)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(world.isEditingControls ? Color.cyan : Color.clear, lineWidth: 2)
            )
            .scaleEffect(world.controlLayout.actionScale)
            .opacity(world.controlLayout.controlOpacity)
            .offset(
                x: world.controlLayout.verticalOffsetX + dragVerticalDelta.width,
                y: world.controlLayout.verticalOffsetY + dragVerticalDelta.height
            )
            .gesture(
                world.isEditingControls ?
                DragGesture()
                    .onChanged { val in
                        dragVerticalDelta = val.translation
                    }
                    .onEnded { val in
                        world.controlLayout.verticalOffsetX += val.translation.width
                        world.controlLayout.verticalOffsetY += val.translation.height
                        dragVerticalDelta = .zero
                    }
                : nil
            )

            // BREAK & PLACE Buttons (independently draggable in Edit Controls mode)
            HStack(spacing: 10) {
                Button {
                    if !world.isEditingControls {
                        world.breakTargetedBlock()
                    }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: "hammer.fill")
                            .font(.system(size: 17, weight: .bold))
                        Text("BREAK")
                            .font(.system(size: 10, weight: .heavy, design: .monospaced))
                    }
                    .foregroundColor(.white)
                    .frame(width: 64, height: 54)
                    .background(Color.red.opacity(0.82))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(world.isEditingControls ? Color.cyan : Color.white.opacity(0.6), lineWidth: 2)
                    )
                }

                Button {
                    if !world.isEditingControls {
                        world.placeSelectedBlock()
                    }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: "cube.fill")
                            .font(.system(size: 17, weight: .bold))
                        Text("PLACE")
                            .font(.system(size: 10, weight: .heavy, design: .monospaced))
                    }
                    .foregroundColor(.white)
                    .frame(width: 64, height: 54)
                    .background(Color.blue.opacity(0.82))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(world.isEditingControls ? Color.cyan : Color.white.opacity(0.6), lineWidth: 2)
                    )
                }
            }
            .scaleEffect(world.controlLayout.actionScale)
            .opacity(world.controlLayout.controlOpacity)
            .offset(
                x: world.controlLayout.actionOffsetX + dragActionDelta.width,
                y: world.controlLayout.actionOffsetY + dragActionDelta.height
            )
            .simultaneousGesture(
                world.isEditingControls ?
                DragGesture()
                    .onChanged { val in
                        dragActionDelta = val.translation
                    }
                    .onEnded { val in
                        world.controlLayout.actionOffsetX += val.translation.width
                        world.controlLayout.actionOffsetY += val.translation.height
                        dragActionDelta = .zero
                    }
                : nil
            )
        }
        }
    }

    private func lockOrientationHorizontal() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
        }
    }
}

// MARK: - Interactive Control Layout Editor Banner

struct ControlLayoutEditorBanner: View {
    @ObservedObject var world: VoxelWorld

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: "hand.draw.fill")
                    .foregroundColor(.cyan)
                Text("CUSTOMIZE CONTROLS: Drag any control on screen to move it!")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                Spacer()

                Button {
                    world.controlLayout.swapLeftRight.toggle()
                } label: {
                    Label(world.controlLayout.swapLeftRight ? "Lefty: ON" : "Swap L/R", systemImage: "arrow.left.arrow.right")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }

                Button {
                    world.resetControlLayout()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }

                Button {
                    withAnimation {
                        world.finishEditingControls()
                    }
                } label: {
                    Label("SAVE & PLAY", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                        .shadow(color: .green.opacity(0.8), radius: 3)
                }
            }

            HStack(spacing: 14) {
                HStack(spacing: 4) {
                    Text("Stick")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                    Slider(value: $world.controlLayout.joystickScale, in: 0.70...1.45)
                        .frame(width: 85)
                }

                HStack(spacing: 4) {
                    Text("Buttons")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                    Slider(value: $world.controlLayout.actionScale, in: 0.70...1.45)
                        .frame(width: 85)
                }

                HStack(spacing: 4) {
                    Text("Hotbar")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                    Slider(value: $world.controlLayout.hotbarScale, in: 0.75...1.30)
                        .frame(width: 85)
                }

                HStack(spacing: 4) {
                    Text("Opacity")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                    Slider(value: $world.controlLayout.controlOpacity, in: 0.35...1.0)
                        .frame(width: 80)
                }

                HStack(spacing: 4) {
                    Text("Look")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                    Slider(value: $world.controlLayout.lookSensitivity, in: 0.45...2.2)
                        .frame(width: 80)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.82))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.cyan.opacity(0.8), lineWidth: 1.5)
        )
    }
}

// MARK: - Local Multiplayer Sheet (Host & Join Nearby Worlds)

struct LocalMultiplayerSheet: View {
    @ObservedObject var world: VoxelWorld
    @Environment(\.dismiss) private var dismiss
    @State private var playerNameInput: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Signal Status (Local Network)") {
                    Toggle(isOn: Binding(
                        get: { world.isMultiplayerEnabled },
                        set: { world.toggleMultiplayerEnabled($0) }
                    )) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(world.isMultiplayerEnabled ? Color.green : Color.gray)
                                    .frame(width: 10, height: 10)
                                Text("Multiplayer Mode")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                            }
                            Text(world.isMultiplayerEnabled ? "Broadcasts signal when in a world so nearby players can join" : "Multiplayer disabled")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }

                    if world.isMultiplayerEnabled {
                        if world.isInGame {
                            HStack(spacing: 8) {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .foregroundColor(.green)
                                Text("World Signal Broadcasting")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.green)
                                Spacer()
                                Text("IN WORLD")
                                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                                    .foregroundColor(.green)
                            }
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.yellow)
                                Text("Signal starts automatically when you enter a world.")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                }

                Section("Your Multiplayer Profile") {
                    HStack(spacing: 12) {
                        CharacterAvatarPreview(skin: world.selectedSkin, size: 30)
                        VStack(alignment: .leading, spacing: 2) {
                            TextField("Display Name", text: $playerNameInput)
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .onSubmit {
                                    world.updateLocalPlayerName(playerNameInput)
                                }
                            Text("Current World: \(world.currentWorldName)")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        if playerNameInput != world.localPlayerName && !playerNameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Button("Save") {
                                world.updateLocalPlayerName(playerNameInput)
                            }
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }
                    }
                }

                Section("Connected Players (\(world.connectedPlayerNames.count + 1))") {
                    HStack {
                        Image(systemName: "person.fill.checkmark")
                            .foregroundColor(.green)
                        Text("\(world.localPlayerName) (You)")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                        Spacer()
                        Text(world.isHostingMultiplayer ? "HOST" : "GUEST")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(world.isHostingMultiplayer ? .green : .cyan)
                    }

                    ForEach(world.connectedPlayerNames, id: \.self) { peerName in
                        HStack {
                            Image(systemName: "person.wave.2.fill")
                                .foregroundColor(.cyan)
                            Text(peerName)
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                            Spacer()
                            Text("IN WORLD")
                                .font(.system(size: 10, weight: .black, design: .monospaced))
                                .foregroundColor(.cyan)
                        }
                    }

                    if !world.connectedPlayerNames.isEmpty {
                        Button(role: .destructive) {
                            world.disconnectMultiplayer()
                        } label: {
                            Label("Disconnect from Session", systemImage: "xmark.circle.fill")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                        }
                    }
                }

                Section("Nearby BlockBuild Signals & Worlds (\(world.discoveredHosts.count))") {
                    if world.discoveredHosts.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 10) {
                                ProgressView()
                                Text("Listening for nearby BlockBuild signals...")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                            }
                            Text("When another device has BlockBuild open on the same Wi-Fi, their world will appear here and pop up on screen.")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 6)
                    } else {
                        ForEach(world.discoveredHosts) { host in
                            HStack(spacing: 12) {
                                CharacterAvatarPreview(skin: host.skin, size: 28)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(host.worldName)
                                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    HStack(spacing: 6) {
                                        Text("By \(host.playerName)")
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(.secondary)
                                        Text(host.isInGame ? "• IN GAME" : "• IN MENU")
                                            .font(.system(size: 9, weight: .heavy, design: .monospaced))
                                            .foregroundColor(host.isInGame ? .green : .blue)
                                    }
                                }
                                Spacer()
                                if host.isInGame {
                                    Button {
                                        world.joinDiscoveredHost(host)
                                        dismiss()
                                    } label: {
                                        Text("Join World")
                                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.green)
                                } else {
                                    Button {
                                        world.invitePeerToCurrentWorld(host.peerID)
                                    } label: {
                                        Text("Invite")
                                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.cyan)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Local Multiplayer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                playerNameInput = world.localPlayerName
                world.startMultiplayerServices()
            }
            .onChange(of: world.isInGame) { inGame in
                if inGame {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Saved Worlds & New World Manager Sheet

struct SavedWorldsSheet: View {
    @ObservedObject var world: VoxelWorld
    @Environment(\.dismiss) private var dismiss
    @State private var worldNameInput: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Current Active 500x500 World (Auto-Saved)") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(world.currentWorldName)
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                Text("\(world.currentArchetype.title) • Seed #\(world.worldSeed)")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button {
                                world.saveCurrentWorld(customName: worldNameInput)
                                dismiss()
                            } label: {
                                Label("Save Now", systemImage: "square.and.arrow.down.fill")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.purple)
                        }

                        TextField("Rename current world (optional)...", text: $worldNameInput)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 13, design: .monospaced))
                    }
                    .padding(.vertical, 4)
                }

                Section("Create New 500x500 World") {
                    Button {
                        world.regenerateNewWorld(customName: worldNameInput)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Generate New Random World")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(.primary)
                                Text("Your current world is automatically saved before generating a new world")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Saved Worlds (\(world.savedWorlds.count))") {
                    if world.savedWorlds.isEmpty {
                        Text("Worlds are automatically saved as you build!")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(world.savedWorlds) { saved in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Text(saved.name)
                                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                                        if saved.id == world.currentWorldID {
                                            Text("ACTIVE")
                                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                                .padding(.horizontal, 5)
                                                .padding(.vertical, 2)
                                                .background(Color.green.opacity(0.25))
                                                .foregroundColor(.green)
                                                .cornerRadius(4)
                                        }
                                    }
                                    Text("\(saved.archetypeName ?? "World") • Seed #\(saved.seed)")
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(.secondary)
                                    Text(saved.savedAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Button {
                                    world.saveCurrentWorld(silent: true)
                                    world.loadSavedWorld(saved)
                                    dismiss()
                                } label: {
                                    Text("Load")
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.blue)

                                Button(role: .destructive) {
                                    world.deleteSavedWorld(saved)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("BlockBuild Worlds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                worldNameInput = ""
            }
        }
    }
}

// MARK: - Retro Voxel Main Menu

struct MainMenuView: View {
    @ObservedObject var world: VoxelWorld
    @Binding var showingWorldsSheet: Bool
    @Binding var showingSkinsSheet: Bool
    @Binding var showingMultiplayerSheet: Bool
    @Binding var showingSettingsSheet: Bool

    var body: some View {
        ZStack {
            // Panoramic 3D Voxel World Scene in background
            VoxelSceneView(world: world)
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.48))

            // Main Menu Content
            VStack(spacing: 16) {
                Spacer()

                // Retro Title Banner
                VStack(spacing: 4) {
                    Text("BLOCKBUILD")
                        .font(.system(size: 40, weight: .black, design: .monospaced))
                        .foregroundColor(.green)
                        .shadow(color: .black, radius: 4, x: 2, y: 3)

                    Text("A RETRO VOXEL SANDBOX")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                        .tracking(3)
                        .shadow(color: .black, radius: 2)
                }

                // Equipped Skin Preview Pill
                Button {
                    showingSkinsSheet = true
                } label: {
                    HStack(spacing: 10) {
                        CharacterAvatarPreview(skin: world.selectedSkin, size: 28)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("SKIN: \(world.selectedSkin.displayName.uppercased())")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            Text("Tap to change skin")
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .foregroundColor(.cyan)
                        }
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color.black.opacity(0.65))
                    .cornerRadius(20)
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }

                Spacer()

                // Main Menu Action Grid
                VStack(spacing: 10) {
                    MainMenuButton(
                        title: "PLAY WORLDS",
                        subtitle: "Create, Load & Explore Worlds",
                        icon: "globe.americas.fill",
                        color: .green
                    ) {
                        showingWorldsSheet = true
                    }

                    MainMenuButton(
                        title: "MULTIPLAYER",
                        subtitle: world.connectedPlayerNames.isEmpty ? "Local Wi-Fi Co-Op" : "\(world.connectedPlayerNames.count) Connected",
                        icon: "person.2.wave.2.fill",
                        color: .pink
                    ) {
                        showingMultiplayerSheet = true
                    }

                    MainMenuButton(
                        title: "SETTINGS",
                        subtitle: "Controls, Sensitivity & Audio",
                        icon: "gearshape.fill",
                        color: .indigo
                    ) {
                        showingSettingsSheet = true
                    }
                }
                .frame(maxWidth: 440)

                Spacer()

                // Footer
                HStack(spacing: 12) {
                    Text("500x500 Worlds")
                    Text("•")
                    Text("Full Block Water")
                    Text("•")
                    Text("Skin Syncing")
                    Text("•")
                    Text("Local Co-Op")
                }
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 24)
        }
    }
}

struct MainMenuButton: View {
    let title: String
    let subtitle: String?
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(.white)

                    if let sub = subtitle {
                        Text(sub)
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.75))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [color.opacity(0.88), color.opacity(0.70)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
        }
    }
}

// MARK: - Character Avatar Preview & Skins Sheet

struct CharacterAvatarPreview: View {
    let skin: PlayerSkin
    var size: CGFloat = 36

    var body: some View {
        let avatarImage = SkinTextureManager.shared.frontAvatarImage(for: skin)
        Image(uiImage: avatarImage)
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(width: size * 0.65, height: size * 1.30)
            .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
    }
}

struct CharacterSkinsSheet: View {
    @ObservedObject var world: VoxelWorld
    @Environment(\.dismiss) private var dismiss

    let columns = [
        GridItem(.adaptive(minimum: 155), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header card
                    HStack(spacing: 14) {
                        CharacterAvatarPreview(skin: world.selectedSkin, size: 52)
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Current Skin: \(world.selectedSkin.displayName)")
                                .font(.system(size: 15, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            Text(world.selectedSkin.roleSubtitle)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.yellow)
                            Text("Other players see this skin in local multiplayer!")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.75))
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )

                    // Skins Grid
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(PlayerSkin.allCases) { skin in
                            let isEquipped = (world.selectedSkin == skin)
                            Button {
                                world.setSkin(skin)
                            } label: {
                                VStack(spacing: 10) {
                                    CharacterAvatarPreview(skin: skin, size: 46)
                                        .frame(height: 64)

                                    VStack(spacing: 2) {
                                        Text(skin.displayName)
                                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                                            .foregroundColor(.white)
                                        Text(skin.roleSubtitle)
                                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                            .foregroundColor(.cyan)
                                    }

                                    if isEquipped {
                                        HStack(spacing: 4) {
                                            Image(systemName: "checkmark.circle.fill")
                                            Text("EQUIPPED")
                                        }
                                        .font(.system(size: 9, weight: .black, design: .monospaced))
                                        .foregroundColor(.green)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.2))
                                        .cornerRadius(6)
                                    } else {
                                        Text("TAP TO EQUIP")
                                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.6))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(6)
                                    }
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(isEquipped ? Color.green.opacity(0.18) : Color.black.opacity(0.45))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isEquipped ? Color.green : Color.white.opacity(0.25), lineWidth: isEquipped ? 2 : 1)
                                )
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(red: 0.12, green: 0.13, blue: 0.16).ignoresSafeArea())
            .navigationTitle("Character Skins")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                }
            }
        }
    }
}

// MARK: - In-Game Settings Sheet

struct InGameSettingsSheet: View {
    @ObservedObject var world: VoxelWorld
    @Binding var showingSkinsSheet: Bool
    @Binding var showingWorldsSheet: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if world.isInGame {
                        Button {
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                    .foregroundColor(.green)
                                Text("Resume Game")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }

                        Button {
                            dismiss()
                            world.leaveToMainMenu()
                        } label: {
                            HStack {
                                Image(systemName: "house.fill")
                                    .foregroundColor(.red)
                                Text("Save & Leave to Menu")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                } header: {
                    Text("Game Session")
                }

                Section {
                    Button {
                        showingSkinsSheet = true
                    } label: {
                        HStack {
                            CharacterAvatarPreview(skin: world.selectedSkin, size: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Change Character Skin")
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                Text("Current: \(world.selectedSkin.displayName)")
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundColor(.cyan)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }

                    if world.isInGame {
                        Button {
                            dismiss()
                            withAnimation {
                                world.isEditingControls = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundColor(.yellow)
                                Text("Customize HUD Controls")
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }

                        Button {
                            world.creativeRefill()
                        } label: {
                            HStack {
                                Image(systemName: "plus.square.fill")
                                    .foregroundColor(.green)
                                Text("Creative Refill (+20 All Blocks)")
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                    }
                } header: {
                    Text("Appearance & Customization")
                }

                Section("Display & Performance") {
                    Toggle(isOn: $world.isPerformanceStabilizationEnabled) {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Image(systemName: "gauge.with.dots.needle.bottom.50percent")
                                    .foregroundColor(.cyan)
                                Text("Performance Stabilization")
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                            }
                            Text("Locks FPS to 30, sets render distance to 2 chunks, and optimizes chunk streaming for smooth, lag-free gameplay.")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }

                    Picker(selection: Binding(
                        get: { world.fpsLimit },
                        set: { world.setFPSLimit($0) }
                    )) {
                        Text("Unlimited").tag(0)
                        Text("30 FPS (Stable)").tag(30)
                        Text("40 FPS").tag(40)
                        Text("60 FPS (Smooth)").tag(60)
                    } label: {
                        HStack {
                            Image(systemName: "speedometer")
                                .foregroundColor(.orange)
                            Text("FPS Limit")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "mountain.2.fill")
                                .foregroundColor(.green)
                            Text("Render Distance")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                            Spacer()
                            Text("\(world.renderDistance) Chunks (\(world.renderDistance * world.chunkSize)m)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.cyan)
                        }
                        Slider(
                            value: Binding(
                                get: { Double(world.renderDistance) },
                                set: { world.setRenderDistance(Int($0)) }
                            ),
                            in: 2...8,
                            step: 1
                        )
                        HStack {
                            Text("2 Chunks (Fast)")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("8 Chunks (Far)")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section {
                    Toggle(isOn: Binding(
                        get: { world.isMultiplayerEnabled },
                        set: { world.toggleMultiplayerEnabled($0) }
                    )) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Image(systemName: "person.2.wave.2.fill")
                                    .foregroundColor(.pink)
                                Text("Multiplayer Mode")
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                            }
                            Text("Broadcasts signal when in a world so nearby players on Wi-Fi can join (Enabled by default)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Local Multiplayer")
                }

                Section {
                    Toggle(isOn: $world.isMusicEnabled) {
                        HStack {
                            Image(systemName: world.isMusicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            Text("Background Music")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                        }
                    }
                    .onChange(of: world.isMusicEnabled) { enabled in
                        AlphaBackgroundMusic.shared.setEnabled(enabled)
                    }

                    Toggle(isOn: $world.controlLayout.swapLeftRight) {
                        Text("Swap Left / Right Controls")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Look Sensitivity")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                            Spacer()
                            Text(String(format: "%.1fx", world.controlLayout.lookSensitivity))
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.cyan)
                        }
                        Slider(value: $world.controlLayout.lookSensitivity, in: 0.4...2.5, step: 0.1)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Movement Speed")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                            Spacer()
                            Text(String(format: "%.1fx", world.controlLayout.movementSpeedMultiplier))
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.cyan)
                        }
                        Slider(value: $world.controlLayout.movementSpeedMultiplier, in: 0.5...1.5, step: 0.1)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("HUD Opacity")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                            Spacer()
                            Text("\(Int(world.controlLayout.controlOpacity * 100))%")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.cyan)
                        }
                        Slider(value: $world.controlLayout.controlOpacity, in: 0.3...1.0, step: 0.05)
                    }
                } header: {
                    Text("Controls & Audio")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                }
            }
        }
    }
}

// Zero-latency UIKit press-and-hold button for instant Up/Down movement
struct HoldButton: View {
    let label: String
    let systemImage: String
    let color: Color
    var isEditing: Bool = false
    let onPressChanged: (Bool) -> Void

    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .bold))
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(isPressed ? Color.white.opacity(0.48) : color)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
        )
        .overlay(
            Group {
                if !isEditing {
                    InstantTouchOverlay { pressed in
                        if isPressed != pressed {
                            isPressed = pressed
                            onPressChanged(pressed)
                        }
                    }
                }
            }
        )
    }
}

private final class ImmediatePressGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        if state == .possible {
            state = .began
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        if state == .began || state == .changed {
            state = .changed
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = .ended
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        state = .cancelled
    }
}

private struct InstantTouchOverlay: UIViewRepresentable {
    let onPressChanged: (Bool) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPressChanged: onPressChanged)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isMultipleTouchEnabled = true
        view.isExclusiveTouch = false

        let recognizer = ImmediatePressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleGesture(_:))
        )
        recognizer.delaysTouchesBegan = false
        recognizer.delaysTouchesEnded = false
        recognizer.cancelsTouchesInView = false
        recognizer.delegate = context.coordinator
        view.addGestureRecognizer(recognizer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.onPressChanged = onPressChanged
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var onPressChanged: (Bool) -> Void

        init(onPressChanged: @escaping (Bool) -> Void) {
            self.onPressChanged = onPressChanged
        }

        @objc func handleGesture(_ gesture: ImmediatePressGestureRecognizer) {
            switch gesture.state {
            case .began:
                onPressChanged(true)
            case .ended, .cancelled, .failed:
                onPressChanged(false)
            default:
                break
            }
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            return true
        }
    }
}

// Zero-sticking UIKit touch overlay that guarantees reset on touchesEnded and touchesCancelled
private struct JoystickTouchOverlay: UIViewRepresentable {
    let maxRadius: CGFloat
    let onMove: (CGPoint, CGSize) -> Void
    let onEnd: () -> Void

    func makeUIView(context: Context) -> JoystickTouchUIView {
        let view = JoystickTouchUIView()
        view.backgroundColor = .clear
        view.isMultipleTouchEnabled = false
        view.maxRadius = maxRadius
        view.onMove = onMove
        view.onEnd = onEnd
        return view
    }

    func updateUIView(_ uiView: JoystickTouchUIView, context: Context) {
        uiView.maxRadius = maxRadius
        uiView.onMove = onMove
        uiView.onEnd = onEnd
    }
}

private final class JoystickTouchUIView: UIView {
    var maxRadius: CGFloat = 38.0
    var onMove: ((CGPoint, CGSize) -> Void)?
    var onEnd: (() -> Void)?
    private weak var activeTouch: UITouch?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if activeTouch == nil, let touch = touches.first {
            activeTouch = touch
            handleTouch(touch)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = activeTouch, touches.contains(touch) else { return }
        handleTouch(touch)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = activeTouch, touches.contains(touch) else { return }
        activeTouch = nil
        onEnd?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeTouch = nil
        onEnd?()
    }

    private func handleTouch(_ touch: UITouch) {
        let loc = touch.location(in: self)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let dx = loc.x - center.x
        let dy = loc.y - center.y
        let dist = sqrt(dx * dx + dy * dy)
        let clampedDist = min(dist, maxRadius)
        let angle = atan2(dy, dx)

        let cx = cos(angle) * clampedDist
        let cy = sin(angle) * clampedDist
        let offset = CGSize(width: cx, height: cy)

        let normDist = clampedDist / maxRadius
        let activeNorm = max(0, normDist - 0.08) / 0.92
        let curvedSpeed = pow(activeNorm, 1.45)
        let move = CGPoint(
            x: cos(angle) * curvedSpeed,
            y: -sin(angle) * curvedSpeed
        )
        onMove?(move, offset)
    }
}

// SceneKit UIViewRepresentable with Touch Look Drag & 60fps Game Loop
struct VoxelSceneView: UIViewRepresentable {
    @ObservedObject var world: VoxelWorld

    func makeCoordinator() -> Coordinator {
        Coordinator(world: world)
    }

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = world.scene
        scnView.pointOfView = world.cameraNode
        scnView.autoenablesDefaultLighting = false
        scnView.allowsCameraControl = false
        scnView.isPlaying = true
        scnView.preferredFramesPerSecond = (world.fpsLimit == 0) ? 0 : world.fpsLimit
        scnView.antialiasingMode = world.isPerformanceStabilizationEnabled ? .none : .multisampling2X

        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        panGesture.maximumNumberOfTouches = 2
        scnView.addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.35
        scnView.addGestureRecognizer(longPressGesture)

        context.coordinator.startDisplayLink()
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        let targetFPS = (world.fpsLimit == 0) ? 0 : world.fpsLimit
        if uiView.preferredFramesPerSecond != targetFPS {
            uiView.preferredFramesPerSecond = targetFPS
            uiView.antialiasingMode = world.isPerformanceStabilizationEnabled ? .none : .multisampling2X
            context.coordinator.updateFrameRate()
        }
    }

    @MainActor
    final class Coordinator: NSObject {
        let world: VoxelWorld
        private var lastPanPoint: CGPoint = .zero
        private var displayLink: CADisplayLink?
        private var lastTimestamp: CFTimeInterval = 0

        init(world: VoxelWorld) {
            self.world = world
        }

        func startDisplayLink() {
            displayLink?.invalidate()
            let link = CADisplayLink(target: self, selector: #selector(stepFrame(_:)))
            link.add(to: .main, forMode: .common)
            displayLink = link
            updateFrameRate()
        }

        func updateFrameRate() {
            guard let link = displayLink else { return }
            if #available(iOS 15.0, *) {
                if world.fpsLimit > 0 {
                    let rate = Float(world.fpsLimit)
                    link.preferredFrameRateRange = CAFrameRateRange(minimum: min(15, rate), maximum: rate, preferred: rate)
                } else {
                    link.preferredFrameRateRange = .default
                }
            } else {
                link.preferredFramesPerSecond = world.fpsLimit
            }
        }

        @objc private func stepFrame(_ link: CADisplayLink) {
            if lastTimestamp == 0 {
                lastTimestamp = link.timestamp
                return
            }
            let dt = Float(link.timestamp - lastTimestamp)
            lastTimestamp = link.timestamp
            world.stepPhysics(dt: dt)
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: gesture.view)
            if gesture.state == .began {
                lastPanPoint = .zero
            }
            let dx = Float(translation.x - lastPanPoint.x)
            let dy = Float(translation.y - lastPanPoint.y)
            lastPanPoint = translation

            let sensitivity: Float = 0.0055
            world.rotateCamera(deltaYaw: dx * sensitivity, deltaPitch: dy * sensitivity)
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            if gesture.state == .ended {
                if let target = world.targetedBlockType, target.isToggleable {
                    world.toggleTargetedDoorOrTrapdoor()
                } else {
                    world.placeSelectedBlock()
                }
            }
        }

        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            if gesture.state == .began {
                world.breakTargetedBlock()
            }
        }
    }
}
