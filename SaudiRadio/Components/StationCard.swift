import SwiftUI

struct StationCard: View {
    let station: RadioStation
    @ObservedObject var viewModel: RadioViewModel
    @ObservedObject var audioManager = AudioPlayerManager.shared
    
    var body: some View {
        HStack(spacing: 15) {
            // Station Image
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 60, height: 60)
                
                Image(station.imageURL)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
            }
            .frame(width: 60, height: 60)
            
            // Station Info
            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(station.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Favorite Button
            Button(action: {
                viewModel.toggleFavorite(for: station)
            }) {
                Image(systemName: viewModel.isFavorite(station: station) ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.isFavorite(station: station) ? .pink : .gray)
                    .font(.system(size: 22))
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 5)
            
            // Play Button
            Button(action: {
                viewModel.playStation(station)
            }) {
                Image(systemName: viewModel.isCurrentlyPlaying(station) ? "pause.circle.fill" : "play.circle.fill")
                    .foregroundColor(.primary)
                    .font(.system(size: 32))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    StationCard(station: SampleData.saudiStations[0], viewModel: RadioViewModel())
        .previewLayout(.sizeThatFits)
        .padding()
}
