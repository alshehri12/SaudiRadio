import Foundation

// This file is only used to enable background audio mode in the app
// The @UIApplicationDelegateAdaptor property wrapper isn't needed since we're using 
// AVAudioSession directly in AudioPlayerManager

// MARK: - Background Modes Configuration
// To enable background audio mode in the Info.plist:
//
// <key>UIBackgroundModes</key>
// <array>
//     <string>audio</string>
// </array>
