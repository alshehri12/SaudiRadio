import SwiftUI
import AVFoundation
import Combine

@main
struct SaudiRadioApp: App {
    @StateObject private var audioManager = AudioManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioManager)
        }
    }
}
