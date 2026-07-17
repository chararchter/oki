# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`oki` is a minimal iOS meditation timer app built with SwiftUI. The user picks a starting bell/vibration option and a duration (hours/minutes/seconds wheels), then runs a countdown that fires the selected feedback (vibration or a sound) on completion.

## Build, run, and test

This is a standard Xcode project (`oki.xcodeproj`), no SPM/CocoaPods dependencies. Requires a full Xcode install (`xcode-select -p` should point at `/Applications/Xcode.app/...`, not just the Command Line Tools) for `xcodebuild` to work.

```bash
# Build for the simulator
xcodebuild -project oki.xcodeproj -scheme oki -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run all tests (unit + UI)
xcodebuild -project oki.xcodeproj -scheme oki -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single test (Swift Testing target, okiTests)
xcodebuild -project oki.xcodeproj -scheme oki -destination 'platform=iOS Simulator,name=iPhone 16' test \
  -only-testing:okiTests/okiTests/example

# Run a single UI test (XCTest target, okiUITests)
xcodebuild -project oki.xcodeproj -scheme oki -destination 'platform=iOS Simulator,name=iPhone 16' test \
  -only-testing:okiUITests/okiUITests/testExample
```

Otherwise open `oki.xcodeproj` in Xcode and use Product > Run / Test (Cmd+U), or Cmd+U on a single test via the diamond gutter icon.

- `okiTests` uses the new Swift `Testing` framework (`@Test`, `#expect`).
- `okiUITests` uses `XCTest`/`XCUIApplication` for UI-level tests.
- Deployment target: iOS 26.2. Swift version 5.0. Bundle id `vika.oki`.

## Architecture

The entire app lives in `oki/` and is small enough to hold in your head at once:

- **`okiApp.swift`** — `@main` entry point. Sets up a SwiftData `ModelContainer` for the `Item` schema and injects it into the view hierarchy. Note: this SwiftData container is unused Xcode-template boilerplate — the app does not otherwise read or write `Item`/`ModelContext` anywhere. All real app state is `@State`/`@AppStorage`, not SwiftData.
- **`ContentView.swift`** — contains essentially the whole app in one file:
  - A `Color` extension providing a light/dark-adaptive warm color palette (`customBackground`, `customText`, `customAccent`) via a `UIColor(dynamicProvider:)` helper initializer.
  - `BellOption` enum — the four starting-bell choices (`none`, `vibrate`, `bell`, `kru`), each mapping to an SF Symbol or a custom Assets.xcassets image, and (for `bell`/`kru`) a bundled sound file name.
  - `ContentView` — the home screen: dark/light mode toggle (persisted via `@AppStorage("isDarkMode")`), bell option picker, hour/minute/second wheel pickers, and the running session counter (`@AppStorage("sessionsToday")`/`"lastSessionDate"`, reset when the stored date differs from today). Navigates to `TimerView` via `NavigationStack` + `navigationDestination`.
  - `BellOptionButton` — reusable button view for the four bell choices.
  - `TimerView` — the countdown screen. Owns a `Timer.scheduledTimer` ticking every second, pause/resume via a single `isPaused` flag, and on completion calls the `onSessionComplete` callback then triggers feedback per `bellOption` (haptic via `UINotificationFeedbackGenerator`, or `AVAudioPlayer` playback trying multiple audio formats in order — aiff, aif, wav, m4a, flac, mp3). Dismisses itself back to `ContentView` when feedback finishes.
  - `AudioPlayerDelegate` — small `NSObject`/`AVAudioPlayerDelegate` shim used only to get an `onFinish` closure callback from `AVAudioPlayer`.
- **`Item.swift`** — the unused SwiftData model left from the project template (see note above).
- **Assets** — `Assets.xcassets` holds `AppIcon`, `AccentColor`, and the custom `bell-icon`/`kru-icon` images referenced by `BellOption.iconName`. `Sounds/bell-sound.wav` and `Sounds/kru-sound.wav` are the bundled completion sounds referenced by `BellOption.soundFileName`.

### State flow

State is intentionally simple and flows one direction, screen to screen — there's no shared app-wide state container:

1. `ContentView` owns the picker selections (`selectedHours/Minutes/Seconds`, `selectedBellOption`) as local `@State`.
2. `isDarkMode` and the session counter (`sessionsToday`/`lastSessionDate`) are persisted directly via `@AppStorage`, read/written from both `ContentView` (display/reset logic) and passed into `TimerView` (dark mode) or invoked via callback (`onSessionComplete`) from `TimerView` back into `ContentView`.
3. On play, those values are passed as `let` constants into `TimerView`, which runs its own independent countdown and feedback lifecycle and calls `dismiss()` to pop back when done.

When adding a new bell/feedback option, extend the `BellOption` enum (case, `iconName`, `isCustomIcon`, `soundFileName`) — `ContentView`'s button row and `TimerView`'s completion `switch` both key off it.
