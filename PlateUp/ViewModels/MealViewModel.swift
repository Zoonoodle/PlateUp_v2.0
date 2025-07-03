//
//  MealViewModel.swift
//  PlateUp v2.0
//
//  Meal logging and management with @Observable
//

import Foundation
import SwiftUI

@Observable
class MealViewModel {
    
    // MARK: - Published Properties
    var meals: [Meal] = []
    var todaysMeals: [Meal] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var selectedMeal: Meal?
    
    // MARK: - Logging State
    var isAnalyzing: Bool = false
    var analysisProgress: Double = 0.0
    var currentMealDraft: Meal?
    var clarificationQuestions: [ClarificationQuestion] = []
    var needsClarification: Bool = false
    
    // MARK: - Form Properties
    var mealName: String = ""
    var mealDescription: String = ""
    var selectedMealType: MealType = .lunch
    var logMethod: Meal.LogMethod = .photoScan
    
    // MARK: - Dependencies
    private let firebaseService = FirebaseService.shared
    private let geminiService = GeminiService.shared
    private let authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        
        // Load meals when user signs in
        if authViewModel.isSignedIn {
            Task {
                await loadMeals()
            }
        }
    }
    
    // MARK: - Meal Loading
    
    func loadMeals() async {
        guard let userId = authViewModel.currentUser?.id else { return }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let fetchedMeals = try await firebaseService.getMeals(for: userId)
            
            await MainActor.run {
                self.meals = fetchedMeals
                self.updateTodaysMeals()
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func loadMealsForDateRange(startDate: Date, endDate: Date) async -> [Meal] {
        guard let userId = authViewModel.currentUser?.id else { return [] }
        
        do {
            return try await firebaseService.getMealsForDateRange(
                userId: userId,
                startDate: startDate,
                endDate: endDate
            )
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return []
        }
    }
    
    private func updateTodaysMeals() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? Date()
        
        todaysMeals = meals.filter { meal in
            meal.timestamp >= today && meal.timestamp < tomorrow
        }.sorted { $0.timestamp < $1.timestamp }
    }
    
    // MARK: - Photo Meal Logging
    
    func logMealFromPhoto(_ imageData: Data, mealType: MealType) async {
        guard let userId = authViewModel.currentUser?.id else { return }
        
        await MainActor.run {
            isAnalyzing = true
            analysisProgress = 0.1
            errorMessage = nil
        }
        
        do {
            // Upload image first
            await MainActor.run { analysisProgress = 0.3 }
            let imagePath = "meals/\(userId)/\(UUID().uuidString).jpg"
            let imageURL = try await firebaseService.uploadImage(imageData, path: imagePath)
            
            // Analyze with Gemini
            await MainActor.run { analysisProgress = 0.6 }
            let userContext = createUserContext()
            let analysisResult = try await geminiService.analyzeMealFromImage(
                imageData,
                mealType: mealType,
                userContext: userContext
            )
            
            await MainActor.run { analysisProgress = 0.9 }
            
            // Create meal with analysis results
            var meal = analysisResult.meal
            meal.userId = userId
            meal.imageURL = imageURL
            meal.mealType = mealType
            meal.logMethod = .photoScan
            
            // Handle clarification if needed
            if !analysisResult.clarificationQuestions.isEmpty {
                meal.clarificationQuestions = analysisResult.clarificationQuestions
                meal.needsClarification = true
                meal.analysisStatus = .needsClarification
                
                await MainActor.run {
                    self.currentMealDraft = meal
                    self.clarificationQuestions = analysisResult.clarificationQuestions
                    self.needsClarification = true
                }
            } else {
                meal.analysisStatus = .completed
                try await firebaseService.saveMeal(meal)
                
                await MainActor.run {
                    self.meals.insert(meal, at: 0)
                    self.updateTodaysMeals()
                }
            }
            
            await MainActor.run {
                self.analysisProgress = 1.0
                self.isAnalyzing = false
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isAnalyzing = false
                self.analysisProgress = 0.0
            }
        }
    }
    
    // MARK: - Voice Meal Logging
    
    func logMealFromVoice(_ transcript: String, mealType: MealType) async {
        guard let userId = authViewModel.currentUser?.id else { return }
        
        await MainActor.run {
            isAnalyzing = true
            analysisProgress = 0.2
            errorMessage = nil
        }
        
        do {
            await MainActor.run { analysisProgress = 0.6 }
            let userContext = createUserContext()
            let analysisResult = try await geminiService.analyzeMealFromVoice(
                transcript,
                mealType: mealType,
                userContext: userContext
            )
            
            await MainActor.run { analysisProgress = 0.9 }
            
            var meal = analysisResult.meal
            meal.userId = userId
            meal.mealType = mealType
            meal.logMethod = .voiceInput
            
            if !analysisResult.clarificationQuestions.isEmpty {
                meal.clarificationQuestions = analysisResult.clarificationQuestions
                meal.needsClarification = true
                meal.analysisStatus = .needsClarification
                
                await MainActor.run {
                    self.currentMealDraft = meal
                    self.clarificationQuestions = analysisResult.clarificationQuestions
                    self.needsClarification = true
                }
            } else {
                meal.analysisStatus = .completed
                try await firebaseService.saveMeal(meal)
                
                await MainActor.run {
                    self.meals.insert(meal, at: 0)
                    self.updateTodaysMeals()
                }
            }
            
            await MainActor.run {
                self.analysisProgress = 1.0
                self.isAnalyzing = false
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isAnalyzing = false
                self.analysisProgress = 0.0
            }
        }
    }
    
    // MARK: - Manual Meal Entry
    
    func createManualMeal() async {
        guard let userId = authViewModel.currentUser?.id,
              !mealName.isEmpty else { return }
        
        isLoading = true
        
        let meal = Meal(
            userId: userId,
            name: mealName,
            description: mealDescription.isEmpty ? nil : mealDescription,
            mealType: selectedMealType,
            logMethod: .manualEntry,
            analysisStatus: .completed,
            isUserGenerated: true
        )
        
        do {
            try await firebaseService.saveMeal(meal)
            
            await MainActor.run {
                self.meals.insert(meal, at: 0)
                self.updateTodaysMeals()
                self.clearMealForm()
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Clarification Handling
    
    func answerClarificationQuestion(_ questionId: String, answer: String) {
        guard let index = clarificationQuestions.firstIndex(where: { $0.id == questionId }) else { return }
        clarificationQuestions[index].userAnswer = answer
    }
    
    func submitClarificationAnswers() async {
        guard var meal = currentMealDraft else { return }
        
        isLoading = true
        
        // Update meal with clarification answers
        meal.clarificationQuestions = clarificationQuestions
        meal.needsClarification = false
        meal.analysisStatus = .completed
        
        do {
            try await firebaseService.saveMeal(meal)
            
            await MainActor.run {
                self.meals.insert(meal, at: 0)
                self.updateTodaysMeals()
                self.clearClarificationState()
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func provideClarificationFeedback(_ questionId: String, feedback: ClarificationQuestion.FeedbackRating, isHelpful: Bool) async {
        guard let meal = currentMealDraft else { return }
        
        do {
            try await firebaseService.saveClarificationFeedback(
                mealId: meal.id,
                questionId: questionId,
                feedback: feedback.rawValue,
                isHelpful: isHelpful
            )
            
            // Update local question with feedback
            if let index = clarificationQuestions.firstIndex(where: { $0.id == questionId }) {
                await MainActor.run {
                    self.clarificationQuestions[index].feedbackRating = feedback
                    self.clarificationQuestions[index].isHelpful = isHelpful
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Meal Management
    
    func updateMeal(_ meal: Meal) async {
        isLoading = true
        
        do {
            try await firebaseService.updateMeal(meal)
            
            if let index = meals.firstIndex(where: { $0.id == meal.id }) {
                await MainActor.run {
                    self.meals[index] = meal
                    self.updateTodaysMeals()
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func deleteMeal(_ meal: Meal) async {
        isLoading = true
        
        do {
            try await firebaseService.deleteMeal(mealId: meal.id)
            
            await MainActor.run {
                self.meals.removeAll { $0.id == meal.id }
                self.updateTodaysMeals()
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createUserContext() -> String {
        guard let user = authViewModel.currentUser else { return "" }
        
        var context = "User Goals: \(user.healthGoals.map { $0.rawValue }.joined(separator: ", "))"
        if let primaryGoal = user.primaryGoal {
            context += "\nPrimary Goal: \(primaryGoal.rawValue)"
        }
        if let dailyCalories = user.dailyCalorieGoal {
            context += "\nDaily Calorie Goal: \(dailyCalories)"
        }
        context += "\nActivity Level: \(user.activityLevel.rawValue)"
        context += "\nDietary Restrictions: \(user.dietaryRestrictions.map { $0.rawValue }.joined(separator: ", "))"
        
        return context
    }
    
    private func clearMealForm() {
        mealName = ""
        mealDescription = ""
        selectedMealType = .lunch
    }
    
    private func clearClarificationState() {
        currentMealDraft = nil
        clarificationQuestions = []
        needsClarification = false
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Daily Statistics
    
    var todaysCalories: Int {
        todaysMeals.compactMap { $0.calories }.reduce(0, +)
    }
    
    var todaysProtein: Double {
        todaysMeals.compactMap { $0.protein }.reduce(0, +)
    }
    
    var todaysCarbs: Double {
        todaysMeals.compactMap { $0.carbs }.reduce(0, +)
    }
    
    var todaysFat: Double {
        todaysMeals.compactMap { $0.fat }.reduce(0, +)
    }
    
    var dailyCalorieGoal: Int {
        authViewModel.currentUser?.dailyCalorieGoal ?? 2000
    }
    
    var calorieProgress: Double {
        guard dailyCalorieGoal > 0 else { return 0 }
        return Double(todaysCalories) / Double(dailyCalorieGoal)
    }
}