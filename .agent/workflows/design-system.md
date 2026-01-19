---
description: How to maintain design consistency during the VirtualDeck UI overhaul
---

# UI Design Consistency Workflow

Follow these steps when creating new views or components to maintain the glassmorphic and minimalistic aesthetic.

## Step 1: Analyze the Objective

Identify which component type you are building:

- **Interactive Component**: Buttons, Toggles, Sliders
- **Container Component**: Cards, Modals, Feed items
- **Display Component**: Icons, Labels, Indicators

## Step 2: Implement Glass Bases

Use the standard `GlassCard` structure for any background surface:

- Apply `.ultraThinMaterial`
- Use rounded corners (standard `20`)
- Add a 1pt white border at `0.2` opacity

## Step 3: Add Micro-Interactions

// turbo

1. For buttons, add a `scaleEffect` on press using a `spring` animation.
2. Add `HapticsManager.trigger(.light)` on every interaction.

## Step 4: Verify Contrast

Ensure all text over glass surfaces has a contrast ratio of at least `4.5:1`. Use **Bold** weights for smaller text on transparent backgrounds.

## Step 5: Animation Setup

// turbo

1. Use `withAnimation(.spring(response: 0.4, dampingFraction: 0.8))` for state changes.
2. If moving cards between views, use `matchedGeometryEffect`.
