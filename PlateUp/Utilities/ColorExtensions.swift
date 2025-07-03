//
//  ColorExtensions.swift
//  PlateUp
//
//  Color extensions for theming support
//

import SwiftUI

// MARK: - Themed Color Support
extension Color {
    static func themed(_ component: ColorComponent, theme: AppTheme) -> Color {
        switch component {
        case .accent:
            return theme == .supabase ? Color(hex: "10b981") : .white
        case .primaryText:
            return .white
        case .secondaryText:
            return Color(hex: "888888")
        case .background:
            return Color(hex: "000000")
        case .surface, .card:
            return Color(hex: "0a0a0a")
        case .border:
            return Color(hex: "1a1a1a")
        }
    }
}

enum ColorComponent {
    case accent
    case primaryText
    case secondaryText
    case background
    case surface
    case card
    case border
}