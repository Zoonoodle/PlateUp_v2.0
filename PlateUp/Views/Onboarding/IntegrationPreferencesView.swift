//
//  IntegrationPreferencesView.swift
//  PlateUp v2.0
//
//  Screen 16: Integration preferences for other apps/devices
//

import SwiftUI

struct IntegrationPreferencesView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var showContent = false
    @State private var selectedIntegrations: Set<IntegrationPreference> = []
    
    let integrations = [
        (IntegrationPreference.appleHealth, "❤️", "Apple Health/Google Fit", "Sync health data automatically"),
        (IntegrationPreference.appleWatch, "⌚", "Apple Watch/Fitness tracker", "Track workouts and activity"),
        (IntegrationPreference.sleepTracking, "😴", "Sleep tracking apps", "Connect sleep data for insights"),
        (IntegrationPreference.meditation, "🧘", "Meditation apps", "Track stress and mindfulness"),
        (IntegrationPreference.otherHealth, "🏥", "Other health apps", "Connect additional health tools"),
        (IntegrationPreference.keepItSimple, "✨", "Keep it simple - just PlateUp", "Start with PlateUp only")
    ]
    
    var body: some View {
        OnboardingContainer(currentStep: 16) {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text("Want to connect other apps or devices?")
                        .font(PlateUpTypography.title1)
                        .foregroundColor(.plateUpPrimaryText)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    Text("Integrations help us provide better insights, but they're totally optional")
                        .font(PlateUpTypography.body)
                        .foregroundColor(.plateUpSecondaryText)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
                }
                
                // Integration options
                VStack(spacing: 16) {
                    ForEach(integrations.indices, id: \.self) { index in
                        let integration = integrations[index]
                        IntegrationCard(
                            emoji: integration.1,
                            title: integration.2,
                            subtitle: integration.3,
                            isSelected: selectedIntegrations.contains(integration.0),
                            isExclusive: integration.0 == .keepItSimple,
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    if integration.0 == .keepItSimple {
                                        // "Keep it simple" is exclusive
                                        if selectedIntegrations.contains(.keepItSimple) {
                                            selectedIntegrations.remove(.keepItSimple)
                                        } else {
                                            selectedIntegrations.removeAll()
                                            selectedIntegrations.insert(.keepItSimple)
                                        }
                                    } else {
                                        // Other integrations remove "keep it simple"
                                        selectedIntegrations.remove(.keepItSimple)
                                        if selectedIntegrations.contains(integration.0) {
                                            selectedIntegrations.remove(integration.0)
                                        } else {
                                            selectedIntegrations.insert(integration.0)
                                        }
                                    }
                                    flowManager.integrationPreferences = selectedIntegrations
                                }
                            }
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.2 + Double(index) * 0.05), value: showContent)
                    }
                }
                
                // Helper text
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.plateUpAccent.opacity(0.7))
                            .font(.caption)
                        
                        Text("You can always change these settings later in the app")
                            .font(PlateUpTypography.caption2)
                            .foregroundColor(.plateUpSecondaryText)
                    }
                    
                    if !selectedIntegrations.isEmpty && !selectedIntegrations.contains(.keepItSimple) {
                        Text("We'll request permissions for selected integrations after setup")
                            .font(PlateUpTypography.caption2)
                            .foregroundColor(.plateUpSecondaryText.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.plateUpAccent.opacity(0.1))
                )
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
                
                Spacer()
                
                // Navigation buttons
                VStack(spacing: 12) {
                    NavigationButton(
                        title: getButtonTitle(),
                        isEnabled: true,
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
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }
    
    func getButtonTitle() -> String {
        if selectedIntegrations.isEmpty {
            return "Skip integrations for now"
        } else if selectedIntegrations.contains(.keepItSimple) {
            return "Keep it simple"
        } else {
            return "Set up these integrations"
        }
    }
}

// MARK: - Integration Card
struct IntegrationCard: View {
    let emoji: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let isExclusive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(emoji)
                    .font(.system(size: 32))
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(PlateUpTypography.headline)
                        .foregroundColor(.plateUpPrimaryText)
                    
                    Text(subtitle)
                        .font(PlateUpTypography.caption1)
                        .foregroundColor(.plateUpSecondaryText)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .plateUpAccent : .plateUpSecondaryText)
                    .font(.title2)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.plateUpAccent.opacity(0.15) : Color.plateUpSecondary.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.plateUpAccent : (isExclusive ? Color.plateUpAccent.opacity(0.5) : Color.clear),
                                lineWidth: isExclusive ? 1 : 2
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
    }
}

// MARK: - Preview
struct IntegrationPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        IntegrationPreferencesView(flowManager: OnboardingFlowManager.preview)
            .applyDarkTheme()
    }
}