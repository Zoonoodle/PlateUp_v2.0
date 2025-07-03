//
//  OnboardingProgressIndicator.swift
//  PlateUp v2.0
//
//  Progress indicator with milestone celebrations
//

import SwiftUI

struct OnboardingProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int = 12
    @State private var showCelebration = false
    
    private var progress: CGFloat {
        CGFloat(currentStep) / CGFloat(totalSteps)
    }
    
    private var milestones: [Int] {
        [3, 6, 9, 12] // Celebrate at 25%, 50%, 75%, and 100%
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.plateUpTertiaryBackground)
                        .frame(height: 8)
                    
                    // Progress fill with solid color
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.plateUpGreen)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                    
                    // Milestone markers
                    ForEach(milestones, id: \.self) { milestone in
                        if currentStep >= milestone {
                            Circle()
                                .fill(Color.plateUpGreen)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 8))
                                        .foregroundColor(.white)
                                )
                                .position(
                                    x: geometry.size.width * (CGFloat(milestone) / CGFloat(totalSteps)),
                                    y: 4
                                )
                                .scaleEffect(showCelebration && currentStep == milestone ? 1.3 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCelebration)
                        }
                    }
                }
            }
            .frame(height: 8)
            
            // Step counter
            HStack {
                Text("Step \(currentStep) of \(totalSteps)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.plateUpForestGreen)
                
                Spacer()
                
                if milestones.contains(currentStep) {
                    Text("Milestone reached!")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.plateUpBrightGreen)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .padding(.horizontal)
        .onChange(of: currentStep) { _, newValue in
            if milestones.contains(newValue) {
                triggerCelebration()
            }
        }
    }
    
    private func triggerCelebration() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            showCelebration = true
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                showCelebration = false
            }
        }
    }
}

// MARK: - Preview
struct OnboardingProgressIndicator_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            OnboardingProgressIndicator(currentStep: 3)
            OnboardingProgressIndicator(currentStep: 6)
            OnboardingProgressIndicator(currentStep: 9)
            OnboardingProgressIndicator(currentStep: 12)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}