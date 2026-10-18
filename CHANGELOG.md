# Changelog

All notable changes to the **BlockBuild** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

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
