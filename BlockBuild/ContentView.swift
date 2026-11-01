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
    @State private var showingTexturePacksSheet = false
    @State private var showingSkinMakerSheet = false
    @State private var showCameraFlash = false

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
                    showingSettingsSheet: $showingSettingsSheet,
                    showingSkinMakerSheet: $showingSkinMakerSheet
                )
            } else {
                inGameWorldView
            }

            // Player joined / left notification (identical banner on Android)
            if let notice = world.playerNotice {
                playerNoticeBanner(notice)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1000)
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
                showingWorldsSheet: $showingWorldsSheet,
                showingTexturePacksSheet: $showingTexturePacksSheet,
                showingSkinMakerSheet: $showingSkinMakerSheet
            )
        }
        .sheet(isPresented: $showingSkinsSheet) {
            CharacterSkinsSheet(world: world, showingSkinMakerSheet: $showingSkinMakerSheet)
        }
        .sheet(isPresented: $showingTexturePacksSheet) {
            TexturePacksSheet(world: world, showingSkinMakerSheet: $showingSkinMakerSheet)
        }
        .sheet(isPresented: $showingSkinMakerSheet) {
            SkinAndTextureMakerView(world: world)
        }
        .onChange(of: showingSettingsSheet) { _ in
            world.resetInputState()
            joystickOffset = .zero
        }
        .onChange(of: showingSkinsSheet) { _ in
            world.resetInputState()
            joystickOffset = .zero
        }
        .onChange(of: showingTexturePacksSheet) { _ in
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
        .onChange(of: showingSkinMakerSheet) { _ in
            world.resetInputState()
            joystickOffset = .zero
        }
    }

    private func dismissAllSheets() {
        showingWorldsSheet = false
        showingMultiplayerSheet = false
        showingSettingsSheet = false
        showingSkinsSheet = false
        showingTexturePacksSheet = false
        showingSkinMakerSheet = false
    }

    private func triggerCameraFlash() {
        withAnimation(.easeOut(duration: 0.06)) {
            showCameraFlash = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
            withAnimation(.easeOut(duration: 0.25)) {
                showCameraFlash = false
            }
        }
    }

    private func playerNoticeBanner(_ notice: PlayerNotice) -> some View {
        let accent: Color = notice.joined ? .green : .orange
        return VStack {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.25))
                        .frame(width: 30, height: 30)
                    Image(systemName: notice.joined ? "person.wave.2.fill" : "person.fill.xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(accent)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(notice.joined ? "PLAYER JOINED" : "PLAYER LEFT")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(accent)
                    Text(notice.joined ? "\(notice.name) joined the world!" : "\(notice.name) left the world")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.88))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(accent.opacity(0.8), lineWidth: 1.5))
                    .shadow(color: .black.opacity(0.6), radius: 8, y: 4)
            )
            .padding(.top, 58)
            Spacer()
        }
        .allowsHitTesting(false)
        .animation(.spring(response: 0.35), value: notice.id)
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

            // Visual camera shutter flash effect
            if showCameraFlash {
                Color.white
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }

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
                            if world.selectedBlock == .water {
                                Text("(BREAK TO SCOOP)")
                                    .foregroundColor(.cyan)
                            } else {
                                Text("(PLACE TO FILL)")
                                    .foregroundColor(.cyan)
                            }
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

                    // 4. Photo / Screenshot (Pure 3D world with no buttons, crosshairs, or UI)
                    Button {
                        triggerCameraFlash()
                        world.captureCleanScreenshot()
                    } label: {
                        Label("Photo", systemImage: "camera.fill")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 7)
                            .background(Color.purple.opacity(0.85))
                            .cornerRadius(8)
                    }

                    // 5. Settings (hidden while customizing HUD controls)
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
                                    .id("hotbar-icon-\(block.rawValue)-\(world.textureUpdateVersion)")

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

    @ObservedObject private var themeMgr = MenuThemeManager.shared

    var body: some View {
        let theme = themeMgr.currentTheme

        GameMenuContainer(
            title: "LOCAL MULTIPLAYER",
            subtitle: "Wi-Fi Co-Op & World Sync",
            icon: "person.2.wave.2.fill",
            onDismiss: { dismiss() }
        ) {
            // Signal Radar & Status Card
            GameCard(
                title: "SIGNAL RADAR",
                icon: "antenna.radiowaves.left.and.right",
                badge: world.isMultiplayerEnabled ? "ACTIVE" : "OFF"
            ) {
                VStack(spacing: 8) {
                    GameToggleRow(
                        title: "Multiplayer Mode",
                        subtitle: "Broadcast signal on local Wi-Fi to join friends",
                        icon: "wifi",
                        isOn: Binding(
                            get: { world.isMultiplayerEnabled },
                            set: { world.toggleMultiplayerEnabled($0) }
                        )
                    )

                    if world.isMultiplayerEnabled {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(world.isInGame ? Color.green : Color.yellow)
                                .frame(width: 8, height: 8)
                            Text(world.isInGame ? "Broadcasting '\(world.currentWorldName)' to nearby devices" : "Signal ready • Join or open a world to broadcast")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(world.isInGame ? .green : .yellow)
                            Spacer()
                            Text(world.isInGame ? "IN WORLD" : "READY")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background((world.isInGame ? Color.green : Color.yellow).opacity(0.18))
                                .foregroundColor(world.isInGame ? .green : .yellow)
                                .cornerRadius(4)
                        }
                        .padding(.top, 4)
                    }
                }
            }

            // Player Profile Card
            GameCard(title: "YOUR PLAYER PROFILE", icon: "person.crop.circle") {
                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        if let custom = world.activeCustomSkin {
                            CharacterAvatarPreview(customSkin: custom, size: 36)
                        } else {
                            CharacterAvatarPreview(skin: world.selectedSkin, size: 36)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("PLAYER DISPLAY NAME")
                                .font(.system(size: 9.5, weight: .black, design: .monospaced))
                                .foregroundColor(theme.secondaryAccent)
                            Text("Current World: \(world.currentWorldName)")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.white.opacity(0.65))
                        }
                        Spacer()
                    }

                    HStack(spacing: 8) {
                        GameTextField(placeholder: "Display Name...", text: $playerNameInput, icon: "person.fill") {
                            world.updateLocalPlayerName(playerNameInput)
                        }

                        if playerNameInput != world.localPlayerName && !playerNameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            GameSmallButton(title: "Save", icon: "checkmark", color: theme.primaryAccent, isProminent: true) {
                                world.updateLocalPlayerName(playerNameInput)
                            }
                        }
                    }
                }
            }

            // Connected Players Card
            GameCard(
                title: "CONNECTED PLAYERS (\(world.connectedPlayerNames.count + 1))",
                icon: "person.3.fill",
                badge: "\(world.connectedPlayerNames.count + 1) ACTIVE"
            ) {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "person.fill.checkmark")
                            .foregroundColor(.green)
                        Text("\(world.localPlayerName) (You)")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        Spacer()
                        Text(world.isHostingMultiplayer ? "HOST" : "GUEST")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(theme.primaryAccent.opacity(0.2))
                            .foregroundColor(theme.primaryAccent)
                            .cornerRadius(4)
                    }
                    .padding(8)
                    .background(theme.buttonBackground.opacity(0.5))
                    .cornerRadius(8)

                    ForEach(world.connectedPlayerNames, id: \.self) { peerName in
                        HStack {
                            Image(systemName: "person.wave.2.fill")
                                .foregroundColor(.cyan)
                            Text(peerName)
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            Spacer()
                            Text("CONNECTED")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .foregroundColor(.cyan)
                        }
                        .padding(8)
                        .background(theme.buttonBackground.opacity(0.5))
                        .cornerRadius(8)
                    }

                    if !world.connectedPlayerNames.isEmpty {
                        GameButton(title: "Disconnect from Session", icon: "xmark.circle.fill", isDestructive: true) {
                            world.disconnectMultiplayer()
                        }
                        .padding(.top, 4)
                    }
                }
            }

            // Nearby Discovered Worlds Card
            GameCard(
                title: "NEARBY WORLDS (\(world.discoveredHosts.count))",
                icon: "antenna.radiowaves.left.and.right.circle",
                badge: world.discoveredHosts.isEmpty ? "LISTENING" : "FOUND"
            ) {
                VStack(spacing: 8) {
                    if world.discoveredHosts.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 10) {
                                ProgressView()
                                    .tint(theme.primaryAccent)
                                Text("Scanning for nearby BlockBuild worlds...")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                            Text("When friends launch BlockBuild on the same Wi-Fi, their world appears here instantly.")
                                .font(.system(size: 9.5, design: .monospaced))
                                .foregroundColor(.white.opacity(0.60))
                        }
                        .padding(8)
                    } else {
                        ForEach(world.discoveredHosts) { host in
                            HStack(spacing: 10) {
                                CharacterAvatarPreview(skin: host.skin, size: 28)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(host.worldName)
                                        .font(.system(size: 12.5, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                    HStack(spacing: 5) {
                                        Text("By \(host.playerName)")
                                            .font(.system(size: 9.5, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.7))
                                        Text(host.isInGame ? (host.isHost ? "• HOST" : "• IN GAME") : "• IN MENU")
                                            .font(.system(size: 8.5, weight: .heavy, design: .monospaced))
                                            .foregroundColor(host.isInGame ? (host.isHost ? .green : .yellow) : .blue)
                                    }
                                }

                                Spacer()

                                if host.isInGame && host.isHost {
                                    GameSmallButton(title: "Join", icon: "arrow.right.circle.fill", color: .green, isProminent: true) {
                                        world.joinDiscoveredHost(host)
                                        dismiss()
                                    }
                                } else {
                                    GameSmallButton(title: "Invite", icon: "paperplane.fill", color: .cyan) {
                                        world.invitePeerToCurrentWorld(host.peerID)
                                    }
                                }
                            }
                            .padding(8)
                            .background(theme.buttonBackground.opacity(0.6))
                            .cornerRadius(8)
                        }
                    }
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

// MARK: - Saved Worlds & New World Manager Sheet

struct SavedWorldsSheet: View {
    @ObservedObject var world: VoxelWorld
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var themeMgr = MenuThemeManager.shared

    @State private var worldNameInput: String = ""
    @State private var selectedWorldType: WorldType = .standard
    @State private var aiPrompt: String = ""
    @State private var generatedCustomWorld: CustomWorldType? = nil
    @State private var isSynthesizingAI: Bool = false

    var body: some View {
        let theme = themeMgr.currentTheme

        GameMenuContainer(
            title: "BLOCKBUILD WORLDS",
            subtitle: "Create, Synthesize & Load Voxel Worlds",
            icon: "globe.americas.fill",
            onDismiss: { dismiss() }
        ) {
            // 1. Current Active World Card
            GameCard(
                title: "CURRENT ACTIVE WORLD",
                icon: "cube.fill",
                badge: "SEED #\(world.worldSeed)"
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(world.currentWorldName.uppercased())
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            Text("\(world.currentWorldType.displayName) • Seed #\(world.worldSeed)")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(theme.primaryAccent)
                        }
                        Spacer()
                        GameSmallButton(title: "Save Now", icon: "square.and.arrow.down.fill", color: theme.primaryAccent, isProminent: true) {
                            world.saveCurrentWorld(customName: worldNameInput)
                            dismiss()
                        }
                    }

                    HStack(spacing: 8) {
                        GameTextField(placeholder: "Rename current world (optional)...", text: $worldNameInput, icon: "pencil")
                    }
                }
            }

            // 2. ✨ AI World Generator (Integrated directly into Worlds Menu)
            GameCard(
                title: "✨ AI WORLD GENERATOR",
                icon: "sparkles",
                badge: "ON-DEVICE AI"
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Describe any world in plain English. The AI synthesizes terrain, custom skies, rivers & waterfalls instantly.")
                        .font(.system(size: 10.5, design: .monospaced))
                        .foregroundColor(.white.opacity(0.80))

                    GameTextField(
                        placeholder: "e.g. Alpine mountain peaks with rushing waterfalls and deep rivers...",
                        text: $aiPrompt,
                        icon: "wand.and.stars"
                    ) {
                        synthesizeAndPlayAIWorld()
                    }

                    // Inspiration Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            inspirationChip("🌊 Cascading Waterfalls", prompt: "Towering mountain cliffs with huge cascading waterfalls, deep plunge pools, and rushing rivers")
                            inspirationChip("🏰 Medieval Villages", prompt: "Sprawling medieval village settlements with cobblestone town hall, watchtower, and glass cottages")
                            inspirationChip("☁️ Celestial Sky Islands", prompt: "Floating celestial islands high in the sky with hanging vines, waterfalls pouring into the void, and twilight fog")
                            inspirationChip("🔥 Volcanic Nether", prompt: "Fiery volcanic underworld with obsidian rocks, blazing lava pools, and crimson ash skies")
                            inspirationChip("❄️ Alpine Glacier Peaks", prompt: "Gigantic snow-capped peaks with extreme vertical cliffs and frozen mountain waterfalls")
                        }
                    }

                    HStack(spacing: 8) {
                        Button {
                            synthesizeAndPlayAIWorld()
                        } label: {
                            HStack(spacing: 6) {
                                if isSynthesizingAI {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "sparkles")
                                }
                                Text("SYNTHESIZE & PLAY")
                                    .font(.system(size: 11, weight: .black, design: .monospaced))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(
                                LinearGradient(colors: [theme.primaryAccent, theme.secondaryAccent], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.4), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .disabled(aiPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                        if let generated = generatedCustomWorld {
                            GameSmallButton(title: "Save Type", icon: "bookmark.fill", color: theme.secondaryAccent) {
                                world.saveCustomWorldType(generated)
                            }
                        }
                    }

                    // Preview of Generated AI World
                    if let generated = generatedCustomWorld {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Image(systemName: generated.iconName)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(theme.primaryAccent)
                                Text(generated.name.uppercased())
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundColor(.white)
                                Spacer()
                                if generated.hasWaterfalls {
                                    Text("WATERFALLS")
                                        .font(.system(size: 8.5, weight: .black, design: .monospaced))
                                        .foregroundColor(.cyan)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.cyan.opacity(0.2))
                                        .cornerRadius(4)
                                }
                            }

                            Text(generated.summary)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.white.opacity(0.75))

                            HStack(spacing: 6) {
                                traitTag(icon: "square.fill", text: generated.surfaceBlock.fullName)
                                traitTag(icon: "mountain.2.fill", text: "Height: \(Int(generated.baseHeight))")
                                if generated.hasWaterfalls {
                                    traitTag(icon: "water.waves", text: "Cascades: 95%")
                                }
                                if generated.hasVillages {
                                    traitTag(icon: "house.fill", text: "Villages: \(Int(generated.villageDensity * 100))%")
                                }
                            }
                        }
                        .padding(10)
                        .background(theme.buttonBackground.opacity(0.7))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(theme.cardBorder, lineWidth: 1))
                    }
                }
            }

            // 3. Saved AI World Types (if any exist)
            if !world.customWorldTypes.isEmpty {
                GameCard(
                    title: "SAVED AI WORLD TYPES (\(world.customWorldTypes.count))",
                    icon: "sparkles.square.filled.on.square",
                    badge: "AI PRESETS"
                ) {
                    VStack(spacing: 8) {
                        ForEach(world.customWorldTypes) { custom in
                            HStack(spacing: 10) {
                                Image(systemName: custom.iconName)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(theme.primaryAccent)
                                    .frame(width: 26)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(custom.name)
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                    Text(custom.summary)
                                        .font(.system(size: 9.5, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.65))
                                        .lineLimit(1)
                                }

                                Spacer()

                                GameSmallButton(title: "Play", icon: "play.fill", color: theme.primaryAccent, isProminent: true) {
                                    world.regenerateWithCustomWorld(custom)
                                    dismiss()
                                }

                                Button {
                                    world.deleteCustomWorldType(id: custom.id)
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 11))
                                        .foregroundColor(.red.opacity(0.8))
                                        .padding(6)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(8)
                            .background(theme.buttonBackground.opacity(0.55))
                            .cornerRadius(8)
                        }
                    }
                }
            }

            // 4. Standard World Types
            GameCard(title: "STANDARD WORLD TYPES", icon: "globe.europe.africa.fill") {
                VStack(spacing: 10) {
                    // Type selector chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(WorldType.allCases) { type in
                                let isSelected = (selectedWorldType == type)
                                Button {
                                    selectedWorldType = type
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: type.iconName)
                                            .font(.system(size: 11, weight: .bold))
                                        Text(type.displayName.uppercased())
                                            .font(.system(size: 9.5, weight: .black, design: .monospaced))
                                    }
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 6)
                                    .background(isSelected ? theme.primaryAccent : theme.buttonBackground)
                                    .foregroundColor(isSelected ? .white : .white.opacity(0.75))
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

                    Text(selectedWorldType.subtitle)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.white.opacity(0.70))

                    GameButton(
                        title: "Generate \(selectedWorldType.displayName) World",
                        subtitle: "Creates a fresh procedural seed",
                        icon: "sparkles",
                        color: theme.primaryAccent,
                        isProminent: true
                    ) {
                        world.regenerateNewWorld(type: selectedWorldType, customName: worldNameInput)
                        dismiss()
                    }
                }
            }

            // 5. Saved Worlds List
            GameCard(
                title: "SAVED WORLDS (\(world.savedWorlds.count))",
                icon: "folder.fill",
                badge: "\(world.savedWorlds.count) SAVED"
            ) {
                VStack(spacing: 8) {
                    if world.savedWorlds.isEmpty {
                        Text("No saved worlds yet. Worlds auto-save automatically as you build!")
                            .font(.system(size: 10.5, design: .monospaced))
                            .foregroundColor(.white.opacity(0.60))
                            .padding(8)
                    } else {
                        ForEach(world.savedWorlds) { saved in
                            let isActive = (saved.id == world.currentWorldID)

                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 6) {
                                        Text(saved.name)
                                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                                            .foregroundColor(.white)

                                        if isActive {
                                            Text("ACTIVE")
                                                .font(.system(size: 8.5, weight: .black, design: .monospaced))
                                                .padding(.horizontal, 5)
                                                .padding(.vertical, 1.5)
                                                .background(theme.primaryAccent.opacity(0.25))
                                                .foregroundColor(theme.primaryAccent)
                                                .cornerRadius(4)
                                        }
                                    }

                                    Text("\(saved.archetypeName ?? "World") • Seed #\(saved.seed) • \(saved.savedAt.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.system(size: 9.5, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.65))
                                }

                                Spacer()

                                GameSmallButton(title: "Load", icon: "arrow.down.circle.fill", color: theme.secondaryAccent, isProminent: true) {
                                    world.saveCurrentWorld(silent: true)
                                    world.loadSavedWorld(saved)
                                    dismiss()
                                }

                                Button {
                                    world.deleteSavedWorld(saved)
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 12))
                                        .foregroundColor(.red.opacity(0.8))
                                        .padding(6)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(9)
                            .background(theme.buttonBackground.opacity(0.55))
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .onAppear {
            worldNameInput = ""
        }
    }

    private func inspirationChip(_ title: String, prompt: String) -> some View {
        Button {
            aiPrompt = prompt
            synthesizeAndPlayAIWorld()
        } label: {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .black, design: .monospaced))
                .foregroundColor(.white.opacity(0.85))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.08))
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func traitTag(icon: String, text: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 8))
            Text(text)
                .font(.system(size: 8.5, weight: .bold, design: .monospaced))
        }
        .foregroundColor(.white.opacity(0.75))
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.white.opacity(0.08))
        .cornerRadius(4)
    }

    private func synthesizeAndPlayAIWorld() {
        guard !aiPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isSynthesizingAI = true
        let generated = LightweightGameAI.shared.synthesizeWorld(prompt: aiPrompt)
        generatedCustomWorld = generated
        world.saveCustomWorldType(generated)
        world.regenerateWithCustomWorld(generated)
        isSynthesizingAI = false
        dismiss()
    }
}

