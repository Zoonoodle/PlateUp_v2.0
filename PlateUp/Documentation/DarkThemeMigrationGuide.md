# PlateUp Dark Theme Migration Guide

## Overview
This guide provides step-by-step instructions for migrating PlateUp from the current light theme with gradients to a professional dark theme inspired by MacroFactor.

## Key Changes

### 1. Color System Migration
Replace all gradient usage with solid colors:

#### Before (Light Theme with Gradients):
```swift
// OLD - Remove these
Color.plateUpPrimaryGradient
Color.plateUpBackgroundGradient
LinearGradient.plateUpEnergyGradient
goal.gradient // from HealthGoal enum
```

#### After (Dark Theme with Solid Colors):
```swift
// NEW - Use these instead
Color.plateUpGreen // Primary accent (sparingly)
Color.plateUpBackground // Pure black background
Color.plateUpCardBackground // Dark cards
Color.plateUpPrimaryText // White text
```

### 2. Component Updates

#### Buttons
```swift
// OLD
Button("Continue") {
    // action
}
.background(Color.plateUpPrimaryGradient)

// NEW
Button("Continue") {
    // action
}
.buttonStyle(PlateUpPrimaryButtonStyle())
```

#### Cards
```swift
// OLD
VStack {
    // content
}
.plateUpCard() // Uses pale green background

// NEW
VStack {
    // content
}
.darkCard() // Uses dark background with subtle border
```

#### Goal Selection Cards
```swift
// OLD
GoalSelectionCard(
    goal: .weightLoss,
    // ...
)

// NEW
DarkGoalSelectionCard(
    goal: .weightLoss,
    // ...
)
```

### 3. Icon Updates

#### Remove Gradient Backgrounds
```swift
// OLD
Circle()
    .fill(Color.plateUpPrimaryGradient)
    .frame(width: 60, height: 60)

// NEW
HealthGoalIcon(goal: .weightLoss, isSelected: true)
// Or for custom icons:
Circle()
    .fill(Color.plateUpGreen) // Solid color only
    .frame(width: 60, height: 60)
```

### 4. Text Color Updates
```swift
// OLD
Text("Title")
    .foregroundColor(.plateUpForestGreen)

// NEW
Text("Title")
    .foregroundColor(.plateUpPrimaryText) // White for dark theme
```

### 5. Background Colors
```swift
// OLD
ZStack {
    Color.plateUpBackgroundGradient
        .ignoresSafeArea()
    // content
}

// NEW
ZStack {
    Color.plateUpBackground // Pure black
        .ignoresSafeArea()
    // content
}
.applyDarkTheme() // Applies navigation and tab bar styling
```

## Migration Checklist

### Phase 1: Core Files
- [ ] Update `Colors.swift` to import `DarkThemeDesignSystem.swift`
- [ ] Replace gradient definitions with solid color references
- [ ] Update `OnboardingContainer.swift` to use dark backgrounds
- [ ] Update `NavigationButton.swift` to use new button styles

### Phase 2: Onboarding Views
- [ ] Replace `SplashView.swift` with `DarkThemeSplashView.swift`
- [ ] Replace `DifferentiationView.swift` with `DarkThemeDifferentiationView.swift`
- [ ] Replace `MultiGoalSelectionView.swift` with `DarkThemeMultiGoalSelectionView.swift`
- [ ] Update `PrimaryGoalView.swift` to use dark theme

### Phase 3: Components
- [ ] Replace `GoalSelectionCard.swift` usage with `DarkGoalSelectionCard.swift`
- [ ] Update `OnboardingProgressIndicator.swift` to use solid colors
- [ ] Update any custom buttons to use `PlateUpPrimaryButtonStyle` or `PlateUpSecondaryButtonStyle`

### Phase 4: App-Wide Changes
- [ ] Add `.applyDarkTheme()` modifier to root views
- [ ] Update `PlateUpApp.swift` to apply dark theme globally
- [ ] Update tab bar icons to use solid colors
- [ ] Update navigation bar styling

## Code Examples

### View Template
```swift
struct MyView: View {
    var body: some View {
        ZStack {
            // Dark background
            Color.plateUpBackground
                .ignoresSafeArea()
            
            VStack(spacing: PlateUpComponentStyle.largeSpacing) {
                // Header
                Text("Title")
                    .font(PlateUpTypography.title1)
                    .foregroundColor(.plateUpPrimaryText)
                
                // Card content
                VStack {
                    // content
                }
                .darkCard()
                
                // Primary action
                Button("Continue") {
                    // action
                }
                .buttonStyle(PlateUpPrimaryButtonStyle())
            }
            .padding()
        }
        .applyDarkTheme()
    }
}
```

### Custom Component Template
```swift
struct MyComponent: View {
    let isSelected: Bool
    
    var body: some View {
        VStack {
            // Icon - NO GRADIENT
            PlateUpIcon("heart.fill", 
                       size: 24, 
                       color: isSelected ? .plateUpGreen : .plateUpSecondaryText)
            
            // Text
            Text("Label")
                .font(PlateUpTypography.body)
                .foregroundColor(.plateUpPrimaryText)
        }
        .selectionCard(isSelected: isSelected)
    }
}
```

## Testing Checklist
- [ ] Verify all gradients have been removed
- [ ] Check contrast ratios for accessibility
- [ ] Test on both standard and OLED displays
- [ ] Verify green accent is used sparingly
- [ ] Ensure consistent dark backgrounds throughout
- [ ] Test haptic feedback on interactions
- [ ] Verify animations work with dark theme

## Notes
- Green (`Color.plateUpGreen`) should only be used for:
  - Selected states
  - Primary CTAs
  - Success indicators
  - Progress indicators
- Never use green as a background color
- Maintain high contrast for readability
- Use subtle borders (`Color.plateUpBorder`) to define card boundaries