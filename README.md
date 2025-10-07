# Jump Space Power Grid Planner

Jump Space Power Grid Planner is a Flutter desktop and web application for planning ship layouts in the game Jump Space. It replicates the power grids produced by in-game reactors and auxiliary generators, and lets you position every ship component by matching the shapes documented in community resources. This is a hobby project maintained for fun; expect occasional rough edges.  

## Features

- Complete data for all reactors, auxiliary generators, sensors, engines, pilot cannons, multi turrets, and special weapons documented in community resources.
- Grid visualizer with protected (blue) and vulnerable (green) power cells.
- Placement validation that ensures components only sit on powered cells.
- Hover previews, rotation shortcuts, and the ability to pick up, move, or delete placed components.
- Continuous outlines and short labels so shapes stay readable even when the grid is crowded.

## Getting Started

### Prerequisites

Install Flutter 3.22 or newer and enable the desktop target you care about (Linux, macOS, or Windows).

```bash
flutter config --enable-linux-desktop    # on Linux
flutter config --enable-macos-desktop    # on macOS
flutter config --enable-windows-desktop  # on Windows
```

### Clone and Build

```bash
git clone https://github.com/insomnolence/jump_space_planner.git
cd jump_space_planner
flutter pub get
```

### Run Locally

```bash
flutter run -d linux     # or macos / windows / chrome
```

### Build Artifacts

```bash
# Linux (bundle in build/linux)
flutter build linux --release

# Windows (bundle in build/windows)
flutter build windows --release

# macOS
flutter build macos --release

# Android APK or App Bundle
flutter build apk --release
flutter build appbundle --release

# Web bundle (output in build/web)
flutter build web --release

- For web distribution, run `flutter build web --release` and serve the contents of `build/web` from any static host.
```

To test the web bundle locally, serve the `build/web` directory with any static server (for example `python3 -m http.server`) and visit `http://localhost:8000`. A hosted build can be shared via GitHub Pages or any static host if you want others to try it in their browser.

## Project Structure

- `lib/models` – core data models (components, reactors, generators, grid state, power cells).
- `lib/services/complete_*` – canonical data sourced from community-maintained component references.
- `lib/screens` – main planner screen, state management, and toolbar controls.
- `lib/widgets` – reusable grid renderer and legend.

The repository includes the derived component and reactor definitions directly, so no additional extraction step is required. Component footprints and power grids are derived from publicly shared gameplay information; special thanks to the authors of https://steamcommunity.com/sharedfiles/filedetails/?id=3572742683 for publishing the reference material.

## Contributing

- Run `flutter analyze` before submitting changes.
- Keep component and generator shapes synchronized with the latest in-game data.

## License

This project is distributed under the MIT License. See the `LICENSE` file for details. Jump Space and related assets remain the property of their respective owners; this planner is an unofficial fan-made companion that uses publicly shared gameplay information.
