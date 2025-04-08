import Foundation
import AVFoundation
import MediaPlayer

class AudioPlayerManager: ObservableObject {
    static let shared = AudioPlayerManager()
    private var audioPlayer: AVPlayer?
    private var playerItemContext = 0
    
    @Published var currentStation: RadioStation?
    @Published var isPlaying: Bool = false
    
    init() {
        setupAudioSession()
        setupRemoteTransportControls()
        setupNowPlaying()
        
        // Register for notifications when the app becomes active
        NotificationCenter.default.addObserver(self,
                                              selector: #selector(handleInterruption),
                                              name: AVAudioSession.interruptionNotification,
                                              object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for play command
        commandCenter.playCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            if let station = self.currentStation {
                self.resume()
                return .success
            }
            return .noActionableNowPlayingItem
        }
        
        // Add handler for pause command
        commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.pause()
            return .success
        }
    }
    
    private func setupNowPlaying() {
        // Define Now Playing Info
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: currentStation?.name ?? "Saudi Radio",
            MPMediaItemPropertyArtist: currentStation?.category.rawValue ?? "Radio",
            MPNowPlayingInfoPropertyIsLiveStream: true,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Interruption began, update UI
            pause()
        case .ended:
            // Interruption ended, resume if needed
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) && currentStation != nil {
                resume()
            }
        @unknown default:
            break
        }
    }
    
    func play(station: RadioStation) {
        // If we're already playing this station, just toggle playback
        if currentStation?.id == station.id {
            if isPlaying {
                pause()
            } else {
                resume()
            }
            return
        }
        
        // Otherwise, play the new station
        guard let url = URL(string: station.streamURL) else { return }
        
        // Stop any current playback
        stop()
        
        // Make sure audio session is active
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to activate audio session: \(error)")
        }
        
        // Create and configure player
        let playerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
        
        // Start playback
        audioPlayer?.play()
        currentStation = station
        isPlaying = true
        
        // Update now playing info
        updateNowPlayingInfo(for: station)
    }
    
    func stop() {
        audioPlayer?.pause()
        audioPlayer = nil
        isPlaying = false
        updateNowPlayingInfo(for: nil)
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        
        // Update now playing info with paused state
        if let station = currentStation {
            updateNowPlayingInfo(for: station, isPlaying: false)
        }
    }
    
    func resume() {
        audioPlayer?.play()
        isPlaying = true
        
        // Update now playing info with playing state
        if let station = currentStation {
            updateNowPlayingInfo(for: station, isPlaying: true)
        }
    }
    
    func togglePlayback() {
        if let station = currentStation {
            if isPlaying {
                pause()
            } else {
                play(station: station)
            }
        }
    }
    
    private func updateNowPlayingInfo(for station: RadioStation?, isPlaying: Bool = true) {
        var nowPlayingInfo = [String: Any]()
        
        if let station = station {
            nowPlayingInfo[MPMediaItemPropertyTitle] = station.name
            nowPlayingInfo[MPMediaItemPropertyArtist] = station.category.rawValue
            
            // Add an image if available
            if let image = UIImage(named: station.imageURL) {
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in return image }
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            }
        } else {
            nowPlayingInfo[MPMediaItemPropertyTitle] = "Saudi Radio"
            nowPlayingInfo[MPMediaItemPropertyArtist] = "No station playing"
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
