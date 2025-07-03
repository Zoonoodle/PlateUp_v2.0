//
//  BiologicalSexView.swift
//  PlateUp v2.0
//
//  Screen 6: Biological sex selection with animated cards
//

import SwiftUI

struct BiologicalSexView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var showContent = false
    @State private var selectedSex: BiologicalSex?
    @State private var showInsight = false
    
    let sexOptions: [(BiologicalSex, String, String, Color)] = [
        (.male, "person.fill", "Male", .blue),
        (.female, "person.fill", "Female", .pink),
        (.other, "person.2.fill", "Other", .purple),
        (.preferNotToSay, "questionmark.circle.fill", "Prefer not to say", .gray)
    ]
    
    var body: some View {
        OnboardingContainer(currentStep: 6) {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    Text("Your biological information")
                        .font(PlateUpTypography.title1)
                        .foregroundColor(.plateUpPrimaryText)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    Text("This helps us calculate accurate nutritional needs based on biological factors")
                        .font(PlateUpTypography.body)
                        .foregroundColor(.plateUpSecondaryText)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
                }
                
                Spacer()
                
                // Selection cards
                VStack(spacing: 16) {
                    ForEach(sexOptions, id: \.0) { option in
                        BiologicalSexCard(
                            sex: option.0,
                            icon: option.1,
                            title: option.2,
                            color: option.3,
                            isSelected: selectedSex == option.0,
                            action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    selectedSex = option.0
                                    flowManager.biologicalSex = option.0
                                    
                                    // Show insight briefly
                                    showInsight = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        withAnimation(.easeOut(duration: 0.5)) {
                                            showInsight = false
                                        }
                                    }
                                }
                            }
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 30)
                        .animation(.easeOut(duration: 0.5).delay(0.2 + Double(option.0.hashValue % 4) * 0.05), value: showContent)
                    }
                }
                
                // Insight card
                if showInsight && selectedSex != nil {
                    InsightCard(sex: selectedSex!)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
                
                Spacer()
                
                // Navigation buttons
                VStack(spacing: 12) {
                    NavigationButton(
                        title: "Continue",
                        isEnabled: selectedSex != nil,
                        action: { flowManager.navigateNext() }
                    )
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)
                    
                    NavigationButton(
                        title: "Back",
                        style: .text,
                        action: { flowManager.navigateBack() }
                    )
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.6), value: showContent)
                }
            }
            .padding()
        }
        .onAppear {
            // Initialize with saved value if available
            if let saved = flowManager.biologicalSex {
                selectedSex = saved
            }
            
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }
}

// MARK: - Biological Sex Card
struct BiologicalSexCard: View {
    let sex: BiologicalSex
    let icon: String
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var showGlow = false
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            action()
        }) {
            HStack(spacing: 20) {
                // Animated icon
                ZStack {
                    // Glow effect
                    if isSelected {
                        Image(systemName: icon)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(color)
                            .blur(radius: showGlow ? 8 : 0)
                            .opacity(showGlow ? 0.6 : 0)
                            .scaleEffect(showGlow ? 1.2 : 1.0)
                    }
                    
                    // Main icon
                    Image(systemName: icon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(isSelected ? color : .plateUpSecondaryText)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .scaleEffect(isPressed ? 0.95 : 1.0)
                        .symbolEffect(.bounce, value: isSelected)
                }
                .frame(width: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(PlateUpTypography.headline)
                        .foregroundColor(.plateUpPrimaryText)
                    
                    if sex == .preferNotToSay {
                        Text("We'll use average values")
                            .font(PlateUpTypography.caption1)
                            .foregroundColor(.plateUpSecondaryText)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? color : .plateUpSecondaryText)
                    .font(.title2)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color.opacity(0.15) : Color.plateUpSecondary.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? color : Color.clear,
                                lineWidth: 2
                            )
                            .shadow(
                                color: isSelected ? color.opacity(0.5) : Color.clear,
                                radius: isSelected ? 4 : 0
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
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
                withAnimation(.easeInOut(duration: 0.8).repeatCount(3, autoreverses: true)) {
                    showGlow = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                    showGlow = false
                }
            }
        }
    }
}

// MARK: - Insight Card
struct InsightCard: View {
    let sex: BiologicalSex
    
    var insight: (icon: String, text: String, color: Color) {
        switch sex {
        case .male:
            return ("bolt.fill", "Males typically have higher caloric needs and muscle mass", .blue)
        case .female:
            return ("heart.fill", "Females have unique nutritional needs that vary with life stages", .pink)
        case .other:
            return ("star.fill", "We'll use personalized data to create your optimal plan", .purple)
        case .preferNotToSay:
            return ("shield.fill", "Your privacy is respected - we'll use average values", .gray)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: insight.icon)
                .font(.system(size: 20))
                .foregroundColor(insight.color)
            
            Text(insight.text)
                .font(PlateUpTypography.caption1)
                .foregroundColor(.plateUpPrimaryText)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(insight.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(insight.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
struct BiologicalSexView_Previews: PreviewProvider {
    static var previews: some View {
        BiologicalSexView(flowManager: OnboardingFlowManager.preview)
            .applyDarkTheme()
    }
}