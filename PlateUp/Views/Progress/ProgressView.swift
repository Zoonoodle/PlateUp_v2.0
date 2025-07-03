//
//  ProgressView.swift
//  PlateUp
//
//  Progress tracking with specific meal impact analysis and pattern recognition
//

import SwiftUI

struct ProgressTabView: View {
    @State private var viewModel = ProgressViewModel()
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedInsight: MealImpact?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: PlateUpComponentStyle.largeSpacing) {
                    // Header with time range selector
                    ProgressHeaderView(
                        selectedTimeRange: $selectedTimeRange,
                        themeManager: themeManager
                    )
                    .padding(.horizontal)
                    
                    // Modular Analytics Grid (MacroFactor-inspired)
                    AnalyticsGridView(
                        viewModel: viewModel,
                        selectedTimeRange: selectedTimeRange
                    )
                    .padding(.horizontal)
                    
                    // Specific Meal Impacts
                    MealImpactAnalysisView(
                        impacts: viewModel.mealImpacts,
                        selectedImpact: $selectedInsight
                    )
                    .padding(.horizontal)
                    
                    // Pattern Recognition
                    PatternRecognitionView(
                        patterns: viewModel.recognizedPatterns
                    )
                    .padding(.horizontal)
                    
                    // Bottom padding
                    Color.clear.frame(height: 20)
                }
            }
            .background(Color.themed(.background, theme: themeManager.currentTheme))
            .navigationBarHidden(true)
            .environment(\.appTheme, themeManager.currentTheme)
            .refreshable {
                await viewModel.loadProgressData(for: selectedTimeRange)
            }
        }
        .task {
            await viewModel.loadProgressData(for: selectedTimeRange)
        }
    }
}

// MARK: - Progress Header
struct ProgressHeaderView: View {
    @Binding var selectedTimeRange: TimeRange
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.appTheme) var theme
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Progress")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.themed(.primaryText, theme: theme))
                
                Spacer()
                
                // Theme toggle button
                Button(action: { themeManager.toggleTheme() }) {
                    Image(systemName: themeManager.currentTheme == .supabase ? "leaf.fill" : "square.fill")
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.accentColor)
                }
            }
            
            // Time range selector
            HStack(spacing: 0) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    TimeRangeButton(
                        title: range.displayName,
                        isSelected: selectedTimeRange == range,
                        theme: theme
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedTimeRange = range
                        }
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.plateUpBorder.opacity(0.3))
            )
        }
    }
}

// MARK: - Time Range Button
struct TimeRangeButton: View {
    let title: String
    let isSelected: Bool
    let theme: AppTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundColor(
                    isSelected ? 
                    (theme == .vercel ? .black : .white) : 
                    Color.themed(.secondaryText, theme: theme)
                )
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? Color.themed(.accent, theme: theme) : Color.clear)
                )
        }
    }
}

// MARK: - Analytics Grid
struct AnalyticsGridView: View {
    let viewModel: ProgressViewModel
    let selectedTimeRange: TimeRange
    @Environment(\.appTheme) var theme
    
    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 16
        ) {
            // Weight Trend Card
            AnalyticsCard(
                title: "WEIGHT TREND",
                subtitle: "Last \(selectedTimeRange.displayDays) Days",
                mainValue: viewModel.weightChange,
                unit: "lbs",
                trend: viewModel.weightTrend,
                chart: {
                    WeightTrendChart(data: viewModel.weightData)
                }
            )
            
            // Energy Pattern Card
            AnalyticsCard(
                title: "ENERGY PATTERN",
                subtitle: "This \(selectedTimeRange.displayName)",
                mainValue: viewModel.energyStability,
                unit: "",
                trend: .stable,
                chart: {
                    EnergyPatternChart(data: viewModel.energyData)
                }
            )
            
            // Meal Quality Card
            AnalyticsCard(
                title: "MEAL QUALITY",
                subtitle: "Average Score",
                mainValue: viewModel.mealQualityScore,
                unit: "/5",
                trend: viewModel.mealQualityTrend,
                chart: {
                    MealQualityIndicator(score: viewModel.mealQualityScore)
                }
            )
            
            // Hydration Card
            AnalyticsCard(
                title: "HYDRATION",
                subtitle: "Daily Average",
                mainValue: "\(viewModel.avgWaterIntake)",
                unit: "cups",
                trend: viewModel.hydrationTrend,
                chart: {
                    HydrationBar(current: viewModel.avgWaterIntake, goal: 8)
                }
            )
        }
    }
}

