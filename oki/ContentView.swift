//
//  ContentView.swift
//  oki
//
//  Created by Viktorija Leimane on 24/12/2025.
//

import SwiftUI
import SwiftData
import UIKit  // For haptic feedback
import AVFoundation  // For audio playback

// MARK: - Custom Color Theme

// Extension to define custom colors for light and dark modes
// iOS best practice: Use Color extensions for app-wide color schemes
extension Color {
    // Custom background color - adapts to light/dark mode
    // Light mode: off-white, Dark mode: dark brown
    static let customBackground = Color(
        light: Color(red: 0.98, green: 0.98, blue: 0.98),  // Off-white for light mode
        dark: Color(red: 0.118, green: 0.078, blue: 0.063)  // #1E1410 - dark brown for dark mode
    )

    // Custom text color
    static let customText = Color(
        light: Color(red: 0.55, green: 0.18, blue: 0.10),  // #8B2E1A
        dark: Color(red: 1.0, green: 0.486, blue: 0.039)  // #ff7c0a - vibrant orange
    )

    // Custom accent color for icons and interactive elements
    static let customAccent = Color(
        light: Color(red: 1.0, green: 0.486, blue: 0.039),  // #ff7c0a - vibrant orange
        dark: Color(red: 1.0, green: 0.486, blue: 0.039)  // #ff7c0a - vibrant orange
    )

    // Helper initializer for light/dark color variants
    // iOS best practice: Use UIColor's dynamic color provider
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor(dynamicProvider: { traits in
            switch traits.userInterfaceStyle {
            case .light, .unspecified:
                return UIColor(light)
            case .dark:
                return UIColor(dark)
            @unknown default:
                return UIColor(light)
            }
        }))
    }
}

// MARK: - Bell Option Enum

// Enum for starting bell options
// iOS best practice: Use enums for mutually exclusive states
enum BellOption: String, CaseIterable {
    case none = "None"
    case vibrate = "Vibrate"
    case bell = "Bell"
    case kru = "Kru"

    // Icon name for each option
    // Can be SF Symbol name OR custom image name from Assets
    var iconName: String {
        switch self {
        case .none:
            return "speaker.slash.fill"
        case .vibrate:
            return "bell.fill"
        case .bell:
            return "bell-icon"  // Custom image name - add bell-icon.png to Assets.xcassets
        case .kru:
            return "kru-icon"   // Custom image name - add kru-icon.png to Assets.xcassets
        }
    }

    // Indicates whether this icon is a custom image (not SF Symbol)
    // iOS best practice: Separate custom assets from system symbols
    var isCustomIcon: Bool {
        switch self {
        case .none, .vibrate:
            return false  // SF Symbols
        case .bell, .kru:
            return true   // Custom images from Assets
        }
    }

    // Sound file name (without extension)
    // Add to Xcode project bundle
    var soundFileName: String? {
        switch self {
        case .bell:
            return "bell-sound"  // Will look for bell-sound.aiff/wav/etc
        case .kru:
            return "kru-sound"   // Will look for kru-sound.aiff/wav/etc
        default:
            return nil
        }
    }
}

struct ContentView: View {
    // MARK: - State Properties

    // @State variables track the currently selected values
    // These update automatically when the user spins the wheels
    // SwiftUI re-renders the view whenever these change

    @State private var selectedHours: Int = 0

    @State private var selectedMinutes: Int = 2

    @State private var selectedSeconds: Int = 0

    // Bell option state - controls whether to vibrate when timer completes
    @State private var selectedBellOption: BellOption = .none

    // Dark mode state - controls color scheme preference
    // iOS best practice: Use @AppStorage for persistent user preferences
    // @AppStorage automatically saves to UserDefaults and loads on app launch
    // Note: Inverted logic for light switch behavior (ON/right = light)
    // true = light mode (default), false = dark mode
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true

    // Navigation state - controls whether we show the countdown timer
    @State private var showingTimer: Bool = false

    // MARK: - Body

