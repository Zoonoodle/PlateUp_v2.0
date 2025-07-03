//
//  InsightsCarousel.swift
//  PlateUp
//
//  Horizontal scrolling carousel for AI insights
//

import SwiftUI

struct InsightsCarousel: View {
    let insights: [CoachingInsight]
    
    var body: some View {
        VStack(alignment: .leading, spacing: PlateUpComponentStyle.mediumSpacing) {
            Text("Today's Insights")
                .font(PlateUpTypography.headline)
                .foregroundColor(.plateUpPrimaryText)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PlateUpComponentStyle.mediumSpacing) {
                    ForEach(insights) { insight in
                        CoachingInsightCard(insight: insight)
                            .frame(width: 280)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CoachingInsightCard: View {
    let insight: CoachingInsight
    @State private var isDismissed = false
    
    var iconName: String {
        switch insight.category {
        case .energyPatterns:
            return "bolt.fill"
        case .mealTiming:
            return "clock.fill"
        case .macroBalance:
            return "chart.pie.fill"
        case .hydration:
            return "drop.fill"
        case .sleepNutrition:
            return "moon.fill"
        case .goalProgress:
            return "target"
        case .foodChoices:
            return "leaf.fill"
        case .portionSizes:
            return "square.resize"
        case .exerciseNutrition:
            return "figure.run"
        case .weeklyReview:
            return "calendar"
        }
    }
    
    var iconColor: Color {
        switch insight.priority {
        case .critical:
            return .plateUpError
        case .high:
            return .plateUpWarning
        case .medium:
            return .plateUpGreen
        case .low:
            return .plateUpInfo
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundColor(iconColor)
                
                Text(insight.title)
                    .font(PlateUpTypography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.plateUpPrimaryText)
                    .lineLimit(1)
                
                Spacer()
                
                Button(action: { 
                    withAnimation {
                        isDismissed = true
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.plateUpTertiaryText)
                }
            }
            
            // Insight text
            Text(insight.insight)
                .font(PlateUpTypography.caption1)
                .foregroundColor(.plateUpSecondaryText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Action
            Text(insight.actionableAdvice)
                .font(PlateUpTypography.caption1)
                .fontWeight(.medium)
                .foregroundColor(.plateUpGreen)
                .lineLimit(1)
            
            // Learn more button
            Button(action: {}) {
                Text("Learn more")
                    .font(PlateUpTypography.caption2)
                    .foregroundColor(.plateUpTertiaryText)
            }
        }
        .padding(PlateUpComponentStyle.cardPadding)
        .background(Color.plateUpCardBackground)
        .cornerRadius(PlateUpComponentStyle.largeRadius)
        .overlay(
            RoundedRectangle(cornerRadius: PlateUpComponentStyle.largeRadius)
                .stroke(Color.plateUpBorder, lineWidth: 0.5)
        )
        .opacity(isDismissed ? 0 : 1)
        .scaleEffect(isDismissed ? 0.8 : 1)
    }
}