// MARK: - Retro Voxel Main Menu

struct MainMenuView: View {
    @ObservedObject var world: VoxelWorld
    @Binding var showingWorldsSheet: Bool
    @Binding var showingSkinsSheet: Bool
    @Binding var showingMultiplayerSheet: Bool
    @Binding var showingSettingsSheet: Bool
    @Binding var showingSkinMakerSheet: Bool

    @ObservedObject private var themeMgr = MenuThemeManager.shared

    var body: some View {
        let theme = themeMgr.currentTheme

        GeometryReader { geo in
            ZStack {
                // Panoramic 3D Voxel World Scene in background
                VoxelSceneView(world: world)
                    .ignoresSafeArea()

                // Theme-responsive atmospheric tint overlay
                LinearGradient(
                    colors: [
                        theme.backgroundGradient[0].opacity(0.60),
                        theme.backgroundGradient[1].opacity(0.40),
                        Color.black.opacity(0.55)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                let safeInsets = geo.safeAreaInsets
                let safeWidth = max(200.0, geo.size.width - safeInsets.leading - safeInsets.trailing)
                let safeHeight = max(200.0, geo.size.height - safeInsets.top - safeInsets.bottom)
                let aspectRatio = geo.size.width / max(1.0, geo.size.height)
                let isWide = aspectRatio >= 1.20

                // Adaptive padding inset to guarantee content never interferes with display edges, notches, or home bars
                let hMargin = max(8.0, min(24.0, safeWidth * 0.03))
                let vMargin = max(6.0, min(16.0, safeHeight * 0.025))
                let usableWidth = max(180.0, safeWidth - hMargin * 2)
                let usableHeight = max(180.0, safeHeight - vMargin * 2)

                // Dynamic scale factor derived directly from resolution and safe bounds
                let scale: CGFloat = isWide
                    ? min(1.15, max(0.60, min(usableWidth / 680.0, usableHeight / 350.0)))
                    : min(1.15, max(0.65, min(usableWidth / 375.0, usableHeight / 660.0)))

                ViewThatFits(in: .vertical) {
                    // 1. Primary resolution & aspect-ratio optimized layout
                    menuContent(
                        isWide: isWide,
                        usableWidth: usableWidth,
                        usableHeight: usableHeight,
                        scale: scale,
                        theme: theme
                    )

                    // 2. Fallback scrollable layout if extreme accessibility Dynamic Type or ultra-compact display
                    ScrollView(.vertical, showsIndicators: false) {
                        menuContent(
                            isWide: isWide,
                            usableWidth: usableWidth,
                            usableHeight: usableHeight,
                            scale: scale,
                            theme: theme
                        )
                        .frame(minHeight: usableHeight)
                    }
                }
                .padding(.leading, safeInsets.leading + hMargin)
                .padding(.trailing, safeInsets.trailing + hMargin)
                .padding(.top, safeInsets.top + vMargin)
                .padding(.bottom, safeInsets.bottom + vMargin)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    @ViewBuilder
    private func menuContent(
        isWide: Bool,
        usableWidth: CGFloat,
        usableHeight: CGFloat,
        scale: CGFloat,
        theme: MenuTheme
    ) -> some View {
        if isWide {
            landscapeLayout(usableWidth: usableWidth, usableHeight: usableHeight, scale: scale, theme: theme)
        } else {
            portraitLayout(usableWidth: usableWidth, usableHeight: usableHeight, scale: scale, theme: theme)
        }
    }

    private func landscapeLayout(
        usableWidth: CGFloat,
        usableHeight: CGFloat,
        scale: CGFloat,
        theme: MenuTheme
    ) -> some View {
        let colSpacing = max(10.0, min(24.0, usableWidth * 0.04))
        let availableForCols = usableWidth - colSpacing
        let leftColWidth = min(320.0 * scale, availableForCols * 0.46)
        let rightColWidth = min(360.0 * scale, availableForCols * 0.52)
        let verticalSpacing = max(6.0, 10.0 * scale)

        return HStack(alignment: .center, spacing: colSpacing) {
            // Left Column: Logo Title, Equipped Skin Pill, Feature Tags
            VStack(alignment: .leading, spacing: verticalSpacing) {
                Spacer(minLength: 2)

                // Retro Themed Title Banner
                VStack(alignment: .leading, spacing: max(2, 3 * scale)) {
                    Text("BLOCKBUILD")
                        .font(.system(size: max(22, 36 * scale), weight: .black, design: .monospaced))
                        .foregroundStyle(theme.headerGradient)
                        .shadow(color: .black, radius: 4, x: 2, y: 3)
                        .minimumScaleFactor(0.65)
                        .lineLimit(1)

                    HStack(spacing: max(3, 5 * scale)) {
                        Text("A RETRO VOXEL SANDBOX")
                            .font(.system(size: max(7.5, 10.0 * scale), weight: .black, design: .monospaced))
                            .foregroundColor(theme.secondaryAccent)
                            .tracking(max(1.0, 2.0 * scale))
                            .shadow(color: .black, radius: 2)
                            .minimumScaleFactor(0.70)
                            .lineLimit(1)

                        Text("•")
                            .foregroundColor(.white.opacity(0.4))
                            .font(.system(size: max(7.5, 9.0 * scale)))

                        Text(theme.displayName.uppercased())
                            .font(.system(size: max(7.0, 8.5 * scale), weight: .black, design: .monospaced))
                            .foregroundColor(theme.primaryAccent)
                            .padding(.horizontal, max(3, 5 * scale))
                            .padding(.vertical, max(1, 1.5 * scale))
                            .background(theme.primaryAccent.opacity(0.18))
                            .cornerRadius(3)
                            .lineLimit(1)
                    }
                }

                // Equipped Skin Preview Pill
                skinPreviewPill(scale: scale, theme: theme)

                // Feature Highlights
                VStack(alignment: .leading, spacing: max(3, 5 * scale)) {
                    featureBadge(icon: "cube.fill", text: "Infinite Voxel Worlds", color: theme.primaryAccent, scale: scale)
                    featureBadge(icon: "paintpalette.fill", text: "Skin & Texture Pixel Studio", color: theme.secondaryAccent, scale: scale)
                    featureBadge(icon: "person.2.fill", text: "Nearby Co-Op & World Sync", color: .pink, scale: scale)
                }
                .padding(.top, max(1, 3 * scale))

                Spacer(minLength: 2)
            }
            .frame(width: leftColWidth, alignment: .leading)

            // Right Column: Action Buttons
            VStack(spacing: max(5.0, 8.5 * scale)) {
                Spacer(minLength: 2)

                MainMenuButton(
                    title: "PLAY WORLDS",
                    subtitle: "Create, Load & AI Biomes",
                    icon: "globe.americas.fill",
                    color: theme.primaryAccent,
                    scale: scale
                ) {
                    showingWorldsSheet = true
                }

                MainMenuButton(
                    title: "SKIN & TEXTURE MAKER",
                    subtitle: "Modify PNG & Inspect 3D Model",
                    icon: "paintpalette.fill",
                    color: theme.secondaryAccent,
                    scale: scale
                ) {
                    showingSkinMakerSheet = true
                }

                MainMenuButton(
                    title: "MULTIPLAYER",
                    subtitle: world.connectedPlayerNames.isEmpty ? "Local Wi-Fi Co-Op" : "\(world.connectedPlayerNames.count) Connected",
                    icon: "person.2.wave.2.fill",
                    color: .pink,
                    scale: scale
                ) {
                    showingMultiplayerSheet = true
                }

                MainMenuButton(
                    title: "SETTINGS",
                    subtitle: "Themes (\(theme.displayName)), Textures & Options",
                    icon: "gearshape.fill",
                    color: Color(red: 0.35, green: 0.38, blue: 0.48),
                    scale: scale
                ) {
                    showingSettingsSheet = true
                }

                Spacer(minLength: 2)
            }
            .frame(width: rightColWidth)
        }
        .frame(maxWidth: usableWidth, maxHeight: usableHeight)
    }

    private func portraitLayout(
        usableWidth: CGFloat,
        usableHeight: CGFloat,
        scale: CGFloat,
        theme: MenuTheme
    ) -> some View {
        let contentWidth = min(360.0 * scale, usableWidth * 0.94)
        let spacing = max(6.0, 9.5 * scale)

        return VStack(spacing: spacing) {
            Spacer(minLength: 4)

            // Retro Themed Title Banner
            VStack(spacing: max(2, 3.5 * scale)) {
                Text("BLOCKBUILD")
                    .font(.system(size: max(22, 34 * scale), weight: .black, design: .monospaced))
                    .foregroundStyle(theme.headerGradient)
                    .shadow(color: .black, radius: 4, x: 2, y: 3)
                    .minimumScaleFactor(0.65)
                    .lineLimit(1)

                HStack(spacing: max(3, 5 * scale)) {
                    Text("A RETRO VOXEL SANDBOX")
                        .font(.system(size: max(8, 10.5 * scale), weight: .black, design: .monospaced))
                        .foregroundColor(theme.secondaryAccent)
                        .tracking(max(1.0, 2.0 * scale))
                        .shadow(color: .black, radius: 2)
                        .minimumScaleFactor(0.70)
                        .lineLimit(1)

                    Text("•")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.system(size: max(8, 9.5 * scale)))

                    Text(theme.displayName.uppercased())
                        .font(.system(size: max(7.5, 9.0 * scale), weight: .black, design: .monospaced))
                        .foregroundColor(theme.primaryAccent)
                        .padding(.horizontal, max(3, 5 * scale))
                        .padding(.vertical, max(1, 1.5 * scale))
                        .background(theme.primaryAccent.opacity(0.18))
                        .cornerRadius(3)
                        .lineLimit(1)
                }
            }

            skinPreviewPill(scale: scale, theme: theme)

            Spacer(minLength: 4)

            VStack(spacing: max(5.5, 8.5 * scale)) {
                MainMenuButton(title: "PLAY WORLDS", subtitle: "Create, Load & AI Biomes", icon: "globe.americas.fill", color: theme.primaryAccent, scale: scale) {
                    showingWorldsSheet = true
                }
                MainMenuButton(title: "SKIN & TEXTURE MAKER", subtitle: "Modify PNG & Inspect 3D Model", icon: "paintpalette.fill", color: theme.secondaryAccent, scale: scale) {
                    showingSkinMakerSheet = true
                }
                MainMenuButton(title: "MULTIPLAYER", subtitle: world.connectedPlayerNames.isEmpty ? "Local Wi-Fi Co-Op" : "\(world.connectedPlayerNames.count) Connected", icon: "person.2.wave.2.fill", color: .pink, scale: scale) {
                    showingMultiplayerSheet = true
                }
                MainMenuButton(title: "SETTINGS", subtitle: "Themes (\(theme.displayName)), Textures & Options", icon: "gearshape.fill", color: Color(red: 0.35, green: 0.38, blue: 0.48), scale: scale) {
                    showingSettingsSheet = true
                }
            }
            .frame(maxWidth: contentWidth)

            Spacer(minLength: 4)

            // Footer
            HStack(spacing: max(4, 7 * scale)) {
                Text("Infinite Worlds")
                Text("•")
                Text("Skin Maker")
                Text("•")
                Text("Local Co-Op")
            }
            .font(.system(size: max(7.5, 9.5 * scale), weight: .bold, design: .monospaced))
            .foregroundColor(.white.opacity(0.6))
            .minimumScaleFactor(0.70)
            .lineLimit(1)
            .padding(.bottom, max(2, 4 * scale))
        }
        .frame(maxWidth: usableWidth, maxHeight: usableHeight)
    }

    private func skinPreviewPill(scale: CGFloat, theme: MenuTheme) -> some View {
        let avatarSize = max(18.0, 24.0 * scale)
        let textSize = max(8.5, 10.0 * scale)
        let subtextSize = max(7.0, 8.5 * scale)
        let hPad = max(8.0, 11.0 * scale)
        let vPad = max(3.5, 5.5 * scale)

        return Button {
            showingSkinsSheet = true
        } label: {
            HStack(spacing: max(5, 7 * scale)) {
                if let custom = world.activeCustomSkin {
                    CharacterAvatarPreview(customSkin: custom, size: avatarSize)
                } else {
                    CharacterAvatarPreview(skin: world.selectedSkin, size: avatarSize)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("SKIN: \((world.activeCustomSkin?.name ?? world.selectedSkin.displayName).uppercased())")
                        .font(.system(size: textSize, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.75)
                        .lineLimit(1)
                    Text("Tap to change skin")
                        .font(.system(size: subtextSize, weight: .medium, design: .monospaced))
                        .foregroundColor(theme.primaryAccent)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: max(7.5, 9.0 * scale), weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .background(theme.cardBackground)
            .cornerRadius(max(12, 16 * scale))
            .overlay(
                Capsule().stroke(theme.cardBorder, lineWidth: 1.2)
            )
            .shadow(color: .black.opacity(0.35), radius: 3, y: 1.5)
        }
    }

    private func featureBadge(icon: String, text: String, color: Color, scale: CGFloat) -> some View {
        HStack(spacing: max(4, 6 * scale)) {
            Image(systemName: icon)
                .font(.system(size: max(7.5, 9.0 * scale), weight: .bold))
                .foregroundColor(color)
                .frame(width: max(11, 14 * scale))
            Text(text)
                .font(.system(size: max(7.5, 9.2 * scale), weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.75))
                .minimumScaleFactor(0.70)
                .lineLimit(1)
        }
    }
}

struct MainMenuButton: View {
    let title: String
    let subtitle: String?
    let icon: String
    let color: Color
    var scale: CGFloat = 1.0
    var compact: Bool = false
    let action: () -> Void

    @ObservedObject private var themeMgr = MenuThemeManager.shared

    var body: some View {
        let theme = themeMgr.currentTheme
        let effectiveScale = compact ? min(scale, 0.85) : scale
        let iconBoxSize = max(22.0, 29.0 * effectiveScale)
        let iconSize = max(11.0, 15.0 * effectiveScale)
        let titleSize = max(10.5, 12.5 * effectiveScale)
        let subtitleSize = max(7.5, 9.0 * effectiveScale)
        let arrowSize = max(9.0, 12.0 * effectiveScale)
        let hPadding = max(8.0, 13.0 * effectiveScale)
        let vPadding = max(5.0, 8.5 * effectiveScale)
        let cornerRad = max(7.0, 10.5 * effectiveScale)
        let spacing = max(7.0, 11.0 * effectiveScale)

        Button(action: action) {
            HStack(spacing: spacing) {
                ZStack {
                    RoundedRectangle(cornerRadius: max(5, 7 * effectiveScale))
                        .fill(color.opacity(0.28))
                        .frame(width: iconBoxSize, height: iconBoxSize)
                    Image(systemName: icon)
                        .font(.system(size: iconSize, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 1.5 * effectiveScale) {
                    Text(title)
                        .font(.system(size: titleSize, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.70)
                        .lineLimit(1)

                    if let sub = subtitle {
                        Text(sub)
                            .font(.system(size: subtitleSize, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.82))
                            .minimumScaleFactor(0.65)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 4)

                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: arrowSize, weight: .bold))
                    .foregroundColor(.white.opacity(0.75))
            }
            .padding(.horizontal, hPadding)
            .padding(.vertical, vPadding)
            .background(
                LinearGradient(
                    colors: [color.opacity(0.90), theme.buttonBackground.opacity(0.85)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(cornerRad)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRad)
                    .stroke(theme.cardBorder, lineWidth: 1.2)
            )
            .shadow(color: .black.opacity(0.35), radius: 3, y: 1.5)
        }
    }
}

// MARK: - Character Avatar Preview & Skins Sheet

struct CharacterAvatarPreview: View {
    var skin: PlayerSkin? = nil
    var customSkin: CustomSkin? = nil
    var size: CGFloat = 36

    init(skin: PlayerSkin, size: CGFloat = 36) {
        self.skin = skin
        self.customSkin = nil
        self.size = size
    }

    init(customSkin: CustomSkin, size: CGFloat = 36) {
        self.skin = nil
        self.customSkin = customSkin
        self.size = size
    }

    var body: some View {
        let avatarImage: UIImage = {
            if let custom = customSkin {
                return SkinTextureManager.shared.frontAvatarImage(for: custom)
            } else if let s = skin {
                return SkinTextureManager.shared.frontAvatarImage(for: s)
            } else {
                return SkinTextureManager.shared.frontAvatarImage(for: .steve)
            }
        }()
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
    @Binding var showingSkinMakerSheet: Bool
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var themeMgr = MenuThemeManager.shared

    let columns = [
        GridItem(.adaptive(minimum: 155), spacing: 12)
    ]

    var body: some View {
        let theme = themeMgr.currentTheme

        GameMenuContainer(
            title: "CHARACTER SKINS",
            subtitle: "Select, Equip & Paint Custom Skins",
            icon: "person.fill",
            onDismiss: { dismiss() }
        ) {
            // Header card: Currently Equipped
            GameCard(title: "CURRENTLY EQUIPPED", icon: "checkmark.seal.fill") {
                HStack(spacing: 14) {
                    if let custom = world.activeCustomSkin {
                        CharacterAvatarPreview(customSkin: custom, size: 48)
                            .padding(6)
                            .background(theme.buttonBackground)
                            .cornerRadius(10)
                    } else {
                        CharacterAvatarPreview(skin: world.selectedSkin, size: 48)
                            .padding(6)
                            .background(theme.buttonBackground)
                            .cornerRadius(10)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(world.activeCustomSkin?.name.uppercased() ?? world.selectedSkin.displayName.uppercased())
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                        Text(world.activeCustomSkin?.roleSubtitle ?? world.selectedSkin.roleSubtitle)
                            .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                            .foregroundColor(theme.secondaryAccent)
                        Text("Visible in singleplayer & local Wi-Fi multiplayer")
                            .font(.system(size: 9.5, design: .monospaced))
                            .foregroundColor(.white.opacity(0.65))
                    }
                    Spacer()
                }
            }

            // Skin & Texture Maker Jump Button
            GameButton(
                title: "Skin & Texture Maker",
                subtitle: "Modify PNG pixels on canvas and inspect live 3D model",
                icon: "paintpalette.fill",
                color: theme.secondaryAccent,
                isProminent: true
            ) {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    showingSkinMakerSheet = true
                }
            }

            // Saved Custom Skins Grid
            if !world.customSkins.isEmpty {
                GameCard(
                    title: "SAVED CUSTOM SKINS (\(world.customSkins.count))",
                    icon: "person.crop.artframe",
                    badge: "PLAYER CREATED"
                ) {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(world.customSkins) { skin in
                            let isEquipped = (world.activeCustomSkin?.id == skin.id)
                            Button {
                                UISelectionFeedbackGenerator().selectionChanged()
                                world.equipCustomSkin(skin)
                            } label: {
                                VStack(spacing: 8) {
                                    CharacterAvatarPreview(customSkin: skin, size: 44)
                                        .frame(height: 60)

                                    VStack(spacing: 2) {
                                        Text(skin.name)
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                        Text(skin.roleSubtitle)
                                            .font(.system(size: 9, design: .monospaced))
                                            .foregroundColor(theme.secondaryAccent)
                                            .lineLimit(1)
                                    }

                                    if isEquipped {
                                        Text("EQUIPPED")
                                            .font(.system(size: 8.5, weight: .black, design: .monospaced))
                                            .foregroundColor(theme.primaryAccent)
                                            .padding(.horizontal, 7)
                                            .padding(.vertical, 3)
                                            .background(theme.primaryAccent.opacity(0.20))
                                            .cornerRadius(5)
                                    } else {
                                        Text("EQUIP")
                                            .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.7))
                                            .padding(.horizontal, 7)
                                            .padding(.vertical, 3)
                                            .background(theme.buttonBackground)
                                            .cornerRadius(5)
                                    }
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(isEquipped ? theme.primaryAccent.opacity(0.18) : theme.buttonBackground.opacity(0.6))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(isEquipped ? theme.primaryAccent : theme.cardBorder.opacity(0.5), lineWidth: 1)
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            // Standard Characters Grid
            GameCard(title: "STANDARD CHARACTERS", icon: "person.3.fill") {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(PlayerSkin.allCases) { skin in
                        let isEquipped = (world.activeCustomSkin == nil && world.selectedSkin == skin)
                        Button {
                            UISelectionFeedbackGenerator().selectionChanged()
                            world.setSkin(skin)
                        } label: {
                            VStack(spacing: 8) {
                                CharacterAvatarPreview(skin: skin, size: 44)
                                    .frame(height: 60)

                                VStack(spacing: 2) {
                                    Text(skin.displayName)
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                    Text(skin.roleSubtitle)
                                        .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                                        .foregroundColor(theme.secondaryAccent)
                                        .lineLimit(1)
                                }

                                if isEquipped {
                                    Text("EQUIPPED")
                                        .font(.system(size: 8.5, weight: .black, design: .monospaced))
                                        .foregroundColor(theme.primaryAccent)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 3)
                                        .background(theme.primaryAccent.opacity(0.20))
                                        .cornerRadius(5)
                                } else {
                                    Text("EQUIP")
                                        .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 3)
                                        .background(theme.buttonBackground)
                                        .cornerRadius(5)
                                }
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(isEquipped ? theme.primaryAccent.opacity(0.18) : theme.buttonBackground.opacity(0.6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                        .stroke(isEquipped ? theme.primaryAccent : theme.cardBorder.opacity(0.5), lineWidth: 1)
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Texture Packs Selection Sheet

struct TexturePacksSheet: View {
    @ObservedObject var world: VoxelWorld
    var showingSkinMakerSheet: Binding<Bool>? = nil
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var themeMgr = MenuThemeManager.shared

    private let sampleBlocks: [BlockType] = [.grass, .stone, .woodPlanks, .door, .glass, .water]

    var body: some View {
        let theme = themeMgr.currentTheme

        GameMenuContainer(
            title: "TEXTURE PACKS",
            subtitle: "Select Pack • Style All 15 Block Types",
            icon: "cube.fill",
            onDismiss: { dismiss() }
        ) {
            // Header card
            GameCard(title: "BLOCK TEXTURE STYLES", icon: "paintpalette.fill", badge: "\(TexturePack.allCases.count) PACKS") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Transform every voxel in your world in real-time with pixel-crafted block textures.")
                        .font(.system(size: 10.5, design: .monospaced))
                        .foregroundColor(.white.opacity(0.80))

                    if let showingSkinMaker = showingSkinMakerSheet {
                        GameButton(
                            title: "Open Texture Maker",
                            subtitle: "Draw custom 16x16 pixel block textures",
                            icon: "paintpalette.fill",
                            color: theme.secondaryAccent
                        ) {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                showingSkinMaker.wrappedValue = true
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }

            // Texture Packs Cards
            ForEach(TexturePack.allCases) { pack in
                let isSelected = (world.currentTexturePack == pack)

                GameCard(
                    title: pack.displayName,
                    icon: pack.iconName,
                    badge: isSelected ? "ACTIVE" : nil
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(pack.subtitle)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.white.opacity(0.70))

                        // Live Block Preview Strip
                        HStack(spacing: 8) {
                            ForEach(sampleBlocks) { block in
                                VStack(spacing: 3) {
                                    Image(uiImage: block.iconImage(for: pack))
                                        .interpolation(.none)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                        .background(theme.buttonBackground)
                                        .cornerRadius(6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(theme.cardBorder.opacity(0.5), lineWidth: 1)
                                        )

                                    Text(block.displayName)
                                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.75))
                                        .lineLimit(1)
                                }
                            }
                        }

                        if !isSelected {
                            GameSmallButton(title: "Apply Pack", icon: "checkmark", color: pack.themeColor, isProminent: true) {
                                UISelectionFeedbackGenerator().selectionChanged()
                                world.setTexturePack(pack)
                            }
                            .padding(.top, 2)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Shaders Sheet (Real-Time Voxel Lighting & Hardware Optimization)

struct ShadersSheet: View {
    @ObservedObject var world: VoxelWorld
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var themeMgr = MenuThemeManager.shared

    var body: some View {
        let theme = themeMgr.currentTheme

        GameMenuContainer(
            title: "SHADERS & VISUALS",
            subtitle: "Select Shader Pack • Real-Time Voxel Lighting",
            icon: "sparkles",
            onDismiss: { dismiss() }
        ) {
            // Hardware capability & Minecraft-style optimization banner
            GameCard(
                title: "SHADER ENGINE & HARDWARE",
                icon: "gauge.with.dots.needle.bottom.50percent",
                badge: VoxelWorld.deviceHas6GBRAMOrHigher ? "6GB+ RAM (DEFAULT ON)" : "OPTIMIZED MODE"
            ) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(
                        VoxelWorld.deviceHas6GBRAMOrHigher
                            ? "Your device has 6GB+ RAM — high-performance shaders are enabled by default with real-time directional sun shadows, HDR bloom and animated water shimmer."
                            : "Your device is running in battery & performance optimized mode. Vanilla is active by default to prevent lag, but you can select any shader pack below!"
                    )
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.80))

                    Text("• Minecraft-style stabilized shadow box centered directly on player position.")
                        .font(.system(size: 9.5, design: .monospaced))
                        .foregroundColor(theme.secondaryAccent)
                    Text("• 1024x1024 deferred shadow maps with anti-aliased soft penumbra.")
                        .font(.system(size: 9.5, design: .monospaced))
                        .foregroundColor(theme.secondaryAccent)
                }
            }

            // Presets Cards
            ForEach(GameShaderPreset.allCases) { shader in
                let isSelected = (world.currentShader == shader)

                GameCard(
                    title: shader.displayName.uppercased(),
                    icon: shader.iconName,
                    badge: isSelected ? "ACTIVE" : nil
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(shader.subtitle)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.white.opacity(0.75))

                        HStack {
                            Circle()
                                .fill(shader.themeColor)
                                .frame(width: 10, height: 10)
                            Text(shader == .vanilla ? "Zero GPU overhead" : (shader.castsShadows ? "HDR Bloom • Real-Time Shadows • Waves" : "HDR Bloom • Sky Tint"))
                                .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.65))

                            Spacer()

                            if !isSelected {
                                GameSmallButton(title: "Apply Shader", icon: "checkmark", color: shader.themeColor, isProminent: true) {
                                    UISelectionFeedbackGenerator().selectionChanged()
                                    world.applyShaderPreset(shader)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct InGameSettingsSheet: View {
    @ObservedObject var world: VoxelWorld
    @Binding var showingSkinsSheet: Bool
    @Binding var showingWorldsSheet: Bool
    @Binding var showingTexturePacksSheet: Bool
    @Binding var showingSkinMakerSheet: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var showRefillToast: Bool = false
    @State private var showingShadersSheet: Bool = false

    @ObservedObject private var themeMgr = MenuThemeManager.shared

    var body: some View {
        let theme = themeMgr.currentTheme

        GameMenuContainer(
            title: "SETTINGS & OPTIONS",
            subtitle: "Themes, Graphics, Controls & Sound",
            icon: "gearshape.fill",
            onDismiss: { dismiss() }
        ) {
            // 1. In-game Session Card
            if world.isInGame {
                GameCard(title: "GAME SESSION", icon: "gamecontroller.fill", badge: "IN WORLD") {
                    VStack(spacing: 8) {
                        GameButton(title: "Resume Game", subtitle: "Return to your voxel world", icon: "play.fill", color: .green, isProminent: true) {
                            dismiss()
                        }

                        GameButton(title: "Save & Leave to Menu", subtitle: "Auto-saves world and exits to main menu", icon: "house.fill", color: .red, isDestructive: true) {
                            dismiss()
                            world.leaveToMainMenu()
                        }

                        Button {
                            world.creativeRefill()
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            withAnimation(.spring(response: 0.3)) {
                                showRefillToast = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                withAnimation {
                                    showRefillToast = false
                                }
                            }
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(Color.cyan.opacity(0.25))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: showRefillToast ? "checkmark.circle.fill" : "plus.square.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(showRefillToast ? .cyan : .green)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(showRefillToast ? "REFILLED! (+20 ALL BLOCKS)" : "CREATIVE REFILL (+20 ALL BLOCKS)")
                                        .font(.system(size: 12.5, weight: .black, design: .monospaced))
                                        .foregroundColor(showRefillToast ? .cyan : .white)
                                    Text("Refills hotbar and inventory with all building materials")
                                        .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.70))
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(theme.buttonBackground)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(theme.cardBorder.opacity(0.7), lineWidth: 1.2))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // 2. Menu Themes Card (Applies to all menus even main menu!)
            GameCard(
                title: "🎨 MENU THEMES (ALL MENUS)",
                icon: "paintpalette.fill",
                badge: theme.displayName.uppercased()
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select a theme to customize all menus, including Main Menu, Worlds Menu, Multiplayer, Settings & Skin Maker.")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.white.opacity(0.75))

                    MenuThemePickerView()
                }
            }

            // 3. Creative & Customization Card
            GameCard(title: "CREATIVE & ASSETS", icon: "square.grid.2x2.fill") {
                VStack(spacing: 8) {
                    GameButton(
                        title: "Skin & Texture Maker",
                        subtitle: "Modify PNG pixels on canvas & inspect 3D model",
                        icon: "paintpalette.fill",
                        color: theme.secondaryAccent
                    ) {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            showingSkinMakerSheet = true
                        }
                    }

                    GameButton(
                        title: "Change Character Skin",
                        subtitle: "Equipped: \(world.activeCustomSkin?.name ?? world.selectedSkin.displayName)",
                        icon: "person.crop.artframe",
                        color: theme.primaryAccent
                    ) {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            showingSkinsSheet = true
                        }
                    }

                    GameButton(
                        title: "Texture Packs",
                        subtitle: "Current: \(world.currentTexturePack.displayName)",
                        icon: "cube.fill",
                        color: world.currentTexturePack.themeColor
                    ) {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            showingTexturePacksSheet = true
                        }
                    }

                    if world.isInGame {
                        GameButton(
                            title: "Customize HUD Controls",
                            subtitle: "Drag joystick, buttons & hotbar anywhere",
                            icon: "slider.horizontal.3",
                            color: .yellow
                        ) {
                            dismiss()
                            withAnimation {
                                world.isEditingControls = true
                            }
                        }
                    }
                }
            }

            // 4. Graphics & Display Card
            GameCard(title: "GRAPHICS & DISPLAY", icon: "display") {
                VStack(spacing: 10) {
                    GameSliderRow(
                        title: "Render Distance",
                        icon: "mountain.2.fill",
                        value: Binding(
                            get: { Float(world.renderDistance) },
                            set: { world.setRenderDistance(Int($0)) }
                        ),
                        range: 2...8,
                        step: 1,
                        formatString: "%.0f Chunks"
                    )

                    GameToggleRow(
                        title: "Performance Stabilization",
                        subtitle: "Caps FPS & optimizes streaming for smooth gameplay",
                        icon: "gauge.with.dots.needle.bottom.50percent",
                        isOn: $world.isPerformanceStabilizationEnabled
                    )

                    GameButton(
                        title: "Shaders & Visuals",
                        subtitle: "Active: \(world.currentShader.displayName)",
                        icon: world.currentShader.iconName,
                        color: world.currentShader.themeColor
                    ) {
                        showingShadersSheet = true
                    }
                }
            }

            // 5. Controls & Sensitivity Card
            GameCard(title: "CONTROLS & HUD", icon: "hand.tap.fill") {
                VStack(spacing: 10) {
                    GameSliderRow(
                        title: "Look Sensitivity",
                        icon: "cursorarrow.motionlines",
                        value: Binding(
                            get: { world.controlLayout.lookSensitivity },
                            set: { world.controlLayout.lookSensitivity = $0 }
                        ),
                        range: 0.4...2.5,
                        step: 0.1,
                        formatString: "%.1fx"
                    )

                    GameSliderRow(
                        title: "Movement Speed",
                        icon: "figure.walk",
                        value: $world.controlLayout.movementSpeedMultiplier,
                        range: 0.5...2.0,
                        step: 0.1,
                        formatString: "%.1fx"
                    )

                    GameSliderRow(
                        title: "HUD Opacity",
                        icon: "circle.lefthalf.filled",
                        value: Binding(
                            get: { Float(world.controlLayout.controlOpacity) },
                            set: { world.controlLayout.controlOpacity = Double($0) }
                        ),
                        range: 0.3...1.0,
                        step: 0.05,
                        formatString: "%.0f"
                    )

                    GameToggleRow(
                        title: "Swap Left / Right Controls",
                        subtitle: "Mirror movement joystick and action buttons",
                        icon: "arrow.left.and.right",
                        isOn: $world.controlLayout.swapLeftRight
                    )
                }
            }

            // 6. Audio & Multiplayer Signals Card
            GameCard(title: "AUDIO & SIGNALS", icon: "speaker.wave.2.fill") {
                VStack(spacing: 8) {
                    GameToggleRow(
                        title: "Background Music",
                        subtitle: "Alpha atmospheric retro soundtrack",
                        icon: "music.note",
                        isOn: $world.isMusicEnabled
                    )
                    .onChange(of: world.isMusicEnabled) { enabled in
                        AlphaBackgroundMusic.shared.setEnabled(enabled)
                    }

                    GameToggleRow(
                        title: "Local Multiplayer Signal",
                        subtitle: "Automatically broadcast world on Wi-Fi",
                        icon: "person.2.wave.2.fill",
                        isOn: Binding(
                            get: { world.isMultiplayerEnabled },
                            set: { world.toggleMultiplayerEnabled($0) }
                        )
                    )
                }
            }
        }
        .sheet(isPresented: $showingShadersSheet) {
            ShadersSheet(world: world)
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

    static func dismantleUIView(_ uiView: SCNView, coordinator: Coordinator) {
        coordinator.stopDisplayLink()
    }

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        world.registerSceneView(scnView)
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
        if world.sceneView !== uiView {
            world.registerSceneView(uiView)
        }
        let targetFPS = (world.fpsLimit == 0) ? 0 : world.fpsLimit
        if uiView.preferredFramesPerSecond != targetFPS {
            uiView.preferredFramesPerSecond = targetFPS
            context.coordinator.updateFrameRate()
        }
        let expectedAntialiasing: SCNAntialiasingMode = world.isPerformanceStabilizationEnabled ? .none : .multisampling2X
        if uiView.antialiasingMode != expectedAntialiasing {
            uiView.antialiasingMode = expectedAntialiasing
        }
    }

    @MainActor
    final class Coordinator: NSObject {
        let world: VoxelWorld
        private var lastPanPoint: CGPoint = .zero
        private var displayLink: CADisplayLink?
        private var lastTimestamp: CFTimeInterval = 0
        private static weak var activeCoordinator: Coordinator?

        init(world: VoxelWorld) {
            self.world = world
        }

        func startDisplayLink() {
            // Guarantee only ONE active display link runs across the entire app
            Self.activeCoordinator?.stopDisplayLink()
            Self.activeCoordinator = self

            displayLink?.invalidate()
            displayLink = nil
            lastTimestamp = 0

            let link = CADisplayLink(target: self, selector: #selector(stepFrame(_:)))
            link.add(to: .main, forMode: .common)
            displayLink = link
            updateFrameRate()
        }

        func stopDisplayLink() {
            displayLink?.invalidate()
            displayLink = nil
            lastTimestamp = 0
            if Self.activeCoordinator === self {
                Self.activeCoordinator = nil
            }
        }

        deinit {
            displayLink?.invalidate()
            displayLink = nil
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
