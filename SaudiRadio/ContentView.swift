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

struct RadioStationRowView: View {
    @EnvironmentObject var audioManager: AudioManager
    let station: RadioStation
    @Binding var expandedStationId: RadioStation.ID?
    @State private var isDraggingVolume = false
    
    var isExpanded: Bool { station.id == expandedStationId }
    var isPlaying: Bool { audioManager.currentStation?.id == station.id && audioManager.isPlaying }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Row
            HStack(spacing: 12) {
                Image(systemName: station.imageSystemName)
                    .font(.title2)
                    .foregroundColor(.saudiGreen)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.saudiGreen.opacity(0.1)))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(station.nameEnglish)
                        .font(.headline)
                    Text(station.nameArabic)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.easeInOut, value: isExpanded)
            }
            .padding(12)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring()) {
                    expandedStationId = isExpanded ? nil : station.id
                }
            }
            
            // Expanded Controls
            if isExpanded {
                VStack(spacing: 16) {
                    // Play/Pause Button
                    Button {
                        isPlaying ? audioManager.pause() : audioManager.play(station: station)
                    } label: {
                      if #available(iOS 17.0, *) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                          .font(.system(size: 42))
                          .foregroundColor(.saudiGreen)
                          .symbolEffect(.bounce, value: isPlaying)
                      } else {
                        // Fallback on earlier versions
                      }
                    }
                    
                    // Volume Controls
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.fill")
                        Slider(value: $audioManager.volume, in: 0...1)
                        Image(systemName: "speaker.wave.3.fill")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 12)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isPlaying ? Color.saudiGreen.opacity(0.05) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isPlaying ? Color.saudiGreen : Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.3), value: isPlaying)
    }
}

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
	@AppStorage("colorScheme") private var selectedColorScheme: UIUserInterfaceStyle = .unspecified

	var body: some View {
		NavigationView {
			Form {
				Section(header: Text("Appearance")) {
					Picker("Theme", selection: $selectedColorScheme) {
						Text("System").tag(UIUserInterfaceStyle.unspecified)
						Text("Light").tag(UIUserInterfaceStyle.light)
						Text("Dark").tag(UIUserInterfaceStyle.dark)
					}
					.pickerStyle(.segmented)
				}
			}
			.navigationTitle("Settings")
		}
		.navigationViewStyle(.stack)
		.preferredColorScheme({
			switch selectedColorScheme {
			case .light: return .light
			case .dark: return .dark
			default: return nil
			}
		}())
	}
}

// ... Rest of the code remains the same ...
