//
//  MealType.swift
//  PlateUp
//
//  Shared meal type enum for use across the app
//

import Foundation

enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    case preWorkout = "Pre-workout"
    case postWorkout = "Post-workout"
    
    var displayName: String { rawValue }
    
    var emoji: String {
        switch self {
        case .breakfast: return "🌅"
        case .lunch: return "☀️"
        case .dinner: return "🌙"
        case .snack: return "🍎"
        case .preWorkout: return "💪"
        case .postWorkout: return "🏃‍♂️"
        }
    }
}