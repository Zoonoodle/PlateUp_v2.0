//
//  OnboardingFlowManager.swift
//  PlateUp v2.0
//
//  State management for onboarding flow using @Observable
//

import SwiftUI
import Observation

@Observable
class OnboardingFlowManager {
    var currentScreen = 1
    var selections: [String: Any] = [:]
    var isProcessing = false
    var selectedGoals: Set<Color.HealthGoal> = []
    var primaryGoal: Color.HealthGoal?
    var successVision: String = ""
    
    // Body Basics (Screen 6)
    var height: Double = 0 // in cm
    var weight: Double = 0 // in kg
    var age: Int = 0
    var biologicalSex: BiologicalSex?
    var useMetricUnits: Bool = false
    
    // Energy Patterns (Screen 7)
    var energyLevels: [EnergyLevel] = []
    var selectedEnergyPattern: EnergyPattern?
    
    // Activity Level (Screen 8)
    var exerciseFrequency: ExerciseFrequency?
    var activityLevel: ActivityLevel?
    var exerciseTypes: Set<ExerciseType> = []
    
    // Lifestyle Context (Screen 9)
    var workSchedule: WorkSchedule?
    var mealTimingPreference: MealTimingPreference?
    var lifestyleChallenges: Set<LifestyleChallenge> = []
    
    // Eating Challenges (Screen 10)
    var eatingChallenges: Set<EatingChallenge> = []
    var dietaryRestrictions: Set<DietaryRestriction> = []
    var foodPreferences: Set<FoodPreference> = []
    
    // Weight Goals (Screen 12 - conditional)
    var weightGoalType: WeightGoalType?
    var targetWeight: Double = 0 // in kg
    var weightTimeline: WeightTimeline?
    var weightFocusArea: WeightFocusArea?
    
    // Learning Style (Screen 13)
    var learningStyle: LearningStyle?
    
    // Guidance Level (Screen 14)
    var guidanceLevel: GuidanceLevel?
    
    // Feature Preferences (Screen 15)
    var featurePreferences: Set<FeaturePreference> = []
    
    // Integration Preferences (Screen 16)
    var integrationPreferences: Set<IntegrationPreference> = []
    
    // Navigation states
    var shouldTransitionToNext = false
    var showValuePreview = false
    
    // Validation for each screen
    func canProceed() -> Bool {
        switch currentScreen {
        case 1: // Splash - auto-transitions
            return true
        case 2: // Differentiation - info only
            return true
        case 3: // Multi-goal selection
            return selectedGoals.count >= 2 && selectedGoals.count <= 4
        case 4: // Primary goal
            return primaryGoal != nil
        case 5: // Success vision
            return !successVision.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 6: // Body basics
            return height > 0 && weight > 0 && age > 0 && biologicalSex != nil
        case 7: // Energy patterns
            return selectedEnergyPattern != nil
        case 8: // Activity level
            return exerciseFrequency != nil && activityLevel != nil
        case 9: // Lifestyle context
            return workSchedule != nil && mealTimingPreference != nil
        case 10: // Eating challenges
            return true // Optional screen
        default:
            return true
        }
    }
    
    // Screen-specific data storage
    func saveCurrentScreenData() {
        switch currentScreen {
        case 3:
            selections["goals"] = Array(selectedGoals)
        case 4:
            selections["primaryGoal"] = primaryGoal
        case 5:
            selections["successVision"] = successVision
        default:
            break
        }
    }
    
    // Navigate to next screen
    func navigateNext() {
        saveCurrentScreenData()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentScreen += 1
        }
        
        // Auto-transition from splash
        if currentScreen == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showValuePreview = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigateNext()
                }
            }
        }
    }
    
    // Navigate to previous screen
    func navigateBack() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentScreen = max(1, currentScreen - 1)
        }
    }
    
    // Navigate to next screen (alias for consistency)
    func navigateToNextScreen() {
        navigateNext()
    }
    
    // Skip to a specific screen
    func skipToScreen(_ screen: Int) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentScreen = screen
        }
    }
    
    // Generate health blueprint (placeholder for now)
    func generateBlueprint() async {
        isProcessing = true
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        
        isProcessing = false
        currentScreen = 13 // Navigate to blueprint screen
    }
    
    // Smart suggestions for success vision
    func getVisionSuggestions() -> [String] {
        guard let primary = primaryGoal else { return [] }
        
        switch primary {
        case .weightLoss:
            return [
                "Feel confident and energetic in my favorite clothes",
                "Run a 5K without stopping",
                "Look and feel my best for my upcoming event"
            ]
        case .muscleGain:
            return [
                "See visible muscle definition and feel stronger",
                "Lift heavier weights with confidence",
                "Build a lean, athletic physique"
            ]
        case .betterSleep:
            return [
                "Wake up refreshed and energized every morning",
                "Fall asleep easily without tossing and turning",
                "Have consistent, restorative sleep every night"
            ]
        case .moreEnergy:
            return [
                "Power through my day without afternoon crashes",
                "Have energy to play with my kids after work",
                "Feel vibrant and focused throughout the day"
            ]
        case .gutHealth:
            return [
                "Enjoy meals without discomfort or bloating",
                "Have regular, comfortable digestion",
                "Feel light and comfortable after eating"
            ]
        case .generalHealth:
            return [
                "Feel strong, healthy, and capable every day",
                "Build sustainable healthy habits for life",
                "Be the healthiest version of myself"
            ]
        }
    }
}

