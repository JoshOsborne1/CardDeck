import CoreHaptics
import UIKit

// MARK: - Haptics Manager
@MainActor
class HapticsManager: ObservableObject {
    static let shared = HapticsManager()
    
    private var engine: CHHapticEngine?
    private var supportsHaptics: Bool = false
    
    @Published var isEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "hapticsEnabled")
        }
    }
    
    private init() {
        // Load user preference
        isEnabled = UserDefaults.standard.bool(forKey: "hapticsEnabled")
        
        // Check if device supports haptics
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        
        if supportsHaptics {
            setupEngine()
        }
    }
    
    // MARK: - Engine Setup
    
    private func setupEngine() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            // Handle engine reset
            engine?.resetHandler = { [weak self] in
                do {
                    try self?.engine?.start()
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }
            
            // Handle engine stopped
            engine?.stoppedHandler = { reason in
                print("Haptic engine stopped: \(reason)")
            }
            
        } catch {
            print("Failed to create haptic engine: \(error)")
            supportsHaptics = false
        }
    }
    
    // MARK: - Predefined Haptic Patterns
    
    /// Light tap - for drawing a card
    func playDrawCardHaptic() {
        guard isEnabled && supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0
        )
        
        playPattern(events: [event])
    }
    
    /// Medium tap - for playing a card
    func playCardPlayHaptic() {
        guard isEnabled && supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0
        )
        
        playPattern(events: [event])
    }
    
    /// Continuous rumble - for shuffling (300ms)
    func playShuffleHaptic() {
        guard isEnabled && supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
        
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: 0.3
        )
        
        playPattern(events: [event])
    }
    
    /// Double tap - for "your turn" notification
    func playYourTurnHaptic() {
        guard isEnabled && supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
        
        let tap1 = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0
        )
        
        let tap2 = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0.1
        )
        
        playPattern(events: [tap1, tap2])
    }
    
    /// Sharp tap - for errors or invalid moves
    func playErrorHaptic() {
        guard isEnabled && supportsHaptics else {
            // Fallback to UINotificationFeedbackGenerator
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return
        }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0
        )
        
        playPattern(events: [event])
    }
    
    /// Success pattern - for winning
    func playWinHaptic() {
        guard isEnabled && supportsHaptics else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            return
        }
        
        // Rising intensity pattern
        let events = (0..<5).map { index in
            let intensity = CHHapticEventParameter(
                parameterID: .hapticIntensity,
                value: Float(0.4 + Double(index) * 0.15)
            )
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            
            return CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensity, sharpness],
                relativeTime: Double(index) * 0.08
            )
        }
        
        playPattern(events: events)
    }
    
    /// Card flip haptic - subtle click
    func playCardFlipHaptic() {
        guard isEnabled && supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0
        )
        
        playPattern(events: [event])
    }
    
    /// Selection haptic - for UI interactions
    func playSelectionHaptic() {
        guard isEnabled else { return }
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    /// Impact haptic - for button presses
    func playImpactHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    // MARK: - Pattern Playback
    
    private func playPattern(events: [CHHapticEvent]) {
        guard supportsHaptics, let engine = engine else { return }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }
}

// MARK: - View Extension for Easy Haptic Access
extension View {
    func hapticFeedback(_ type: HapticFeedbackType) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                switch type {
                case .selection:
                    HapticsManager.shared.playSelectionHaptic()
                case .impact(let style):
                    HapticsManager.shared.playImpactHaptic(style: style)
                case .cardPlay:
                    HapticsManager.shared.playCardPlayHaptic()
                case .cardDraw:
                    HapticsManager.shared.playDrawCardHaptic()
                case .error:
                    HapticsManager.shared.playErrorHaptic()
                }
            }
        )
    }
}

enum HapticFeedbackType {
    case selection
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    case cardPlay
    case cardDraw
    case error
}
