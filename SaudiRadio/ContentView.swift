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
            NavigationView {
                List {
                    ForEach(RadioStation.sampleStations) { station in
                        RadioStationRowView(station: station)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                audioManager.play(station: station)
                                showMiniPlayer = true
                            }
                    }
                }
                .navigationTitle("Saudi Radio")
            }
            
            if showMiniPlayer, let currentStation = audioManager.currentStation {
                MiniPlayerView(station: currentStation)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: showMiniPlayer)
            }
        }
    }
}

struct RadioStationRowView: View {
    let station: RadioStation
    @EnvironmentObject var audioManager: AudioManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Station Icon
            Image(systemName: station.imageSystemName)
                .font(.system(size: 30))
                .frame(width: 50, height: 50)
                .background(Color.accentColor.opacity(0.2))
                .clipShape(Circle())
                .foregroundColor(Color.accentColor)
            
            // Station Name
            VStack(alignment: .leading, spacing: 4) {
                Text(station.nameEnglish)
                    .font(.headline)
                Text(station.nameArabic)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Play/Pause Button
            Button(action: {
                if audioManager.currentStation?.id == station.id {
                    if audioManager.isPlaying {
                        audioManager.pause()
                    } else {
                        audioManager.play()
                    }
                } else {
                    audioManager.play(station: station)
                }
            }) {
                Image(systemName: audioManager.isPlaying && audioManager.currentStation?.id == station.id ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)
            }
            
            // Now Playing Indicator
            if audioManager.isPlaying && audioManager.currentStation?.id == station.id {
                NowPlayingIndicatorView()
                    .frame(width: 30, height: 30)
            }
        }
        .padding(.vertical, 8)
    }
}

struct MiniPlayerView: View {
    let station: RadioStation
    @EnvironmentObject var audioManager: AudioManager
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 16) {
                // Station Icon
                Image(systemName: station.imageSystemName)
                    .font(.system(size: 24))
                    .foregroundColor(Color.accentColor)
                    .frame(width: 40, height: 40)
                
                // Station Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(station.nameEnglish)
                        .font(.headline)
                        .lineLimit(1)
                    Text(station.nameArabic)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Now Playing Indicator or Play Button
                if audioManager.isPlaying {
                    NowPlayingIndicatorView()
                        .frame(width: 36, height: 36)
                }
                
                // Play/Pause Button
                Button(action: {
                    if audioManager.isPlaying {
                        audioManager.pause()
                    } else {
                        audioManager.play()
                    }
                }) {
                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Color.accentColor)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(height: 60)
            .background(Color.gray.opacity(0.1))
        }
    }
}

struct NowPlayingIndicatorView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: 1)
                    .frame(width: 3, height: 12 + (isAnimating ? 6 : 0))
                    .animation(
                        Animation
                            .easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(Double(i) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
        .foregroundColor(.accentColor)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AudioManager())
    }
}
