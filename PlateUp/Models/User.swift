//
//  User.swift
//  PlateUp v2.0
//
//  User model with enhanced goal tracking
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    var name: String
    var email: String
    var profileImageURL: String?
    
    // MARK: - Health Profile
    var age: Int?
    var height: Double? // in cm
    var weight: Double? // in kg
    var activityLevel: ActivityLevel
    var healthGoals: [HealthGoal]
    var primaryGoal: HealthGoal?
    var physicalStats: PhysicalStats?
    var dietaryPreferences: DietaryPreferences?
    var healthBlueprint: HealthBlueprint?
    
    // MARK: - Preferences
    var dietaryRestrictions: [DietaryRestriction]
    var preferredMealTimes: MealTimingPreferences
    var notificationSettings: NotificationPreferences
    
    // MARK: - Progress Tracking
    var createdAt: Date
    var lastActiveAt: Date
    
    enum ActivityLevel: String, CaseIterable, Codable {
        case sedentary = "Sedentary"
        case lightlyActive = "Lightly Active"
        case moderatelyActive = "Moderately Active"
        case veryActive = "Very Active"
        case extraActive = "Extra Active"
        
        var multiplier: Double {
            switch self {
            case .sedentary: return 1.2
            case .lightlyActive: return 1.375
            case .moderatelyActive: return 1.55
            case .veryActive: return 1.725
            case .extraActive: return 1.9
            }
        }
    }
    
    enum HealthGoal: String, CaseIterable, Codable {
        case weightLoss = "Weight Loss"
        case weightGain = "Weight Gain"
        case muscleGain = "Muscle Gain"
        case maintainWeight = "Maintain Weight"
        case improveEnergy = "Improve Energy"
        case betterSleep = "Better Sleep"
        case athleticPerformance = "Athletic Performance"
        case generalHealth = "General Health"
        
        var description: String {
            switch self {
            case .weightLoss:
                return "Lose weight in a healthy, sustainable way"
            case .weightGain:
                return "Gain weight and build muscle mass"
            case .muscleGain:
                return "Build lean muscle while maintaining current weight"
            case .maintainWeight:
                return "Maintain current weight while improving body composition"
            case .improveEnergy:
                return "Increase daily energy levels and reduce fatigue"
            case .betterSleep:
                return "Improve sleep quality through optimal nutrition timing"
            case .athleticPerformance:
                return "Optimize nutrition for athletic performance"
            case .generalHealth:
                return "Improve overall health and wellbeing"
            }
        }
    }
    
    enum DietaryRestriction: String, CaseIterable, Codable {
        case vegetarian = "Vegetarian"
        case vegan = "Vegan"
        case glutenFree = "Gluten-Free"
        case dairyFree = "Dairy-Free"
        case nutFree = "Nut-Free"
        case lowCarb = "Low-Carb"
        case keto = "Ketogenic"
        case paleo = "Paleo"
        case mediterranean = "Mediterranean"
        case intermittentFasting = "Intermittent Fasting"
    }
    
    // MARK: - Nested Types for Onboarding
    
    struct PhysicalStats: Codable {
        var age: Int?
        var height: Double?
        var weight: Double?
        var heightUnit: String?
        var weightUnit: String?
        var sex: String?
        var bodyFatPercentage: Double?
    }
    
    struct DietaryPreferences: Codable {
        var restrictions: [String]
        var allergies: [String]
        var preferences: [String]
        var cuisinePreferences: [String]?
    }
    
    struct HealthBlueprint: Codable {
        var goals: [String]
        var recommendations: [String]
        var mealPlan: String?
        var calorieTarget: Int?
        var macroTargets: MacroTargets?
        var createdAt: Date?
        var updatedAt: Date?
    }
    
    struct MacroTargets: Codable {
        var protein: Double
        var carbs: Double
        var fat: Double
    }
    
    init(
        id: String = UUID().uuidString,
        name: String,
        email: String,
        profileImageURL: String? = nil,
        age: Int? = nil,
        height: Double? = nil,
        weight: Double? = nil,
        activityLevel: ActivityLevel = .moderatelyActive,
        healthGoals: [HealthGoal] = [],
        primaryGoal: HealthGoal? = nil,
        physicalStats: PhysicalStats? = nil,
        dietaryPreferences: DietaryPreferences? = nil,
        healthBlueprint: HealthBlueprint? = nil,
        dietaryRestrictions: [DietaryRestriction] = [],
        preferredMealTimes: MealTimingPreferences = MealTimingPreferences(),
        notificationSettings: NotificationPreferences = NotificationPreferences()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImageURL = profileImageURL
        self.age = age
        self.height = height
        self.weight = weight
        self.activityLevel = activityLevel
        self.healthGoals = healthGoals
        self.primaryGoal = primaryGoal
        self.physicalStats = physicalStats
        self.dietaryPreferences = dietaryPreferences
        self.healthBlueprint = healthBlueprint
        self.dietaryRestrictions = dietaryRestrictions
        self.preferredMealTimes = preferredMealTimes
        self.notificationSettings = notificationSettings
        self.createdAt = Date()
        self.lastActiveAt = Date()
    }
    
    // MARK: - Computed Properties
    
    var bmi: Double? {
        guard let height = height, let weight = weight, height > 0 else { return nil }
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    var dailyCalorieGoal: Int? {
        guard let age = age,
              let height = height,
              let weight = weight else { return nil }
        
        // Using Mifflin-St Jeor Equation
        let bmr = (10 * weight) + (6.25 * height) - (5 * Double(age)) + 5 // For male
        let tdee = bmr * activityLevel.multiplier
        
        // Adjust based on primary goal
        switch primaryGoal {
        case .weightLoss:
            return Int(tdee * 0.8) // 20% deficit
        case .weightGain:
            return Int(tdee * 1.2) // 20% surplus
        case .muscleGain:
            return Int(tdee * 1.1) // 10% surplus
        default:
            return Int(tdee)
        }
    }
    
    var isProfileComplete: Bool {
        return age != nil &&
               height != nil &&
               weight != nil &&
               primaryGoal != nil &&
               !healthGoals.isEmpty
    }
}

// MARK: - Supporting Types

struct MealTimingPreferences: Codable {
    var breakfastTime: Date
    var lunchTime: Date
    var dinnerTime: Date
    var allowSnacks: Bool
    var intermittentFastingWindow: Int? // hours
    
    init() {
        let calendar = Calendar.current
        let now = Date()
        
        self.breakfastTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now) ?? now
        self.lunchTime = calendar.date(bySettingHour: 12, minute: 30, second: 0, of: now) ?? now
        self.dinnerTime = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now) ?? now
        self.allowSnacks = true
        self.intermittentFastingWindow = nil
    }
}

struct NotificationPreferences: Codable {
    var mealReminders: Bool
    var coachingInsights: Bool
    var progressUpdates: Bool
    var motivationalMessages: Bool
    var quietHoursStart: Date
    var quietHoursEnd: Date
    
    init() {
        let calendar = Calendar.current
        let now = Date()
        
        self.mealReminders = true
        self.coachingInsights = true
        self.progressUpdates = true
        self.motivationalMessages = false
        self.quietHoursStart = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: now) ?? now
        self.quietHoursEnd = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now) ?? now
    }
}