# Changelog

All notable changes to the **BlockBuild** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [1.4.8] - 2026-10-18

### Changed
- **Default Movement Speed Set to 5.0x**:
  - Changed default `movementSpeedMultiplier` to `1.0` (which cleanly displays as **`5.0x`** in the settings slider, right in the middle of the `0.5x...10.0x` range).
  - Added automatic migration `blockbuild_speed_v50_migrated` to update existing saved control configurations.
- **Open Door Button Placed Higher by Default**:
  - Moved default `doorButtonOffsetY` from `-90` to **`-180`**, elevating the contextual OPEN/CLOSE door and trapdoor action button well above the UP/DOWN and BREAK/PLACE control cluster to prevent any accidental interference with movement and action buttons.
  - Added automatic migration `blockbuild_door_btn_v2_migrated` for existing layouts.

---

## [1.4.7] - 2026-10-18

### Changed
- **Performance Stabilization Defaults to 60 FPS**:
  - Updated Performance Stabilization to target **60 FPS** by default (previously 30 FPS) while continuing to optimize render distance and chunk streaming.
  - Set default `fpsLimit` to 60 and added automatic migration for existing saved settings.
  - Updated the settings description and picker labels to reflect 60 FPS as the default smooth target.
  - Independent synchronization for antialiasing mode and FPS limit in `updateUIView`.

---

## [1.4.6] - 2026-10-18

### Changed
- **Movement Speed Limit Expanded to 10.0x**:
  - Expanded the Settings slider range for Movement Speed from `0.1...0.4` to `0.1...2.0` (with clean `0.02` step increments), allowing players to adjust movement speed all the way from `0.5x` up to a maximum limit of **`10.0x`** (`2.0 / 0.2 = 10.0x`).
  - Updated physics calculation in `stepPhysics(dt:)` to support multiplier clamping up to `min(10.0, ...)` without throttling higher velocity movement.

---

## [1.4.5] - 2026-10-18

### Changed
- **Default Speed Set to 0.2 (Labeled as 1.0x)**:
  - Adjusted internal `movementSpeedMultiplier` to default to `0.2` in `ControlLayoutConfig` with physics velocity running at the `0.2` base speed.
  - Automatically migrated existing saved settings to the new `0.2` default.
  - In `SettingsSheet`, the speed label displays `movementSpeedMultiplier / 0.2`, so the default `0.2` is cleanly displayed as **`1.0x`** with the slider adjustable from `0.5x` (`0.1`) to `2.0x` (`0.4`).
- **Infinite World Generation for All World Types**:
  - Removed all `halfWorld` boundaries and chunk generation clamps across Standard, Flat World, Sky Islands, Amplified Peaks, and Endless Desert so the procedural world generates infinitely in all directions.
  - Removed horizontal coordinate clamping in `stepPhysics(dt:)`, allowing players to walk, run, and fly infinitely across the world.
  - Enabled dynamic infinite chunk streaming in `updateStreamedChunks` and unrestricted block placement in `placeSelectedBlock()`.
  - Removed boundary limits on water flow simulation.
- **Render Distance Uncoupled from Vertical Y Axis**:
  - Removed distance fog in SceneKit and expanded camera `zFar` to 800.0.
  - Render distance now strictly governs horizontal chunk streaming (`dx`, `dz`), ensuring the full vertical height of towering mountains, sky islands, and void depth is always visible without vertical fog cut-offs or clipping.

---

## [1.4.4] - 2026-10-18

### Added
- **5 Distinct Selectable World Types**:
  - **Standard**: Classic procedural alpha terrain featuring rolling green hills, winding river canyons, monolithic cliffs, beaches, oak forests, and cozy cabins.
  - **Flat World**: Endless level grass building plane (bedrock layer at y=0, 3 dirt layers, grass surface at y=4) with no basins or obstacles, ideal for creative mega-builds.
  - **Sky Islands**: Floating islands suspended high in the sky over the open void with waterfalls cascading into the abyss, wooden cabins, and connecting bridges.
  - **Amplified Peaks**: Towering extreme alpine mountains reaching up to y=36 with dramatic sheer stone cliffs, waterfalls, and high mountain spruce trees.
  - **Endless Desert**: Vast rolling golden sand dunes with underlying sandstone bedrock, dried wood shrubs, and lush hidden water oases ringed with tall palm trees.
