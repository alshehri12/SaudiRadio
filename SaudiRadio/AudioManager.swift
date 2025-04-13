import Foundation
import AVFoundation
import Combine

#if os(iOS)
import MediaPlayer
import UIKit
#endif

class AudioManager: NSObject, ObservableObject {
    // Playback states
    @Published var isPlaying = false
    @Published var currentStation: RadioStation?
    @Published var currentTime: Double = 0
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var timeControlStatusObservation: NSKeyValueObservation?
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        #if os(iOS)
        setupAudioSession()
        setupRemoteTransportControls()
        #endif
    }
    
    #if os(iOS)
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    #endif
    
    #if os(iOS)
    private func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for play command
        commandCenter.playCommand.addTarget { [weak self] event in
            if let self = self {
                self.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for pause command
        commandCenter.pauseCommand.addTarget { [weak self] event in
            if let self = self {
                self.pause()
                return .success
            }
            return .commandFailed
        }
    }
    #endif
    
    #if os(iOS)
    // Register for audio interruption notifications
    private func observeInterruptions() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }
    #endif
    
    @objc func handleInterruption(notification: Notification) {
        #if os(iOS)
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Audio session was interrupted, pause playback
            pause()
        case .ended:
            // Interruption ended, check if we should resume playback
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt,
               AVAudioSession.InterruptionOptions(rawValue: optionsValue).contains(.shouldResume) {
                play()
            }
        @unknown default:
            break
        }
        #endif
    }
    
    // Play a station either from parameter or current station
    func play(station: RadioStation? = nil) {
        if let station = station {
            stop()
            currentStation = station
            
            // Create an asset with the stream URL and specify content type for HLS and other formats
            let headers = [
                "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
                "Accept": "*/*",
                "Accept-Encoding": "identity",
                "Connection": "keep-alive"
            ]
            
            let asset = AVURLAsset(url: station.streamURL, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
            
            let playerItem = AVPlayerItem(asset: asset)
            playerItem.preferredForwardBufferDuration = 5.0
            playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
            
            // Add KVO observer for status changes
            playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new], context: nil)
            
            // Create a new player with the properly configured item
            player = AVPlayer(playerItem: playerItem)
            
            #if os(iOS)
            // Configure audio for background playback
            configureNowPlayingInfo(for: station)
            #endif
            
            // Print debugging info about the stream
            print("Attempting to play stream: \(station.streamURL.absoluteString)")
        }
        
        guard let player = player else { return }
        
        // Play will be called once the stream is actually ready in observeValue
        
        // Observe Time Control Status for buffering/playing state
        timeControlStatusObservation = player.observe(\.timeControlStatus, options: [.new]) { [weak self] player, change in
            guard let self = self else { return }
            // Use change.newValue safely
            guard let newStatus = change.newValue else { return }

            switch newStatus { // Use the unwrapped newStatus
            case .paused:
                self.isPlaying = false
            case .playing:
                self.isPlaying = true
            case .waitingToPlayAtSpecifiedRate:
                self.isPlaying = false
            @unknown default:
                break
            }
        }
        
        // Observe playback time
        removeTimeObserver()
        addTimeObserver()
    }
    
    // Play using a station ID
    func play(stationID: Int) {
        if let station = RadioStation.sampleStations.first(where: { $0.id == stationID }) {
            play(station: station)
        }
    }
    
    func stop() {
        guard let player = player else { return }
        
        // Remove observers
        removeTimeObserver()
        timeControlStatusObservation?.invalidate()
        
        if let playerItem = player.currentItem {
            playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        }
        
        player.pause()
        self.player = nil
        isPlaying = false
        
        #if os(iOS)
        // Clear now playing info
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        #endif
    }
    
    func pause() {
        guard let player = player, isPlaying else { return }
        
        player.pause()
        isPlaying = false
        #if os(iOS)
        updateNowPlayingInfoPlaybackRate(rate: 0.0)
        #endif
    }
    
    #if os(iOS)
    private func configureNowPlayingInfo(for station: RadioStation) {
        // Define now playing information
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = station.nameEnglish
        nowPlayingInfo[MPMediaItemPropertyArtist] = station.nameArabic
        nowPlayingInfo[MPMediaItemPropertyMediaType] = MPMediaType.anyAudio.rawValue
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        
        // Create artwork from system image
        if let image = UIImage(systemName: station.imageSystemName)?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
                return image
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        // Set the now playing info
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    #endif
    
    #if os(iOS)
    private func updateNowPlayingInfoPlaybackRate(rate: Float) {
        if var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = rate
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
    #endif
    
    private func addTimeObserver() {
        let interval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
        }
    }
    
    private func removeTimeObserver() {
        if let timeObserver = timeObserver, let player = player {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
    
    // Attempt to use a fallback stream URL if the primary one fails
    private func tryFallbackStream(for station: RadioStation?) {
        guard let station = station else { return }
        
        // Define fallback URLs for each station
        var fallbackURL: URL?
        
        switch station.id {
        case 1: // MBC FM
            fallbackURL = URL(string: "https://mbcfm-riyadh-prod-dub.shahid.net/out/v1/69c8a03f507e422f99cf5c07291c9e3a/index_1.m3u8")
        case 2: // Alif Alif FM
            fallbackURL = URL(string: "https://alifalifjobs.com/radio/8100/AlifAlifLive.mp3")
        case 3: // Mix FM
            fallbackURL = URL(string: "http://s1.voscast.com:11377/stream")
        case 4: // Makkah Radio
            fallbackURL = URL(string: "https://stream.radiojar.com/0tpy1h0kxtzuv_backup")
        case 5: // BBC World Service
            fallbackURL = URL(string: "https://stream.live.vc.bbcmedia.co.uk/bbc_world_service_west_africa")
        case 7: // Radio Monte Carlo
            fallbackURL = URL(string: "https://montecarlodoualiya128k.ice.infomaniak.ch/mc-doualiya-64.mp3")
        case 8: // Al Jazeera English
            fallbackURL = URL(string: "https://live-hls-audio-aje-ak.getaj.net/VOICE-AJE/index.m3u8")
        default:
            fallbackURL = nil
        }
        
        if let fallbackURL = fallbackURL {
            print("Trying fallback URL: \(fallbackURL.absoluteString)")
            
            // Create a new station with the fallback URL
            let fallbackStation = RadioStation(
                id: station.id,
                nameEnglish: station.nameEnglish,
                nameArabic: station.nameArabic,
                streamURL: fallbackURL,
                imageSystemName: station.imageSystemName
            )
            
            // Attempt to play with the fallback URL
            play(station: fallbackStation)
        } else {
            // No fallback available, notify user
            print("No fallback URL available for \(station.nameEnglish)")
        }
    }
    
    // KVO observer for player item status changes
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status),
           let item = object as? AVPlayerItem {
            switch item.status {
            case .readyToPlay:
                print("Stream is ready to play")
                player?.play()
                isPlaying = true
                #if os(iOS)
                updateNowPlayingInfoPlaybackRate(rate: 1.0)
                #endif
            case .failed:
                print("Stream failed to load: \(item.error?.localizedDescription ?? "Unknown error")")
                // Try fallback stream if available
                tryFallbackStream(for: currentStation)
            case .unknown:
                print("Stream status unknown")
            @unknown default:
                print("Stream status is an unknown case")
            }
        }
    }
    
    deinit {
        stop()
        #if os(iOS)
        NotificationCenter.default.removeObserver(self)
        #endif
    }
}
