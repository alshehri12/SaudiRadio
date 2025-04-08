import Foundation

struct RadioStation: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let streamURL: String
    let imageURL: String
    let category: StationCategory
    var isFavorite: Bool = false
    
    static func == (lhs: RadioStation, rhs: RadioStation) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum StationCategory: String, CaseIterable {
    case news = "News"
    case quran = "Quran"
    case music = "Music"
    case talk = "Talk"
    case sports = "Sports"
    case entertainment = "Entertainment"
    
    var color: String {
        switch self {
        case .news: return "newsCategoryColor"
        case .quran: return "quranCategoryColor"
        case .music: return "musicCategoryColor"
        case .talk: return "talkCategoryColor"
        case .sports: return "sportsCategoryColor" 
        case .entertainment: return "entertainmentCategoryColor"
        }
    }
}

// Sample radio stations data - Using verified Saudi Broadcasting Authority streams
class SampleData {
    static let saudiStations: [RadioStation] = [
        // General Radio Stations
        RadioStation(name: "Saudi Radio", streamURL: "https://edge.mixlr.com/channel/qtgru", imageURL: "saudi", category: .news),
        RadioStation(name: "Riyadh Radio", streamURL: "https://edge.mixlr.com/channel/kpkga", imageURL: "riyadh", category: .news),
        RadioStation(name: "Jeddah Radio", streamURL: "https://edge.mixlr.com/channel/kmbqw", imageURL: "jeddah", category: .entertainment),
        RadioStation(name: "Makkah Radio", streamURL: "https://edge.mixlr.com/channel/xynrb", imageURL: "makkah", category: .news),
        RadioStation(name: "Madinah Radio", streamURL: "https://edge.mixlr.com/channel/jukyq", imageURL: "madinah", category: .news),
        
        // Specialized Stations
        RadioStation(name: "Saudi Quran", streamURL: "https://edge.mixlr.com/channel/lbvmv", imageURL: "quran", category: .quran),
        RadioStation(name: "Saudi Sunnah", streamURL: "https://edge.mixlr.com/channel/jjhkx", imageURL: "sunnah", category: .quran),
        RadioStation(name: "Saudi Sport", streamURL: "https://edge.mixlr.com/channel/nbpzm", imageURL: "sport", category: .sports),
        
        // FM & Private Stations
        RadioStation(name: "MBC FM", streamURL: "https://mbcfmmedia.akamaized.net/hls/live/2038329/mbcfm_web_lah/master.m3u8", imageURL: "mbcfm", category: .music),
        RadioStation(name: "Rotana FM", streamURL: "https://rotanafm.withott.com/rotanafm/stream/chunklist.m3u8", imageURL: "rotana", category: .music),
        RadioStation(name: "Panorama FM", streamURL: "https://shls-panoramafm-prod-dub.shahid.net/out/v1/66262e420d824475aaae794dc2d69f14/index.m3u8", imageURL: "panorama", category: .entertainment),
        RadioStation(name: "UFM", streamURL: "https://streams.radio.co/s9f46973da/listen", imageURL: "ufm", category: .music),
        RadioStation(name: "Mix FM Saudi", streamURL: "https://usa1.fastcast4u.com/proxy/mixsaudi?mp=/;stream.mp3", imageURL: "mixfm", category: .music),
        RadioStation(name: "Alif Alif FM", streamURL: "https://alifalifjobs.com/radio/8000/AlifAlifLive.mp3", imageURL: "alif", category: .talk),
        
        // Regional Stations
        RadioStation(name: "Dammam Radio", streamURL: "https://edge.mixlr.com/channel/ibzmm", imageURL: "dammam", category: .news),
        RadioStation(name: "Hail Radio", streamURL: "https://edge.mixlr.com/channel/qothv", imageURL: "hail", category: .news),
        RadioStation(name: "Qassim Radio", streamURL: "https://edge.mixlr.com/channel/yrkbd", imageURL: "qassim", category: .news),
        RadioStation(name: "Abha Radio", streamURL: "https://edge.mixlr.com/channel/wsmvs", imageURL: "abha", category: .news),
        RadioStation(name: "Jizan Radio", streamURL: "https://edge.mixlr.com/channel/aotpr", imageURL: "jizan", category: .news),
        
        // Other Popular Stations
        RadioStation(name: "Al-Arabiya FM", streamURL: "https://fm.alarabiya.net/fm/myStream/playlist.m3u8", imageURL: "alarabiya", category: .news),
        RadioStation(name: "Nidae AlIslam", streamURL: "https://edge.mixlr.com/channel/gzqpj", imageURL: "nidae", category: .quran),
        RadioStation(name: "Saudi International", streamURL: "https://edge.mixlr.com/channel/yhiiw", imageURL: "international", category: .news)
    ]
}
