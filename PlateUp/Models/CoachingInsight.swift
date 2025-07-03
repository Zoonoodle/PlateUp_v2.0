//
//  CoachingInsight.swift
//  PlateUp v2.0
//
//  AI-powered coaching insights and recommendations
//

import Foundation

class CoachingInsight: Identifiable, Codable {
    let id: String
    let userId: String
    
    // MARK: - Core Insight Data
    var title: String
    var insight: String
    var actionableAdvice: String
    var reasoning: String
    var expectedOutcome: String
    
    // MARK: - Categorization
    var category: InsightCategory
    var priority: Priority
    var confidenceScore: Double // AI confidence in this insight (0-1)
    
    // MARK: - Goal Integration
    var relatedGoals: [User.HealthGoal]
    var impactOnPrimaryGoal: GoalImpact
    var progressMetrics: [ProgressMetric]
    
    // MARK: - User Interaction
    var userRating: UserRating?
    var userFeedback: String?
    var isActionTaken: Bool
    var dismissedAt: Date?
    
    // MARK: - Data Sources
    var basedOnMeals: [String] // Meal IDs
    var analysisTimeframe: TimeFrame
    var dataPoints: [DataPoint]
    
    // MARK: - Metadata
    var createdAt: Date
    var expiresAt: Date?
    var isActive: Bool
    
    enum InsightCategory: String, CaseIterable, Codable {
        case mealTiming = "Meal Timing"
        case macroBalance = "Macro Balance"
        case energyPatterns = "Energy Patterns"
        case sleepNutrition = "Sleep & Nutrition"
        case goalProgress = "Goal Progress"
        case foodChoices = "Food Choices"
        case portionSizes = "Portion Sizes"
        case hydration = "Hydration"
        case exerciseNutrition = "Exercise & Nutrition"
        case weeklyReview = "Weekly Review"
        
        var emoji: String {
            switch self {
            case .mealTiming: return "⏰"
            case .macroBalance: return "⚖️"
            case .energyPatterns: return "⚡"
            case .sleepNutrition: return "😴"
            case .goalProgress: return "🎯"
            case .foodChoices: return "🥗"
            case .portionSizes: return "📏"
            case .hydration: return "💧"
            case .exerciseNutrition: return "🏋️‍♂️"
            case .weeklyReview: return "📊"
            }
        }
    }
    
    enum Priority: String, CaseIterable, Codable {
        case critical = "Critical"
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        
        var color: String {
            switch self {
            case .critical: return "red"
            case .high: return "orange"
            case .medium: return "yellow"
            case .low: return "green"
            }
        }
    }
    
    enum GoalImpact: String, Codable {
        case veryPositive = "Very Positive"
        case positive = "Positive"
        case neutral = "Neutral"
        case negative = "Negative"
        case veryNegative = "Very Negative"
        
        var emoji: String {
            switch self {
            case .veryPositive: return "🚀"
            case .positive: return "✅"
            case .neutral: return "➖"
            case .negative: return "⚠️"
            case .veryNegative: return "🚨"
            }
        }
    }
    
    enum UserRating: Int, CaseIterable, Codable {
        case terrible = 1
        case poor = 2
        case okay = 3
        case good = 4
        case excellent = 5
        
        var emoji: String {
            switch self {
            case .terrible: return "😞"
            case .poor: return "😐"
            case .okay: return "🙂"
            case .good: return "😊"
            case .excellent: return "🤩"
            }
        }
    }
    
    enum TimeFrame: String, Codable {
        case daily = "Daily"
        case threeDay = "3-Day"
        case weekly = "Weekly"
        case biweekly = "2-Week"
        case monthly = "Monthly"
        