    var body: some View {
        // NavigationStack enables navigation to the timer view
        NavigationStack {
            // VStack arranges views vertically (top to bottom)
            VStack(spacing: 20) {
                // MARK: - Dark Mode Toggle

                // HStack to center toggle at the top
                HStack {
                    Spacer()

                    // Custom toggle UI using HStack with icons
                    // iOS best practice: Use SF Symbols for mode indicators
                    // Light switch behavior: ON (right) = Light mode
                    HStack(spacing: 8) {
                        // Dark mode icon (left)
                        Image(systemName: "moon.fill")
                            .foregroundColor(isDarkMode ? Color.customText.opacity(0.3) : .customAccent)
                            .font(.system(size: 18))

                        // Toggle switch
                        // ON (right/true) = Light mode, OFF (left/false) = Dark mode
                        Toggle("", isOn: $isDarkMode)
                            .labelsHidden()
                            .tint(.customAccent)

                        // Light mode icon (right)
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(isDarkMode ? .customAccent : Color.customText.opacity(0.3))
                            .font(.system(size: 18))
                    }

                    Spacer()
                }
                .padding(.top, 10)

                // MARK: - Starting Bell Section

                Text("Starting bell")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.customText)

                // HStack for the four bell options
                // Reduced spacing to fit all options in one row
                HStack(spacing: 12) {
                    // Silent/None option
                    BellOptionButton(
                        option: .none,
                        isSelected: selectedBellOption == .none
                    ) {
                        selectedBellOption = .none
                    }

                    // Vibrate option
                    BellOptionButton(
                        option: .vibrate,
                        isSelected: selectedBellOption == .vibrate
                    ) {
                        selectedBellOption = .vibrate
                    }

                    // Bell sound option
                    BellOptionButton(
                        option: .bell,
                        isSelected: selectedBellOption == .bell
                    ) {
                        selectedBellOption = .bell
                    }

                    // Kru sound option
                    BellOptionButton(
                        option: .kru,
                        isSelected: selectedBellOption == .kru
                    ) {
                        selectedBellOption = .kru
                    }
                }
                .padding(.bottom, 20)

                // MARK: - Duration Section

                // Title to show what we're selecting
                Text("Duration")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.customText)


                // MARK: - The Time Picker Wheels

                // HStack arranges views horizontally (left to right)
                // spacing: 0 puts the wheels right next to each other (like iOS Clock app)
                // Order: Hours (left) → Minutes (middle) → Seconds (right)
                HStack(spacing: 0) {

                    // MARK: - Hours Wheel (LEFT)
                    VStack(spacing: 8) {
                        // Label above the hours wheel
                        Text("hours")
                            .font(.caption)
                            .foregroundColor(.customText.opacity(0.6))

                        // Hours Picker: 0-12
                        // Could potentially increase this range but who meditates more than 12 hours?
                        Picker("Hours", selection: $selectedHours) {
                            ForEach(0...12, id: \.self) { hour in
                                Text("\(hour)")
                                    .font(.title)
                                    .foregroundColor(.customText)
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 150)  // width: 100 gives enough room for 2-digit numbers
                        .clipped()
                    }

                    // MARK: - Minutes Wheel (MIDDLE)
                    VStack(spacing: 8) {
                        // Label above the minutes wheel
                        Text("minutes")
                            .font(.caption)
                            .foregroundColor(.customText.opacity(0.6))

                        // Minutes Picker: 0-59
                        Picker("Minutes", selection: $selectedMinutes) {
                            ForEach(0...59, id: \.self) { minute in
                                Text("\(minute)")
                                    .font(.title)
                                    .foregroundColor(.customText)
                                    .tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 150)
                        .clipped()
                    }

                    // MARK: - Seconds Wheel (RIGHT)
                    VStack(spacing: 8) {
                        // Label above the seconds wheel
                        Text("seconds")
                            .font(.caption)
                            .foregroundColor(.customText.opacity(0.6))

                        // Seconds Picker: 0, 10, 20, 30, 40, 50
                        Picker("Seconds", selection: $selectedSeconds) {
                            ForEach(Array(stride(from: 0, through: 50, by: 10)), id: \.self) { second in
                                Text("\(second)")
                                    .font(.title)
                                    .foregroundColor(.customText)
                                    .tag(second)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 150)
                        .clipped()
                    }
                }

                // MARK: - Play Button

                // NavigationLink presents the timer view when tapped
                // iOS best practice: Use SF Symbols for consistent icon design
                Button(action: {
                    showingTimer = true
                }) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.customAccent)
                        .clipShape(Circle())
                }
                .padding(.top, 30)  // Add space between wheels and button
            }
            .padding()  // Adds spacing around the entire VStack
            // NavigationDestination: When showingTimer is true, navigate to TimerView
            .navigationDestination(isPresented: $showingTimer) {
                TimerView(
                    hours: selectedHours,
                    minutes: selectedMinutes,
                    seconds: selectedSeconds,
                    bellOption: selectedBellOption,
                    isDarkMode: isDarkMode  // Pass dark mode state to timer view
                )
            }
        }
        // Apply background to entire screen including safe areas
        // iOS best practice: Use ignoresSafeArea() for full-screen backgrounds
        .background(Color.customBackground.ignoresSafeArea())
        // iOS best practice: Use .preferredColorScheme() to override system appearance
        // This respects Apple's Dark Mode implementation
        // Inverted logic: true = light mode, false = dark mode
        .preferredColorScheme(isDarkMode ? .light : .dark)
    }
}

