//
//  GeminiService.swift
//  PlateUp v2.0
//
//  Gemini AI integration with Firebase AI Logic SDK
//

import Foundation
#if canImport(FirebaseVertexAI)
import FirebaseVertexAI
#endif

class GeminiService: ObservableObject {
    static let shared = GeminiService()
    
    #if canImport(FirebaseVertexAI)
    private let vertex = VertexAI.vertexAI()
    private var flashModel: GenerativeModel?
    private var proModel: GenerativeModel?
    #endif
    
    // MARK: - Configuration
    #if canImport(FirebaseVertexAI)
    private let generationConfig = GenerationConfig(
        temperature: 0.7,
        topP: 0.8,
        topK: 40,
        maxOutputTokens: 2048
    )
    
    private let safetySettings = [
        SafetySetting(harmCategory: .harassment, threshold: .blockMediumAndAbove),
        SafetySetting(harmCategory: .hateSpeech, threshold: .blockMediumAndAbove),
        SafetySetting(harmCategory: .sexuallyExplicit, threshold: .blockMediumAndAbove),
        SafetySetting(harmCategory: .dangerousContent, threshold: .blockMediumAndAbove)
    ]
    #endif
    
    private init() {
        #if canImport(FirebaseVertexAI)
        // Initialize Flash model for quick responses
        flashModel = vertex.generativeModel(
            modelName: "gemini-1.5-flash",
            generationConfig: generationConfig,
            safetySettings: safetySettings
        )
        
        // Initialize Pro model for complex analysis
        proModel = vertex.generativeModel(
            modelName: "gemini-1.5-pro",
            generationConfig: generationConfig,
            safetySettings: safetySettings
        )
        #endif
    }
    
    // MARK: - Meal Analysis
    
    func analyzeMealFromImage(_ imageData: Data, mealType: MealType, userContext: String = "") async throws -> MealAnalysisResult {
        #if canImport(FirebaseVertexAI)
        let prompt = createMealAnalysisPrompt(mealType: mealType, userContext: userContext)
        
        do {
            guard let model = proModel else {
                throw GeminiError.analysisError("Model not initialized")
            }
            let response = try await model.generateContent(prompt)
            return try parseMealAnalysisResponse(response.text ?? "")
        } catch {
            print("Gemini API Error: \(error)")
            throw GeminiError.analysisError("Failed to analyze meal image")
        }
        #else
        // Return mock data when Firebase is not available
        return MealAnalysisResult(
            meal: Meal(userId: "", name: "Mock Meal", mealType: mealType, logMethod: .photoScan),
            confidence: 0.85,
            clarificationQuestions: []
        )
        #endif
    }
    
    func analyzeMealFromVoice(_ transcript: String, mealType: MealType, userContext: String = "") async throws -> MealAnalysisResult {
        let prompt = createVoiceMealAnalysisPrompt(transcript: transcript, mealType: mealType, userContext: userContext)
        
        do {
            guard let model = flashModel else {
                throw GeminiError.analysisError("Model not initialized")
            }
            let response = try await model.generateContent(prompt)
            return try parseMealAnalysisResponse(response.text ?? "")
        } catch {
            print("Gemini API Error: \(error)")
            throw GeminiError.analysisError("Failed to analyze meal from voice")
        }
    }
    
    func generateClarificationQuestions(for meal: Meal, confidence: Double) async throws -> [ClarificationQuestion] {
        let prompt = createClarificationPrompt(meal: meal, confidence: confidence)
        
        do {
            guard let model = flashModel else {
                throw GeminiError.clarificationError("Model not initialized")
            }
            let response = try await model.generateContent(prompt)
            return try parseClarificationResponse(response.text ?? "")
        } catch {
            print("Gemini API Error: \(error)")
            throw GeminiError.clarificationError("Failed to generate clarification questions")
        }
    }
    
    // MARK: - Coaching Insights
    
    func generateCoachingInsights(for user: PlateUp.User, meals: [Meal], timeframe: CoachingInsight.TimeFrame) async throws -> [CoachingInsight] {
        let prompt = createCoachingAnalysisPrompt(user: user, meals: meals, timeframe: timeframe)
        
        do {
            guard let model = proModel else {
                throw GeminiError.coachingError("Model not initialized")
            }
            let response = try await model.generateContent(prompt)
            return try parseCoachingInsightsResponse(response.text ?? "", userId: user.id)
        } catch {
            print("Gemini API Error: \(error)")
            throw GeminiError.coachingError("Failed to generate coaching insights")
        }
    }
    
