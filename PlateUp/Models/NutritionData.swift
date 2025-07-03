//
//  NutritionData.swift
//  PlateUp v2.0
//
//  Extended nutrition data model for comprehensive tracking
//

import Foundation

// Macro type enum
enum MacroType: String, CaseIterable {
    case protein = "Protein"
    case carbs = "Carbs"
    case fats = "Fats"
    
    var color: String {
        switch self {
        case .protein: return "FF6B6B"  // Red
        case .carbs: return "4ECDC4"    // Teal
        case .fats: return "FFE66D"      // Yellow
        }
    }
}

struct NutritionData: Codable {
    // MARK: - Macros (Page 1)
    let calories: Int
    let protein: Double // grams
    let carbs: Double // grams
    let fats: Double // grams
    
    // MARK: - Micronutrients (Page 2)
    let fiber: Double? // grams
    let sugar: Double? // grams
    let sodium: Double? // mg
    
    // MARK: - Vitamins & Minerals (Page 3)
    let iron: Double? // mg
    let vitaminD: Double? // mcg
    let magnesium: Double? // mg
    let calcium: Double? // mg
    
    // MARK: - Metrics (Page 4)
    let glucoseImpact: Double? // 0-100 scale
    let qualityScore: Double? // 0-100 scale
    let hydration: Int? // glasses of water
    let steps: Int? // daily step count
    
    // MARK: - Daily Goals (for progress calculations)
    struct DailyGoals: Codable {
        let calories: Int
        let protein: Double
        let carbs: Double
        let fats: Double
        let fiber: Double
        let sugar: Double
        let sodium: Double
        let iron: Double
        let vitaminD: Double
        let magnesium: Double
        let calcium: Double
        let glucoseImpact: Double
        let qualityScore: Double
        let hydration: Int
        let steps: Int
        
        static var defaultGoals: DailyGoals {
            DailyGoals(
                calories: 2000,
                protein: 50,
                carbs: 300,
                fats: 65,
                fiber: 25,
                sugar: 50,
                sodium: 2300,
                iron: 18,
                vitaminD: 20,
                magnesium: 400,
                calcium: 1000,
                glucoseImpact: 50,
                qualityScore: 80,
                hydration: 8,
                steps: 10000
            )
        }
    }
    
    let goals: DailyGoals
    
    // MARK: - Computed Properties
    
    var caloriesProgress: Double {
        Double(calories) / Double(goals.calories)
    }
    
    var proteinProgress: Double {
        protein / goals.protein
    }
    
    var carbsProgress: Double {
        carbs / goals.carbs
    }
    
    var fatsProgress: Double {
        fats / goals.fats
    }
    
    var fiberProgress: Double {
        (fiber ?? 0) / goals.fiber
    }
    
    var sugarProgress: Double {
        (sugar ?? 0) / goals.sugar
    }
    
    var sodiumProgress: Double {
        (sodium ?? 0) / goals.sodium
    }
    
    var ironProgress: Double {
        (iron ?? 0) / goals.iron
    }
    
    var vitaminDProgress: Double {
        (vitaminD ?? 0) / goals.vitaminD
    }
    
    var magnesiumProgress: Double {
        (magnesium ?? 0) / goals.magnesium
    }
    
    var calciumProgress: Double {
        (calcium ?? 0) / goals.calcium
    }
    
    var glucoseImpactProgress: Double {
        (glucoseImpact ?? 0) / goals.glucoseImpact
    }
    
    var qualityScoreProgress: Double {
        (qualityScore ?? 0) / goals.qualityScore
    }
    
    var hydrationProgress: Double {
        Double(hydration ?? 0) / Double(goals.hydration)
    }
    
    var stepsProgress: Double {
        Double(steps ?? 0) / Double(goals.steps)
    }
    
    // MARK: - Mock Data
    static var mockData: NutritionData {
        NutritionData(
            calories: 1475,
            protein: 68,
            carbs: 178,
            fats: 52,
            fiber: 18,
            sugar: 32,
            sodium: 1850,
            iron: 12,
            vitaminD: 15,
            magnesium: 280,
            calcium: 800,
            glucoseImpact: 42,
            qualityScore: 72,
            hydration: 6,
            steps: 7234,
            goals: .defaultGoals
        )
    }
}