- **No Invisible Barrier for Sky Islands**:
  - Completely removed floor barrier and horizontal boundary wall clamping in Sky Islands, allowing full freedom to fly below the floating islands down into the open void.
  - Added safety void catch: falling in walking mode below y < -50 safely respawns the player on the central spawn island with a gentle toast.
  - Enabled unrestricted block placement into the void and across chunk boundaries.
- **Interactive World Type Selector UI**:
  - Added visual selection cards in the "Create New World" section of `SavedWorldsSheet` displaying each world type's SF Symbol icon, title, and descriptive subtitle.
  - Included custom world renaming TextField and one-tap generation button.
- **Full Backward Compatibility & Multiplayer Sync**:
  - Preserves and restores world types seamlessly using `archetypeName` in saved world snapshots.
  - Synchronizes `worldTypeRaw` across local multiplayer peers so joined clients experience the exact same world generation.

---

## [1.4.3] - 2026-10-18

### Added
- **Customizable Door Open/Close Button**: The contextual OPEN/CLOSE Door button is now an independently movable HUD control in the UI Control Settings customizer ("DRAG DOOR BTN"), letting players position it anywhere on screen.
- **Higher Default Door Button Position**: Anchored the door button higher (`y: -90`) by default above the UP/DOWN and BREAK/PLACE buttons so it never interferes with movement, jump, or block interaction controls.
- **Zero-Sticking Joystick Touch Overlay**: Replaced the gameplay `DragGesture` with a high-performance UIKit touch handler (`JoystickTouchOverlay`) implementing `touchesBegan`, `touchesMoved`, `touchesEnded`, and `touchesCancelled`, ensuring touches are always cleanly released even when interrupted by OS gestures or multi-touch transitions.

### Fixed
- **FPS Hiccups Down to 10 FPS**:
  - Offloaded all chunk block-packing, delta serialization, and world encoding in `saveCurrentWorld()` to a background utility queue (`DispatchQueue.global(qos: .utility)`), completely eliminating 50–100ms main thread stalls during autosaves, block placement, and block breaking.
  - Optimized water seam face updates in `updateStreamedChunks` to only refresh blocks adjacent to newly loaded chunks instead of scanning all active water nodes.
  - Upgraded real-time FPS calculation in `stepPhysics(dt:)` to accumulate true frame delta times and apply exponential moving average smoothing, preventing momentary single-frame hitches from dragging the display counter to 10 FPS.
- **Input State Resets on Sheets & Background**: Automatically resets movement velocity and joystick deflection when opening in-game settings, skins, worlds, or multiplayer sheets, or when the app enters the background.

---

## [1.4.2] - 2026-10-18

### Added
- **Generated House SideRoof Corners**: Procedural wooden cabins now automatically generate with `SideRoof` corner blocks at all 4 roof corners of each tier, seamlessly joining orthogonal roof slopes towards the central peak.

### Changed
- **Roof Block Renaming**: Renamed the regular stair roof block to **"EdgeRoof"** (no space) and the corner roof block to **"SideRoof"** (no space) across all inventory, hotbar, and display labels.
- **World Loading Orientations**: Ensured saved worlds and chunk decoders restore orientations for `SideRoof` (`.roofCorner`) alongside `EdgeRoof` (`.roof`).

---

## [1.4.1] - 2026-10-18

### Added
- **Dedicated Corner Roof Block**: Added `.roofCorner` as a separate, selectable block type (ID 13) in the hotbar and inventory with its own quarter-step geometry and rotation based on player facing direction, keeping standard `.roof` blocks strictly uniform without unexpected automatic neighbor mutations.

### Changed
- **30 FPS Performance Stabilization**: Updated "Performance Stabilization" mode to lock the target frame rate to **30 FPS** (formerly 40) alongside 2 chunks render distance for rock-solid stability and battery efficiency.
- **Display-Friendly FPS Limit Options**: Streamlined FPS limit options to clean hardware-synchronized refresh rates (**Unlimited**, **30 FPS (Stable)**, **40 FPS**, and **60 FPS (Smooth)**), eliminating CADisplayLink jitter caused by non-standard refresh intervals.

