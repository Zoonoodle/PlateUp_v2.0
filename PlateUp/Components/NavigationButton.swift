//
//  NavigationButton.swift
//  PlateUp v2.0
//
//  Premium navigation button with haptic feedback
//

import SwiftUI

enum NavigationButtonStyle {
    case primary
    case secondary
    case text
}

struct NavigationButton: View {
    let title: String
    let style: NavigationButtonStyle
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        title: String,
        style: NavigationButtonStyle = .primary,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if isEnabled {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                action()
            }
        }) {
            HStack {
                Text(title)
                    .font(PlateUpTypography.body)
                    .fontWeight(style == .text ? .regular : .semibold)
                
                if style != .text {
                    Image(systemName: "arrow.right")
                        .font(PlateUpTypography.footnote)
                        .fontWeight(.bold)
                }
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: style == .text ? nil : .infinity)
            .padding(.horizontal, style == .text ? 0 : 24)
            .padding(.vertical, style == .text ? 0 : 16)
            .background(backgroundView)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .pressEvents(
            onPress: {
                if isEnabled {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = true
                    }
                }
            },
            onRelease: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        )
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.plateUpGreen)
                .opacity(isEnabled ? 1.0 : 0.5)
        case .secondary:
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.plateUpCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.plateUpGreen, lineWidth: 2)
                )
                .opacity(isEnabled ? 1.0 : 0.5)
        case .text:
            Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return isEnabled ? .plateUpGreen : .plateUpSecondaryText
        case .text:
            return isEnabled ? .plateUpGreen : .plateUpSecondaryText
        }
    }
}

// MARK: - Skip Button Variant
struct SkipButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Skip")
                .font(PlateUpTypography.footnote)
                .fontWeight(.medium)
                .foregroundColor(.plateUpSecondaryText)
                .underline()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct NavigationButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            NavigationButton(
                title: "Continue",
                style: .primary,
                action: {}
            )
            
            NavigationButton(
                title: "Continue",
                style: .primary,
                isEnabled: false,
                action: {}
            )
            
            NavigationButton(
                title: "Back",
                style: .secondary,
                action: {}
            )
            
            NavigationButton(
                title: "Learn more",
                style: .text,
                action: {}
            )
            
            SkipButton(action: {})
        }
        .padding()
        .background(Color.plateUpBackground)
        .applyDarkTheme()
    }
}