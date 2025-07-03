//
//  RecentMealsSection.swift
//  PlateUp
//
//  Recent meals display with quick actions
//

import SwiftUI

struct RecentMealsSection: View {
    let meals: [Meal]
    
    var body: some View {
        VStack(alignment: .leading, spacing: PlateUpComponentStyle.mediumSpacing) {
            // Header
            HStack {
                Text("Recent Meals")
                    .font(PlateUpTypography.headline)
                    .foregroundColor(.plateUpPrimaryText)
                
                Spacer()
                
                Button(action: {}) {
                    Text("View All")
                        .font(PlateUpTypography.caption1)
                        .foregroundColor(.plateUpGreen)
                }
            }
            
            // Meal cards
            VStack(spacing: PlateUpComponentStyle.smallSpacing) {
                ForEach(meals.prefix(3)) { meal in
                    MealPreviewCard(meal: meal)
                }
            }
        }
    }
}

struct MealPreviewCard: View {
    let meal: Meal
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: meal.timestamp, relativeTo: Date())
    }
    
    var qualityScore: Int {
        // Calculate based on meal composition
        Int(meal.qualityScore)
    }
    
    var qualityColor: Color {
        switch qualityScore {
        case 80...:
            return .plateUpGreen
        case 60..<80:
            return .plateUpWarning
        default:
            return .plateUpError
        }
    }
    
    var body: some View {
        HStack(spacing: PlateUpComponentStyle.mediumSpacing) {
            // Meal type icon
            ZStack {
                Circle()
                    .fill(Color.plateUpTertiaryBackground)
                    .frame(width: 50, height: 50)
                
                Text(meal.mealType.emoji)
                    .font(.title2)
            }
            
            // Meal info
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(PlateUpTypography.subheadline)
                    .foregroundColor(.plateUpPrimaryText)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    // Time
                    Text(timeAgo)
                        .font(PlateUpTypography.caption2)
                        .foregroundColor(.plateUpSecondaryText)
                    
                    // Calories
                    if let calories = meal.calories {
                        Text("•")
                            .foregroundColor(.plateUpTertiaryText)
                        
                        Text("\(calories) cal")
                            .font(PlateUpTypography.caption2)
                            .foregroundColor(.plateUpSecondaryText)
                    }
                    
                    // Quality score
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(qualityColor)
                        
                        Text("\(qualityScore)")
                            .font(PlateUpTypography.caption2)
                            .foregroundColor(qualityColor)
                    }
                }
            }
            
            Spacer()
            
            // Quick actions
            Menu {
                Button(action: {}) {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(action: {}) {
                    Label("Log Again", systemImage: "arrow.clockwise")
                }
                
                Button(action: {}) {
                    Label("View Details", systemImage: "eye")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundColor(.plateUpTertiaryText)
            }
        }
        .padding(PlateUpComponentStyle.cardPadding)
        .background(Color.plateUpCardBackground)
        .cornerRadius(PlateUpComponentStyle.mediumRadius)
        .overlay(
            RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                .stroke(Color.plateUpBorder, lineWidth: 0.5)
        )
    }
}