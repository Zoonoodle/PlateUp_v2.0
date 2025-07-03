//
//  FirebaseOnboardingService.swift
//  PlateUp v2.0
//
//  Manages onboarding data flow between temporary storage and permanent user profiles
//

import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
import FirebaseAuth
#endif

@Observable
class FirebaseOnboardingService {
    static let shared = FirebaseOnboardingService()
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    // MARK: - Onboarding Data Model
    struct OnboardingData: Codable {
        let id: String
        var primaryGoal: String?
        var secondaryGoals: [String]?
        var physicalStats: PhysicalStats?
        var dailyActivity: DailyActivity?
        var dietaryPreferences: DietaryPreferences?
        var lifestyleFactors: LifestyleFactors?
        var healthBlueprint: HealthBlueprint?
        var createdAt: Date
        var updatedAt: Date
        var isComplete: Bool
        
        init(id: String = UUID().uuidString) {
            self.id = id
            self.createdAt = Date()
            self.updatedAt = Date()
            self.isComplete = false
        }
    }
    
    struct PhysicalStats: Codable {
        var age: Int?
        var weight: Double?
        var weightUnit: WeightUnit
        var height: Double?
        var heightUnit: HeightUnit
        var bodyFatPercentage: Double?
        var sex: BiologicalSex?
        
        enum WeightUnit: String, Codable {
            case pounds = "lbs"
            case kilograms = "kg"
        }
        
        enum HeightUnit: String, Codable {
            case feet = "ft"
            case centimeters = "cm"
        }
        
        enum BiologicalSex: String, Codable {
            case male = "male"
            case female = "female"
            case other = "other"
        }
    }
    
    struct DailyActivity: Codable {
        var activityLevel: ActivityLevel?
        var workoutFrequency: Int? // times per week
        var workoutTypes: [String]?
        var averageSteps: Int?
        var sleepHours: Double?
        var sleepQuality: SleepQuality?
        
        enum ActivityLevel: String, Codable {
            case sedentary = "sedentary"
            case lightlyActive = "lightly_active"
            case moderatelyActive = "moderately_active"
            case veryActive = "very_active"
            case extremelyActive = "extremely_active"
        }
        
        enum SleepQuality: String, Codable {
            case poor = "poor"
            case fair = "fair"
            case good = "good"
            case excellent = "excellent"
        }
    }
    
    struct DietaryPreferences: Codable {
        var restrictions: [String]? // vegetarian, vegan, gluten-free, etc.
        var allergies: [String]?
        var dislikedFoods: [String]?
        var preferredCuisines: [String]?
        var mealPrep: Bool?
        var cookingTime: CookingTime?
        
        enum CookingTime: String, Codable {
            case minimal = "minimal" // < 15 min
            case moderate = "moderate" // 15-30 min
            case extended = "extended" // 30+ min
        }
    }
    
    struct LifestyleFactors: Codable {
        var workSchedule: WorkSchedule?
        var stressLevel: StressLevel?
        var hydrationGoal: Double? // liters per day
        var alcoholFrequency: AlcoholFrequency?
        var smokingStatus: Bool?
        
        enum WorkSchedule: String, Codable {
            case regular = "regular" // 9-5
            case shift = "shift"
            case irregular = "irregular"
            case remote = "remote"
        }
        
        enum StressLevel: String, Codable {
            case low = "low"
            case moderate = "moderate"
            case high = "high"
            case veryHigh = "very_high"
        }
        
        enum AlcoholFrequency: String, Codable {
            case never = "never"
            case occasionally = "occasionally"
            case weekly = "weekly"
            case daily = "daily"
        }
    }
    
    struct HealthBlueprint: Codable {
        let generatedAt: Date
        let dailyCalorieTarget: Int
        let macroTargets: MacroTargets
        let mealTiming: MealTimingRecommendations
        let personalizedAdvice: [String]
        let weeklyGoals: [String]
        let supplementRecommendations: [String]?
        
        struct MacroTargets: Codable {
            let protein: Int // grams
            let carbs: Int
            let fat: Int
            let fiber: Int
        }
        
