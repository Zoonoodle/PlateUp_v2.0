//
//  PatternRecognitionView.swift
//  PlateUp
//
//  Pattern recognition for foods that help or hurt goals
//

import SwiftUI

struct PatternRecognitionView: View {
    let patterns: RecognizedPatterns
    @State private var showAllPositive = false
    @State private var showAllNegative = false
    @Environment(\.appTheme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("PATTERNS FOUND")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.themed(.secondaryText, theme: theme))
            
            // Positive Patterns
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Foods That Help", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.plateUpSuccess)
                    
                    Spacer()
                    
                    if patterns.positiveFoods.count > 3 {
                        Button(action: { showAllPositive.toggle() }) {
                            Text(showAllPositive ? "Show Less" : "Show All")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.themed(.accent, theme: theme))
                        }
                    }
                }
                
                ForEach(showAllPositive ? patterns.positiveFoods : Array(patterns.positiveFoods.prefix(3))) { food in
                    PatternFoodRow(food: food, isPositive: true, theme: theme)
                }
            }
            
            Divider()
                .background(Color.plateUpBorder)
            
            // Negative Patterns
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Foods That Hurt", systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.plateUpWarning)
                    
                    Spacer()
                    
                    if patterns.negativeFoods.count > 3 {
                        Button(action: { showAllNegative.toggle() }) {
                            Text(showAllNegative ? "Show Less" : "Show All")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.themed(.accent, theme: theme))
                        }
                    }
                }
                
                ForEach(showAllNegative ? patterns.negativeFoods : Array(patterns.negativeFoods.prefix(3))) { food in
                    PatternFoodRow(food: food, isPositive: false, theme: theme)
                }
            }
            
            // Meal Timing Patterns
            if !patterns.timingPatterns.isEmpty {
                Divider()
                    .background(Color.plateUpBorder)
                
                VStack(alignment: .leading, spacing: 12) {
                    Label("Timing Patterns", systemImage: "clock.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.themed(.accent, theme: theme))
                    
                    ForEach(patterns.timingPatterns) { pattern in
                        TimingPatternRow(pattern: pattern, theme: theme)
                    }
                }
            }
        }
        .padding(PlateUpComponentStyle.largeSpacing)
        .background(
            RoundedRectangle(cornerRadius: PlateUpComponentStyle.largeRadius)
                .fill(Color.themed(.card, theme: theme))
        )
    }
}

// MARK: - Pattern Food Row
struct PatternFoodRow: View {
    let food: PatternFood
    let isPositive: Bool
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Food Icon
            ZStack {
                Circle()
                    .fill(isPositive ? Color.plateUpSuccess.opacity(0.1) : Color.plateUpWarning.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: food.icon)
                    .font(.system(size: 18))
                    .foregroundColor(isPositive ? .plateUpSuccess : .plateUpWarning)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.themed(.primaryText, theme: theme))
                
                Text(food.impact)
                    .font(.system(size: 12))
                    .foregroundColor(Color.themed(.secondaryText, theme: theme))
            }
            
            Spacer()
            
            // Frequency
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(food.frequency)x")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.themed(.primaryText, theme: theme))
                
                Text("this week")
                    .font(.system(size: 10))
                    .foregroundColor(Color.plateUpTertiaryText)
            }
        }
    }
}

// MARK: - Timing Pattern Row
struct TimingPatternRow: View {
    let pattern: TimingPattern
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 16))
                .foregroundColor(Color.themed(.accent, theme: theme))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(pattern.description)
                    .font(.system(size: 13))
                    .foregroundColor(Color.themed(.primaryText, theme: theme))
                
                Text(pattern.impact)
                    .font(.system(size: 12))
                    .foregroundColor(Color.themed(.secondaryText, theme: theme))
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.plateUpTertiaryBackground)
        )
    }
}