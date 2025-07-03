//
//  Colors.swift
//  PlateUp v2.0
//
//  Modern Light/Dark Theme Design System
//

import SwiftUI

extension Color {
    // MARK: - Premium Dark Backgrounds
    
    /// Main background - rich black with subtle warmth
    static let plateUpBackground = Color(hex: "0A0A0B")
    
    /// Secondary background - elevated surfaces
    static let plateUpSecondaryBackground = Color(hex: "111113")
    
    /// Card backgrounds - premium feel with depth
    static let plateUpCardBackground = Color(hex: "18181B")
    
    /// Tertiary background - for nested elements
    static let plateUpTertiaryBackground = Color(hex: "212124")
    
    /// Input field backgrounds - subtle contrast
    static let plateUpQuaternaryBackground = Color(hex: "27272A")
    
    // MARK: - Text Colors - Premium Contrast
    
    /// Primary text - crisp white
    static let plateUpPrimaryText = Color(hex: "FFFFFF")
    
    /// Secondary text - refined gray
    static let plateUpSecondaryText = Color(hex: "A1A1AA")
    
    /// Tertiary text - subtle
    static let plateUpTertiaryText = Color(hex: "71717A")
    
    /// Placeholder text
    static let plateUpPlaceholderText = Color(hex: "52525B")
    
    // MARK: - Brand Colors - Modern Green Palette
    
    /// Primary brand green - vibrant and modern
    static let plateUpGreen = Color(hex: "34C759")  // iOS system green
    static let plateUpPrimaryGreen = Color(hex: "34C759") // Alias for compatibility
    static let plateUpAccentGreen = Color(hex: "34C759") // Alias for compatibility
    
    /// Darker green for depth
    static let plateUpGreenDark = Color(hex: "248A3D")
    
    /// Lighter green for backgrounds
    static let plateUpGreenLight = Color(hex: "E3F9E5")
    
    /// Medium green for interactive elements
    static let plateUpGreenMedium = Color(hex: "5DD362")
    
    // MARK: - Legacy Color Aliases (mapped to dark theme)
    static let plateUpForestGreen = Color.plateUpGreen
    static let plateUpMediumGreen = Color.plateUpGreen
    static let plateUpLightGreen = Color.plateUpGreenLight
    static let plateUpPaleGreen = Color.plateUpCardBackground
    static let plateUpWarmGreen = Color.plateUpGreen
    static let plateUpCoolGreen = Color.plateUpGreen
    static let plateUpBrightGreen = Color.plateUpGreenLight
    
    // MARK: - Common Aliases
    static let plateUpAccent = Color.plateUpGreen
    static let plateUpSecondary = Color.plateUpCardBackground
    
    // MARK: - Semantic Colors
    
    /// Success color
    static let plateUpSuccess = Color(hex: "34C759")
    
    /// Warning color
    static let plateUpWarning = Color(hex: "FF9500")
    
    /// Error color
    static let plateUpError = Color(hex: "FF3B30")
    
    /// Info color
    static let plateUpInfo = Color(hex: "007AFF")
    
    // MARK: - Border Colors
    
    /// Subtle border for cards
    static let plateUpBorder = Color(hex: "38383A")
    
    /// Separator lines
    static let plateUpSeparator = Color(hex: "48484A")
    
    
    // MARK: - Health Goal Contextual Colors (Dark Theme)
    
    enum HealthGoal {
        case weightLoss
        case muscleGain
        case betterSleep
        case moreEnergy
        case gutHealth
        case generalHealth
        
        var primaryColor: Color {
            // All goals use the same green in dark theme for consistency
            return .plateUpGreen
        }
        
        var icon: String {
            switch self {
            case .weightLoss: return "figure.walk"
            case .muscleGain: return "figure.strengthtraining.traditional"
            case .betterSleep: return "bed.double.fill"
            case .moreEnergy: return "bolt.fill"
            case .gutHealth: return "leaf.fill"
            case .generalHealth: return "heart.fill"
            }
        }
    }
    
    // MARK: - Context-Aware Colors
    
    enum PlateUpContext {
        case coaching
        case energy
        case sleep
        case nutrition
        case achievement
        case warning
        case success
    }
    
    static func plateUpGreen(for context: PlateUpContext, intensity: CGFloat = 1.0) -> Color {
        // In dark theme, all contexts use the same green for consistency
        return plateUpGreen.opacity(intensity)
    }
    
    // MARK: - Hex Color Initializer
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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
// MARK: - Component Styles
struct PlateUpComponentStyle {
    // MARK: - Corner Radius
    static let smallRadius: CGFloat = 8
    static let mediumRadius: CGFloat = 12
    static let largeRadius: CGFloat = 16
    static let extraLargeRadius: CGFloat = 20
    static let circularRadius: CGFloat = 24
    
