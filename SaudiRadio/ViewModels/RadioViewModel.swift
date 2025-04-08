import Foundation
import Combine

class RadioViewModel: ObservableObject {
    @Published var stations: [RadioStation]
    @Published var favoriteStations: [RadioStation] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: StationCategory?
    
    private let audioManager = AudioPlayerManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    var filteredStations: [RadioStation] {
        if searchText.isEmpty {
            if let category = selectedCategory {
                return stations.filter { $0.category == category }
            }
            return stations
        } else {
            return stations.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    init(stations: [RadioStation] = SampleData.saudiStations) {
        self.stations = stations
        
        // Set initial favorites from UserDefaults if available
        if let savedFavorites = UserDefaults.standard.array(forKey: "favoriteStations") as? [String] {
            for (index, station) in self.stations.enumerated() {
                if savedFavorites.contains(station.name) {
                    self.stations[index].isFavorite = true
                    self.favoriteStations.append(self.stations[index])
                }
            }
        }
    }
    
    func toggleFavorite(for station: RadioStation) {
        if let index = stations.firstIndex(where: { $0.id == station.id }) {
            stations[index].isFavorite.toggle()
            
            if stations[index].isFavorite {
                favoriteStations.append(stations[index])
            } else {
                favoriteStations.removeAll { $0.id == station.id }
            }
            
            saveFavorites()
        }
    }
    
    func isFavorite(station: RadioStation) -> Bool {
        return favoriteStations.contains(where: { $0.id == station.id })
    }
    
    private func saveFavorites() {
        let favoriteNames = favoriteStations.map { $0.name }
        UserDefaults.standard.set(favoriteNames, forKey: "favoriteStations")
    }
    
    func selectCategory(_ category: StationCategory?) {
        selectedCategory = category
    }
    
    func playStation(_ station: RadioStation) {
        audioManager.play(station: station)
    }
    
    func isCurrentlyPlaying(_ station: RadioStation) -> Bool {
        return audioManager.currentStation?.id == station.id && audioManager.isPlaying
    }
}
