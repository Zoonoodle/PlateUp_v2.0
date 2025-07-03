//
//  HealthGoal.swift
//  PlateUp
//
//  Model for health goals with selection state
//

import SwiftUI

struct HealthGoal: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    var isSelected: Bool
    
    static let defaultGoals: [HealthGoal] = [
        HealthGoal(name: "Lose Weight", icon: "scalemass", color: Color(hex: "3b82f6"), isSelected: true),
        HealthGoal(name: "Build Muscle", icon: "figure.strengthtraining.traditional", color: Color(hex: "f97316"), isSelected: true),
        HealthGoal(name: "Improve Energy", icon: "bolt.fill", color: Color(hex: "eab308"), isSelected: true),
        HealthGoal(name: "Better Sleep", icon: "moon.fill", color: Color(hex: "8b5cf6"), isSelected: true)
    ]
}