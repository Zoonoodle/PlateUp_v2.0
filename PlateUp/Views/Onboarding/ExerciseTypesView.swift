//
//  ExerciseTypesView.swift
//  PlateUp
//
//  Exercise types selection (Activity Screen 3 of 3)
//

import SwiftUI

struct ExerciseTypesView: View {
    @Bindable var flowManager: OnboardingFlowManager
    
    var body: some View {
        OnboardingContainer(
            currentStep: 8
        ) {
            VStack(spacing: 32) {
                // Header - continued from previous screens
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
                VStack(alignment: .leading, spacing: 8) {
                    Text("What types of exercise do you do?")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Select all that apply")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Exercise type grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(ExerciseType.allCases, id: \.self) { type in
                        ExerciseTypeCard(
                            title: type.rawValue,
                            icon: getIcon(for: type),
                            isSelected: flowManager.exerciseTypes.contains(type),
                            action: {
                                if flowManager.exerciseTypes.contains(type) {
                                    flowManager.exerciseTypes.remove(type)
                                } else {
                                    flowManager.exerciseTypes.insert(type)
                                }
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
    
    private func getIcon(for type: ExerciseType) -> String {
        switch type {
        case .cardio:
            return "heart.circle.fill"
        case .weightlifting:
            return "dumbbell.fill"
        case .yoga:
            return "figure.yoga"
        case .sports:
            return "sportscourt.fill"
        case .walking:
            return "figure.walk.motion"
        case .cycling:
            return "bicycle"
        case .swimming:
            return "figure.pool.swim"
        }
    }
}

// Exercise type card component
struct ExerciseTypeCard: View {
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
    ExerciseTypesView(flowManager: OnboardingFlowManager())
}