        struct MealTimingRecommendations: Codable {
            let breakfastWindow: String // e.g., "7:00 AM - 9:00 AM"
            let lunchWindow: String
            let dinnerWindow: String
            let snackWindows: [String]?
            let fastingWindow: String? // e.g., "8:00 PM - 8:00 AM"
        }
    }
    
    private init() {}
    
    // MARK: - Save/Load Onboarding Progress
    
    func saveOnboardingProgress(_ data: OnboardingData) async throws {
        var updatedData = data
        updatedData.updatedAt = Date()
        
        try await db.collection("onboarding")
            .document(data.id)
            .setData(from: updatedData, merge: true)
    }
    
    func loadOnboardingProgress(id: String) async throws -> OnboardingData? {
        let document = try await db.collection("onboarding").document(id).getDocument()
        return try? document.data(as: OnboardingData.self)
    }
    
    func createNewOnboardingSession() async throws -> OnboardingData {
        let newData = OnboardingData()
        try await saveOnboardingProgress(newData)
        return newData
    }
    
    // MARK: - Update Specific Sections
    
    func updatePrimaryGoal(sessionId: String, goal: String) async throws {
        try await db.collection("onboarding").document(sessionId).updateData([
            "primaryGoal": goal,
            "updatedAt": Date()
        ])
    }
    
    func updateSecondaryGoals(sessionId: String, goals: [String]) async throws {
        try await db.collection("onboarding").document(sessionId).updateData([
            "secondaryGoals": goals,
            "updatedAt": Date()
        ])
    }
    
    func updatePhysicalStats(sessionId: String, stats: PhysicalStats) async throws {
        let encodedStats = try Firestore.Encoder().encode(stats)
        try await db.collection("onboarding").document(sessionId).updateData([
            "physicalStats": encodedStats,
            "updatedAt": Date()
        ])
    }
    
    func updateDailyActivity(sessionId: String, activity: DailyActivity) async throws {
        let encodedActivity = try Firestore.Encoder().encode(activity)
        try await db.collection("onboarding").document(sessionId).updateData([
            "dailyActivity": encodedActivity,
            "updatedAt": Date()
        ])
    }
    
    func updateDietaryPreferences(sessionId: String, preferences: DietaryPreferences) async throws {
        let encodedPrefs = try Firestore.Encoder().encode(preferences)
        try await db.collection("onboarding").document(sessionId).updateData([
            "dietaryPreferences": encodedPrefs,
            "updatedAt": Date()
        ])
    }
    
    func updateLifestyleFactors(sessionId: String, factors: LifestyleFactors) async throws {
        let encodedFactors = try Firestore.Encoder().encode(factors)
        try await db.collection("onboarding").document(sessionId).updateData([
            "lifestyleFactors": encodedFactors,
            "updatedAt": Date()
        ])
    }
    
    func saveHealthBlueprint(sessionId: String, blueprint: HealthBlueprint) async throws {
        let encodedBlueprint = try Firestore.Encoder().encode(blueprint)
        try await db.collection("onboarding").document(sessionId).updateData([
            "healthBlueprint": encodedBlueprint,
            "updatedAt": Date(),
            "isComplete": true
        ])
    }
    
    // MARK: - Generate Health Blueprint
    
    func generateHealthBlueprint(for onboardingData: OnboardingData) async throws -> HealthBlueprint {
        // Prepare data for Cloud Function
        let functionData: [String: Any] = [
            "primaryGoal": onboardingData.primaryGoal ?? "",
            "secondaryGoals": onboardingData.secondaryGoals ?? [],
            "physicalStats": try encodeToDict(onboardingData.physicalStats),
            "dailyActivity": try encodeToDict(onboardingData.dailyActivity),
            "dietaryPreferences": try encodeToDict(onboardingData.dietaryPreferences),
            "lifestyleFactors": try encodeToDict(onboardingData.lifestyleFactors)
        ]
        
        // Call Cloud Function
        let result = try await FirebaseService.shared.callFunction(
            name: "healthBlueprint",
            data: functionData
        )
        
        // Decode the response
        guard let blueprintData = result["blueprint"] as? [String: Any] else {
            throw FirebaseError.invalidFunctionResponse
        }
        
        // Convert to HealthBlueprint
        let jsonData = try JSONSerialization.data(withJSONObject: blueprintData)
        let blueprint = try JSONDecoder().decode(HealthBlueprint.self, from: jsonData)
        
        return blueprint
    }
    
