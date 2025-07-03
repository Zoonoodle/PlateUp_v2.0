//
//  MealTimingInsights.swift
//  PlateUp
//
//  Meal timing visualization showing correlation with sleep and energy
//

import SwiftUI

struct MealTimingInsights: View {
    let viewModel: ProgressViewModel
    @State private var selectedDay: String?
    @Environment(\.appTheme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("MEAL TIMING IMPACT")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.themed(.secondaryText, theme: theme))
                
                Spacer()
                
                Text("This Week")
                    .font(.system(size: 12))
                    .foregroundColor(Color.plateUpTertiaryText)
            }
            
            // Key Insights
            VStack(spacing: 12) {
                TimingInsightRow(
                    icon: "moon.zzz.fill",
                    title: "Late dinners affecting sleep",
                    detail: "Eating after 8pm → 1.5hrs less sleep",
                    isNegative: true,
                    theme: theme
                )
                
                TimingInsightRow(
                    icon: "sun.max.fill",
                    title: "Early protein boosts energy",
                    detail: "Breakfast before 8am → Better focus",
                    isNegative: false,
                    theme: theme
                )
            }
            
            Divider()
                .background(Color.plateUpBorder)
            
            // Weekly Pattern Chart
            Text("WEEKLY PATTERN")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.plateUpSecondaryText)
            
            MealTimingChart(data: viewModel.mealTimingData)
                .frame(height: 250)
            
            // Correlation Summary
            CorrelationSummaryView(theme: theme)
        }
        .padding(PlateUpComponentStyle.largeSpacing)
        .background(
            RoundedRectangle(cornerRadius: PlateUpComponentStyle.largeRadius)
                .fill(Color.themed(.card, theme: theme))
        )
    }
}

// MARK: - Timing Insight Row
struct TimingInsightRow: View {
    let icon: String
    let title: String
    let detail: String
    let isNegative: Bool
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isNegative ? .plateUpWarning : .plateUpSuccess)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.themed(.primaryText, theme: theme))
                
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundColor(Color.themed(.secondaryText, theme: theme))
            }
            
            Spacer()
        }
    }
}

// MARK: - Correlation Summary
struct CorrelationSummaryView: View {
    let theme: AppTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("KEY CORRELATIONS")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.plateUpSecondaryText)
            
            HStack(spacing: 16) {
                CorrelationCard(
                    title: "Best Sleep",
                    value: "7:30pm",
                    subtitle: "dinner time",
                    color: .plateUpSuccess,
                    theme: theme
                )
                
                CorrelationCard(
                    title: "Best Energy",
                    value: "7:00am",
                    subtitle: "breakfast time",
                    color: .plateUpInfo,
                    theme: theme
                )
                
                CorrelationCard(
                    title: "Optimal Gap",
                    value: "3hrs",
                    subtitle: "dinner to bed",
                    color: .plateUpWarning,
                    theme: theme
                )
            }
        }
    }
}

// MARK: - Correlation Card
struct CorrelationCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let theme: AppTheme
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(Color.plateUpSecondaryText)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(Color.plateUpTertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

