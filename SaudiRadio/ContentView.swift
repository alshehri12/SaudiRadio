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
				SaudiStationsView(expandedStationId: $expandedStationId)
					.tabItem { Label("Saudi", systemImage: "radio") }
					.tag(Tab.saudi)

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
    @EnvironmentObject var audioManager: AudioManager
    @State private var expandedStationId: RadioStation.ID? = nil
    
    let usStations = [
        RadioStation(id: 8,
                   nameEnglish: "NPR",
                   nameArabic: "راديو NPR",
                   streamURL: URL(string: "https://npr-ice.streamguys1.com/live.mp3") ?? URL(string: "about:blank")!,
                   imageSystemName: "newspaper.fill"),
        RadioStation(id: 9,
                   nameEnglish: "Minnesota Public Radio",
                   nameArabic: "راديو مينيسوتا",
                   streamURL: URL(string: "https://nis.stream.publicradio.org/nis.mp3") ?? URL(string: "about:blank")!,
                   imageSystemName: "music.note"),
        RadioStation(id: 10,
                   nameEnglish: " public radio",
                   nameArabic: "راديو العام",
                   streamURL: URL(string: "https://npr-ice.streamguys1.com/live.mp3") ?? URL(string: "about:blank")!,
                   imageSystemName: "music.quarternote.3"),
        RadioStation(id: 5,
                     nameEnglish: "BBC World Service",
                     nameArabic: "بي بي سي العالمية",
                     streamURL: URL(string: "https://stream.live.vc.bbcmedia.co.uk/bbc_world_service")!,
                     imageSystemName: "globe"),
        RadioStation(id: 15,
                     nameEnglish: "Al Jazeera English",
                     nameArabic: "الجزيرة الإنجليزية",
                     streamURL: URL(string: "https://live-hls-audio-web-aje.getaj.net/VOICE-AJE/index.m3u8")!,
                     imageSystemName: "newspaper"),
        RadioStation(id: 11,
                    nameEnglish: "Cadena SER",
                    nameArabic: "كادينا سير",
                    streamURL: URL(string: "https://playerservices.streamtheworld.com/api/livestream-redirect/CADENASER.mp3") ?? URL(string: "about:blank")!,
                    imageSystemName: "antenna.radiowaves.left.and.right"),

    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("United States")) {
                    ForEach(usStations) { station in
                        RadioStationRowView(station: station, 
                                          expandedStationId: $expandedStationId)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("World Stations")
        }
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
  
  // ... Rest of the code remains the same ...
}
