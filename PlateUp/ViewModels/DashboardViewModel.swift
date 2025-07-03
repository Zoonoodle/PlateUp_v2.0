//
//  DashboardViewModel.swift
//  PlateUp
//
//  View model for the dashboard functionality
//

import SwiftUI
import Foundation

class DashboardViewModel: ObservableObject {
    // User data
    @Published var userName: String = "Alex"
    @Published var currentGoals: [HealthGoal] = HealthGoal.defaultGoals
    @Published var nutritionData: NutritionData = .mockData
    
    // First-time user detection
    @Published var isFirstTimeUser: Bool = true
    @Published var totalMealsLogged: Int = 0
    
    // Focus card states
    @Published var hasLoggedBreakfast: Bool = false
    @Published var hasLoggedLunch: Bool = false
    @Published var hasLoggedDinner: Bool = false
    @Published var isAllCaughtUp: Bool = false
    
    // Check-in data
    @Published var morningCheckInCompleted: Bool = false
    @Published var afternoonCheckInCompleted: Bool = false
    @Published var eveningCheckInCompleted: Bool = false
    
    // Recent meals
    @Published var recentMeals: [Meal] = Array(MockDataService.mockMeals.prefix(3))
    
    // Progress data
    @Published var weeklyTrend: WeeklyTrend = .mockData
    @Published var yesterdaysImpact: YesterdaysImpact = .mockData
    
    // Additional properties for FocusCard
    @Published var todaysMetrics = TodaysMetrics(isComplete: false)
    @Published var quickSuggestions: [String] = ["Greek Yogurt", "Protein Shake", "Mixed Nuts", "Chicken Salad"]
    
    // AI Agent Integration Properties
    @Published var currentEnergyLevel: String = ""
    @Published var currentHydrationLevel: String = ""
    @Published var dailyRating: String = ""
    
    // Smart Focus Content (AI Agent will populate these)
    @Published var smartFocusContent: SmartFocusContent = SmartFocusContent.default
    @Published var aiGeneratedSuggestions: [AISuggestion] = []
    @Published var nutritionalGaps: NutritionalGaps = NutritionalGaps.empty
    @Published var userPatterns: UserPatterns = UserPatterns.empty
    
    init() {
        // Initialize with smart focus content
        Task {
            await updateSmartFocusContent()
        }
    }
    
    // Computed properties
    var currentGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = userName
        
        switch hour {
        case 5..<12:
            return "Good morning, \(name)"
        case 12..<17:
            return "Good afternoon, \(name)"
        case 17..<21:
            return "Good evening, \(name)"
        default:
            return "Late night fuel, \(name)"
        }
    }
    
    
    // Methods
    
    func refreshData() async {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Refresh data
        withAnimation {
            // Update nutrition data, meals, etc.
        }
    }
    
    
    // Navigation methods for FocusCard
    func navigateToMealLogging() {
        // Handle navigation to meal logging
    }
    
    func showSuggestions() {
        // Show nutrition suggestions
    }
    
    func openCheckIn() {
        // Open check-in flow
    }
    
    func showProgress() {
        // Navigate to progress view
    }
    
    func showDetailedProgress() {
        // Show detailed progress
    }
    
    func openMealPlanning() {
        // Open meal planning view
    }
    
    // MARK: - AI Agent Integration Methods
    
    func processCheckInForAI(type: CheckInType, response: String) {
        // This method will be called by the AI agent to process check-in data
        // The AI can use this to update recommendations and insights
        Task {
            await updateSmartFocusContent()
        }
    }
    
    func updateSmartFocusContent() async {
        // This is where the AI agent will analyze user data and generate personalized content
        // For now, using mock data that will be replaced by AI-generated content
        
        let hour = Calendar.current.component(.hour, from: Date())
        
        // AI agent will populate this based on:
        // - User's meal history and patterns
        // - Current nutritional status
        // - Time of day and usual meal times
        // - Recent check-in responses
        // - Energy patterns and goals
        
        await MainActor.run {
            // Check if this is a first-time user
            if self.isFirstTimeUser && self.totalMealsLogged == 0 {
                self.smartFocusContent = self.generateWelcomeContent()
            } else {
                self.smartFocusContent = self.generateSmartContent(for: hour)
            }
        }
    }
    
    private func generateWelcomeContent() -> SmartFocusContent {
        return SmartFocusContent(
            title: "Welcome to PlateUp, \(userName)!",
            subtitle: "Your journey to personalized nutrition starts here. Log your first meal to unlock tailored insights.",
            actionText: "Log First Meal",
            icon: "sparkles",
            quickOptions: [],
            nutritionalContext: "I'll learn your preferences and patterns to provide personalized coaching",
            primaryNeed: "Let's start by tracking what you eat today"
        )
    }
    
    private func generateSmartContent(for hour: Int) -> SmartFocusContent {
        // This will be replaced by AI agent logic
        // For now, returning contextual mock data
        
        switch hour {
        case 7..<9:
            return SmartFocusContent(
                title: "Ready for breakfast, \(userName)?",
                subtitle: "You usually have Greek Yogurt at 8 AM",
                actionText: "Log Breakfast",
                icon: "sun.max.fill",
                quickOptions: ["Greek Yogurt", "Protein Shake"],
                nutritionalContext: "Yesterday's breakfast gave you great energy",
                primaryNeed: "Start with 30g protein for sustained energy"
            )
        case 14..<16:
            let proteinGap = nutritionData.goals.protein - nutritionData.protein
            return SmartFocusContent(
                title: "Energy Check",
                subtitle: "Your energy typically dips now",
                actionText: "Log Snack",
                icon: "bolt.fill",
                quickOptions: ["Mixed Nuts (\(Int(proteinGap/2))g)", "Cottage Cheese (\(Int(proteinGap))g)"],
                nutritionalContext: "You're \(Int(proteinGap))g short on protein today",
                primaryNeed: "A protein snack will prevent the 3 PM crash"
            )
        default:
            return SmartFocusContent.default
        }
    }
}

