//
//  ExerciseFrequencyView.swift
//  PlateUp
//
//  Exercise frequency selection (Activity Screen 1 of 3)
//

import SwiftUI

struct ExerciseFrequencyView: View {
    @Bindable var flowManager: OnboardingFlowManager
    
    var body: some View {
        OnboardingContainer(
            currentStep: 8
        ) {
            VStack(spacing: 32) {
                // Header
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
                Text("How often do you exercise?")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Options with icons
                VStack(spacing: 12) {
                    ForEach(ExerciseFrequency.allCases, id: \.self) { frequency in
                        ActivityOptionCard(
                            title: frequency.rawValue,
                            icon: getIcon(for: frequency),
                            isSelected: flowManager.exerciseFrequency == frequency,
                            action: {
                                flowManager.exerciseFrequency = frequency
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
                    .disabled(flowManager.exerciseFrequency == nil)
                    .opacity(flowManager.exerciseFrequency == nil ? 0.6 : 1.0)
                    
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
    
    private func getIcon(for frequency: ExerciseFrequency) -> String {
        switch frequency {
        case .none:
            return "figure.walk.circle"
        case .occasional:
            return "calendar.badge.clock"
        case .regular:
            return "figure.run"
        case .frequent:
            return "figure.strengthtraining.traditional"
        case .daily:
            return "star.circle.fill"
        }
    }
}

// Activity option card component
struct ActivityOptionCard: View {
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
    ExerciseFrequencyView(flowManager: OnboardingFlowManager())
}