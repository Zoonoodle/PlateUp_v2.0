//
//  MockDataService.swift
//  PlateUp
//
//  Mock data for testing without Firebase
//

import Foundation
import SwiftUI

class MockDataService {
    static let shared = MockDataService()
    
    private init() {}
    
    // MARK: - Mock User
    static let mockUser = User(
        name: "Test User",
        email: "test@example.com",
        age: 28,
        height: 175,
        weight: 70,
        activityLevel: .moderatelyActive,
        healthGoals: [.improveEnergy, .betterSleep, .weightLoss, .generalHealth],
        primaryGoal: .improveEnergy
    )
    
    // MARK: - Mock Meals
    static let mockMeals: [Meal] = [
        Meal(
            userId: mockUser.id,
            name: "Greek Yogurt Parfait",
            mealType: .breakfast,
            timestamp: Date().addingTimeInterval(-14400),
            calories: 320,
            protein: 18,
            carbs: 42,
            fat: 8,
            logMethod: .photoScan
        ),
        Meal(
            userId: mockUser.id,
            name: "Grilled Chicken Salad",
            mealType: .lunch,
            timestamp: Date().addingTimeInterval(-7200),
            calories: 450,
            protein: 35,
            carbs: 28,
            fat: 22,
            logMethod: .voiceInput
        ),
        Meal(
            userId: mockUser.id,
            name: "Apple with Almond Butter",
            mealType: .snack,
            timestamp: Date().addingTimeInterval(-3600),
            calories: 200,
            protein: 7,
            carbs: 25,
            fat: 10,
            logMethod: .manualEntry
        )
    ]
    
    // MARK: - Mock Coaching Insights
    static func createMockInsights() -> [CoachingInsight] {
        return [
            CoachingInsight(
                userId: mockUser.id,
                title: "Optimize Your Lunch Timing",
                insight: "Your energy dips around 3 PM. Try eating lunch 30 minutes earlier.",
                actionableAdvice: "Move lunch to 12:30 PM tomorrow",
                reasoning: "Earlier lunch helps maintain stable blood sugar levels throughout the afternoon",
                expectedOutcome: "Reduced afternoon energy crashes and improved focus",
                category: .mealTiming,
                priority: .high,
                confidenceScore: 0.85,
                relatedGoals: [.improveEnergy],
                impactOnPrimaryGoal: .positive
            ),
            CoachingInsight(
                userId: mockUser.id,
                title: "Increase Morning Protein",
                insight: "Your breakfast is carb-heavy. Adding more protein can help with satiety.",
                actionableAdvice: "Add 2 eggs or Greek yogurt to breakfast",
                reasoning: "Protein helps control hunger and stabilizes energy levels",
                expectedOutcome: "Less mid-morning snacking and steadier energy",
                category: .macroBalance,
                priority: .medium,
                confidenceScore: 0.90,
                relatedGoals: [.improveEnergy, .weightLoss],
                impactOnPrimaryGoal: .positive
            )
        ]
    }
    
    // MARK: - Mock Analysis Result
    static func createMockMealAnalysis(for mealType: MealType) -> MealAnalysisResult {
        let meal = Meal(
            userId: mockUser.id,
            name: "Analyzed Meal",
            mealType: mealType,
            calories: Int.random(in: 300...800),
            protein: Double.random(in: 15...40),
            carbs: Double.random(in: 30...80),
            fat: Double.random(in: 10...30),
            logMethod: .photoScan
        )
        
        return MealAnalysisResult(
            meal: meal,
            confidence: 0.85,
            clarificationQuestions: []
        )
    }
}