// MARK: - AI Agent Data Structures

struct SmartFocusContent {
    let title: String
    let subtitle: String
    let actionText: String
    let icon: String
    let quickOptions: [String]
    let nutritionalContext: String
    let primaryNeed: String
    
    static let `default` = SmartFocusContent(
        title: "Track your nutrition",
        subtitle: "Log meals to get personalized insights",
        actionText: "Log Meal",
        icon: "camera.fill",
        quickOptions: [],
        nutritionalContext: "",
        primaryNeed: ""
    )
}

struct AISuggestion {
    let id: UUID = UUID()
    let text: String
    let reason: String
    let impact: String
    let priority: Int
}

struct NutritionalGaps {
    let proteinGap: Double
    let carbGap: Double
    let fatGap: Double
    let fiberGap: Double
    let waterGap: Int
    
    static let empty = NutritionalGaps(
        proteinGap: 0,
        carbGap: 0,
        fatGap: 0,
        fiberGap: 0,
        waterGap: 0
    )
}

struct UserPatterns {
    let usualBreakfastTime: Date?
    let usualLunchTime: Date?
    let usualDinnerTime: Date?
    let commonBreakfastItems: [String]
    let energyDipTimes: [Date]
    let optimalProteinTiming: String
    
    static let empty = UserPatterns(
        usualBreakfastTime: nil,
        usualLunchTime: nil,
        usualDinnerTime: nil,
        commonBreakfastItems: [],
        energyDipTimes: [],
        optimalProteinTiming: ""
    )
}

// MARK: - Supporting Types
// FocusType and FocusContent are defined in FocusCard.swift

struct WeeklyTrend {
    let title: String
    let value: String
    let change: Double
    let isPositive: Bool
    
    static let mockData = WeeklyTrend(
        title: "Weekly Average",
        value: "2,150 cal",
        change: -5.2,
        isPositive: true
    )
}

struct YesterdaysImpact {
    let positiveImpact: String
    let negativeImpact: String
    let suggestion: String
    
    static let mockData = YesterdaysImpact(
        positiveImpact: "Morning protein helped maintain steady energy",
        negativeImpact: "Late dinner may have affected sleep quality",
        suggestion: "Try eating dinner before 7 PM tonight"
    )
}

// Mock data extensions
// HealthGoal.defaultGoals is now defined in Models/HealthGoal.swift

struct TodaysMetrics {
    let isComplete: Bool
}

