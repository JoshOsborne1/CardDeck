---
name: GlassmorphicDesign
description: Instructions for maintaining a consistent glassmorphic and minimalistic UI in VirtualDeck.
---

# Glassmorphic Design System SKILL

This skill provides guidelines and snippets for implementing the designated design system for VirtualDeck.

## Core Principles

1. **Glassmorphism**: Use `.ultraThinMaterial` as the base for all floating surfaces.
2. **Neon Accents**: Use neon purple (`#BF5AF2`) and neon teal (`#64D2FF`) for primary actions and borders.
3. **Typography**: Use **Bold Inter** or **System Rounded** fonts for headers and **Compact** fonts for body text.
4. **Depth**: Maintain a clear hierarchy using `shadow` and `overlay` on glass elements.
5. **Aesthetics**: High contrast, vibrant colors, and smooth micro-animations.

## Standard Components

### GlassCard

```swift
struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
```

### NeonGlow

```swift
extension View {
    func neonGlow(color: Color) -> some View {
        self.shadow(color: color.opacity(0.5), radius: 10)
            .shadow(color: color.opacity(0.3), radius: 20)
    }
}
```

## Implementation Workflow

When adding a new UI element:

1. Reference the `.agent/workflows/design-system.md` file.
2. Use the `GlassCard` or `GlassButton` components.
3. Ensure backgrounds are set to the designated app gradients.
