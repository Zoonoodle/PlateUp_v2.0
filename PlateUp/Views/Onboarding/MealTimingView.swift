//
//  MealTimingView.swift
//  PlateUp
//
//  Meal timing preferences selection (Lifestyle Screen 2 of 3)
//

import SwiftUI

struct MealTimingView: View {
    @Bindable var flowManager: OnboardingFlowManager
    
    var body: some View {
        OnboardingContainer(
            currentStep: 11
        ) {
            VStack(spacing: 32) {
                // Header - continued from previous screen
                VStack(spacing: 16) {
                    Text("Help us understand your lifestyle")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Your schedule and routines help us time your nutrition perfectly")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // Question
                Text("How do you prefer to time your meals?")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Options with icons
                VStack(spacing: 12) {
                    ForEach(MealTimingPreference.allCases, id: \.self) { timing in
                        MealTimingOptionCard(
                            title: timing.rawValue,
                            icon: getIcon(for: timing),
                            isSelected: flowManager.mealTimingPreference == timing,
                            action: {
                                flowManager.mealTimingPreference = timing
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Navigation buttons
                VStack(spacing: 12) {
                    Button(action: {
                        flowManager.navigateToNextScreen()
                    }) {
                        HStack {
                            Text("Continue")
                                .font(.system(size: 17, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.green)
                        .cornerRadius(28)
                    }
                    .disabled(flowManager.mealTimingPreference == nil)
                    .opacity(flowManager.mealTimingPreference == nil ? 0.6 : 1.0)
                    
                    Button(action: {
                        flowManager.navigateBack()
                    }) {
                        Text("Back")
                            .font(.system(size: 17))
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
    
    private func getIcon(for timing: MealTimingPreference) -> String {
        switch timing {
        case .regular:
            return "clock.badge.checkmark.fill"
        case .flexible:
            return "clock.arrow.2.circlepath"
        case .skipBreakfast:
            return "sunrise.fill"
        case .lateEater:
            return "moon.fill"
        case .intermittentFasting:
            return "timer"
        }
    }
}

// Meal timing option card component
struct MealTimingOptionCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .green : .gray)
                    .frame(width: 40)
                
                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.green.opacity(0.15) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    MealTimingView(flowManager: OnboardingFlowManager())
}