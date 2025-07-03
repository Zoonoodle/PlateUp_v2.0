//
//  MultiGoalSelectionView.swift
//  PlateUp v2.0
//
//  Screen 3: Multi-goal selection (2-4 goals)
//

import SwiftUI

struct MultiGoalSelectionView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var showContent = false
    @State private var selectionError = false
    
    let goals: [(Color.HealthGoal, String, String, String)] = [
        (.weightLoss, "Weight Loss", "Lose weight sustainably", "figure.walk"),
        (.muscleGain, "Muscle Gain", "Build lean muscle mass", "figure.strengthtraining.traditional"),
        (.betterSleep, "Better Sleep", "Improve sleep quality", "bed.double"),
        (.moreEnergy, "More Energy", "Boost daily energy levels", "bolt.circle"),
        (.gutHealth, "Gut Health", "Improve digestive health", "heart.circle"),
        (.generalHealth, "General Health", "Overall wellness improvement", "sparkles")
    ]
    
    var body: some View {
        OnboardingContainer(currentStep: 3) {
            VStack(spacing: 24) {
                headerSection
                
                goalSelectionGrid
                
                errorMessage
                
                Spacer(minLength: 20)
                
                continueButton
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("What are your health goals?")
                .font(PlateUpTypography.largeTitle)
                .foregroundColor(.plateUpPrimaryText)
                .multilineTextAlignment(.center)
                .opacity(showContent ? 1 : 0)
            
            Text("Select 2-4 goals that matter most to you")
                .font(PlateUpTypography.body)
                .foregroundColor(.plateUpSecondaryText)
                .opacity(showContent ? 1 : 0)
            
            selectionIndicator
        }
    }
    
    private var selectionIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<4) { index in
                Circle()
                    .fill(index < flowManager.selectedGoals.count ? Color.plateUpGreen : Color.plateUpBorder)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.top, 4)
        .opacity(showContent ? 1 : 0)
    }
    
    private var goalSelectionGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(Array(goals.enumerated()), id: \.0) { index, goalData in
                GoalSelectionCard(
                    goal: goalData.0,
                    title: goalData.1,
                    description: goalData.2,
                    icon: goalData.3,
                    isSelected: flowManager.selectedGoals.contains(goalData.0),
                    action: {
                        toggleGoalSelection(goalData.0)
                    }
                )
                .opacity(showContent ? 1 : 0)
            }
        }
    }
    
    @ViewBuilder
    private var errorMessage: some View {
        if selectionError {
            Text("Please select between 2 and 4 goals")
                .font(PlateUpTypography.caption1)
                .foregroundColor(.plateUpError)
        }
    }
    
    private var continueButton: some View {
        NavigationButton(
            title: "Continue",
            isEnabled: flowManager.canProceed(),
            action: {
                if flowManager.canProceed() {
                    flowManager.navigateNext()
                } else {
                    showSelectionError()
                }
            }
        )
        .opacity(showContent ? 1 : 0)
    }
    
    private func toggleGoalSelection(_ goal: Color.HealthGoal) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if flowManager.selectedGoals.contains(goal) {
                flowManager.selectedGoals.remove(goal)
            } else if flowManager.selectedGoals.count < 4 {
                flowManager.selectedGoals.insert(goal)
                selectionError = false
            } else {
                showSelectionError()
            }
        }
    }
    
    private func showSelectionError() {
        withAnimation {
            selectionError = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                selectionError = false
            }
        }
    }
}

// MARK: - Preview
struct MultiGoalSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        MultiGoalSelectionView(flowManager: OnboardingFlowManager())
            .applyDarkTheme()
    }
}