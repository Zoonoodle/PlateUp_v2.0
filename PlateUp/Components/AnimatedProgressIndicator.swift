//
//  AnimatedProgressIndicator.swift
//  PlateUp v2.0
//
//  Enhanced progress indicator with milestone animations
//

import SwiftUI

struct AnimatedProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    @State private var animatedProgress: CGFloat = 0
    @State private var showMilestone = false
    
    // Define milestone phases
    private let milestones = [
        (phase: "Foundation", steps: 1...5, icon: "foundation.fill"),
        (phase: "Your Body", steps: 6...10, icon: "figure.walk"),
        (phase: "Lifestyle", steps: 11...15, icon: "slider.horizontal.3"),
        (phase: "Preferences", steps: 16...18, icon: "gear"),
        (phase: "Your Plan", steps: 19...22, icon: "doc.text.fill")
    ]
    
    private var currentMilestone: (phase: String, steps: ClosedRange<Int>, icon: String) {
        return milestones.first { $0.steps.contains(currentStep) } ?? milestones[0]
    }
    
    private var progressPercentage: CGFloat {
        return CGFloat(currentStep) / CGFloat(totalSteps)
    }
    
    private var isAtMilestone: Bool {
        return milestones.contains { $0.steps.upperBound == currentStep }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Main progress bar with milestones
            HStack(spacing: 0) {
                ForEach(milestones.indices, id: \.self) { index in
                    let milestone = milestones[index]
                    let isCompleted = currentStep > milestone.steps.upperBound
                    let isCurrent = milestone.steps.contains(currentStep)
                    let isUpcoming = currentStep < milestone.steps.lowerBound
                    
                    HStack(spacing: 0) {
                        // Milestone indicator
                        ZStack {
                            Circle()
                                .fill(getBackgroundColor(isCompleted: isCompleted, isCurrent: isCurrent))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.plateUpAccent, lineWidth: isCurrent ? 3 : 0)
                                        .scaleEffect(showMilestone && isCurrent ? 1.2 : 1.0)
                                )
                            
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.plateUpBackground)
                                    .scaleEffect(showMilestone ? 1.2 : 1.0)
                            } else {
                                Image(systemName: milestone.icon)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(isCurrent ? .plateUpAccent : .plateUpSecondaryText)
                                    .scaleEffect(showMilestone && isCurrent ? 1.1 : 1.0)
                            }
                        }
                        .scaleEffect(isCurrent ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentStep)
                        
                        // Connection line (except for last milestone)
                        if index < milestones.count - 1 {
                            Rectangle()
                                .fill(isCompleted ? Color.plateUpAccent : Color.plateUpSecondaryText.opacity(0.3))
                                .frame(height: 2)
                                .frame(maxWidth: .infinity)
                                .animation(.easeInOut(duration: 0.5), value: currentStep)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // Current phase info with animation
            VStack(spacing: 4) {
                HStack {
                    Text("\(currentMilestone.phase)")
                        .font(PlateUpTypography.headline)
                        .foregroundColor(.plateUpAccent)
                        .scaleEffect(showMilestone ? 1.05 : 1.0)
                    
                    if isAtMilestone {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.plateUpAccent)
                            .scaleEffect(showMilestone ? 1.2 : 0.8)
                            .opacity(showMilestone ? 1.0 : 0.0)
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentStep)
                
                // Animated progress text
                Text("Step \(currentStep) of \(currentMilestone.steps.upperBound)")
                    .font(PlateUpTypography.caption1)
                    .foregroundColor(.plateUpSecondaryText)
                    .opacity(0.8)
            }
            
            // Celebration animation for milestones
            if isAtMilestone && showMilestone {
                HStack(spacing: 4) {
                    Image(systemName: "party.popper.fill")
                        .font(.caption)
                        .foregroundColor(.plateUpAccent)
                    
                    Text("Milestone reached!")
                        .font(PlateUpTypography.caption2)
                        .foregroundColor(.plateUpAccent)
                        .fontWeight(.medium)
                    
                    Image(systemName: "party.popper.fill")
                        .font(.caption)
                        .foregroundColor(.plateUpAccent)
                        .scaleEffect(x: -1, y: 1)
                }
                .scaleEffect(showMilestone ? 1.0 : 0.5)
                .opacity(showMilestone ? 1.0 : 0.0)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            // Animate progress on appear
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedProgress = progressPercentage
            }
            
            // Show milestone celebration if appropriate
            if isAtMilestone {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        showMilestone = true
                    }
                    
                    // Hide celebration after a moment
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showMilestone = false
                        }
                    }
                }
            }
        }
        .onChange(of: currentStep) { oldValue, newValue in
            // Animate progress changes
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedProgress = progressPercentage
            }
            
            // Show milestone celebration for new milestones
            let newMilestone = milestones.first { $0.steps.upperBound == newValue }
            if newMilestone != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showMilestone = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showMilestone = false
                        }
                    }
                }
            }
        }
    }
    
    private func getBackgroundColor(isCompleted: Bool, isCurrent: Bool) -> Color {
        if isCompleted {
            return .plateUpAccent
        } else if isCurrent {
            return .plateUpAccent.opacity(0.2)
        } else {
            return .plateUpSecondaryText.opacity(0.2)
        }
    }
}

// MARK: - Preview
struct AnimatedProgressIndicator_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            AnimatedProgressIndicator(currentStep: 1, totalSteps: 19)
            AnimatedProgressIndicator(currentStep: 5, totalSteps: 19)
            AnimatedProgressIndicator(currentStep: 10, totalSteps: 19)
            AnimatedProgressIndicator(currentStep: 19, totalSteps: 19)
        }
        .padding()
        .applyDarkTheme()
    }
}