// MARK: - Bell Option Button

// Reusable button component for bell options
// iOS best practice: Extract reusable UI components
struct BellOptionButton: View {
    let option: BellOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Icon - either SF Symbol or custom image from Assets
                // iOS best practice: Conditional view based on icon type
                if option.isCustomIcon {
                    // Custom image from Assets.xcassets
                    Image(option.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(isSelected ? .customAccent : Color.customText.opacity(0.4))
                } else {
                    // SF Symbol
                    Image(systemName: option.iconName)
                        .font(.system(size: 30))
                        .foregroundColor(isSelected ? .customAccent : Color.customText.opacity(0.4))
                }

                // Option label
                Text(option.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .customAccent : Color.customText.opacity(0.6))
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.customAccent.opacity(0.15) : Color.clear)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.customAccent : Color.customText.opacity(0.2), lineWidth: 2)
            )
        }
    }
}

// MARK: - Timer View

// This view displays the countdown timer
// Conforms to AVAudioPlayerDelegate to detect when sound finishes playing
struct TimerView: View, @unchecked Sendable {
    // The initial time values passed from ContentView
    let hours: Int
    let minutes: Int
    let seconds: Int
    let bellOption: BellOption
    let isDarkMode: Bool  // Dark mode preference from ContentView

    // State for the countdown
    // @State lets us modify these values as the timer counts down
    @State private var remainingSeconds: Int = 0

    // Timer that fires every second
    // The timer will update remainingSeconds every second
    @State private var timer: Timer?

    // Tracks whether the timer is paused
    // iOS best practice: Use a single boolean state for play/pause toggle
    @State private var isPaused: Bool = false

    // Audio player for sound playback
    // iOS best practice: Use @State for mutable objects that affect UI
    @State private var audioPlayer: AVAudioPlayer?

    // Coordinator to handle audio player delegate callbacks
    @State private var audioDelegate: AudioPlayerDelegate?