    // MARK: - Spacing
    static let tinySpacing: CGFloat = 4
    static let smallSpacing: CGFloat = 8
    static let mediumSpacing: CGFloat = 16
    static let largeSpacing: CGFloat = 24
    static let extraLargeSpacing: CGFloat = 32
    
    // MARK: - Button Heights
    static let smallButtonHeight: CGFloat = 36
    static let mediumButtonHeight: CGFloat = 44
    static let largeButtonHeight: CGFloat = 52
    static let extraLargeButtonHeight: CGFloat = 60
    
    // MARK: - Card Padding
    static let cardPadding: CGFloat = 16
    static let cardSpacing: CGFloat = 12
    
    // MARK: - Shadow
    static let shadowRadius: CGFloat = 12
    static let shadowOpacity: Double = 0.08
    static let shadowY: CGFloat = 4
}

// MARK: - Card Styling (Legacy compatibility)
enum CardStyle {
    case standard
    case prominent
    case subtle
    
    var cornerRadius: CGFloat {
        switch self {
        case .standard: return PlateUpComponentStyle.largeRadius
        case .prominent: return PlateUpComponentStyle.extraLargeRadius
        case .subtle: return PlateUpComponentStyle.mediumRadius
        }
    }
}

// MARK: - Dark Theme View Extensions

extension View {
    // MARK: - Premium Card Style
    func premiumCard(
        padding: CGFloat = PlateUpComponentStyle.cardPadding,
        cornerRadius: CGFloat = PlateUpComponentStyle.largeRadius
    ) -> some View {
        self
            .padding(padding)
            .background(
                LinearGradient(
                    colors: [
                        Color.plateUpCardBackground,
                        Color.plateUpCardBackground.opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.plateUpBorder.opacity(0.5),
                                Color.plateUpBorder.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(
                color: Color.black.opacity(PlateUpComponentStyle.shadowOpacity),
                radius: PlateUpComponentStyle.shadowRadius,
                x: 0,
                y: PlateUpComponentStyle.shadowY
            )
    }
    
    // MARK: - Dark Card Style (legacy support)
    func darkCard(
        padding: CGFloat = PlateUpComponentStyle.cardPadding,
        cornerRadius: CGFloat = PlateUpComponentStyle.largeRadius
    ) -> some View {
        self.premiumCard(padding: padding, cornerRadius: cornerRadius)
    }
    
    // MARK: - Selection Card Style
    func selectionCard(isSelected: Bool) -> some View {
        self
            .padding(PlateUpComponentStyle.cardPadding)
            .background(
                isSelected ? Color.plateUpGreen.opacity(0.1) : Color.plateUpCardBackground
            )
            .cornerRadius(PlateUpComponentStyle.largeRadius)
            .overlay(
                RoundedRectangle(cornerRadius: PlateUpComponentStyle.largeRadius)
                    .stroke(
                        isSelected ? Color.plateUpGreen : Color.plateUpBorder,
                        lineWidth: isSelected ? 2 : 0.5
                    )
            )
    }
    
    // MARK: - Apply Dark Theme
    func applyDarkTheme() -> some View {
        self
            .preferredColorScheme(.dark)
            .background(Color.plateUpBackground.ignoresSafeArea())
    }
    
    // MARK: - Legacy plateUpCard (now maps to darkCard)
    func plateUpCard(_ style: CardStyle = .standard) -> some View {
        self.darkCard(cornerRadius: style.cornerRadius)
    }
}

// MARK: - Typography System
struct PlateUpTypography {
    // MARK: - Font Weights
    static let light = Font.Weight.light
    static let regular = Font.Weight.regular
    static let medium = Font.Weight.medium
    static let semibold = Font.Weight.semibold
    static let bold = Font.Weight.bold
    
    // MARK: - Text Styles
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption1 = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
}

// MARK: - Button Styles
struct PlateUpPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PlateUpTypography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: PlateUpComponentStyle.largeButtonHeight)
            .background(
                Color.plateUpGreen
                    .opacity(isEnabled ? 1.0 : 0.5)
                    .brightness(configuration.isPressed ? -0.1 : 0)
            )
            .cornerRadius(PlateUpComponentStyle.mediumRadius)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct PlateUpSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PlateUpTypography.headline)
            .foregroundColor(.plateUpGreen)
            .frame(maxWidth: .infinity)
            .frame(height: PlateUpComponentStyle.largeButtonHeight)
            .background(
                Color.plateUpGreen
                    .opacity(configuration.isPressed ? 0.2 : 0.1)
            )
            .cornerRadius(PlateUpComponentStyle.mediumRadius)
            .overlay(
                RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                    .stroke(Color.plateUpGreen, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}