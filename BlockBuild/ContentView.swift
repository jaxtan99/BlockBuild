import SwiftUI
import SceneKit
import UIKit

struct ContentView: View {
    @StateObject private var world = VoxelWorld()
    @State private var joystickOffset: CGSize = .zero
    @State private var showingWorldsSheet = false
    @State private var showingMultiplayerSheet = false

    // Temporary drag states while dragging HUD elements in Edit Controls mode
    @State private var dragJoyDelta: CGSize = .zero
    @State private var dragHotbarDelta: CGSize = .zero
    @State private var dragActionDelta: CGSize = .zero
    @State private var dragVerticalDelta: CGSize = .zero

    var body: some View {
        ZStack {
            // 1. 3D Voxel World View + Look Drag Gesture
            VoxelSceneView(world: world)
                .ignoresSafeArea()

            // 2. Center Crosshair & Target Indicator
            VStack(spacing: 6) {
                ZStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.92))
                        .frame(width: 18, height: 2)
                    Rectangle()
                        .fill(Color.white.opacity(0.92))
                        .frame(width: 2, height: 18)
                }
                .shadow(color: .black.opacity(0.85), radius: 2)

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
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(6)
                }
            }
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

                    Button {
                        world.creativeRefill()
                    } label: {
                        Label("+Blocks", systemImage: "plus.square.fill")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 7)
                            .background(Color.green.opacity(0.82))
                            .cornerRadius(8)
                    }

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            world.isEditingControls.toggle()
                        }
                    } label: {
                        Label(world.isEditingControls ? "Done HUD" : "Controls", systemImage: "slider.horizontal.3")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 7)
                            .background(world.isEditingControls ? Color.yellow.opacity(0.88) : Color.indigo.opacity(0.85))
                            .cornerRadius(8)
                    }

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

                    Button {
                        showingWorldsSheet = true
                    } label: {
                        Label("Worlds", systemImage: "globe.americas.fill")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 7)
                            .background(Color.orange.opacity(0.85))
                            .cornerRadius(8)
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
        .defersSystemGestures(on: .all)
        .onAppear {
            lockOrientationHorizontal()
        }
        .sheet(isPresented: $showingWorldsSheet) {
            SavedWorldsSheet(world: world)
        }
        .sheet(isPresented: $showingMultiplayerSheet) {
            LocalMultiplayerSheet(world: world)
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
        }
        .scaleEffect(world.controlLayout.joystickScale)
        .opacity(world.controlLayout.controlOpacity)
        .offset(
            x: world.controlLayout.joystickOffsetX + dragJoyDelta.width,
            y: world.controlLayout.joystickOffsetY + dragJoyDelta.height
        )
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if world.isEditingControls {
                        dragJoyDelta = value.translation
                    } else {
                        let maxRadius: CGFloat = 38.0
                        let dx = value.translation.width
                        let dy = value.translation.height
                        let dist = sqrt(dx * dx + dy * dy)
                        let clampedDist = min(dist, maxRadius)
                        let angle = atan2(dy, dx)

                        let cx = cos(angle) * clampedDist
                        let cy = sin(angle) * clampedDist
                        joystickOffset = CGSize(width: cx, height: cy)

                        world.moveInput = CGPoint(
                            x: cx / maxRadius,
                            y: -cy / maxRadius
                        )
                    }
                }
                .onEnded { value in
                    if world.isEditingControls {
                        world.controlLayout.joystickOffsetX += value.translation.width
                        world.controlLayout.joystickOffsetY += value.translation.height
                        dragJoyDelta = .zero
                    } else {
                        withAnimation(.spring(response: 0.2)) {
                            joystickOffset = .zero
                        }
                        world.moveInput = .zero
                    }
                }
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

    private var rightActionCluster: some View {
        VStack(alignment: world.controlLayout.swapLeftRight ? .leading : .trailing, spacing: 9) {
            // Contextual OPEN/CLOSE button when looking at a Door or Trapdoor
            if let target = world.targetedBlockType, target.isToggleable, !world.isEditingControls {
                Button {
                    world.toggleTargetedDoorOrTrapdoor()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: world.isTargetedBlockOpen ? "door.left.hand.closed" : "door.left.hand.open")
                            .font(.system(size: 13, weight: .bold))
                        Text(world.isTargetedBlockOpen ? "CLOSE \(target.displayName.uppercased())" : "OPEN \(target.displayName.uppercased())")
                            .font(.system(size: 10, weight: .heavy, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.yellow)
                    .cornerRadius(10)
                }
            }

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

    var body: some View {
        NavigationStack {
            List {
                Section("Local Wi-Fi & Peer-to-Peer Multiplayer") {
                    Toggle(isOn: Binding(
                        get: { world.isHostingMultiplayer },
                        set: { world.toggleMultiplayerHosting($0) }
                    )) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Host Current World ('\(world.currentWorldName)')")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                            Text("Allows nearby players with BlockBuild on Wi-Fi / Bluetooth to discover and join your world")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
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
                        Text("ONLINE")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.green)
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
                            Label("Disconnect from Multiplayer Session", systemImage: "xmark.circle.fill")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                        }
                    }
                }

                Section("Nearby Local Worlds to Join (\(world.discoveredHosts.count))") {
                    if world.discoveredHosts.isEmpty {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("Searching for nearby players with BlockBuild open on local Wi-Fi / Bluetooth...")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 6)
                    } else {
                        ForEach(world.discoveredHosts) { host in
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(host.worldName)
                                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    Text("Hosted by \(host.peerID.displayName)")
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button {
                                    world.joinDiscoveredHost(host)
                                    dismiss()
                                } label: {
                                    Text("Join World")
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)
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
        scnView.preferredFramesPerSecond = 60
        scnView.antialiasingMode = .multisampling2X

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

    func updateUIView(_ uiView: SCNView, context: Context) {}

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