// MARK: - Analytics Card Component
struct AnalyticsCard<Chart: View>: View {
    let title: String
    let subtitle: String
    let mainValue: String
    let unit: String
    let trend: TrendDirection
    let chart: () -> Chart
    @Environment(\.appTheme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.themed(.secondaryText, theme: theme))
                
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(Color.plateUpTertiaryText)
            }
            
            // Chart
            chart()
                .frame(height: 60)
            
            // Value & Trend
            HStack(alignment: .bottom) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(mainValue)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color.themed(.primaryText, theme: theme))
                    
                    Text(unit)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.themed(.secondaryText, theme: theme))
                }
                
                Spacer()
                
                TrendIndicator(direction: trend)
            }
        }
        .padding(PlateUpComponentStyle.mediumSpacing)
        .background(
            RoundedRectangle(cornerRadius: PlateUpComponentStyle.largeRadius)
                .fill(Color.themed(.card, theme: theme))
        )
    }
}

// MARK: - Trend Indicator
struct TrendIndicator: View {
    let direction: TrendDirection
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: direction.icon)
                .font(.system(size: 14, weight: .semibold))
            
            Text(direction.text)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(direction.color)
    }
}

// MARK: - Meal Impact Analysis
struct MealImpactAnalysisView: View {
    let impacts: [MealImpact]
    @Binding var selectedImpact: MealImpact?
    @Environment(\.appTheme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("SPECIFIC MEAL IMPACTS")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.themed(.secondaryText, theme: theme))
                
                Spacer()
                
                Button(action: {}) {
                    Text("See All")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.themed(.accent, theme: theme))
                }
            }
            
            VStack(spacing: 12) {
                ForEach(impacts.prefix(3)) { impact in
                    MealImpactCard(
                        impact: impact,
                        isSelected: selectedImpact?.id == impact.id,
                        theme: theme
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedImpact = selectedImpact?.id == impact.id ? nil : impact
                        }
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

// MARK: - Meal Impact Card
struct MealImpactCard: View {
    let impact: MealImpact
    let isSelected: Bool
    let theme: AppTheme
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(impact.outcome)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.themed(.primaryText, theme: theme))
                        
                        Text(impact.timeDescription)
                            .font(.system(size: 12))
                            .foregroundColor(Color.themed(.secondaryText, theme: theme))
                    }
                    
                    Spacer()
                    
                    Image(systemName: impact.isNegative ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                        .foregroundColor(impact.isNegative ? .plateUpWarning : .plateUpSuccess)
                }
                
                // Meal Details
                VStack(alignment: .leading, spacing: 8) {
                    Text("Caused by: \(impact.mealName)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.themed(.primaryText, theme: theme))
                    
                    ForEach(impact.nutritionFactors, id: \.self) { factor in
                        HStack(spacing: 6) {
                            Text("•")
                                .foregroundColor(Color.plateUpWarning)
                            Text(factor)
                                .font(.system(size: 13))
                                .foregroundColor(Color.themed(.secondaryText, theme: theme))
                        }
                    }
                }
                
                // Suggestion (if expanded)
                if isSelected {
                    VStack(alignment: .leading, spacing: 8) {
                        Divider()
                            .background(Color.plateUpBorder)
                        
                        HStack(alignment: .top, spacing: 8) {
                            PlateUpIcons.focusIcon()
                                .scaleEffect(0.7)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Fix:")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color.themed(.accent, theme: theme))
                                
                                Text(impact.suggestion)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.themed(.primaryText, theme: theme))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .push(from: .top).combined(with: .opacity),
                        removal: .push(from: .bottom).combined(with: .opacity)
                    ))
                }
            }
            .padding(PlateUpComponentStyle.mediumSpacing)
            .background(
                RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                    .fill(Color.plateUpTertiaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                            .stroke(
                                isSelected ? Color.themed(.accent, theme: theme) : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}