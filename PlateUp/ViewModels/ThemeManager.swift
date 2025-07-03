//
//  ThemeManager.swift
//  PlateUp
//
//  Manages app theme switching between Supabase and Vercel themes
//

import SwiftUI

enum AppTheme: String, CaseIterable {
    case supabase = "supabase"
    case vercel = "vercel"
    
    var name: String {
        switch self {
        case .supabase:
            return "Supabase"
        case .vercel:
            return "Vercel"
        }
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    private let themeKey = "selectedTheme"
    
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: themeKey)
        }
    }
    
    init() {
        // Always use Supabase theme for consistency
        self.currentTheme = .supabase
    }
    
    // Theme-specific colors
    var accentColor: Color {
        switch currentTheme {
        case .supabase:
            return Color(hex: "10b981") // Emerald green
        case .vercel:
            return .white
        }
    }
    
    var backgroundColor: Color {
        return Color(hex: "000000") // Pure black for both
    }
    
    var surfaceColor: Color {
        return Color(hex: "0a0a0a") // Near black for both
    }
    
    var primaryTextColor: Color {
        return .white // White for both
    }
    
    var secondaryTextColor: Color {
        return Color(hex: "888888") // Gray for both
    }
    
    var borderColor: Color {
        return Color(hex: "1a1a1a") // Subtle border for both
    }
    
    // Computed colors for specific use cases
    var glowColor: Color {
        switch currentTheme {
        case .supabase:
            return accentColor.opacity(0.3)
        case .vercel:
            return accentColor.opacity(0.2)
        }
    }
    
    var cardBackgroundColor: Color {
        return surfaceColor
    }
    
    func toggleTheme() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentTheme = currentTheme == .supabase ? .vercel : .supabase
        }
    }
}

// Environment key for theme
private struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppTheme = .supabase
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

// View modifier for applying theme
struct ThemedView: ViewModifier {
    @ObservedObject var themeManager = ThemeManager.shared
    
    func body(content: Content) -> some View {
        content
            .environment(\.appTheme, themeManager.currentTheme)
            .preferredColorScheme(.dark) // Always dark mode
    }
}

extension View {
    func themed() -> some View {
        modifier(ThemedView())
    }
}