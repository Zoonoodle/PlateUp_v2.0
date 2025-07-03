//
//  OnboardingCoordinator.swift
//  PlateUp v2.0
//
//  Main coordinator for onboarding flow with smooth transitions
//

import SwiftUI

struct OnboardingCoordinator: View {
    @State private var flowManager = OnboardingFlowManager()
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            // Dark background
            Color.plateUpBackground
                .ignoresSafeArea()
            
            // Screen content with transitions
            Group {
                switch flowManager.currentScreen {
                case 1:
                    SplashView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 1.1)),
                            removal: .opacity.combined(with: .scale(scale: 0.9))
                        ))
                
                case 2:
                    DifferentiationView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 3:
                    MultiGoalSelectionView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 4:
                    PrimaryGoalView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 5:
                    SuccessVisionView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 6:
                    BiologicalSexView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 7:
                    AgeSelectionView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 8:
                    HeightSelectionView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 9:
                    WeightSelectionView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 10:
                    BodyTypeSelectionView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 11:
                    EnergyPatternsView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 12:
                    ExerciseFrequencyView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 13:
                    DailyActivityView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 14:
                    // Only show exercise types if they actually exercise
                    if flowManager.exerciseFrequency != ExerciseFrequency.none {
                        ExerciseTypesView(flowManager: flowManager)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else {
                        // Skip to work schedule
                        WorkScheduleView(flowManager: flowManager)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                            .onAppear {
                                flowManager.currentScreen = 15
                            }
                    }
                
                case 15:
                    WorkScheduleView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 16:
                    MealTimingView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 17:
                    LifestyleChallengesView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 18:
                    EatingChallengesView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 19:
                    HealthConsiderationsView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 20:
                    // Weight goals - conditional based on selected goals
                    if flowManager.selectedGoals.contains(.weightLoss) || flowManager.selectedGoals.contains(.muscleGain) {
                        WeightGoalsView(flowManager: flowManager)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else {
                        // Skip to guidance level
                        GuidanceLevelView(flowManager: flowManager)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                            .onAppear {
                                flowManager.currentScreen = 21
                            }
                    }
                
                case 21:
                    GuidanceLevelView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 22:
                    FeaturePreferencesView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 23:
                    IntegrationPreferencesView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 24:
                    BuildingBlueprintView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                case 25:
                    HealthBlueprintView(flowManager: flowManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                
                default:
                    // Placeholder for future screens
                    OnboardingContainer(currentStep: flowManager.currentScreen) {
                        VStack(spacing: 20) {
                            Text("Screen \(flowManager.currentScreen)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.plateUpPrimaryText)
                            
                            Text("Coming soon...")
                                .foregroundColor(.plateUpSecondaryText)
                            
                            NavigationButton(
                                title: "Next",
                                action: { flowManager.navigateNext() }
                            )
                            
                            NavigationButton(
                                title: "Back",
                                style: .text,
                                action: { flowManager.navigateBack() }
                            )
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: flowManager.currentScreen)
            
            // Loading overlay when processing
            if flowManager.isProcessing {
                LoadingOverlay(message: "Creating your personalized health blueprint...")
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(100)
            }
        }
    }
}

// MARK: - Preview
struct OnboardingCoordinator_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingCoordinator()
            .applyDarkTheme()
    }
}