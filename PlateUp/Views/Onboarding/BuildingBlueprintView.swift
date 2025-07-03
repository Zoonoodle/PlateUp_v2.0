//
//  BuildingBlueprintView.swift
//  PlateUp v2.0
//
//  Screen 17: Building blueprint loading screen
//

import SwiftUI

struct BuildingBlueprintView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var showContent = false
    @State private var progressValue: Double = 0.0
    @State private var currentStep = 0
    @State private var isComplete = false
    
    let buildingSteps = [
        ("🔍", "Analyzing your goals and preferences"),
        ("🧬", "Creating your unique nutrition profile"),
        ("📊", "Calculating personalized recommendations"),
        ("🎯", "Setting up your coaching system"),
        ("✨", "Your blueprint is ready!")
    ]
    
    var body: some View {
        OnboardingContainer(currentStep: 17) {
            VStack(spacing: 32) {
                Spacer()
                
                // Main title
                Text("Building your personalized health blueprint")
                    .font(PlateUpTypography.title1)
                    .foregroundColor(.plateUpPrimaryText)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                
                // Progress circle
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.plateUpSecondary.opacity(0.3), lineWidth: 8)
                        .frame(width: 120, height: 120)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: progressValue)
                        .stroke(
                            LinearGradient(
                                colors: [.plateUpAccent, .plateUpAccent.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.8), value: progressValue)
                    
                    // Center content
                    VStack(spacing: 4) {
                        Text(buildingSteps[currentStep].0)
                            .font(.system(size: 32))
                            .scaleEffect(isComplete ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isComplete)
                        
                        if !isComplete {
                            Text("\(Int(progressValue * 100))%")
                                .font(PlateUpTypography.caption1)
                                .fontWeight(.medium)
                                .foregroundColor(.plateUpSecondaryText)
                        }
                    }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                
                // Current step text
                Text(buildingSteps[currentStep].1)
                    .font(PlateUpTypography.body)
                    .foregroundColor(.plateUpSecondaryText)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
                    .id("step-\(currentStep)") // Force view refresh
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                
                Spacer()
                
                // Fun facts while waiting
                if !isComplete {
                    VStack(spacing: 8) {
                        Text("💡 Did you know?")
                            .font(PlateUpTypography.caption1)
                            .fontWeight(.medium)
                            .foregroundColor(.plateUpAccent)
                        
                        Text(getCurrentFunFact())
                            .font(PlateUpTypography.caption2)
                            .foregroundColor(.plateUpSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
                }
                
                // Continue button (only when complete)
                if isComplete {
                    NavigationButton(
                        title: "See my blueprint",
                        action: { flowManager.navigateNext() }
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.easeOut(duration: 0.5).delay(0.5), value: isComplete)
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
            startBuildingProcess()
        }
    }
    
    func startBuildingProcess() {
        // Simulate building process with realistic timing
        let stepDurations: [Double] = [1.5, 2.0, 1.8, 1.2, 1.0] // Seconds for each step
        
        var totalTime: Double = 0
        
        for (index, duration) in stepDurations.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + totalTime) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentStep = index
                    progressValue = Double(index + 1) / Double(buildingSteps.count)
                }
                
                if index == buildingSteps.count - 1 {
                    // Final step
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            isComplete = true
                        }
                    }
                }
            }
            totalTime += duration
        }
    }
    
    func getCurrentFunFact() -> String {
        let facts = [
            "Your taste preferences can change in as little as 2 weeks with consistent exposure to new foods.",
            "The timing of your meals can affect your sleep quality and energy levels throughout the day.",
            "Eating slowly and mindfully can help you feel satisfied with smaller portions.",
            "The color of your plate can actually influence how much you eat and how satisfied you feel.",
            "Your gut microbiome is unique to you and plays a huge role in how you process different foods."
        ]
        return facts[currentStep % facts.count]
    }
}

// MARK: - Preview
struct BuildingBlueprintView_Previews: PreviewProvider {
    static var previews: some View {
        BuildingBlueprintView(flowManager: OnboardingFlowManager.preview)
            .applyDarkTheme()
    }
}