    // Environment value to dismiss this view (go back to ContentView)
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 40) {
            // MARK: - Countdown Display

            // Display remaining time in HH:MM:SS format
            // This updates every second as the timer counts down
            Text(formattedTime)
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(.customText)
                .monospacedDigit()  // Keeps digits the same width

            // MARK: - Pause/Play Button

            // iOS best practice: Use SF Symbols for system icons
            // Single button that toggles between pause and play states
            Button(action: {
                togglePauseResume()
            }) {
                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.customAccent)
                    .clipShape(Circle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.customBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(false)  // Show back button to return to duration picker
        // onAppear runs when this view first appears
        .onAppear {
            startTimer()
        }
        // onDisappear runs when leaving this view
        .onDisappear {
            stopTimer()
        }
        // Apply same color scheme as ContentView
        // Inverted logic: true = light mode, false = dark mode
        .preferredColorScheme(isDarkMode ? .light : .dark)
    }

    // MARK: - Helper Functions

    // Converts hours, minutes, seconds to total seconds
    // Called when view appears to set up initial countdown value
    private func startTimer() {
        // Calculate total seconds from hours, minutes, seconds
        remainingSeconds = (hours * 3600) + (minutes * 60) + seconds

        // Create a timer that fires every 1 second
        // Timer.publish creates a publisher that emits events on a schedule
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Only decrement if not paused
            // iOS best practice: Check state before modifying
            if !isPaused && remainingSeconds > 0 {
                remainingSeconds -= 1  // Decrease by 1 second
            } else if remainingSeconds == 0 {
                // Timer finished - stop the timer
                stopTimer()

                // Trigger feedback based on selected bell option
                // iOS best practice: Different feedback types for different options
                switch bellOption {
                case .vibrate:
                    // Haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    // Dismiss after brief delay for vibration to complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }

                case .bell, .kru:
                    // Play sound file (works for both bell-sound and kru-sound)
                    // The playSound() function uses bellOption.soundFileName to get the right file
                    // Will auto-dismiss when sound finishes via delegate
                    playSound()

                case .none:
                    // No feedback - dismiss immediately
                    dismiss()
                }
            }
        }
    }

    // Stops and cleans up the timer
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // Toggles between pause and resume states
    // iOS best practice: Single function for toggle behavior
    private func togglePauseResume() {
        isPaused.toggle()  // Flip the boolean: true -> false, false -> true
        // Timer continues running but checks isPaused before decrementing
        // This is more efficient than stopping/starting timer
    }

    // Plays the completion sound
    // iOS best practice: Use AVAudioPlayer for local audio files
    private func playSound() {
        guard let soundFileName = bellOption.soundFileName else { return }

        // Try to find the sound file in the bundle
        // Supports multiple audio formats (prioritizing lossless)
        // Order: AIFF → WAV → ALAC → FLAC → MP3
        let formats = ["aiff", "aif", "wav", "m4a", "flac", "mp3"]

        for format in formats {
            if let soundURL = Bundle.main.url(forResource: soundFileName, withExtension: format) {
                do {
                    // Create audio player with the sound file
                    audioPlayer = try AVAudioPlayer(contentsOf: soundURL)

                    // Create delegate to handle completion and dismissal
                    audioDelegate = AudioPlayerDelegate(onFinish: {
                        dismiss()
                    })
                    audioPlayer?.delegate = audioDelegate
                    audioPlayer?.play()
                    return  // Successfully loaded and playing
                } catch {
                    // If this format fails, try next format
                    print("Could not play \(format) format: \(error.localizedDescription)")
                }
            }
        }

        // No supported format found in bundle - dismiss anyway
        print("Sound file '\(soundFileName)' not found in any supported format")
        dismiss()
    }

    // Formats remainingSeconds into MM:SS or HH:MM:SS string
    // This computed property recalculates whenever remainingSeconds changes
    private var formattedTime: String {
        let hours = remainingSeconds / 3600  // 3600 seconds in an hour
        let minutes = (remainingSeconds % 3600) / 60  // Remaining seconds / 60
        let seconds = remainingSeconds % 60  // Leftover seconds

        // Conditional formatting:
        // If hours == 0: show MM:SS (e.g., "05:30")
        // If hours > 0: show HH:MM:SS (e.g., "02:05:30")
        if hours == 0 {
            return String(format: "%02d:%02d", minutes, seconds)
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
}

// MARK: - Audio Player Delegate

// Delegate class to handle AVAudioPlayer completion events
// iOS best practice: Use NSObject-based delegate for Objective-C protocols
class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    // Called when audio playback finishes successfully
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
