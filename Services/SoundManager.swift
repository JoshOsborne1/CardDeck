import AVFoundation
import AudioToolbox
import SwiftUI

// MARK: - Sound Manager
class SoundManager: ObservableObject {
    nonisolated(unsafe) static let shared = SoundManager()
    
    private var audioEngine: AVAudioEngine?
    private var playerNodes: [String: AVAudioPlayerNode] = [:]
    private var audioBuffers: [SoundEffect: AVAudioPCMBuffer] = [:]
    
    @Published var isEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "soundEnabled")
            if !isEnabled {
                stopAllSounds()
            }
        }
    }
    
    @Published var volume: Float = 0.7 {
        didSet {
            UserDefaults.standard.set(volume, forKey: "soundVolume")
            updateVolume()
        }
    }
    
    private init() {
        // Load preferences
        isEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        volume = UserDefaults.standard.float(forKey: "soundVolume")
        
        setupAudioEngine()
        loadSounds()
    }
    
    // MARK: - Audio Engine Setup
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        
        // Configure audio session
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
        
        // Start engine
        do {
            try audioEngine?.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    // MARK: - Sound Loading (Placeholder - will use actual files)
    
    private func loadSounds() {
        // In production, load from bundle
        // For now, using system sounds as placeholders
    }
    
    private func loadAudioBuffer(from url: URL, for sound: SoundEffect) {
        do {
            let file = try AVAudioFile(forReading: url)
            let format = file.processingFormat
            let frameCount = UInt32(file.length)
            
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                return
            }
            
            try file.read(into: buffer)
            audioBuffers[sound] = buffer
        } catch {
            print("Failed to load sound \(sound): \(error)")
        }
    }
    
    // MARK: - Sound Playback
    
    func play(_ sound: SoundEffect, spatialPosition: SpatialPosition = .center) {
        guard isEnabled else { return }
        
        // Use system sound for now (will be replaced with custom sounds)
        playSystemSound(for: sound)
    }
    
    private func playSystemSound(for sound: SoundEffect) {
        // Using system sound IDs as placeholder
        let soundID: SystemSoundID
        
        switch sound {
        case .cardDraw, .cardPlay:
            soundID = 1104 // Tock sound
        case .cardFlip:
            soundID = 1105 // Pop sound
        case .shuffleShort, .shuffleLong:
            soundID = 1106 // Peek sound
        case .chipClink:
            soundID = 1055 // Tink sound
        case .winFanfare:
            soundID = 1050 // Success sound
        case .turnNotification:
            soundID = 1103 // Anticipate sound
        }
        
        AudioServicesPlaySystemSound(soundID)
    }
    
    private func playSpatialSound(_ sound: SoundEffect, at position: SpatialPosition) {
        guard let engine = audioEngine,
              let buffer = audioBuffers[sound] else { return }
        
        let playerNode = AVAudioPlayerNode()
        let environmentNode = AVAudioEnvironmentNode()
        
        // Attach nodes
        engine.attach(playerNode)
        engine.attach(environmentNode)
        
        // Connect nodes
        engine.connect(playerNode, to: environmentNode, format: buffer.format)
        engine.connect(environmentNode, to: engine.mainMixerNode, format: buffer.format)
        
        // Set spatial position
        playerNode.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )
        
        // Set volume
        playerNode.volume = volume
        
        // Schedule and play
        playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        playerNode.play()
        
        // Store reference
        playerNodes[sound.rawValue] = playerNode
        
        // Clean up after playback
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            playerNode.stop()
            self?.playerNodes.removeValue(forKey: sound.rawValue)
        }
    }
    
    // MARK: - Specific Sound Methods
    
    func playCardDraw() {
        play(.cardDraw)
    }
    
    func playCardPlay() {
        play(.cardPlay)
    }
    
    func playCardFlip() {
        play(.cardFlip)
    }
    
    func playShuffle(long: Bool = false) {
        play(long ? .shuffleLong : .shuffleShort)
    }
    
    func playChipClink() {
        play(.chipClink)
    }
    
    func playWin() {
        play(.winFanfare)
    }
    
    func playTurnNotification() {
        play(.turnNotification)
    }
    
    // MARK: - Volume Control
    
    private func updateVolume() {
        audioEngine?.mainMixerNode.outputVolume = volume
    }
    
    private func stopAllSounds() {
        playerNodes.values.forEach { $0.stop() }
        playerNodes.removeAll()
    }
}

// MARK: - Sound Effect Enum
enum SoundEffect: String {
    case cardDraw = "card_draw"
    case cardPlay = "card_play"
    case cardFlip = "card_flip"
    case shuffleShort = "shuffle_short"
    case shuffleLong = "shuffle_long"
    case chipClink = "chip_clink"
    case winFanfare = "win_fanfare"
    case turnNotification = "turn_notification"
}

// MARK: - Spatial Position
struct SpatialPosition {
    var x: Float
    var y: Float
    var z: Float
    
    static let center = SpatialPosition(x: 0, y: 0, z: 0)
    static let left = SpatialPosition(x: -1, y: 0, z: 0)
    static let right = SpatialPosition(x: 1, y: 0, z: 0)
    static let front = SpatialPosition(x: 0, y: 0, z: -1)
    static let back = SpatialPosition(x: 0, y: 0, z: 1)
}
