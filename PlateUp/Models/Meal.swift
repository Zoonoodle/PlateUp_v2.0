//
//  Meal.swift
//  PlateUp v2.0
//
//  Comprehensive meal model for AI analysis
//

import Foundation

struct Meal: Identifiable, Codable {
    let id: String
    var userId: String
    
    // MARK: - Basic Information
    var name: String
    var description: String?
    var mealType: MealType
    var timestamp: Date
    
    // MARK: - Nutrition Information
    var calories: Int?
    var protein: Double? // grams
    var carbs: Double? // grams
    var fat: Double? // grams
    var fiber: Double? // grams
    var sugar: Double? // grams
    var sodium: Double? // mg
    
    // MARK: - AI Analysis Data
    var ingredients: [Ingredient]
    var imageURL: String?
    var audioTranscriptURL: String?
    var logMethod: LogMethod
    var confidenceScore: Double? // AI confidence in nutritional analysis
    
    // MARK: - Clarification System
    var clarificationQuestions: [ClarificationQuestion]
    var needsClarification: Bool
    var analysisStatus: AnalysisStatus
    
    // MARK: - Coaching Integration
    var coachingNotes: String?
    var impactsGoals: [String] // How this meal affects user's goals
    var alternativeSuggestions: [String]
    
    // MARK: - Metadata
    var createdAt: Date
    var updatedAt: Date
    var isUserGenerated: Bool // true if user manually entered, false if AI generated
    
    enum LogMethod: String, Codable {
        case photoScan = "Photo Scan"
        case voiceInput = "Voice Input"
        case manualEntry = "Manual Entry"
        case recipe = "Recipe"
        case barcodeScan = "Barcode Scan"
    }
    
    enum AnalysisStatus: String, Codable {
        case pending = "pending"
        case analyzing = "analyzing"
        case needsClarification = "needs_clarification"
        case completed = "completed"
        case failed = "failed"
    }
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        name: String,
        description: String? = nil,
        mealType: MealType,
        timestamp: Date = Date(),
        calories: Int? = nil,
        protein: Double? = nil,
        carbs: Double? = nil,
        fat: Double? = nil,
        fiber: Double? = nil,
        sugar: Double? = nil,
        sodium: Double? = nil,
        ingredients: [Ingredient] = [],
        imageURL: String? = nil,
        audioTranscriptURL: String? = nil,
        logMethod: LogMethod,
        confidenceScore: Double? = nil,
        clarificationQuestions: [ClarificationQuestion] = [],
        needsClarification: Bool = false,
        analysisStatus: AnalysisStatus = .pending,
        coachingNotes: String? = nil,
        impactsGoals: [String] = [],
        alternativeSuggestions: [String] = [],
        isUserGenerated: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.description = description
        self.mealType = mealType
        self.timestamp = timestamp
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.ingredients = ingredients
        self.imageURL = imageURL
        self.audioTranscriptURL = audioTranscriptURL
        self.logMethod = logMethod
        self.confidenceScore = confidenceScore
        self.clarificationQuestions = clarificationQuestions
        self.needsClarification = needsClarification
        self.analysisStatus = analysisStatus
        self.coachingNotes = coachingNotes
        self.impactsGoals = impactsGoals
        self.alternativeSuggestions = alternativeSuggestions
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isUserGenerated = isUserGenerated
    }
    
    // MARK: - Computed Properties
    
    var totalMacros: Double {
        let proteinCals = (protein ?? 0) * 4
        let carbCals = (carbs ?? 0) * 4
        let fatCals = (fat ?? 0) * 9
        return proteinCals + carbCals + fatCals
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    var icon: String? {
        mealType.emoji
    }
    
    var macroDistribution: (protein: Double, carbs: Double, fat: Double) {
        guard totalMacros > 0 else { return (0, 0, 0) }
        
        let proteinPercent = ((protein ?? 0) * 4) / totalMacros
        let carbPercent = ((carbs ?? 0) * 4) / totalMacros
        let fatPercent = ((fat ?? 0) * 9) / totalMacros
        
        return (proteinPercent, carbPercent, fatPercent)
    }
    
    var isAnalysisComplete: Bool {
        return analysisStatus == .completed && calories != nil
    }
    
    var qualityScore: Double {
        var score = 0.0
        let maxScore = 5.0
        
        // Fiber content (higher is better)
        if let fiber = fiber {
            score += min(fiber / 10.0, 1.0) // Max 1 point for 10g+ fiber
        }
        
        // Protein content (moderate is good)
        if let protein = protein, let calories = calories {
            let proteinPercent = (protein * 4) / Double(calories)
            if proteinPercent >= 0.15 && proteinPercent <= 0.35 {
                score += 1.0
            }
        }
        
        // Sugar content (lower is better)
        if let sugar = sugar, let calories = calories {
            let sugarPercent = (sugar * 4) / Double(calories)
            score += max(0, 1.0 - (sugarPercent * 2)) // Penalty for high sugar
        }
        
        // Sodium content (lower is better)
        if let sodium = sodium {
            score += max(0, 1.0 - (sodium / 2300.0)) // Penalty for high sodium
        }
        
        // Ingredient quality (more whole foods = better)
        let wholeFootCount = ingredients.filter { $0.isWholeFood }.count
        let totalIngredients = ingredients.count
        if totalIngredients > 0 {
            score += Double(wholeFootCount) / Double(totalIngredients)
        }
        
        return (score / maxScore) * 100 // Convert to percentage
    }
}

// MARK: - Supporting Types

struct Ingredient: Identifiable, Codable {
    let id: String
    let name: String
    let quantity: Double?
    let unit: String?
    let isWholeFood: Bool
    let category: IngredientCategory
    
    enum IngredientCategory: String, CaseIterable, Codable {
        case vegetable = "Vegetable"
        case fruit = "Fruit"
        case protein = "Protein"
        case grain = "Grain"
        case dairy = "Dairy"
        case fat = "Fat"
        case spice = "Spice"
        case processed = "Processed"
        case beverage = "Beverage"
        case other = "Other"
    }
    
    init(
        id: String = UUID().uuidString,
        name: String,
        quantity: Double? = nil,
        unit: String? = nil,
        isWholeFood: Bool = false,
        category: IngredientCategory = .other
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.isWholeFood = isWholeFood
        self.category = category
    }
}

struct ClarificationQuestion: Identifiable, Codable {
    let id: String
    let question: String
    let options: [String]?
    var userAnswer: String?
    var feedbackRating: FeedbackRating?
    var isHelpful: Bool?
    let timestamp: Date
    
    enum FeedbackRating: String, Codable {
        case thumbsUp = "thumbs_up"
        case thumbsDown = "thumbs_down"
        
        var displayName: String {
            switch self {
            case .thumbsUp: return "👍"
            case .thumbsDown: return "👎"
            }
        }
    }
    
    init(
        id: String = UUID().uuidString,
        question: String,
        options: [String]? = nil,
        userAnswer: String? = nil,
        feedbackRating: FeedbackRating? = nil,
        isHelpful: Bool? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.question = question
        self.options = options
        self.userAnswer = userAnswer
        self.feedbackRating = feedbackRating
        self.isHelpful = isHelpful
        self.timestamp = timestamp
    }
}