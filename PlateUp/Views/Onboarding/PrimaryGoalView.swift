//
//  PrimaryGoalView.swift
//  PlateUp v2.0
//
//  Screen 4: Primary goal selection from previously selected goals
//

import SwiftUI

struct PrimaryGoalView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var showContent = false
    @State private var selectedCardScale: CGFloat = 1.0
    
    var body: some View {
        OnboardingContainer(currentStep: 4) {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Text("Which goal is most important?")
                        .font(PlateUpTypography.largeTitle)
                        .foregroundColor(.plateUpPrimaryText)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    Text("We'll prioritize this in your personalized plan")
                        .font(PlateUpTypography.body)
                        .foregroundColor(.plateUpSecondaryText)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
                    
                    // Visual indicator
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.plateUpGreen)
                        Text("Your primary focus")
                            .font(PlateUpTypography.caption1)
                            .fontWeight(.medium)
                            .foregroundColor(.plateUpGreen)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.plateUpGreen.opacity(0.2))
                    )
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                }
                
                // Goals list
                VStack(spacing: 16) {
                    ForEach(Array(flowManager.selectedGoals.enumerated()), id: \.element) { index, goal in
                        PrimaryGoalCard(
                            goal: goal,
                            isSelected: flowManager.primaryGoal == goal,
                            action: {
                                selectPrimaryGoal(goal)
                            }
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 30)
                        .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.1 + 0.3), value: showContent)
                    }
                }
                
                Spacer()
                
                // Info message
                ValueMessageView(
                    icon: "lightbulb.fill",
                    title: "Why this matters",
                    description: "Your primary goal shapes your daily recommendations and coaching focus"
                )
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)
                
                // Continue button
                NavigationButton(
                    title: "Continue",
                    isEnabled: flowManager.canProceed(),
                    action: { flowManager.navigateNext() }
                )
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.6), value: showContent)
                
                // Back button
                NavigationButton(
                    title: "Back",
                    style: .text,
                    action: { flowManager.navigateBack() }
                )
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.7), value: showContent)
            }
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
    }
    
    private func selectPrimaryGoal(_ goal: Color.HealthGoal) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            flowManager.primaryGoal = goal
            selectedCardScale = 0.95
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedCardScale = 1.0
            }
        }
    }
}

struct PrimaryGoalCard: View {
    let goal: Color.HealthGoal
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.plateUpGreen : Color.plateUpTertiaryBackground)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: goal.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .plateUpSecondaryText)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(PlateUpTypography.headline)
                        .foregroundColor(.plateUpPrimaryText)
                    
                    Text(goal.description)
                        .font(PlateUpTypography.caption1)
                        .foregroundColor(.plateUpSecondaryText)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.plateUpGreen : Color.plateUpBorder, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.plateUpGreen)
                            .frame(width: 16, height: 16)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding()
            .selectionCard(isSelected: isSelected)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
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

// MARK: - Preview
struct PrimaryGoalView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryGoalView(flowManager: OnboardingFlowManager.preview)
            .applyDarkTheme()
    }
}