        var days: Int {
            switch self {
            case .daily: return 1
            case .threeDay: return 3
            case .weekly: return 7
            case .biweekly: return 14
            case .monthly: return 30
            }
        }
    }
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        title: String,
        insight: String,
        actionableAdvice: String,
        reasoning: String,
        expectedOutcome: String,
        category: InsightCategory,
        priority: Priority = .medium,
        confidenceScore: Double,
        relatedGoals: [User.HealthGoal] = [],
        impactOnPrimaryGoal: GoalImpact = .neutral,
        progressMetrics: [ProgressMetric] = [],
        basedOnMeals: [String] = [],
        analysisTimeframe: TimeFrame = .weekly,
        dataPoints: [DataPoint] = [],
        expiresAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.insight = insight
        self.actionableAdvice = actionableAdvice
        self.reasoning = reasoning
        self.expectedOutcome = expectedOutcome
        self.category = category
        self.priority = priority
        self.confidenceScore = confidenceScore
        self.relatedGoals = relatedGoals
        self.impactOnPrimaryGoal = impactOnPrimaryGoal
        self.progressMetrics = progressMetrics
        self.basedOnMeals = basedOnMeals
        self.analysisTimeframe = analysisTimeframe
        self.dataPoints = dataPoints
        self.userRating = nil
        self.userFeedback = nil
        self.isActionTaken = false
        self.dismissedAt = nil
        self.createdAt = Date()
        self.expiresAt = expiresAt
        self.isActive = true
    }
    
    // MARK: - Computed Properties
    
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
    
    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
    }
    
    var isHighPriority: Bool {
        return priority == .critical || priority == .high
    }
    
    var shouldShowToUser: Bool {
        return isActive && !isExpired && dismissedAt == nil
    }
}

// MARK: - Supporting Types

struct ProgressMetric: Identifiable, Codable {
    let id: String
    let name: String
    let currentValue: Double
    let targetValue: Double
    let unit: String
    let trend: Trend
    
    enum Trend: String, Codable {
        case improving = "Improving"
        case stable = "Stable"
        case declining = "Declining"
        
        var emoji: String {
            switch self {
            case .improving: return "📈"
            case .stable: return "➡️"
            case .declining: return "📉"
            }
        }
    }
    
    init(
        id: String = UUID().uuidString,
        name: String,
        currentValue: Double,
        targetValue: Double,
        unit: String,
        trend: Trend = .stable
    ) {
        self.id = id
        self.name = name
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.unit = unit
        self.trend = trend
    }
    
    var progressPercentage: Double {
        guard targetValue != 0 else { return 0 }
        return (currentValue / targetValue) * 100
    }
    
    var isOnTrack: Bool {
        return progressPercentage >= 80
    }
}

struct DataPoint: Identifiable, Codable {
    let id: String
    let label: String
    let value: Double
    let unit: String
    let timestamp: Date
    let source: DataSource
    
    enum DataSource: String, Codable {
        case mealLog = "Meal Log"
        case userInput = "User Input"
        case healthKit = "HealthKit"
        case aiAnalysis = "AI Analysis"
    }
    
    init(
        id: String = UUID().uuidString,
        label: String,
        value: Double,
        unit: String,
        timestamp: Date = Date(),
        source: DataSource
    ) {
        self.id = id
        self.label = label
        self.value = value
        self.unit = unit
        self.timestamp = timestamp
        self.source = source
    }
}

// MARK: - Weekly Coaching Report

class WeeklyCoachingReport: Identifiable, Codable {
    let id: String
    let userId: String
    let weekStartDate: Date
    let weekEndDate: Date
    
    // MARK: - Analysis Results
    var overallRating: Int // 1-10 scale
    var keyInsights: [CoachingInsight]
    var achievements: [Achievement]
    var areasForImprovement: [ImprovementArea]
    var weeklyGoalProgress: [GoalProgress]
    
    // MARK: - Recommendations
    var nextWeekRecommendations: [WeeklyRecommendation]
    var mealPlanSuggestions: [MealPlanSuggestion]
    var timingOptimizations: [TimingOptimization]
    
