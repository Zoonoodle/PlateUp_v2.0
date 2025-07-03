//
//  GoalSelectionCard.swift
//  PlateUp v2.0
//
//  Reusable goal selection card with pulse animation
//

import SwiftUI

struct GoalSelectionCard: View {
    let goal: Color.HealthGoal
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPulsing = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            action()
        }) {
            VStack(spacing: 12) {
                // Icon with solid background (NO GRADIENT)
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.plateUpGreen : Color.plateUpTertiaryBackground)
                        .frame(width: 60, height: 60)
                        .scaleEffect(isPulsing ? 1.05 : 1.0)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(isSelected ? .white : .plateUpSecondaryText)
                }
                
                // Title
                Text(title)
                    .font(PlateUpTypography.headline)
                    .foregroundColor(.plateUpPrimaryText)
                    .multilineTextAlignment(.center)
                
                // Description
                Text(description)
                    .font(PlateUpTypography.caption1)
                    .foregroundColor(.plateUpSecondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .selectionCard(isSelected: isSelected)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isPulsing = hovering && !isSelected
            }
        }
        .pressEvents(
            onPress: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = true
                }
            },
            onRelease: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        )
    }
}

// MARK: - HealthGoal Extension
extension Color.HealthGoal {
    var title: String {
        switch self {
        case .weightLoss:
            return "Lose Weight"
        case .muscleGain:
            return "Build Muscle"
        case .betterSleep:
            return "Sleep Better"
        case .moreEnergy:
            return "More Energy"
        case .gutHealth:
            return "Gut Health"
        case .generalHealth:
            return "Overall Health"
        }
    }
    
    var description: String {
        switch self {
        case .weightLoss:
            return "Sustainable fat loss with smart nutrition"
        case .muscleGain:
            return "Optimize protein and recovery timing"
        case .betterSleep:
            return "Improve sleep through meal timing"
        case .moreEnergy:
            return "Stable energy throughout the day"
        case .gutHealth:
            return "Support digestive wellness"
        case .generalHealth:
            return "Balanced nutrition for wellbeing"
        }
    }
}

// MARK: - Press Events Modifier
struct PressEvents: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEvents(onPress: onPress, onRelease: onRelease))
    }
}

// MARK: - Preview
struct GoalSelectionCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.plateUpBackground
                .ignoresSafeArea()
            
            VStack(spacing: PlateUpComponentStyle.mediumSpacing) {
                HStack(spacing: PlateUpComponentStyle.mediumSpacing) {
                    GoalSelectionCard(
                        goal: .weightLoss,
                        title: Color.HealthGoal.weightLoss.title,
                        description: Color.HealthGoal.weightLoss.description,
                        icon: Color.HealthGoal.weightLoss.icon,
                        isSelected: true,
                        action: {}
                    )
                    
                    GoalSelectionCard(
                        goal: .moreEnergy,
                        title: "More Energy",
                        description: "Stable energy throughout the day",
                        icon: "bolt.fill",
                        isSelected: false,
                        action: {}
                    )
                }
            }
            .padding()
        }
        .applyDarkTheme()
    }
}