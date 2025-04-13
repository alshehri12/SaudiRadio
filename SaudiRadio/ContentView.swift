import SwiftUI
import AVFoundation
import Combine

#if os(iOS)
import UIKit
#endif

struct ContentView: View {
    @EnvironmentObject var audioManager: AudioManager
    @State private var showMiniPlayer = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content Area
            VStack(spacing: 0) {
                // Custom Header
                Text("Saudi Radio")
                    .font(.largeTitle.bold())
                    .padding(.top)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Station List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(RadioStation.sampleStations) { station in
                            RadioStationRowView(station: station)
                                .contentShape(Rectangle()) // Keep tappable area
                                .onTapGesture {
                                    audioManager.play(station: station)
                                    withAnimation { // Animate mini player appearance
                                        showMiniPlayer = true
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, showMiniPlayer ? 70 : 0) // Add padding to avoid overlap with mini player
                }
            }
            .background(colorScheme == .dark ? Color.black : Color(white: 0.96)) // Use simple adaptive background
            .edgesIgnoringSafeArea(.bottom) // Allow content to go under mini player slightly

            // Mini Player Overlay
            if showMiniPlayer, let currentStation = audioManager.currentStation {
                MiniPlayerView(station: currentStation)
                    .transition(.move(edge: .bottom).combined(with: .opacity)) // Smoother transition
                    .zIndex(1) // Ensure mini player is on top
            }
        }
        .accentColor(.saudiGreen) // Apply the custom green accent color globally
    }
}

struct RadioStationRowView: View {
    let station: RadioStation
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
      if #available(iOS 15.0, *) {
        HStack(spacing: 15) {
          // Station Icon
          Image(systemName: station.imageSystemName)
            .font(.system(size: 28)) // Slightly smaller icon
            .frame(width: 45, height: 45)
            .background(Color.saudiGreen.opacity(0.15)) // Use accent color background
            .clipShape(Circle())
            .foregroundColor(.saudiGreen) // Explicitly set icon color
          
          // Station Name
          VStack(alignment: .leading, spacing: 4) {
            Text(station.nameEnglish)
              .font(.headline)
              .fontWeight(.medium) // Slightly bolder
            Text(station.nameArabic)
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
          
          Spacer()
          
          // Now Playing Indicator (if playing this station)
          if audioManager.isPlaying && audioManager.currentStation?.id == station.id {
            NowPlayingIndicatorView()
              .frame(width: 25, height: 25) // Adjusted size
          }
          // Play Button (if not playing this station, or paused)
          else {
            Button(action: {
              if audioManager.currentStation?.id == station.id {
                if !audioManager.isPlaying { audioManager.play() }
              } else {
                audioManager.play(station: station)
              }
            }) {
              Image(systemName: "play.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.saudiGreen.opacity(0.8)) // Slightly faded play icon
            }
          }
        }
        .padding(12) // Padding inside the card
        .background(.regularMaterial) // Frosted glass effect
        .cornerRadius(10) // Rounded corners for card look
        .shadow(color: colorScheme == .dark ? .white.opacity(0.05) : .black.opacity(0.08), radius: 5, x: 0, y: 2)
      } else {
        // Fallback on earlier versions
      } // Subtle shadow
    }
}


struct MiniPlayerView: View {
    let station: RadioStation
    @EnvironmentObject var audioManager: AudioManager
    
    var body: some View {
        VStack(spacing: 0) {
             // Divider removed for cleaner look with material background
            
          if #available(iOS 15.0, *) {
            HStack(spacing: 15) {
              // Station Icon
              Image(systemName: station.imageSystemName)
                .font(.system(size: 22))
                .foregroundColor(.saudiGreen) // Explicit foreground color
                .frame(width: 35, height: 35)
              
              // Station Info
              VStack(alignment: .leading, spacing: 2) {
                Text(station.nameEnglish)
                  .font(.callout) // Slightly smaller font
                  .fontWeight(.semibold)
                  .lineLimit(1)
                Text(station.nameArabic)
                  .font(.caption2) // Smaller caption
                  .foregroundColor(.secondary)
                  .lineLimit(1)
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              
              // Play/Pause Button
              Button(action: {
                if audioManager.isPlaying {
                  audioManager.pause()
                } else {
                  audioManager.play() // Resume current station
                }
              }) {
                Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                  .font(.system(size: 38)) // Slightly larger button
                  .foregroundColor(.saudiGreen) // Explicit foreground color
              }
            }
            .padding(.horizontal)
            .padding(.vertical, 10) // Adjusted vertical padding
            .frame(height: 65) // Increased height slightly
            .background(.thinMaterial)
          } else {
            // Fallback on earlier versions
          } // Use thin material background
            // Add a subtle top border if needed
            // .overlay(Divider().padding(.horizontal, -16), alignment: .top)
        }
    }
}

struct NowPlayingIndicatorView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 2) { // Reduced spacing
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: 1.5) // Slightly rounder
                    .frame(width: 3, height: 6 + CGFloat(isAnimating ? (i == 1 ? 12 : 8) : 0)) // Varied animation height
                    .animation(
                        Animation.easeInOut(duration: 0.4) // Faster animation
                            .repeatForever(autoreverses: true) // Add autoreverse
                            .delay(Double(i) * 0.15), // Adjust delay
                        value: isAnimating
                    )
            }
        }
        .frame(width: 20, height: 20) // Ensure consistent frame
        .onAppear {
             // Add a small delay before starting animation to avoid stutter on appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isAnimating = true
            }
        }
        .foregroundColor(.saudiGreen) // Explicit foreground color
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AudioManager()) // Ensure AudioManager is provided
    }
}
