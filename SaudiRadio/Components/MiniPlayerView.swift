import SwiftUI

struct MiniPlayerView: View {
    @ObservedObject var audioManager = AudioPlayerManager.shared
    
    var body: some View {
        if let currentStation = audioManager.currentStation {
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 12) {
                    // Station Image
                    Image(currentStation.imageURL)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    
                    // Station Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(currentStation.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        
                        Text(currentStation.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Play/Pause Button
                    Button(action: {
                        audioManager.togglePlayback()
                    }) {
                        Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .frame(height: 60)
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    VStack {
        Spacer()
        MiniPlayerView()
    }
}
