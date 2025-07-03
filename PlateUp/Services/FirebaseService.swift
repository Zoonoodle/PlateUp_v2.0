//
//  FirebaseService.swift
//  PlateUp v2.0
//
//  Centralized Firebase service layer
//

import Foundation
#if canImport(FirebaseCore)
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions
import FirebaseStorage
#endif

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    
    #if canImport(FirebaseCore)
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    private let storage = Storage.storage()
    private let functions = Functions.functions()
    #endif
    
    // MARK: - Auth State
    #if canImport(FirebaseCore)
    var currentUser: FirebaseAuth.User? {
        return auth.currentUser
    }
    #else
    var currentUser: Any? {
        return nil
    }
    #endif
    
    var isUserSignedIn: Bool {
        return currentUser != nil
    }
    
    private init() {
        #if canImport(FirebaseFirestore)
        // Configure Firestore settings only when Firebase is available
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        db.settings = settings
        #endif
    }
    
    // MARK: - Authentication
    
    func signInWithEmail(_ email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await auth.signIn(withEmail: email, password: password)
        return result.user
    }
    
    func signUpWithEmail(_ email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await auth.createUser(withEmail: email, password: password)
        return result.user
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = currentUser else {
            throw FirebaseError.userNotSignedIn
        }
        
        // Delete user data from Firestore first
        try await deleteUserData(userId: user.uid)
        
        // Then delete the auth account
        #if canImport(FirebaseAuth)
        try await user.delete()
        #endif
    }
    
    // MARK: - User Management
    
    func createUserProfile(_ user: PlateUp.User) async throws {
        try await db.collection("users").document(user.id).setData(from: user, merge: false)
    }
    
    func getUserProfile(userId: String) async throws -> PlateUp.User {
        let document = try await db.collection("users").document(userId).getDocument()
        return try document.data(as: PlateUp.User.self)
    }
    
    func updateUserProfile(_ user: PlateUp.User) async throws {
        try await db.collection("users").document(user.id).setData(from: user, merge: true)
    }
    
    private func deleteUserData(userId: String) async throws {
        let batch = db.batch()
        
        // Delete user profile
        let userRef = db.collection("users").document(userId)
        batch.deleteDocument(userRef)
        
        // Delete user's meals
        let mealsQuery = db.collection("meals").whereField("userId", isEqualTo: userId)
        let mealsSnapshot = try await mealsQuery.getDocuments()
        for meal in mealsSnapshot.documents {
            batch.deleteDocument(meal.reference)
        }
        
        // Delete user's coaching insights
        let insightsQuery = db.collection("coaching_insights").whereField("userId", isEqualTo: userId)
        let insightsSnapshot = try await insightsQuery.getDocuments()
        for insight in insightsSnapshot.documents {
            batch.deleteDocument(insight.reference)
        }
        
        try await batch.commit()
    }
    
    // MARK: - Meal Management
    
    func saveMeal(_ meal: Meal) async throws {
        try await db.collection("meals").document(meal.id).setData(from: meal, merge: false)
    }
    
    func getMeals(for userId: String, limit: Int = 50) async throws -> [Meal] {
        let query = db.collection("meals")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
        
        let snapshot = try await query.getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Meal.self) }
    }
    
    func getMealsForDateRange(userId: String, startDate: Date, endDate: Date) async throws -> [Meal] {
        let query = db.collection("meals")
            .whereField("userId", isEqualTo: userId)
            .whereField("timestamp", isGreaterThanOrEqualTo: startDate)
            .whereField("timestamp", isLessThanOrEqualTo: endDate)
            .order(by: "timestamp", descending: true)
        
        let snapshot = try await query.getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Meal.self) }
    }
    
    func updateMeal(_ meal: Meal) async throws {
        var updatedMeal = meal
        updatedMeal.updatedAt = Date()
        try await db.collection("meals").document(meal.id).setData(from: updatedMeal, merge: false)
    }
    
    func deleteMeal(mealId: String) async throws {
        try await db.collection("meals").document(mealId).delete()
    }
    
    // MARK: - Coaching Insights
    
    func saveCoachingInsight(_ insight: CoachingInsight) async throws {
        try await db.collection("coaching_insights").document(insight.id).setData(from: insight, merge: false)
    }
    
    func getActiveCoachingInsights(for userId: String) async throws -> [CoachingInsight] {
        let query = db.collection("coaching_insights")
            .whereField("userId", isEqualTo: userId)
            .whereField("isActive", isEqualTo: true)
            .order(by: "createdAt", descending: true)
        
        let snapshot = try await query.getDocuments()
        let insights = try snapshot.documents.compactMap { try $0.data(as: CoachingInsight.self) }
        
        // Filter out expired insights
        return insights.filter { !$0.isExpired && $0.shouldShowToUser }
    }
    
    func updateCoachingInsight(_ insight: CoachingInsight) async throws {
        try await db.collection("coaching_insights").document(insight.id).setData(from: insight, merge: false)
    }
    
    func dismissCoachingInsight(insightId: String) async throws {
        try await db.collection("coaching_insights").document(insightId).updateData([
            "dismissedAt": Date(),
            "isActive": false
        ])
    }
    
    // MARK: - Clarification Feedback
    
    func saveClarificationFeedback(mealId: String, questionId: String, feedback: String, isHelpful: Bool) async throws {
        let feedbackData: [String: Any] = [
            "mealId": mealId,
            "questionId": questionId,
            "feedback": feedback,
            "isHelpful": isHelpful,
            "timestamp": Date(),
            "userId": currentUser?.uid ?? ""
        ]
        
        try await db.collection("clarification_feedback").addDocument(data: feedbackData)
    }
    
    // MARK: - File Upload
    
    func uploadImage(_ imageData: Data, path: String) async throws -> String {
        let storageRef = storage.reference().child(path)
        var metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let _ = try await storageRef.putData(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }
    
    func uploadAudio(_ audioData: Data, path: String) async throws -> String {
        let storageRef = storage.reference().child(path)
        var metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"
        
        let _ = try await storageRef.putData(audioData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }
    
    // MARK: - Cloud Functions
    
    func callFunction(name: String, data: [String: Any]) async throws -> [String: Any] {
        let function = functions.httpsCallable(name)
        let result = try await function.call(data)
        
        guard let data = result.data as? [String: Any] else {
            throw FirebaseError.invalidFunctionResponse
        }
        
        return data
    }
    
    // MARK: - Analytics
    
    func logEvent(_ eventName: String, parameters: [String: Any]? = nil) {
        // Firebase Analytics will be integrated later
        print("Analytics Event: \(eventName), Parameters: \(parameters ?? [:])")
    }
}

// MARK: - Error Types

enum FirebaseError: Error, LocalizedError {
    case userNotSignedIn
    case invalidFunctionResponse
    case dataEncodingError
    case dataDecodingError
    
    var errorDescription: String? {
        switch self {
        case .userNotSignedIn:
            return "User is not signed in"
        case .invalidFunctionResponse:
            return "Invalid response from cloud function"
        case .dataEncodingError:
            return "Failed to encode data"
        case .dataDecodingError:
            return "Failed to decode data"
        }
    }
}