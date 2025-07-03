//
//  WeightGoalsView.swift
//  PlateUp
//
//  Weight goals selection with proper layout
//

import SwiftUI

struct WeightGoalsView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var selectedGoalType: WeightGoalType?
    
    var body: some View {
        OnboardingContainer(
            currentStep: 12
        ) {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Text("Let's talk about your weight goals")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Most people aren't sure about specifics - that's totally normal")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // Goal Type Selection
                VStack(spacing: 16) {
                    ForEach(WeightGoalType.allCases, id: \.self) { goalType in
                        WeightGoalOptionCard(
                            icon: getIcon(for: goalType),
                            title: getTitle(for: goalType),
                            subtitle: getSubtitle(for: goalType),
                            isSelected: selectedGoalType == goalType,
                            action: {
                                selectedGoalType = goalType
                                flowManager.weightGoalType = goalType
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Helper text
                VStack(spacing: 12) {
                    Text("Remember: sustainable changes happen gradually. We'll help you set realistic expectations.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Navigation buttons
                VStack(spacing: 12) {
                    Button(action: {
                        flowManager.navigateToNextScreen()
                    }) {
                        HStack {
                            Text("That sounds right")
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
                    .disabled(selectedGoalType == nil)
                    .opacity(selectedGoalType == nil ? 0.6 : 1.0)
                    
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
        .onAppear {
            selectedGoalType = flowManager.weightGoalType
        }
    }
    
    func getIcon(for goalType: WeightGoalType) -> String {
        switch goalType {
        case .specificTarget: return "🎯"
        case .notSureAboutNumbers: return "💭"
        case .feelBetterInBody: return "🤷"
        }
    }
    
    func getTitle(for goalType: WeightGoalType) -> String {
        switch goalType {
        case .specificTarget: return "I have a specific target"
        case .notSureAboutNumbers: return "I'm not sure about numbers"
        case .feelBetterInBody: return "I just want to feel better in my body"
        }
    }
    
    func getSubtitle(for goalType: WeightGoalType) -> String {
        switch goalType {
        case .specificTarget: return "Set a target weight and timeline"
        case .notSureAboutNumbers: return "Focus on direction, not specifics"
        case .feelBetterInBody: return "Health and wellness over numbers"
        }
    }
}

// Weight goal option card component
struct WeightGoalOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(icon)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .green : .gray)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.green.opacity(0.15) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.green : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    WeightGoalsView(flowManager: OnboardingFlowManager())
}