// MARK: - Supporting Enums

enum BiologicalSex: String, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    case preferNotToSay = "Prefer not to say"
}

enum EnergyPattern: String, CaseIterable {
    case morningPerson = "Morning Person"
    case nightOwl = "Night Owl"
    case consistent = "Consistent Energy"
    case afternoon = "Afternoon Crasher"
}

struct EnergyLevel {
    let hour: Int
    let level: Int // 1-5
}

enum ExerciseFrequency: String, CaseIterable {
    case none = "I don't exercise"
    case occasional = "1-2 times per week"
    case regular = "3-4 times per week"
    case frequent = "5+ times per week"
    case daily = "Every day"
}

enum ActivityLevel: String, CaseIterable {
    case sedentary = "Mostly sitting"
    case lightlyActive = "Light activity"
    case moderatelyActive = "Moderate activity"
    case veryActive = "Very active"
}

enum ExerciseType: String, CaseIterable {
    case cardio = "Cardio"
    case weightlifting = "Weight training"
    case yoga = "Yoga/Pilates"
    case sports = "Sports"
    case walking = "Walking/Hiking"
    case cycling = "Cycling"
    case swimming = "Swimming"
}

enum WorkSchedule: String, CaseIterable {
    case traditional = "Traditional 9-5"
    case flexible = "Flexible hours"
    case shiftWork = "Shift work"
    case irregular = "Irregular schedule"
    case workFromHome = "Work from home"
    case partTime = "Part-time"
}

enum MealTimingPreference: String, CaseIterable {
    case regular = "Regular meal times"
    case flexible = "Flexible timing"
    case skipBreakfast = "I skip breakfast"
    case lateEater = "I eat late"
    case intermittentFasting = "I do intermittent fasting"
}

enum LifestyleChallenge: String, CaseIterable {
    case busySchedule = "Very busy schedule"
    case travelFrequently = "Travel frequently"
    case irregularHours = "Irregular work hours"
    case limitedCookingTime = "Limited time to cook"
    case eatOutOften = "Eat out often"
    case familyObligations = "Family meal obligations"
}

enum EatingChallenge: String, CaseIterable {
    case emotionalEating = "Emotional eating"
    case lateNightSnacking = "Late night snacking"
    case portionControl = "Portion control"
    case cravings = "Sugar/carb cravings"
    case socialEating = "Overeating in social situations"
    case stressEating = "Stress eating"
    case boredomEating = "Boredom eating"
}

enum DietaryRestriction: String, CaseIterable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten-free"
    case dairyFree = "Dairy-free"
    case keto = "Keto"
    case paleo = "Paleo"
    case lowCarb = "Low-carb"
    case mediterranean = "Mediterranean"
}

enum FoodPreference: String, CaseIterable {
    case quickMeals = "Quick & easy meals"
    case mealPrep = "Meal prepping"
    case freshIngredients = "Fresh ingredients"
    case comfortFoods = "Comfort foods"
    case internationalFlavors = "International flavors"
    case simpleIngredients = "Simple ingredients"
}

enum WeightGoalType: String, CaseIterable {
    case specificTarget = "I have a specific target"
    case notSureAboutNumbers = "I'm not sure about numbers"
    case feelBetterInBody = "I just want to feel better in my body"
}

enum WeightTimeline: String, CaseIterable {
    case threeMonths = "3 months"
    case sixMonths = "6 months"
    case oneYear = "1 year"
    case notSure = "I'm not sure"
}

enum WeightFocusArea: String, CaseIterable {
    case loseWeight = "I want to lose some weight"
    case maintainWeight = "I want to maintain my current weight"
    case gainWeight = "I want to gain weight healthily"
    case feelBetter = "Focus on how I feel, not the scale"
}

enum LearningStyle: String, CaseIterable {
    case showMeData = "Show me the data"
    case keepItSimple = "Keep it simple"
    case explainWhy = "Explain the why"
    case learnFromOthers = "Learn from others"
    case letMeExperiment = "Let me experiment"
}

enum GuidanceLevel: String, CaseIterable {
    case lightTouch = "Light touch"
    case balanced = "Balanced approach"
    case deepDive = "Deep dive"
}

enum FeaturePreference: String, CaseIterable {
    case calorieTracking = "Calorie/macro tracking"
    case foodQuality = "Food quality insights"
    case photoLogging = "Photo-based food logging"
    case dailyTips = "Daily tips and education"
    case mealPlanning = "Meal planning help"
    case progressTracking = "Progress tracking and trends"
    case moodMonitoring = "Mood and stress monitoring"
    case sleepOptimization = "Sleep optimization"
    case energyTracking = "Energy tracking"
    case exerciseIntegration = "Exercise integration"
    case smartReminders = "Smart reminders"
}

enum IntegrationPreference: String, CaseIterable {
    case appleWatch = "Apple Watch/Fitness tracker"
    case appleHealth = "Apple Health/Google Fit"
    case sleepTracking = "Sleep tracking apps"
    case meditation = "Meditation apps"
    case otherHealth = "Other health apps"
    case keepItSimple = "Keep it simple - just PlateUp"
}

// MARK: - Preview Helper
extension OnboardingFlowManager {
    static var preview: OnboardingFlowManager {
        let manager = OnboardingFlowManager()
        manager.selectedGoals = [.weightLoss, .moreEnergy]
        manager.primaryGoal = .weightLoss
        return manager
    }
}