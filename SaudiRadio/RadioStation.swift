import Foundation
import SwiftUI

struct RadioStation: Identifiable {
    let id: Int
    let nameEnglish: String
    let nameArabic: String
    let streamURL: URL
    let imageSystemName: String
    
    static let sampleStations = [
        RadioStation(id: 1, 
                     nameEnglish: "MBC FM", 
                     nameArabic: "إم بي سي إف إم", 
                     streamURL: URL(string: "https://mbcfm-riyadh-prod-dub.shahid.net/out/v1/69c8a03f507e422f99cf5c07291c9e3a/index.m3u8")!, 
                     imageSystemName: "antenna.radiowaves.left.and.right"),
        RadioStation(id: 2, 
                     nameEnglish: "Alif Alif FM", 
                     nameArabic: "ألف ألف إف إم", 
                     streamURL: URL(string: "https://alifalifjobs.com/radio/8000/AlifAlifLive.mp3")!, 
                     imageSystemName: "building.columns"),
        RadioStation(id: 4, 
                     nameEnglish: "Makkah Radio", 
                     nameArabic: "إذاعة مكة المكرمة", 
                     streamURL: URL(string: "https://stream.radiojar.com/0tpy1h0kxtzuv")!, 
                     imageSystemName: "book"),
        RadioStation(id: 6, 
                     nameEnglish: "Riyadh Radio", 
                     nameArabic: "إذاعة الرياض", 
                     streamURL: URL(string: "https://live.kwikmotion.com/sbrksariyadhradiolive/srpksariyadhradio/playlist.m3u8")!, 
                     imageSystemName: "building.2"),
        RadioStation(id: 7, 
                     nameEnglish: "Jeddah Radio", 
                     nameArabic: "إذاعة جدة", 
                     streamURL: URL(string: "https://live.kwikmotion.com/sbrksajeddahradiolive/srpksajeddahradio/playlist.m3u8")!, 
                     imageSystemName: "figure.wave"),
        
    ]
}
