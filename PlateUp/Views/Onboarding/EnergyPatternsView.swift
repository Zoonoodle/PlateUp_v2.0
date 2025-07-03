//
//  EnergyPatternsView.swift
//  PlateUp v2.0
//
//  Screen 7: Energy patterns throughout the day
//

import SwiftUI

struct EnergyPatternsView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var showContent = false
    
    var body: some View {
        OnboardingContainer(currentStep: 7) {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text("When do you feel most energized?")
                        .font(PlateUpTypography.title1)
                        .foregroundColor(.plateUpPrimaryText)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    Text("Understanding your natural energy patterns helps us time your meals perfectly")
                        .font(PlateUpTypography.body)
                        .foregroundColor(.plateUpSecondaryText)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
                }
                
                // Energy pattern options
                VStack(spacing: 12) {
                    ForEach(Array(EnergyPattern.allCases.enumerated()), id: \.element) { index, pattern in
                        EnergyPatternCard(
                            pattern: pattern,
                            isSelected: flowManager.selectedEnergyPattern == pattern,
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    flowManager.selectedEnergyPattern = pattern
                                }
                            }
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.1 + 0.2), value: showContent)
                    }
                }
                
                Spacer()
                
                // Info box
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.plateUpGreen)
                        Text("Why this matters")
                            .font(PlateUpTypography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.plateUpPrimaryText)
                        Spacer()
                    }
                    
                    Text("Your energy pattern helps us recommend the best times to eat for sustained energy throughout your day.")
                        .font(PlateUpTypography.caption1)
                        .foregroundColor(.plateUpSecondaryText)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(Color.plateUpGreen.opacity(0.1))
                .cornerRadius(PlateUpComponentStyle.mediumRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                        .stroke(Color.plateUpGreen.opacity(0.3), lineWidth: 1)
                )
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.6), value: showContent)
                
                // Buttons
                VStack(spacing: 12) {
                    NavigationButton(
                        title: "Continue",
                        isEnabled: flowManager.canProceed(),
                        action: {
                            flowManager.navigateNext()
                        }
                    )
                    
                    NavigationButton(
                        title: "Back",
                        style: .text,
                        action: {
                            flowManager.navigateBack()
                        }
                    )
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.7), value: showContent)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
}

// MARK: - Energy Pattern Card
struct EnergyPatternCard: View {
    let pattern: EnergyPattern
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var patternIcon: String {
        switch pattern {
        case .morningPerson: return "sunrise.fill"
        case .nightOwl: return "moon.stars.fill"
        case .consistent: return "chart.line.flattrend.xyaxis"
        case .afternoon: return "sun.max.fill"
        }
    }
    
    var patternDescription: String {
        switch pattern {
        case .morningPerson: return "I'm most energized in the morning"
        case .nightOwl: return "I come alive in the evening"
        case .consistent: return "My energy stays pretty steady"
        case .afternoon: return "I crash in the afternoon"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.plateUpGreen : Color.plateUpTertiaryBackground)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: patternIcon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(isSelected ? .white : .plateUpSecondaryText)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(pattern.rawValue)
                        .font(PlateUpTypography.headline)
                        .foregroundColor(.plateUpPrimaryText)
                    
                    Text(patternDescription)
                        .font(PlateUpTypography.caption1)
                        .foregroundColor(.plateUpSecondaryText)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.plateUpGreen)
                        .font(.title3)
                }
            }
            .padding()
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
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents(
            onPress: {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                    isPressed = true
                }
            },
            onRelease: {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                    isPressed = false
                }
            }
        )
    }
}

// MARK: - Preview
struct EnergyPatternsView_Previews: PreviewProvider {
    static var previews: some View {
        let flowManager = OnboardingFlowManager.preview
        flowManager.selectedEnergyPattern = .morningPerson
        
        return EnergyPatternsView(flowManager: flowManager)
            .applyDarkTheme()
    }
}