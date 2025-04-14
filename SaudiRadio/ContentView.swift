import SwiftUI
import AVFoundation
import Combine

// --- Add Color extension here ---
// REMOVED: Duplicate definition moved to dedicated file (e.g., AppColor.swift)
/*
extension Color {
	static let saudiGreen = Color(red: 0.11, green: 0.36, blue: 0.21) // Define Saudi Green Color
}
*/
// --- End of Color extension ---

#if os(iOS)
import UIKit
#endif

struct ContentView: View {
	@EnvironmentObject var audioManager: AudioManager
	@Environment(\.colorScheme) var colorScheme
	@State private var selectedTab: Tab = .saudi
	@State private var expandedStationId: RadioStation.ID? = nil // NEW: Tracks expanded row

	enum Tab { 
        case saudi
        case world
        case settings
    }
	var backgroundGradient: LinearGradient { 
        if colorScheme == .dark {
            return LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.95), Color.gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
        } else {
            return LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
        }
     }

	var body: some View {
		ZStack(alignment: .bottom) {
			backgroundGradient
				.ignoresSafeArea()

			TabView(selection: $selectedTab) {
				// Pass binding to expanded ID
				SaudiStationsView(expandedStationId: $expandedStationId)
					.tabItem { Label("Saudi", systemImage: "radio") }
					.tag(Tab.saudi)

				// Pass simplified padding (or none if placeholders don't need it)
				WorldStationsView()
					.tabItem { Label("World", systemImage: "globe.americas.fill") }
					.tag(Tab.world)

				SettingsView()
					.tabItem { Label("Settings", systemImage: "gear") }
					.tag(Tab.settings)
			}
			.accentColor(.saudiGreen)

			// REMOVED: MiniPlayerView instance is gone
		}
		.environmentObject(audioManager)
		// REMOVED: .onReceive modifiers for showMiniPlayer are gone
	}
}

// MARK: - Tab Content Views

struct SaudiStationsView: View {
	@EnvironmentObject var audioManager: AudioManager
	@Binding var expandedStationId: RadioStation.ID? // CHANGED: Now binding to ID?
	// REMOVED: showMiniPlayer binding and bottomPadding property

	var body: some View {
		NavigationView { 
			ScrollView {
				LazyVStack(spacing: 12) {
					ForEach(RadioStation.sampleStations) { station in
						// Pass binding down to each row
						RadioStationRowView(station: station,
											expandedStationId: $expandedStationId)
							// REMOVED: Tap gesture from here
					}
				}
				.padding(.horizontal)
				// Simplified bottom padding - only for TabBar
				.padding(.bottom, 60) // Adjust as needed
			}
			.navigationTitle("Saudi Stations")
			.navigationBarTitleDisplayMode(.large)
		}
		.navigationViewStyle(.stack)
	}
}

// Placeholder Views - Remove bottomPadding parameter if no longer needed
struct WorldStationsView: View {
	var body: some View {
		NavigationView {
			Text("World Radio Stations Coming Soon!")
				.navigationTitle("World Radio")
				// REMOVED: Padding
		}
		.navigationViewStyle(.stack)
	}
}

struct SettingsView: View {
	var body: some View {
		NavigationView {
			Text("App Settings Coming Soon!")
				.navigationTitle("Settings")
				// REMOVED: Padding
		}
		.navigationViewStyle(.stack)
	}
}


struct RadioStationRowView: View {
	@EnvironmentObject var audioManager: AudioManager // Get AudioManager
	let station: RadioStation
	@Binding var expandedStationId: RadioStation.ID? // Binding to track expansion state
	@Environment(\.colorScheme) var colorScheme

	// Gesture state
	@GestureState private var dragOffset: CGSize = .zero
	@State private var isDraggingVolume = false // To potentially change UI during drag
	// Store initial volume when drag starts to calculate delta more reliably
	@State private var initialVolumeOnDrag: Float? = nil

	// Check if this specific row is the one currently expanded
	var isExpanded: Bool {
		station.id == expandedStationId
	}

