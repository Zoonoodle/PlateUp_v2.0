//
//  ProgressCharts.swift
//  PlateUp
//
//  Chart components for progress tracking
//

import SwiftUI
import Charts

// MARK: - Weight Trend Chart
struct WeightTrendChart: View {
    let data: [WeightDataPoint]
    @Environment(\.appTheme) var theme
    
    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Day", point.date),
                y: .value("Weight", point.weight)
            )
            .foregroundStyle(Color.themed(.accent, theme: theme))
            .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
            
            AreaMark(
                x: .value("Day", point.date),
                y: .value("Weight", point.weight)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color.themed(.accent, theme: theme).opacity(0.3),
                        Color.themed(.accent, theme: theme).opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

// MARK: - Energy Pattern Chart
struct EnergyPatternChart: View {
    let data: [EnergyDataPoint]
    @Environment(\.appTheme) var theme
    
    var body: some View {
        Chart(data) { point in
            BarMark(
                x: .value("Time", point.hour),
                y: .value("Energy", point.level)
            )
            .foregroundStyle(energyColor(for: point.level))
            .cornerRadius(4)
        }
        .chartXAxis {
            AxisMarks(values: [6, 12, 18]) { value in
                AxisValueLabel {
                    if let hour = value.as(Int.self) {
                        Text("\(hour)")
                            .font(.system(size: 10))
                            .foregroundColor(Color.plateUpTertiaryText)
                    }
                }
            }
        }
        .chartYAxis(.hidden)
    }
    
    private func energyColor(for level: Double) -> Color {
        switch level {
        case 0..<2: return .plateUpError
        case 2..<3: return .plateUpWarning
        case 3..<4: return .plateUpGreenMedium
        default: return .plateUpGreen
        }
    }
}

// MARK: - Meal Quality Indicator
struct MealQualityIndicator: View {
    let score: String
    @Environment(\.appTheme) var theme
    
    private var scoreValue: Double {
        Double(score.replacingOccurrences(of: "/5", with: "")) ?? 0
    }
    
    private var starCount: Int {
        Int(scoreValue.rounded())
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= starCount ? "star.fill" : "star")
                    .font(.system(size: 20))
                    .foregroundColor(
                        index <= starCount ? 
                        Color.themed(.accent, theme: theme) : 
                        Color.plateUpBorder
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
    }
}

// MARK: - Hydration Bar
struct HydrationBar: View {
    let current: Int
    let goal: Int
    @Environment(\.appTheme) var theme
    
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(current) / Double(goal), 1.0)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.plateUpBorder.opacity(0.3))
                
                // Progress
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.plateUpInfo,
                                Color.plateUpInfo.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress)
                
                // Cup markers
                HStack(spacing: 0) {
                    ForEach(0..<goal, id: \.self) { index in
                        if index > 0 {
                            Rectangle()
                                .fill(Color.plateUpBackground)
                                .frame(width: 1)
                        }
                        Spacer()
                    }
                }
            }
        }
        .frame(height: 8)
        .padding(.vertical, 26)
    }
}

// MARK: - Meal Timing Chart
struct MealTimingChart: View {
    let data: [MealTimingData]
    @Environment(\.appTheme) var theme
    
    var body: some View {
        VStack(spacing: 16) {
            // Chart
            Chart(data) { timing in
                RectangleMark(
                    xStart: .value("Start", timing.startTime),
                    xEnd: .value("End", timing.endTime),
                    y: .value("Day", timing.dayLabel)
                )
                .foregroundStyle(mealColor(for: timing.mealType))
                .cornerRadius(4)
                
                // Sleep quality indicator
                if let sleepQuality = timing.sleepQuality {
                    PointMark(
                        x: .value("Sleep", 24),
                        y: .value("Day", timing.dayLabel)
                    )
                    .symbol {
                        Image(systemName: sleepIcon(for: sleepQuality))
                            .font(.system(size: 12))
                            .foregroundColor(sleepColor(for: sleepQuality))
                    }
                }
            }
            .chartXScale(domain: 0...24)
            .chartXAxis {
                AxisMarks(values: [6, 12, 18, 24]) { value in
                    AxisValueLabel {
                        if let hour = value.as(Int.self) {
                            Text(hour == 24 ? "12am" : "\(hour % 12 == 0 ? 12 : hour % 12)\(hour < 12 ? "am" : "pm")")
                                .font(.system(size: 10))
                                .foregroundColor(Color.plateUpTertiaryText)
                        }
                    }
                }
            }
            .frame(height: 200)
            
            // Legend
            HStack(spacing: 20) {
                ForEach(MealType.allCases, id: \.self) { meal in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(mealColor(for: meal))
                            .frame(width: 8, height: 8)
                        Text(meal.rawValue.capitalized)
                            .font(.system(size: 11))
                            .foregroundColor(Color.plateUpSecondaryText)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.plateUpGreen)
                    Text("Sleep Quality")
                        .font(.system(size: 11))
                        .foregroundColor(Color.plateUpSecondaryText)
                }
            }
        }
    }
    
    private func mealColor(for type: MealType) -> Color {
        switch type {
        case .breakfast: return Color(hex: "FFB84D")
        case .lunch: return Color(hex: "4ECDC4")
        case .dinner: return Color(hex: "5D7CFF")
        case .snack: return Color(hex: "B8B8D1")
        case .preWorkout: return Color(hex: "FF6B6B")
        case .postWorkout: return Color(hex: "95E1D3")
        }
    }
    
    private func sleepIcon(for quality: Double) -> String {
        switch quality {
        case 0..<5: return "moon"
        case 5..<7: return "moon.haze"
        default: return "moon.stars"
        }
    }
    
    private func sleepColor(for quality: Double) -> Color {
        switch quality {
        case 0..<5: return .plateUpError
        case 5..<7: return .plateUpWarning
        default: return .plateUpGreen
        }
    }
}

// MARK: - Data Models
struct WeightDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}

struct EnergyDataPoint: Identifiable {
    let id = UUID()
    let hour: Int
    let level: Double
}

struct MealTimingData: Identifiable {
    let id = UUID()
    let dayLabel: String
    let mealType: MealType
    let startTime: Double // Hour as decimal (e.g., 12.5 = 12:30pm)
    let endTime: Double
    let sleepQuality: Double? // Hours of sleep that night
}