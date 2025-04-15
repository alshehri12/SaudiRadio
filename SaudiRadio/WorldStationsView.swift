// WorldStationsView.swift - New File

import SwiftUI

struct WorldStationsView: View {
    @EnvironmentObject var audioManager: AudioManager
    @State private var expandedStationId: RadioStation.ID? = nil // State local to this view

    // Combine all world stations for easier iteration if needed later,
    // but for sections, we'll use the static arrays directly.
    // let allWorldStations = RadioStation.usStations + RadioStation.spainStations + RadioStation.franceStations

    var body: some View {
        NavigationView {
            List {
                // --- US Section ---
                Section(header: Text("🇺🇸 United States").font(.title2).fontWeight(.bold)) {
                    ForEach(RadioStation.usStations) { station in
                        RadioStationRowView(station: station, expandedStationId: $expandedStationId)
                            // Pass environment object down if RadioStationRowView needs it directly
                            // .environmentObject(audioManager) // Already available via environment
                    }
                }

                // --- Spain Section ---
                Section(header: Text("🇪🇸 Spain").font(.title2).fontWeight(.bold)) {
                    ForEach(RadioStation.spainStations) { station in
                        RadioStationRowView(station: station, expandedStationId: $expandedStationId)
                    }
                }

                // --- France Section ---
                Section(header: Text("🇫🇷 France").font(.title2).fontWeight(.bold)) {
                    ForEach(RadioStation.franceStations) { station in
                        RadioStationRowView(station: station, expandedStationId: $expandedStationId)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle()) // Use grouped style for sections
            .navigationTitle("World Radio")
        }
        // Ensure AudioManager is available to RadioStationRowView instances within this hierarchy
        .environmentObject(audioManager)
    }
}

struct WorldStationsView_Previews: PreviewProvider {
    static var previews: some View {
        WorldStationsView()
            .environmentObject(AudioManager()) // Provide a dummy manager for preview
    }
}
