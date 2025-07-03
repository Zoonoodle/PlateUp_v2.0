//
//  ProgressViewModel.swift
//  PlateUp
//
//  View model for progress tracking and analytics
//

import SwiftUI

@MainActor
@Observable
class ProgressViewModel {
    // Weight tracking
    var weightData: [WeightDataPoint] = []
    var weightChange: String = "-0.8"
    var weightTrend: TrendDirection = .down
    
    // Energy tracking
    var energyData: [EnergyDataPoint] = []
    var energyStability: String = "Stable"
    
    // Meal quality
    var mealQualityScore: String = "4.2/5"
    var mealQualityTrend: TrendDirection = .up
    
    // Hydration
    var avgWaterIntake: Int = 6
    var hydrationTrend: TrendDirection = .stable
    
    // Meal impacts
    var mealImpacts: [MealImpact] = []
    
    // Pattern recognition
    var recognizedPatterns = RecognizedPatterns()
    
    // Meal timing data
    var mealTimingData: [MealTimingData] = []
    
    init() {
        loadMockData()
    }
    
    func loadProgressData(for timeRange: TimeRange) async {
        // In production, this would fetch from Firebase
        // For now, using mock data
        loadMockData()
    }
    
    private func loadMockData() {
        // Weight data
        let calendar = Calendar.current
        let today = Date()
        weightData = (0..<7).map { daysAgo in
            WeightDataPoint(
                date: calendar.date(byAdding: .day, value: -daysAgo, to: today)!,
                weight: 142.5 - Double(daysAgo) * 0.1 + Double.random(in: -0.3...0.3)
            )
        }.reversed()
        
        // Energy data (hourly from 6am to 10pm)
        energyData = stride(from: 6, through: 22, by: 2).map { hour in
            let level: Double = {
                switch hour {
                case 6...8: return Double.random(in: 2.5...3.5)
                case 9...11: return Double.random(in: 3.5...4.5)
                case 12...13: return Double.random(in: 3.0...4.0)
                case 14...16: return Double.random(in: 2.0...3.0) // Afternoon dip
                case 17...19: return Double.random(in: 3.0...4.0)
                default: return Double.random(in: 2.5...3.5)
                }
            }()
            return EnergyDataPoint(hour: hour, level: level)
        }
        
        // Meal impacts
        mealImpacts = [
            MealImpact(
                outcome: "3pm Energy Crash",
                timeDescription: "Yesterday at 3:00 PM",
                mealName: "Pasta Carbonara",
                mealTime: "12:30 PM",
                nutritionFactors: [
                    "82g refined carbs",
                    "Only 18% protein ratio",
                    "Low fiber content"
                ],
                suggestion: "Add protein side dish, choose whole grain pasta, or reduce portion by 25%",
                isNegative: true
            ),
            MealImpact(
                outcome: "Poor Sleep Quality",
                timeDescription: "Tuesday night",
                mealName: "Thai Red Curry",
                mealTime: "8:45 PM",
                nutritionFactors: [
                    "Spicy food late at night",
                    "Heavy meal 2hrs before bed",
                    "High sodium content"
                ],
                suggestion: "Eat dinner by 7pm, choose milder flavors for evening meals",
                isNegative: true
            ),
            MealImpact(
                outcome: "Sustained Morning Energy",
                timeDescription: "Monday 7am-12pm",
                mealName: "Eggs & Avocado Toast",
                mealTime: "7:30 AM",
                nutritionFactors: [
                    "35g protein",
                    "Healthy fats from avocado",
                    "Complex carbs from whole grain"
                ],
                suggestion: "Keep this breakfast! Perfect macro balance for your goals",
                isNegative: false
            )
        ]
        
        // Pattern recognition
        recognizedPatterns = RecognizedPatterns(
            positiveFoods: [
                PatternFood(
                    name: "Greek Yogurt",
                    impact: "Improves morning energy",
                    frequency: 5,
                    icon: "leaf.fill"
                ),
                PatternFood(
                    name: "Grilled Chicken",
                    impact: "Better sleep when eaten at lunch",
                    frequency: 4,
                    icon: "flame.fill"
                ),
                PatternFood(
                    name: "Oatmeal",
                    impact: "Stable energy all morning",
                    frequency: 6,
                    icon: "sun.max.fill"
                ),
                PatternFood(
                    name: "Mixed Berries",
                    impact: "No energy crashes",
                    frequency: 7,
                    icon: "leaf.circle.fill"
                )
            ],
            negativeFoods: [
                PatternFood(
                    name: "Pasta (large portions)",
                    impact: "Afternoon energy crash",
                    frequency: 3,
                    icon: "fork.knife"
                ),
                PatternFood(
                    name: "Coffee after 2pm",
                    impact: "Poor sleep quality",
                    frequency: 4,
                    icon: "cup.and.saucer.fill"
                ),
                PatternFood(
                    name: "Sugary Snacks",
                    impact: "Energy rollercoaster",
                    frequency: 5,
                    icon: "bolt.slash.fill"
                )
            ],
            timingPatterns: [
                TimingPattern(
                    description: "Eating after 8pm",
                    impact: "1.5 hours less sleep on average"
                ),
                TimingPattern(
                    description: "Protein within 30min of waking",
                    impact: "23% more sustained energy"
                ),
                TimingPattern(
                    description: "3+ hours between dinner and sleep",
                    impact: "Better sleep quality score"
                )
            ]
        )
        
        // Meal timing data
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        mealTimingData = days.enumerated().flatMap { index, day in
            [
                MealTimingData(
                    dayLabel: day,
                    mealType: .breakfast,
                    startTime: Double.random(in: 6.5...8.5),
                    endTime: Double.random(in: 7...9),
                    sleepQuality: nil
                ),
                MealTimingData(
                    dayLabel: day,
                    mealType: .lunch,
                    startTime: Double.random(in: 11.5...13.5),
                    endTime: Double.random(in: 12...14),
                    sleepQuality: nil
                ),
                MealTimingData(
                    dayLabel: day,
                    mealType: .dinner,
                    startTime: Double.random(in: 18...20.5),
                    endTime: Double.random(in: 18.5...21),
                    sleepQuality: Double.random(in: 5...9)
                )
            ]
        }
    }
}

// MARK: - Supporting Types
enum TimeRange: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case threeMonths = "3 Months"
    
    var displayName: String { rawValue }
    
    var displayDays: String {
        switch self {
        case .day: return "1"
        case .week: return "7"
        case .month: return "30"
        case .threeMonths: return "90"
        }
    }
}

enum TrendDirection {
    case up, down, stable
    
    var icon: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }
    
    var text: String {
        switch self {
        case .up: return "Up"
        case .down: return "Down"
        case .stable: return "Stable"
        }
    }
    
    var color: Color {
        switch self {
        case .up: return .plateUpSuccess
        case .down: return .plateUpError
        case .stable: return .plateUpSecondaryText
        }
    }
}

struct MealImpact: Identifiable {
    let id = UUID()
    let outcome: String
    let timeDescription: String
    let mealName: String
    let mealTime: String
    let nutritionFactors: [String]
    let suggestion: String
    let isNegative: Bool
}

struct RecognizedPatterns {
    var positiveFoods: [PatternFood] = []
    var negativeFoods: [PatternFood] = []
    var timingPatterns: [TimingPattern] = []
}

struct PatternFood: Identifiable {
    let id = UUID()
    let name: String
    let impact: String
    let frequency: Int
    let icon: String
}

struct TimingPattern: Identifiable {
    let id = UUID()
    let description: String
    let impact: String
}