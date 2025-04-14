import Foundation

// Defines the structure for a radio station
struct RadioStation: Identifiable, Equatable {
    let id = UUID() // Use UUID for unique identification
    let nameEnglish: String
    let nameArabic: String
    let streamURL: URL?
    let imageSystemName: String // SF Symbol name for the station's icon

    // Sample Stations (moved here for better organization)
    static let sampleStations: [RadioStation] = [
        RadioStation(nameEnglish: "MBC FM", nameArabic: "ام بي سي اف ام", streamURL: URL(string: "https://mbcradio.fm/:mbcfm-fm"), imageSystemName: "radio.fill"),
        RadioStation(nameEnglish: "Rotana FM", nameArabic: "روتانا اف ام", streamURL: URL(string: "http://stream.radiojar.com/zn4z2k7gmk8uv"), imageSystemName: "music.note.radio.fill"),
        RadioStation(nameEnglish: "Alif Alif FM", nameArabic: "ألف ألف اف ام", streamURL: URL(string: "http://178.33.239.179:8000/stream"), imageSystemName: "antenna.radiowaves.left.and.right"),
        RadioStation(nameEnglish: "Quran Radio", nameArabic: "إذاعة القرآن الكريم", streamURL: URL(string: "http://live.mp3quran.net:9702/;"), imageSystemName: "book.closed.fill"),
        RadioStation(nameEnglish: "UFM Radio", nameArabic: "اذاعة يو اف ام", streamURL: URL(string: "http://radio.ufmsa.com:8000/ufmrec"), imageSystemName: "sportscourt.fill")
        // Add more stations here
    ]

    // Equatable conformance based on URL, as names might not be unique enough
    static func == (lhs: RadioStation, rhs: RadioStation) -> Bool {
        lhs.streamURL == rhs.streamURL && lhs.nameEnglish == rhs.nameEnglish
    }
}
