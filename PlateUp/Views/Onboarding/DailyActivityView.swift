//
//  DailyActivityView.swift
//  PlateUp
//
//  Daily activity level selection (Activity Screen 2 of 3)
//

import SwiftUI

struct DailyActivityView: View {
    @Bindable var flowManager: OnboardingFlowManager
    
    var body: some View {
        OnboardingContainer(
            currentStep: 8
        ) {
            VStack(spacing: 32) {
                // Header - continued from previous screen
                VStack(spacing: 16) {
                    Text("Tell us about your activity")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("This helps us calculate your daily calorie and protein needs")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // Question
                Text("How active are you outside of exercise?")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Options with icons
                VStack(spacing: 12) {
                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        ActivityOptionCard(
                            title: level.rawValue,
                            icon: getIcon(for: level),
                            isSelected: flowManager.activityLevel == level,
                            action: {
                                flowManager.activityLevel = level
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
                    .disabled(flowManager.activityLevel == nil)
                    .opacity(flowManager.activityLevel == nil ? 0.6 : 1.0)
                    
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
    
    private func getIcon(for level: ActivityLevel) -> String {
        switch level {
        case .sedentary:
            return "chair.fill"
        case .lightlyActive:
            return "figure.walk"
        case .moderatelyActive:
            return "figure.walk.motion"
        case .veryActive:
            return "figure.run.circle.fill"
        }
    }
}

#Preview {
    DailyActivityView(flowManager: OnboardingFlowManager())
}