	// Check if this station is the one currently playing
	var isPlaying: Bool {
		audioManager.currentStation?.id == station.id && audioManager.isPlaying
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 0) { // Use VStack for main content + controls
			// --- Main Row Content ---
      if #available(iOS 15.0, *) {
        HStack(spacing: 15) {
          Image(systemName: station.imageSystemName)
            .font(.title2)
            .frame(width: 40, height: 40)
            .foregroundColor(.saudiGreen) // Use the theme color
            .background(Circle().fill(Color.saudiGreen.opacity(0.1))) // Subtle background
          
          VStack(alignment: .leading) {
            Text(station.nameEnglish)
              .font(.headline)
              .fontWeight(.medium)
            Text(station.nameArabic)
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
          .lineLimit(1)
          
          Spacer() // Push content left
          
          // Optional: Add a subtle chevron or indicator?
          Image(systemName: "chevron.down")
            .font(.caption.weight(.bold))
            .foregroundColor(.secondary.opacity(0.5))
            .rotationEffect(.degrees(isExpanded ? 180 : 0)) // Rotate chevron when expanded
          
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(.regularMaterial) // Use material background
        // Apply highlight modifier based on PLAYING state, not expanded state
        .modifier(PlayingStationHighlightModifier(isPlaying: audioManager.currentStation?.id == station.id))
        .contentShape(Rectangle()) // Make the HStack tappable
        .onTapGesture { // --- Tap Gesture to Expand/Collapse ---
          withAnimation(.easeInOut(duration: 0.3)) { // Animate the change
            if isExpanded {
              expandedStationId = nil // Collapse if tapped while expanded
              // Optional: Decide if tapping expanded row should stop playback?
              // if isPlaying { audioManager.stop() }
            } else {
              expandedStationId = station.id // Expand this row
              // Optional: Start playing immediately on expand? Or wait for button press?
              // audioManager.play(station: station)
            }
          }
        }
      } else {
        // Fallback on earlier versions
      }

			// --- Expanded Controls Area (Conditional) ---
			if isExpanded {
				VStack(spacing: 8) { // Use VStack to place progress bar below button, added spacing
					HStack {
						Spacer() // Push controls to the right or center as desired

						// Play/Pause Button
						Button {
							if isPlaying {
								audioManager.pause()
							} else {
								// If it's expanded but not playing, or playing a different station
								audioManager.play(station: station)
							}
						} label: {
							Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
								.font(.system(size: 35)) // Larger control button
								.foregroundColor(.saudiGreen)
						}
						.buttonStyle(.plain) // Use plain style to avoid default button background/borders

						Spacer()
					}

					// --- Volume Control Area ---
					HStack(spacing: 8) { // Added spacing
						 Image(systemName: "speaker.fill")
							.foregroundColor(.secondary)
						 // Visual feedback for volume
						 ProgressView(value: audioManager.volume)
							.progressViewStyle(LinearProgressViewStyle(tint: .saudiGreen))
                            // Give it a bit more vertical space if needed
                            .padding(.vertical, 4)
                            // Add slight scale effect when dragging for feedback
                            .scaleEffect(isDraggingVolume ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: isDraggingVolume)

						 Image(systemName: "speaker.wave.3.fill")
							 .foregroundColor(.secondary)
					}
					.font(.caption)
					.padding(.horizontal, 20)
					 // --- Add Drag Gesture Here ---
                    .contentShape(Rectangle()) // Make the whole HStack draggable area
					.gesture(DragGesture(minimumDistance: 5, coordinateSpace: .local)
						.updating($dragOffset) { value, state, _ in
							 state = value.translation
						}
						.onChanged { value in
							 // Store initial volume only on the first change event of a drag
                            if !isDraggingVolume {
                                isDraggingVolume = true
                                initialVolumeOnDrag = audioManager.volume
                            }

                            // Use the stored initial volume for calculation
                            guard let startVolume = initialVolumeOnDrag else { return }

							let sensitivity: CGFloat = 200
							let deltaVolume = Float(value.translation.width / sensitivity)
							let targetVolume = startVolume + deltaVolume

							audioManager.setVolume(targetVolume)
						}
						 .onEnded { _ in
							 // Reset drag state
                            isDraggingVolume = false
                            initialVolumeOnDrag = nil
						}
					) // End Gesture

				} // End Controls VStack
				.padding(.vertical, 10) // Increased padding
				.padding(.horizontal)
				.background(Color.secondary.opacity(0.1))
				.transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
			} // End if isExpanded
		} // End Main VStack
		.clipShape(RoundedRectangle(cornerRadius: 12)) // Clip the whole VStack
		.overlay( // Add subtle border
			RoundedRectangle(cornerRadius: 12)
				.stroke(Color.secondary.opacity(0.2), lineWidth: 1)
		)
		// Apply overall animation to the row for changes like highlight
		.animation(.easeInOut, value: audioManager.currentStation?.id)
	}
}

// Helper for rounding specific corners (useful for MiniPlayer)
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct PlayingStationHighlightModifier: ViewModifier {
	let isPlaying: Bool
	@Environment(\.colorScheme) var colorScheme // Access colorScheme for shadow

	func body(content: Content) -> some View {
    if #available(iOS 15.0, *) {
      content
        .background(.regularMaterial) // Base background
        .overlay( // Conditional overlay
          RoundedRectangle(cornerRadius: 10)
            .fill(Color.saudiGreen.opacity(isPlaying ? 0.1 : 0))
        )
        .cornerRadius(10) // Apply corner radius after background and overlay
        .shadow(color: colorScheme == .dark ? .white.opacity(0.05) : .black.opacity(0.08), radius: 5, x: 0, y: 2)
    } else {
      // Fallback on earlier versions
    }
			// Animation is applied where the modifier is used, triggered by the value change
	}
}

extension View {
	func playingHighlight(isPlaying: Bool) -> some View {
		self.modifier(PlayingStationHighlightModifier(isPlaying: isPlaying))
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AudioManager()) // Ensure AudioManager is provided
    }
}
