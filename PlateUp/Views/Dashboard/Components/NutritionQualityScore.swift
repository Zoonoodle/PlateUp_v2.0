//
//  NutritionQualityScore.swift
//  PlateUp
//
//  Interactive nutrition quality score visualization
//

import SwiftUI

struct NutritionQualityScoreCard: View {
    @State private var score: Int = 78
    @State private var showBreakdown = false
    @State private var animateScore = false
    @State private var selectedCategory: QualityCategory? = nil
    
    let qualityMetrics = [
        QualityMetric(category: .variety, score: 85, icon: "leaf.circle.fill", color: Color(hex: "4CAF50")),
        QualityMetric(category: .balance, score: 72, icon: "scalemass.fill", color: Color(hex: "FF9800")),
        QualityMetric(category: .timing, score: 80, icon: "clock.fill", color: Color(hex: "2196F3")),
        QualityMetric(category: .portions, score: 65, icon: "chart.pie.fill", color: Color(hex: "9C27B0"))
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nutrition Quality")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.plateUpPrimaryText)
                    
                    Text("Today's performance")
                        .font(.system(size: 14))
                        .foregroundColor(.plateUpSecondaryText)
                }
                
                Spacer()
                
                // Info button
                Button(action: { showBreakdown.toggle() }) {
                    Image(systemName: showBreakdown ? "info.circle.fill" : "info.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.plateUpGreen)
                }
            }
            
            // Main score display
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.plateUpTertiaryBackground, lineWidth: 12)
                    .frame(width: 180, height: 180)
                
                // Score progress
                Circle()
                    .trim(from: 0, to: animateScore ? CGFloat(score) / 100 : 0)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                scoreColor(for: score),
                                scoreColor(for: score).opacity(0.7),
                                scoreColor(for: score)
                            ]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.8), value: animateScore)
                
                // Score text
                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.plateUpPrimaryText)
                    
                    Text(scoreLabel(for: score))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(scoreColor(for: score))
                    
                    // Stars
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < starCount(for: score) ? "star.fill" : "star")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            
            // Quality metrics
            VStack(spacing: 12) {
                ForEach(qualityMetrics) { metric in
                    QualityMetricRow(
                        metric: metric,
                        isSelected: selectedCategory == metric.category,
                        onTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedCategory = selectedCategory == metric.category ? nil : metric.category
                            }
                        }
                    )
                }
            }
            
            // Breakdown detail
            if showBreakdown {
                QualityBreakdownDetail(selectedCategory: selectedCategory)
                    .transition(.asymmetric(
                        insertion: .push(from: .bottom).combined(with: .opacity),
                        removal: .push(from: .top).combined(with: .opacity)
                    ))
            }
            
            // Improvement tip
            ImprovementTip(score: score)
        }
        .padding(20)
        .premiumCard()
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animateScore = true
            }
        }
    }
    
    private func scoreColor(for score: Int) -> Color {
        switch score {
        case 80...100: return Color.plateUpGreen
        case 60..<80: return Color(hex: "FF9800")
        case 40..<60: return Color(hex: "FF5722")
        default: return Color(hex: "F44336")
        }
    }
    
    private func scoreLabel(for score: Int) -> String {
        switch score {
        case 90...100: return "Excellent"
        case 80..<90: return "Great"
        case 70..<80: return "Good"
        case 60..<70: return "Fair"
        default: return "Needs Work"
        }
    }
    
    private func starCount(for score: Int) -> Int {
        switch score {
        case 90...100: return 5
        case 80..<90: return 4
        case 70..<80: return 3
        case 60..<70: return 2
        default: return 1
        }
    }
}

// MARK: - Quality Metric Row
struct QualityMetricRow: View {
    let metric: QualityMetric
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: metric.icon)
                .font(.system(size: 20))
                .foregroundColor(metric.color)
                .frame(width: 32)
            
            // Category name
            Text(metric.category.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.plateUpPrimaryText)
                .frame(width: 80, alignment: .leading)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.plateUpTertiaryBackground)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(metric.color)
                        .frame(width: geometry.size.width * CGFloat(metric.score) / 100, height: 8)
                }
            }
            .frame(height: 8)
            
            // Score
            Text("\(metric.score)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.plateUpSecondaryText)
                .frame(width: 30, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? metric.color.opacity(0.1) : Color.clear)
        )
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Quality Breakdown Detail
struct QualityBreakdownDetail: View {
    let selectedCategory: QualityCategory?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let category = selectedCategory {
                VStack(alignment: .leading, spacing: 8) {
                    Text(category.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.plateUpPrimaryText)
                    
                    Text(category.description)
                        .font(.system(size: 14))
                        .foregroundColor(.plateUpSecondaryText)
                    
                    // Specific tips
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(category.tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 8) {
                                Circle()
                                    .fill(Color.plateUpGreen)
                                    .frame(width: 6, height: 6)
                                    .offset(y: 6)
                                
                                Text(tip)
                                    .font(.system(size: 13))
                                    .foregroundColor(.plateUpSecondaryText)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                .padding()
                .background(Color.plateUpTertiaryBackground)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Improvement Tip
struct ImprovementTip: View {
    let score: Int
    
    var tip: String {
        if score < 60 {
            return "Focus on adding more vegetables to each meal for better variety"
        } else if score < 80 {
            return "Try to eat your meals at consistent times for better energy"
        } else {
            return "Great job! Keep maintaining these healthy habits"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 16))
                .foregroundColor(.yellow)
            
            Text(tip)
                .font(.system(size: 13))
                .foregroundColor(.plateUpSecondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color.yellow.opacity(0.1),
                    Color.yellow.opacity(0.05)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
    }
}

// MARK: - Models
struct QualityMetric: Identifiable {
    let id = UUID()
    let category: QualityCategory
    let score: Int
    let icon: String
    let color: Color
}

enum QualityCategory {
    case variety
    case balance
    case timing
    case portions
    
    var name: String {
        switch self {
        case .variety: return "Variety"
        case .balance: return "Balance"
        case .timing: return "Timing"
        case .portions: return "Portions"
        }
    }
    
    var description: String {
        switch self {
        case .variety:
            return "Eating diverse foods ensures you get all necessary nutrients"
        case .balance:
            return "Proper macro balance supports your energy and goals"
        case .timing:
            return "Consistent meal timing optimizes metabolism and energy"
        case .portions:
            return "Right-sized portions help maintain healthy weight"
        }
    }
    
    var tips: [String] {
        switch self {
        case .variety:
            return [
                "Try to eat foods from all color groups",
                "Include at least 5 different vegetables this week",
                "Rotate your protein sources daily"
            ]
        case .balance:
            return [
                "Aim for 30% protein, 40% carbs, 30% fat",
                "Include fiber with every meal",
                "Don't skip healthy fats"
            ]
        case .timing:
            return [
                "Eat within 1 hour of waking up",
                "Space meals 3-4 hours apart",
                "Stop eating 2-3 hours before bed"
            ]
        case .portions:
            return [
                "Use your palm to measure protein",
                "Fill half your plate with vegetables",
                "Eat slowly and mindfully"
            ]
        }
    }
}