    func generateWeeklyReport(for user: PlateUp.User, meals: [Meal], previousInsights: [CoachingInsight]) async throws -> WeeklyCoachingReport {
        let prompt = createWeeklyReportPrompt(user: user, meals: meals, previousInsights: previousInsights)
        
        do {
            guard let model = proModel else {
                throw GeminiError.reportError("Model not initialized")
            }
            let response = try await model.generateContent(prompt)
            return try parseWeeklyReportResponse(response.text ?? "", userId: user.id)
        } catch {
            print("Gemini API Error: \(error)")
            throw GeminiError.reportError("Failed to generate weekly report")
        }
    }
    
    // MARK: - Recipe Generation
    
    func generatePersonalizedRecipe(for user: PlateUp.User, mealType: MealType, constraints: RecipeConstraints) async throws -> PersonalizedRecipe {
        let prompt = createRecipeGenerationPrompt(user: user, mealType: mealType, constraints: constraints)
        
        do {
            guard let model = flashModel else {
                throw GeminiError.recipeError("Model not initialized")
            }
            let response = try await model.generateContent(prompt)
            return try parseRecipeResponse(response.text ?? "")
        } catch {
            print("Gemini API Error: \(error)")
            throw GeminiError.recipeError("Failed to generate personalized recipe")
        }
    }
    
    // MARK: - Prompt Creation
    
    private func createMealAnalysisPrompt(mealType: MealType, userContext: String) -> String {
        return """
        You are an expert nutritionist analyzing a meal photo. Please provide a detailed nutritional breakdown.
        
        Meal Type: \(mealType.rawValue)
        User Context: \(userContext)
        
        Analyze the image and provide:
        1. Meal name/description
        2. List of visible ingredients with estimated quantities
        3. Nutritional information (calories, protein, carbs, fat, fiber, sugar, sodium)
        4. Confidence score for your analysis (0-100)
        5. Any items that are unclear or need clarification
        
        Format your response as JSON with the following structure:
        {
            "name": "Meal name",
            "description": "Brief description",
            "ingredients": [
                {
                    "name": "ingredient name",
                    "quantity": estimated_quantity,
                    "unit": "measurement unit",
                    "isWholeFood": true/false,
                    "category": "ingredient category"
                }
            ],
            "nutrition": {
                "calories": estimated_calories,
                "protein": grams,
                "carbs": grams,
                "fat": grams,
                "fiber": grams,
                "sugar": grams,
                "sodium": mg
            },
            "confidence": confidence_score,
            "clarificationNeeded": ["list of unclear items"]
        }
        """
    }
    
    private func createVoiceMealAnalysisPrompt(transcript: String, mealType: MealType, userContext: String) -> String {
        return """
        You are an expert nutritionist analyzing a meal description from voice input. Please provide a detailed nutritional breakdown.
        
        Voice Transcript: "\(transcript)"
        Meal Type: \(mealType.rawValue)
        User Context: \(userContext)
        
        Based on the voice description, provide:
        1. Meal name/description
        2. List of mentioned ingredients with estimated quantities
        3. Nutritional information (calories, protein, carbs, fat, fiber, sugar, sodium)
        4. Confidence score for your analysis (0-100)
        5. Any unclear items that need clarification
        
        Format your response as JSON with the same structure as meal image analysis.
        """
    }
    
    private func createClarificationPrompt(meal: Meal, confidence: Double) -> String {
        return """
        You are helping clarify meal details for better nutritional accuracy.
        
        Current Meal Data:
        - Name: \(meal.name)
        - Description: \(meal.description ?? "N/A")
        - Ingredients: \(meal.ingredients.map { $0.name }.joined(separator: ", "))
        - Current Confidence: \(confidence)%
        
        Generate 1-3 clarification questions to improve accuracy. Focus on:
        - Portion sizes if unclear
        - Cooking methods that affect calories
        - Hidden ingredients (oils, sauces, etc.)
        - Preparation details
        
        Format as JSON:
        {
            "questions": [
                {
                    "question": "Question text",
                    "options": ["option1", "option2", "option3"] // optional
                }
            ]
        }
        """
    }
    
