# BlockBuild

A voxel sandbox game built for iOS using **SwiftUI** and **SceneKit**.

## Features

- **3D Voxel World**: Real-time voxel terrain rendering and chunk management powered by SceneKit.
- **Block Manipulation**: Place, break, and interact with blocks in real time.
- **Rich Block Palette**: Cobblestone, Wood Logs, Wood Planks, Leaves, Water, Smooth Stone, Sand, Glass, Doors, Trapdoors, Grass, Dirt, and more.
- **Interactive Blocks**: Functional doors and trapdoors with interactive states.
- **Touch-Optimized Controls**:
  - Virtual movement joystick
  - Smooth look and camera drag gestures
  - Customizable / draggable HUD controls
  - Center crosshair and block targeting indicators
- **World Management**: Save and load multiple voxel worlds.

## Requirements

- **iOS 16.0+**
- **Xcode 15.0+**
- **Swift 5.9+**

## Getting Started

1. Clone the repository:
   ```bash
   git clone git@github.com:jaxtan99/BlockBuild.git
   ```
2. Open the project in Xcode:
   ```bash
   cd BlockBuild
   open BlockBuild.xcodeproj
   ```
3. Select an iOS Simulator or connected iOS device as the run target.
4. Press `Cmd + R` to build and run.

## Project Structure

- `BlockBuild/`: Swift source files and asset catalogs.
  - `BlockBuildApp.swift`: Main application entry point.
  - `ContentView.swift`: Main UI layer, gesture recognizers, HUD, and virtual controls.
  - `VoxelWorld.swift`: World state, chunk generation, and SceneKit scene coordinator.
  - `BlockType.swift`: Block definitions, textures, and properties.
  - `Assets.xcassets`: App icons and visual assets.
- `BlockBuild.xcodeproj`: Xcode project settings and configurations.

## License

This project is open source under the [MIT License](LICENSE).
