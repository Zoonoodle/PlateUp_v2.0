//
//  FeaturePreferencesView.swift
//  PlateUp v2.0
//
//  Screen 15: Feature preferences selection
//

import SwiftUI

struct FeaturePreferencesView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var showContent = false
    @State private var selectedFeatures: Set<FeaturePreference> = []
    
    let features = [
        (FeaturePreference.photoLogging, "📸", "Photo-based food logging", "Snap a pic instead of typing"),
        (FeaturePreference.calorieTracking, "🔢", "Calorie/macro tracking", "Track your numbers"),
        (FeaturePreference.foodQuality, "🥬", "Food quality insights", "Learn about nutrition quality"),
        (FeaturePreference.mealPlanning, "📝", "Meal planning help", "Get recipe suggestions"),
        (FeaturePreference.progressTracking, "📊", "Progress tracking and trends", "See your patterns over time"),
        (FeaturePreference.energyTracking, "⚡", "Energy tracking", "Monitor how food affects energy"),
        (FeaturePreference.sleepOptimization, "😴", "Sleep optimization", "Improve sleep through nutrition"),
        (FeaturePreference.moodMonitoring, "😊", "Mood and stress monitoring", "Track emotional patterns"),
        (FeaturePreference.dailyTips, "💡", "Daily tips and education", "Learn something new daily"),
        (FeaturePreference.smartReminders, "🔔", "Smart reminders", "Gentle nudges at the right time"),
        (FeaturePreference.exerciseIntegration, "🏃", "Exercise integration", "Connect workouts with nutrition")
    ]
    
    var body: some View {
        OnboardingContainer(currentStep: 15) {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Which features interest you most?")
                            .font(PlateUpTypography.title1)
                            .foregroundColor(.plateUpPrimaryText)
                            .multilineTextAlignment(.center)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        Text("Select 3-5 features - we'll prioritize these in your experience")
                            .font(PlateUpTypography.body)
                            .foregroundColor(.plateUpSecondaryText)
                            .multilineTextAlignment(.center)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
                    }
                    
                    // Features grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(features.indices, id: \.self) { index in
                            let feature = features[index]
                            FeatureCard(
                                emoji: feature.1,
                                title: feature.2,
                                subtitle: feature.3,
                                isSelected: selectedFeatures.contains(feature.0),
                                isDisabled: selectedFeatures.count >= 5 && !selectedFeatures.contains(feature.0),
                                action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        if selectedFeatures.contains(feature.0) {
                                            selectedFeatures.remove(feature.0)
                                        } else if selectedFeatures.count < 5 {
                                            selectedFeatures.insert(feature.0)
                                        }
                                        flowManager.featurePreferences = selectedFeatures
                                    }
                                }
                            )
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.2 + Double(index) * 0.03), value: showContent)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Selection counter
                    HStack {
                        Text("\(selectedFeatures.count)/5 features selected")
                            .font(PlateUpTypography.caption1)
                            .foregroundColor(.plateUpSecondaryText)
                        
                        Spacer()
                        
                        if selectedFeatures.count >= 3 {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.plateUpAccent)
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
                    
                    // Navigation buttons
                    VStack(spacing: 12) {
                        NavigationButton(
                            title: selectedFeatures.count >= 3 ? "These look perfect" : "Select at least 3 features",
                            isEnabled: selectedFeatures.count >= 3,
                            action: { flowManager.navigateNext() }
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)
                        
                        NavigationButton(
                            title: "Back",
                            style: .text,
                            action: { flowManager.navigateBack() }
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.6), value: showContent)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }
}

// MARK: - Feature Card
struct FeatureCard: View {
    let emoji: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 28))
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(PlateUpTypography.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(.plateUpPrimaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(subtitle)
                        .font(PlateUpTypography.caption2)
                        .foregroundColor(.plateUpSecondaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.plateUpAccent.opacity(0.15) : Color.plateUpSecondary.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.plateUpAccent : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .disabled(isDisabled)
    }
}

// MARK: - Preview
struct FeaturePreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturePreferencesView(flowManager: OnboardingFlowManager.preview)
            .applyDarkTheme()
    }
}