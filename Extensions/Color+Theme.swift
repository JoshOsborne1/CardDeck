import SwiftUI

// MARK: - Hex Initialization
extension Color {
  // MARK: - Brand Colors
  static let neonPurple = Color(hex: "BF5AF2")
  static let neonTeal = Color(hex: "64D2FF")
  static let neonPink = Color(hex: "FF64D2")
  static let deepNavy = Color(hex: "0A0E17")

  // MARK: - Theme Colors
  static let glassBorder = Color.white.opacity(0.2)
  static let glassBackground = Material.ultraThin

  // MARK: - Gradients
  static var brandGradient: LinearGradient {
    LinearGradient(
      colors: [Color.deepNavy, Color.deepNavy.opacity(0.8)],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  static var neonGradient: LinearGradient {
    LinearGradient(
      colors: [Color.neonPurple, Color.neonTeal],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
}
extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a: UInt64
    let r: UInt64
    let g: UInt64
    let b: UInt64
    switch hex.count {
    case 3:  // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6:  // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8:  // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (1, 1, 1, 0)
    }

    self.init(
      .sRGB,
      red: Double(r) / 255,
      green: Double(g) / 255,
      blue: Double(b) / 255,
      opacity: Double(a) / 255
    )
  }
}
