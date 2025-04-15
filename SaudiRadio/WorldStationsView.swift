// WorldStationsView.swift - New File

import SwiftUI

struct WorldStationsView: View {
    @EnvironmentObject var audioManager: AudioManager
    @State private var expandedStationId: RadioStation.ID? = nil // State local to this view

    // Combine all world stations for easier iteration if needed later,
    // but for sections, we'll use the static arrays directly.
    // let allWorldStations = RadioStation.usStations + RadioStation.spainStations + RadioStation.franceStations

    let usStations = [
        RadioStation(nameEnglish: "NPR", 
                   streamURL: URL(string: "https://npr-ice.streamguys1.com/live.mp3") ?? URL(string: "about:blank")!,
                   imageSystemName: "newspaper.fill"),
        RadioStation(nameEnglish: "BBC World Service", 
                   streamURL: URL(string: "http://bbcwssc.ic.llnwd.net/stream/bbcwssc_mp1_ws-eieuk") ?? URL(string: "about:blank")!,
                   imageSystemName: "globe.americas.fill"),
        RadioStation(nameEnglish: "CNN Radio", 
                   streamURL: URL(string: "http://tunein.streamguys1.com/cnnfree") ?? URL(string: "about:blank")!,
                   imageSystemName: "play.tv.fill")
    ]

    var body: some View {
        NavigationView {
            List {
                // --- US Section ---
                Section(header: Text("United States")) {
                    ForEach(usStations) { station in
                        RadioStationRowView(station: station, 
                                          expandedStationId: $expandedStationId)
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