    private func createCoachingAnalysisPrompt(user: PlateUp.User, meals: [Meal], timeframe: CoachingInsight.TimeFrame) -> String {
        let mealsSummary = meals.prefix(10).map { meal in
            "\(meal.name) (\(meal.mealType.rawValue)): \(meal.calories ?? 0) cal at \(DateFormatter().string(from: meal.timestamp))"
        }.joined(separator: "\n")
        
        return """
        You are a personalized nutrition coach analyzing \(user.name)'s eating patterns.
        
        USER PROFILE:
        - Primary Goal: \(user.primaryGoal?.rawValue ?? "General Health")
        - Additional Goals: \(user.healthGoals.map { $0.rawValue }.joined(separator: ", "))
        - Activity Level: \(user.activityLevel.rawValue)
        - Daily Calorie Target: \(user.dailyCalorieGoal ?? 2000)
        
        RECENT MEALS (\(timeframe.rawValue)):
        \(mealsSummary)
        
        Provide 1-3 actionable coaching insights. For each insight:
        1. Identify specific patterns affecting their \(user.primaryGoal?.rawValue ?? "goals")
        2. Provide specific, actionable advice
        3. Explain the reasoning
        4. Predict expected outcomes
        5. Rate priority (critical/high/medium/low)
        
        Format as JSON:
        {
            "insights": [
                {
                    "title": "Insight title",
                    "insight": "What you observed",
                    "actionableAdvice": "Specific action to take",
                    "reasoning": "Why this matters",
                    "expectedOutcome": "What will improve",
                    "category": "mealTiming/macroBalance/energyPatterns/etc",
                    "priority": "high/medium/low",
                    "confidenceScore": 0.8,
                    "impactOnPrimaryGoal": "positive/negative/neutral"
                }
            ]
        }
        """
    }
    
    private func createWeeklyReportPrompt(user: PlateUp.User, meals: [Meal], previousInsights: [CoachingInsight]) -> String {
        return """
        Generate a comprehensive weekly nutrition report for \(user.name).
        
        [Include similar detailed prompting structure for weekly reports]
        """
    }
    
    private func createRecipeGenerationPrompt(user: PlateUp.User, mealType: MealType, constraints: RecipeConstraints) -> String {
        return """
        Generate a personalized recipe for \(user.name).
        
        [Include detailed recipe generation prompting]
        """
    }
    
    // MARK: - Response Parsing
    
    private func parseMealAnalysisResponse(_ response: String) throws -> MealAnalysisResult {
        // Parse JSON response and convert to MealAnalysisResult
        // Implementation will parse the structured JSON response
        guard let data = response.data(using: .utf8) else {
            throw GeminiError.parsingError("Invalid response format")
        }
        
        // For now, return a placeholder - full implementation would parse JSON
        return MealAnalysisResult(
            meal: Meal(userId: "", name: "Parsed Meal", mealType: .lunch, logMethod: .photoScan),
            confidence: 0.85,
            clarificationQuestions: []
        )
    }
    
    private func parseClarificationResponse(_ response: String) throws -> [ClarificationQuestion] {
        // Parse clarification questions from JSON response
        return []
    }
    
    private func parseCoachingInsightsResponse(_ response: String, userId: String) throws -> [CoachingInsight] {
        // Parse coaching insights from JSON response
        return []
    }
    
    private func parseWeeklyReportResponse(_ response: String, userId: String) throws -> WeeklyCoachingReport {
        // Parse weekly report from JSON response
        let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek) ?? Date()
        
        return WeeklyCoachingReport(
            userId: userId,
            weekStartDate: startOfWeek,
            weekEndDate: endOfWeek
        )
    }
    
    private func parseRecipeResponse(_ response: String) throws -> PersonalizedRecipe {
        // Parse recipe from JSON response
        // TODO: Implement proper JSON parsing
        return PersonalizedRecipe(
            name: "Generated Recipe",
            ingredients: [],
            instructions: [],
            nutrition: PersonalizedRecipe.NutritionInfo(
                calories: 0,
                protein: 0,
                carbs: 0,
                fat: 0,
                fiber: nil
            ),
            cookingTime: 30,
            servings: 1,
            difficulty: "Medium",
            reasoning: "Recipe generated based on your preferences"
        )
    }
}

// MARK: - Supporting Types

struct MealAnalysisResult {
    let meal: Meal
    let confidence: Double
    let clarificationQuestions: [ClarificationQuestion]
}

struct RecipeConstraints {
    let cookingTime: Int? // minutes
    let servings: Int
    let dietaryRestrictions: [PlateUp.User.DietaryRestriction]
    let availableIngredients: [String]
    let budgetRange: String?
}

struct PersonalizedRecipe: Identifiable {
    let id = UUID()
    let name: String
    let ingredients: [Ingredient]
    let instructions: [String]
    let nutrition: NutritionInfo
    let cookingTime: Int
    let servings: Int
    let difficulty: String
    let reasoning: String
    
    struct Ingredient {
        let name: String
        let amount: String
        let unit: String?
    }
    
    struct NutritionInfo {
        let calories: Int
        let protein: Double
        let carbs: Double
        let fat: Double
        let fiber: Double?
    }
}

// MARK: - Error Types

enum GeminiError: Error, LocalizedError {
    case analysisError(String)
    case clarificationError(String)
    case coachingError(String)
    case reportError(String)
    case recipeError(String)
    case parsingError(String)
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .analysisError(let message),
             .clarificationError(let message),
             .coachingError(let message),
             .reportError(let message),
             .recipeError(let message),
             .parsingError(let message),
             .networkError(let message):
            return message
        }
    }
}