    // MARK: - Merge to User Profile
    
    func mergeOnboardingToUserProfile(onboardingId: String, userId: String) async throws {
        // Load onboarding data
        guard let onboardingData = try await loadOnboardingProgress(id: onboardingId) else {
            throw FirebaseError.dataDecodingError
        }
        
        // Create or update user profile with onboarding data
        let userProfile = User(
            id: userId,
            name: auth.currentUser?.displayName ?? "",
            email: auth.currentUser?.email ?? "",
            activityLevel: mapStringToActivityLevel(onboardingData.dailyActivity?.activityLevel?.rawValue),
            healthGoals: (onboardingData.secondaryGoals ?? []).compactMap { mapStringToHealthGoal($0) },
            primaryGoal: mapStringToHealthGoal(onboardingData.primaryGoal),
            physicalStats: mapToUserPhysicalStats(onboardingData.physicalStats),
            dietaryPreferences: mapToUserDietaryPreferences(onboardingData.dietaryPreferences),
            healthBlueprint: mapToUserHealthBlueprint(onboardingData.healthBlueprint)
        )
        
        // Save to permanent user profile
        try await FirebaseService.shared.updateUserProfile(userProfile)
        
        // Delete temporary onboarding data
        try await db.collection("onboarding").document(onboardingId).delete()
    }
    
    // MARK: - Helper Methods
    
    private func encodeToDict<T: Encodable>(_ value: T?) throws -> [String: Any] {
        guard let value = value else { return [:] }
        let data = try JSONEncoder().encode(value)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        return dict
    }
    
    private func mapToUserPhysicalStats(_ stats: PhysicalStats?) -> User.PhysicalStats {
        guard let stats = stats else {
            return User.PhysicalStats(
                age: 0,
                height: 0,
                weight: 0,
                bodyFatPercentage: nil
            )
        }
        
        return User.PhysicalStats(
            age: stats.age ?? 0,
            height: stats.height ?? 0,
            weight: stats.weight ?? 0,
            bodyFatPercentage: stats.bodyFatPercentage
        )
    }
    
    private func mapToUserDietaryPreferences(_ prefs: DietaryPreferences?) -> User.DietaryPreferences {
        return User.DietaryPreferences(
            restrictions: prefs?.restrictions ?? [],
            allergies: prefs?.allergies ?? [],
            preferences: prefs?.dislikedFoods ?? []
        )
    }
    
    private func mapToUserHealthBlueprint(_ blueprint: HealthBlueprint?) -> User.HealthBlueprint? {
        guard let blueprint = blueprint else { return nil }
        
        return User.HealthBlueprint(
            goals: blueprint.personalizedAdvice,
            recommendations: blueprint.weeklyGoals,
            calorieTarget: blueprint.dailyCalorieTarget,
            macroTargets: User.MacroTargets(
                protein: Double(blueprint.macroTargets.protein),
                carbs: Double(blueprint.macroTargets.carbs),
                fat: Double(blueprint.macroTargets.fat)
            )
        )
    }
    
    private func mapStringToHealthGoal(_ goalString: String?) -> User.HealthGoal? {
        guard let goalString = goalString else { return nil }
        return User.HealthGoal(rawValue: goalString)
    }
    
    private func mapStringToActivityLevel(_ activityString: String?) -> User.ActivityLevel {
        guard let activityString = activityString else { return .moderatelyActive }
        return User.ActivityLevel(rawValue: activityString) ?? .moderatelyActive
    }
    
    // MARK: - Offline Support
    
    func enableOfflineSupport() {
        // Already configured in FirebaseService init
        // This is just a convenience method for clarity
    }
}