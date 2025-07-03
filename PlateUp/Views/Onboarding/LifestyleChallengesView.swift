//
//  LifestyleChallengesView.swift
//  PlateUp
//
//  Lifestyle challenges selection (Lifestyle Screen 3 of 3)
//

import SwiftUI

struct LifestyleChallengesView: View {
    @Bindable var flowManager: OnboardingFlowManager
    
    var body: some View {
        OnboardingContainer(
            currentStep: 12
        ) {
            VStack(spacing: 32) {
                // Header - continued from previous screens
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
                VStack(alignment: .leading, spacing: 8) {
                    Text("What challenges do you face? (Optional)")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Select any that apply to help us personalize your plan")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Challenge grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(LifestyleChallenge.allCases, id: \.self) { challenge in
                        LifestyleChallengeCard(
                            title: challenge.rawValue,
                            icon: getIcon(for: challenge),
                            isSelected: flowManager.lifestyleChallenges.contains(challenge),
                            action: {
                                if flowManager.lifestyleChallenges.contains(challenge) {
                                    flowManager.lifestyleChallenges.remove(challenge)
                                } else {
                                    flowManager.lifestyleChallenges.insert(challenge)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Info box
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.green)
                        Text("Timing is everything")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    Text("We'll use your schedule to recommend the perfect meal timing for your goals and lifestyle.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                
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
    
    private func getIcon(for challenge: LifestyleChallenge) -> String {
        switch challenge {
        case .busySchedule:
            return "clock.fill"
        case .travelFrequently:
            return "airplane"
        case .irregularHours:
            return "clock.arrow.circlepath"
        case .limitedCookingTime:
            return "timer"
        case .eatOutOften:
            return "fork.knife"
        case .familyObligations:
            return "figure.2.and.child.holdinghands"
        }
    }
}

// Lifestyle challenge card component
struct LifestyleChallengeCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.green.opacity(0.15) : Color.gray.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(isSelected ? .green : .gray)
                }
                
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .green : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    LifestyleChallengesView(flowManager: OnboardingFlowManager())
}