### Fixed
- **Player Movement Decoupling**: Fixed physics delta-time clamping in `stepPhysics(dt:)` so player walk and fly speeds never artificially slow down during framerate dips or when locked to 30 FPS.
- **Movement Freezes & Hitching**: Completely eliminated periodic movement freezes by moving world JSON serialization and disk persistence to a background utility queue (`DispatchQueue.global(qos: .utility)`) and preventing procedural chunk streaming from marking unnecessary unsaved changes.
- **iOS 16 Compatibility**: Fixed `.onChange` modifiers in `ContentView.swift` to ensure seamless backwards compatibility across iOS 16 and iOS 17+.

---

## [1.4.0] - 2026-10-18

### Added
- **Configurable FPS Limit**: Added a dedicated FPS limit setting under Settings -> Display & Performance offering Unlimited, 30, 35, 40, 45, 50, 55, and 60 FPS options.
- **Performance Stabilization Mode**: Renamed and upgraded the stabilization setting to "Performance Stabilization"; when enabled, automatically locks FPS to 40, sets render distance to 2 chunks, and applies movement and streaming optimizations for butter-smooth gameplay.

### Changed
- **Render Distance Limit (2 to 8 Chunks)**: Reduced maximum render distance limit from 16 to 8 chunks (20m to 80m view distance) to prevent out-of-memory crashes while maintaining distant scenery.
- **Avatar Forward Alignment (Head & Torso)**: Wrapped player avatar limbs in an oriented container rotated 180° around the Y-axis so that both the head and torso face forward in the player's walk and look direction.
- **Textured Shoulders Across All Skins**: Regenerated all 14 Minecraft skin PNG files with textured arm and shoulder tops, and added robust fallback color rendering in `SkinTextureManager` so shoulders are never transparent or missing.
- **Corner-Only Roof Block Steps**: Refined roof block geometry so that the half-top quarter step triggers **only** at genuine orthogonal L-corners, leaving straight 1-row roof lines as clean, standard angled roof blocks.

### Fixed
- **Movement Lag Spikes**: Eliminated movement stutter by:
  - Removing full world serialization from player movement coordinates so disk saves no longer fire periodically while simply walking or flying.
  - Wrapping chunk loading and unloading in atomic `SCNTransaction` blocks.
  - Restricting water seam updates to rendered block nodes rather than the full world dictionary.

---

## [1.3.1] - 2026-10-18

### Changed
- **Main Menu UI Cleanup**: Removed duplicate purple "SKINS" button from the main menu action grid. The equipped skin preview pill at the top of the menu continues to provide one-tap access to character skin customization, and "MULTIPLAYER" now matches full-width styling alongside "PLAY WORLDS" and "SETTINGS".
- **Single UI Controls Save Button**: Removed duplicate save/dismiss controls in the HUD layout customizer (removed redundant "xmark" close button in the banner and duplicate "DONE / PLAY" button in the top bar), leaving a single, prominent "SAVE & PLAY" action to commit layout changes.

---

## [1.3.0] - 2026-10-18

### Added
- **Configurable Render Distance Setting**: Added in-game slider under Settings -> Display & Performance allowing players to customize chunk render distance between 2 and 16 chunks (20m to 160m). Dynamically recalculates camera far clipping plane and atmospheric fog, and persists choice across sessions in `UserDefaults`.
- **Authentic Minecraft PNG Skin Textures**: Generated clean 64x64 pixel-art skin PNG files for all 14 skins bundled into the asset catalog and `BlockBuild/Skins/`.
- **SkinTextureManager**: High-performance texture manager that loads skin PNGs and maps UV faces with nearest-neighbor interpolation to clean standard Minecraft-proportioned body limbs.

### Changed
- **Non-Creepy Player Avatars**: Replaced protruding 3D box accessories with smooth, authentic Minecraft character models textured directly from standard PNG files.
- **2D Pixel Art Skin Previews**: `CharacterAvatarPreview` in the Skins sheet now renders directly from the skin PNG file with nearest-neighbor pixel scaling.

