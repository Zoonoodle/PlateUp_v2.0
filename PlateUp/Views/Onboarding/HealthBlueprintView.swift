//
//  HealthBlueprintView.swift
//  PlateUp v2.0
//
//  Screen 18: Display personalized health blueprint
//

import SwiftUI

struct HealthBlueprintView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var showContent = false
    @State private var showCards = false
    
    var body: some View {
        OnboardingContainer(currentStep: 18) {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Your Personalized Health Blueprint")
                            .font(PlateUpTypography.title1)
                            .foregroundColor(.plateUpPrimaryText)
                            .multilineTextAlignment(.center)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        Text("Based on your goals and preferences, here's what we've created for you")
                            .font(PlateUpTypography.body)
                            .foregroundColor(.plateUpSecondaryText)
                            .multilineTextAlignment(.center)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
                    }
                    
                    // Primary goal highlight
                    if let primaryGoal = flowManager.primaryGoal {
                        BlueprintCard(
                            title: "Your Primary Focus",
                            content: getPrimaryGoalDescription(primaryGoal),
                            icon: getPrimaryGoalIcon(primaryGoal),
                            isPrimary: true
                        )
                        .opacity(showCards ? 1 : 0)
                        .offset(y: showCards ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: showCards)
                    }
                    
                    // Success vision
                    if !flowManager.successVision.isEmpty {
                        BlueprintCard(
                            title: "Your 90-Day Vision",
                            content: flowManager.successVision,
                            icon: "🎯"
                        )
                        .opacity(showCards ? 1 : 0)
                        .offset(y: showCards ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: showCards)
                    }
                    
                    // Personalized recommendations
                    BlueprintCard(
                        title: "Your Coaching Style",
                        content: getCoachingStyleDescription(),
                        icon: "🧠"
                    )
                    .opacity(showCards ? 1 : 0)
                    .offset(y: showCards ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: showCards)
                    
                    // Key features
                    BlueprintCard(
                        title: "Your Priority Features",
                        content: getFeatureDescription(),
                        icon: "⭐"
                    )
                    .opacity(showCards ? 1 : 0)
                    .offset(y: showCards ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.5), value: showCards)
                    
                    // Special considerations
                    if !flowManager.eatingChallenges.isEmpty {
                        BlueprintCard(
                            title: "We'll Help You With",
                            content: getChallengesDescription(),
                            icon: "💪"
                        )
                        .opacity(showCards ? 1 : 0)
                        .offset(y: showCards ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.6), value: showCards)
                    }
                    
                    // Next steps preview
                    VStack(spacing: 16) {
                        Text("What happens next:")
                            .font(PlateUpTypography.headline)
                            .foregroundColor(.plateUpPrimaryText)
                        
                        VStack(spacing: 12) {
                            NextStepItem(icon: "📱", text: "Explore your personalized dashboard")
                            NextStepItem(icon: "📸", text: "Log your first meal to see PlateUp in action")
                            NextStepItem(icon: "🎓", text: "Start receiving daily insights tailored to you")
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.plateUpAccent.opacity(0.1))
                    )
                    .opacity(showCards ? 1 : 0)
                    .offset(y: showCards ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.7), value: showCards)
                    
                    // Navigation button
                    NavigationButton(
                        title: "Let's start my journey",
                        action: { flowManager.navigateNext() }
                    )
                    .opacity(showCards ? 1 : 0)
                    .offset(y: showCards ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.8), value: showCards)
                }
                .padding()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showCards = true
                }
            }
        }
    }
    
    // Helper functions for generating descriptions
    func getPrimaryGoalDescription(_ goal: Color.HealthGoal) -> String {
        switch goal {
        case .weightLoss:
            return "Focus on sustainable weight loss through balanced nutrition and portion awareness. We'll help you make gradual changes that stick."
        case .muscleGain:
            return "Optimize your nutrition for muscle growth with proper protein timing and balanced macronutrients to support your training."
        case .betterSleep:
            return "Improve your sleep quality through strategic meal timing and foods that promote better rest and recovery."
        case .moreEnergy:
            return "Boost your daily energy through optimized nutrition timing and foods that provide sustained fuel throughout the day."
        case .gutHealth:
            return "Support your digestive health with foods and timing that promote a healthy gut microbiome and comfortable digestion."
        case .generalHealth:
            return "Build sustainable healthy habits that support your overall wellbeing and create a foundation for long-term health."
        }
    }
    
    func getPrimaryGoalIcon(_ goal: Color.HealthGoal) -> String {
        switch goal {
        case .weightLoss: return "⚖️"
        case .muscleGain: return "💪"
        case .betterSleep: return "😴"
        case .moreEnergy: return "⚡"
        case .gutHealth: return "🌱"
        case .generalHealth: return "🌟"
        }
    }
    
    func getCoachingStyleDescription() -> String {
        var description = ""
        
        if let learningStyle = flowManager.learningStyle {
            switch learningStyle {
            case .showMeData:
                description += "We'll show you detailed charts and trends to help you understand your patterns. "
            case .keepItSimple:
                description += "We'll keep things simple with clear, actionable recommendations without overwhelming details. "
            case .explainWhy:
                description += "We'll explain the science behind our recommendations so you understand the reasoning. "
            case .learnFromOthers:
                description += "We'll share community insights and tips from others with similar goals. "
            case .letMeExperiment:
                description += "We'll give you options to try and see what works best for your unique situation. "
            }
        }
        
        if let guidanceLevel = flowManager.guidanceLevel {
            switch guidanceLevel {
            case .lightTouch:
                description += "You'll receive gentle, occasional guidance when you need it most."
            case .balanced:
                description += "You'll get daily check-ins and weekly insights to stay on track."
            case .deepDive:
                description += "You'll receive comprehensive analysis and detailed coaching throughout your journey."
            }
        }
        
        return description.isEmpty ? "Personalized coaching tailored to your preferences." : description
    }
    
    func getFeatureDescription() -> String {
        let topFeatures = Array(flowManager.featurePreferences.prefix(3))
        if topFeatures.isEmpty {
            return "A comprehensive set of features to support your health journey."
        }
        
        let featureNames = topFeatures.map { preference in
            switch preference {
            case .photoLogging: return "photo-based food logging"
            case .calorieTracking: return "calorie and macro tracking"
            case .foodQuality: return "food quality insights"
            case .mealPlanning: return "meal planning assistance"
            case .progressTracking: return "progress tracking and trends"
            case .energyTracking: return "energy level monitoring"
            case .sleepOptimization: return "sleep optimization"
            case .moodMonitoring: return "mood and stress tracking"
            case .dailyTips: return "daily tips and education"
            case .smartReminders: return "smart reminders"
            case .exerciseIntegration: return "exercise integration"
            }
        }
        
        return "Your dashboard will prioritize " + featureNames.joined(separator: ", ") + " to match your interests."
    }
    
    func getChallengesDescription() -> String {
        let challenges = Array(flowManager.eatingChallenges.prefix(3))
        if challenges.isEmpty {
            return "Overcome common eating challenges with personalized strategies."
        }
        
        return "We've identified your main challenges and will provide specific strategies to help you overcome them while building sustainable habits."
    }
}

// MARK: - Blueprint Card
struct BlueprintCard: View {
    let title: String
    let content: String
    let icon: String
    var isPrimary: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: isPrimary ? 32 : 24))
                
                Text(title)
                    .font(isPrimary ? PlateUpTypography.title2 : PlateUpTypography.headline)
                    .fontWeight(isPrimary ? .bold : .medium)
                    .foregroundColor(.plateUpPrimaryText)
                
                Spacer()
            }
            
            Text(content)
                .font(PlateUpTypography.body)
                .foregroundColor(.plateUpSecondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isPrimary ? Color.plateUpAccent.opacity(0.15) : Color.plateUpSecondary.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isPrimary ? Color.plateUpAccent : Color.clear,
                            lineWidth: isPrimary ? 2 : 0
                        )
                )
        )
    }
}

// MARK: - Next Step Item
struct NextStepItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 20))
            
            Text(text)
                .font(PlateUpTypography.body)
                .foregroundColor(.plateUpPrimaryText)
            
            Spacer()
        }
    }
}

// MARK: - Preview
struct HealthBlueprintView_Previews: PreviewProvider {
    static var previews: some View {
        HealthBlueprintView(flowManager: OnboardingFlowManager.preview)
            .applyDarkTheme()
    }
}