    var createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        weekStartDate: Date,
        weekEndDate: Date,
        overallRating: Int = 5,
        keyInsights: [CoachingInsight] = [],
        achievements: [Achievement] = [],
        areasForImprovement: [ImprovementArea] = [],
        weeklyGoalProgress: [GoalProgress] = [],
        nextWeekRecommendations: [WeeklyRecommendation] = [],
        mealPlanSuggestions: [MealPlanSuggestion] = [],
        timingOptimizations: [TimingOptimization] = []
    ) {
        self.id = id
        self.userId = userId
        self.weekStartDate = weekStartDate
        self.weekEndDate = weekEndDate
        self.overallRating = overallRating
        self.keyInsights = keyInsights
        self.achievements = achievements
        self.areasForImprovement = areasForImprovement
        self.weeklyGoalProgress = weeklyGoalProgress
        self.nextWeekRecommendations = nextWeekRecommendations
        self.mealPlanSuggestions = mealPlanSuggestions
        self.timingOptimizations = timingOptimizations
        self.createdAt = Date()
    }
}

// MARK: - Additional Supporting Types

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let type: AchievementType
    let earnedAt: Date
    
    enum AchievementType: String, Codable {
        case consistency = "Consistency"
        case improvement = "Improvement"
        case milestone = "Milestone"
        case habit = "Habit Formation"
    }
    
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        type: AchievementType,
        earnedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.earnedAt = earnedAt
    }
}

struct ImprovementArea: Identifiable, Codable {
    let id: String
    let area: String
    let currentScore: Double
    let targetScore: Double
    let suggestions: [String]
    let priority: CoachingInsight.Priority
    
    init(
        id: String = UUID().uuidString,
        area: String,
        currentScore: Double,
        targetScore: Double,
        suggestions: [String] = [],
        priority: CoachingInsight.Priority = .medium
    ) {
        self.id = id
        self.area = area
        self.currentScore = currentScore
        self.targetScore = targetScore
        self.suggestions = suggestions
        self.priority = priority
    }
}

struct GoalProgress: Identifiable, Codable {
    let id: String
    let goal: User.HealthGoal
    let progressPercentage: Double
    let weeklyChange: Double
    let onTrack: Bool
    
    init(
        id: String = UUID().uuidString,
        goal: User.HealthGoal,
        progressPercentage: Double,
        weeklyChange: Double,
        onTrack: Bool = true
    ) {
        self.id = id
        self.goal = goal
        self.progressPercentage = progressPercentage
        self.weeklyChange = weeklyChange
        self.onTrack = onTrack
    }
}

struct WeeklyRecommendation: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let expectedBenefit: String
    let difficulty: Difficulty
    
    enum Difficulty: String, CaseIterable, Codable {
        case easy = "Easy"
        case moderate = "Moderate"
        case challenging = "Challenging"
    }
    
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        expectedBenefit: String,
        difficulty: Difficulty = .moderate
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.expectedBenefit = expectedBenefit
        self.difficulty = difficulty
    }
}

struct MealPlanSuggestion: Identifiable, Codable {
    let id: String
    let mealType: MealType
    let suggestedTime: Date
    let foods: [String]
    let calories: Int
    let reasoning: String
    
    init(
        id: String = UUID().uuidString,
        mealType: MealType,
        suggestedTime: Date,
        foods: [String],
        calories: Int,
        reasoning: String
    ) {
        self.id = id
        self.mealType = mealType
        self.suggestedTime = suggestedTime
        self.foods = foods
        self.calories = calories
        self.reasoning = reasoning
    }
}

struct TimingOptimization: Identifiable, Codable {
    let id: String
    let currentPattern: String
    let suggestedPattern: String
    let reasoning: String
    let expectedBenefit: String
    
    init(
        id: String = UUID().uuidString,
        currentPattern: String,
        suggestedPattern: String,
        reasoning: String,
        expectedBenefit: String
    ) {
        self.id = id
        self.currentPattern = currentPattern
        self.suggestedPattern = suggestedPattern
        self.reasoning = reasoning
        self.expectedBenefit = expectedBenefit
    }
}