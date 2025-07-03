//
//  EatingChallengesView.swift
//  PlateUp v2.0
//
//  Screen 10: Eating challenges selection
//

import SwiftUI

struct EatingChallengesView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var showContent = false
    @State private var selectedChallenges: Set<String> = []
    
    let challenges = [
        ("clock.fill", "No time to cook", "Busy schedule makes meal prep difficult", Color.orange),
        ("dollarsign.circle.fill", "Budget constraints", "Healthy eating feels expensive", Color.green),
        ("person.3.fill", "Family has different preferences", "Hard to please everyone", Color.blue),
        ("questionmark.circle.fill", "Don't know how to cook", "Limited cooking skills", Color.purple),
        ("list.bullet.circle.fill", "Meal planning feels overwhelming", "Too many decisions", Color.red),
        ("brain.head.profile", "Stress eating", "Turn to food when stressed", Color.pink),
        ("figure.run", "Always eating on the go", "No time for sit-down meals", Color.cyan),
        ("info.circle.fill", "Don't know what 'healthy' means", "Confused about nutrition", Color.yellow),
        ("heart.fill", "Cravings and emotional eating", "Hard to resist certain foods", Color.red),
        ("calendar.circle.fill", "Irregular meal times", "Schedule makes regular meals tough", Color.indigo),
        ("takeoutbag.and.cup.and.straw.fill", "Rely on takeout/delivery", "Easier than cooking", Color.brown)
    ]
    
    var body: some View {
        OnboardingContainer(currentStep: 10) {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text("What makes healthy eating challenging for you?")
                        .font(PlateUpTypography.title1)
                        .foregroundColor(.plateUpPrimaryText)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    Text("Select up to 3 - we'll help you work around these")
                        .font(PlateUpTypography.body)
                        .foregroundColor(.plateUpSecondaryText)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
                }
                
                // Challenges grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(challenges.indices, id: \.self) { index in
                            let challenge = challenges[index]
                            AnimatedChallengeCard(
                                icon: challenge.0,
                                title: challenge.1,
                                subtitle: challenge.2,
                                iconColor: challenge.3,
                                isSelected: selectedChallenges.contains(challenge.1),
                                isDisabled: selectedChallenges.count >= 3 && !selectedChallenges.contains(challenge.1)
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    if selectedChallenges.contains(challenge.1) {
                                        selectedChallenges.remove(challenge.1)
                                    } else if selectedChallenges.count < 3 {
                                        selectedChallenges.insert(challenge.1)
                                    }
                                }
                            }
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.05), value: showContent)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 400)
                
                Spacer()
                
                // Navigation buttons
                VStack(spacing: 12) {
                    NavigationButton(
                        title: selectedChallenges.isEmpty ? "None of these apply" : "These are my challenges",
                        isEnabled: true,
                        action: {
                            // Convert selected challenges to enum values
                            flowManager.eatingChallenges = Set(selectedChallenges.compactMap { challengeTitle in
                                switch challengeTitle {
                                case "Stress eating": return .stressEating
                                case "Cravings and emotional eating": return .emotionalEating
                                case "Always eating on the go": return .lateNightSnacking
                                case "Irregular meal times": return .portionControl
                                case "Rely on takeout/delivery": return .socialEating
                                default: return nil
                                }
                            })
                            flowManager.navigateNext()
                        }
                    )
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
                    
                    NavigationButton(
                        title: "Back",
                        style: .text,
                        action: { flowManager.navigateBack() }
                    )
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)
                }
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }
}

// MARK: - Animated Challenge Card Component
struct AnimatedChallengeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var showGlow = false
    
    var body: some View {
        Button(action: {
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Animate selection
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                action()
            }
        }) {
            VStack(spacing: 8) {
                // Animated SF Symbol Icon
                ZStack {
                    // Glow effect for selected state
                    if isSelected {
                        Image(systemName: icon)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(iconColor)
                            .blur(radius: showGlow ? 8 : 0)
                            .opacity(showGlow ? 0.6 : 0)
                            .scaleEffect(showGlow ? 1.2 : 1.0)
                    }
                    
                    // Main icon
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(isSelected ? iconColor : .plateUpSecondaryText)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .scaleEffect(isPressed ? 0.95 : 1.0)
                        .symbolEffect(.bounce, value: isSelected)
                }
                .frame(height: 40)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(PlateUpTypography.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(.plateUpPrimaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(subtitle)
                        .font(PlateUpTypography.caption2)
                        .foregroundColor(.plateUpSecondaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? iconColor.opacity(0.15) : Color.plateUpSecondary.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? iconColor : Color.clear,
                                lineWidth: 2
                            )
                            .shadow(
                                color: isSelected ? iconColor.opacity(0.5) : Color.clear,
                                radius: isSelected ? 4 : 0,
                                x: 0,
                                y: 0
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(isDisabled ? 0.5 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .disabled(isDisabled)
        .scaleEffect(isDisabled ? 0.95 : 1.0)
        .onPressGesture(
            onPress: {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
            },
            onRelease: {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        )
        .onChange(of: isSelected) { oldValue, newValue in
            if newValue {
                // Start glow animation when selected
                withAnimation(.easeInOut(duration: 0.8).repeatCount(3, autoreverses: true)) {
                    showGlow = true
                }
                
                // Stop glow after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                    showGlow = false
                }
            }
        }
    }
}

// MARK: - Press Gesture Extension
extension View {
    func onPressGesture(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}

// MARK: - Preview
struct EatingChallengesView_Previews: PreviewProvider {
    static var previews: some View {
        EatingChallengesView(flowManager: OnboardingFlowManager.preview)
            .applyDarkTheme()
    }
}