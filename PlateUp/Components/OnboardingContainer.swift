//
//  OnboardingContainer.swift
//  PlateUp v2.0
//
//  Consistent container for onboarding screens
//

import SwiftUI

struct OnboardingContainer<Content: View>: View {
    let content: Content
    let showProgress: Bool
    let currentStep: Int
    let showSkip: Bool
    let skipAction: (() -> Void)?
    
    init(
        showProgress: Bool = true,
        currentStep: Int = 1,
        showSkip: Bool = false,
        skipAction: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.showProgress = showProgress
        self.currentStep = currentStep
        self.showSkip = showSkip
        self.skipAction = skipAction
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section with progress and skip
            if showProgress || showSkip {
                HStack {
                    if showProgress {
                        AnimatedProgressIndicator(currentStep: currentStep, totalSteps: 22)
                            .frame(maxWidth: .infinity)
                    }
                    
                    if showSkip, let skipAction = skipAction {
                        SkipButton(action: skipAction)
                            .padding(.trailing)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            
            // Main content with consistent padding
            ScrollView {
                VStack(spacing: 24) {
                    content
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
        .background(Color.plateUpBackground)
        .navigationBarHidden(true)
    }
}


// MARK: - Value Message View
struct ValueMessageView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.plateUpGreen)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(PlateUpTypography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.plateUpPrimaryText)
                
                Text(description)
                    .font(PlateUpTypography.caption1)
                    .foregroundColor(.plateUpSecondaryText)
            }
            
            Spacer()
        }
        .darkCard(padding: PlateUpComponentStyle.mediumSpacing, cornerRadius: PlateUpComponentStyle.mediumRadius)
    }
}

// MARK: - Preview
struct OnboardingContainer_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContainer(
            showProgress: true,
            currentStep: 3,
            showSkip: true,
            skipAction: {}
        ) {
            VStack(spacing: 20) {
                Text("Sample Onboarding Screen")
                    .font(PlateUpTypography.largeTitle)
                    .foregroundColor(.plateUpPrimaryText)
                
                ValueMessageView(
                    icon: "brain.head.profile",
                    title: "AI-Powered Insights",
                    description: "Get personalized nutrition coaching based on your unique goals"
                )
                
                NavigationButton(
                    title: "Continue",
                    action: {}
                )
            }
        }
        .applyDarkTheme()
        .overlay(
            LoadingOverlay(message: "Creating your personalized plan...")
        )
    }
}