### Fixed
- **Roof Corner / Between-Row Steps**: Fixed corner and between-row detection so the special half-top step (`roofCornerStepGeo`) triggers whenever a roof block is between roof blocks, including within a single row (along X or Z), at L-corners, and at sloped intersections.

---

## [1.2.0] - 2026-10-18

### Added
- **Expanded Character Skins Roster**: Added 6 new skins (`Shadow Ninja`, `Sea Pirate`, `Nordic Viking`, `Cyberpunk`, `Nether Lord`, and `Arctic Ranger`), expanding the playable roster to 14 skins.
- **Rich 3D Avatar Texture Features**:
  - Independent left and right legs with layered boots/footwear cuffs.
  - Left and right arms with shirt/armor sleeves, skin-tone hands, and shoulder pauldrons.
  - Waistband belt with metallic accent buckle and torso core emblems.
  - 3D facial details with white sclera and colored pupils, or pirate eyepatch.
  - Skin-specific 3D accessories: Miner hardhat lamp with glow emission, Knight visor slit, Ninja cloth mask, Viking and Nether horns, Wizard spire, Astronaut life-support backpack, Arctic fur hood, and Cyberpunk neon ocular implant.
- **Enhanced 2D Avatar Previews**: Upgraded `CharacterAvatarPreview` across the Skin Customization sheet and settings to show full textured limbs, boots, belts, facial eyes, and accessories.
- **Directional Roof Blocks**: Roof blocks now calculate placement orientation based on player camera yaw (North, South, East, West).
- **Corner Roof Blocks**: Automatic detection and rendering of 3D half-step corner roof blocks when nestled between orthogonal roof blocks.
- **Slab Blocks**: Added new `.slab` block type textured directly off the roof block for eaves and flat roofs.
- **House Roof Generation**: Procedural village houses now generate with authentic angled roof blocks and slab peaks.
- **HUD Layout Save Button**: Added a dedicated "Save & Done" button in HUD layout customization mode to cleanly commit UI control positions and resume gameplay.
- **Multiplayer Bonjour Configuration**: Added `Info.plist` with Bonjour service definitions (`_blockbuild._tcp`, `_blockbuild._udp`) and local network / Bluetooth usage descriptions.

### Changed
- **Multiplayer Nametag Cleanup**: Floating player billboard nametags now display **only** the username, removing the skin name label.
- **Centered Nametag Positioning**: Positioned remote player nametags directly on top of the character's head with dynamic height clearance for hats and horns.
- **Simplified Block Names**:
  - `Wood Log` -> `logs`
  - `Wood Planks` -> `planks`
  - `Smooth Stone` -> `stone`
  - `Wooden Door` -> `door`
  - `Glass Block` -> `glass`
  - `Grass Block` -> `Grass`
  - `Roof Block` -> `roof`
- **Continuous Multiplayer Broadcasting**: Peer-to-peer advertising and browsing run reliably when in-game with multiplayer enabled.

### Fixed
- Fixed issue where players could not close or save customized UI touch controls.
- Fixed multiplayer connection discovery when searching for nearby hosts on local Wi-Fi.
- Fixed corner gap rendering between perpendicular roof slopes.

---

## [1.1.0] - 2026-10-18

### Added
- **Local Multiplayer System**: Apple MultipeerConnectivity integration for zero-config Wi-Fi multiplayer.
  - Automatic peer discovery and join requests.
  - Real-time block placement/removal delta broadcasting and multi-peer relay.
  - Host-to-client world snapshot replication.
  - Remote player pose synchronization with interpolated motion and 3D avatars.
- **Multiplayer UI**: Join game alerts, peer connection status toasts, and host world browsing.
- **Skin Customization Sheet**: In-game skin picker sheet with real-time avatar previews and persistence.

---

## [1.0.0] - 2026-10-17

### Added
- Initial release of BlockBuild iOS voxel sandbox game.
- Procedural infinite terrain generation with simplex noise, biomes, trees, and structures.
- SceneKit-based 60 FPS voxel engine with greedy chunk meshing and fluid water dynamics.
- Touch controls with dual virtual sticks, camera look gestures, and block interaction.
- World saving and loading with JSON persistence.
