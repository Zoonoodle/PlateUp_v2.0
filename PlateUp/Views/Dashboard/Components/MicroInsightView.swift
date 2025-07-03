//
//  MicroInsightView.swift
//  PlateUp
//
//  Daily micro-insights for motivation and education
//

import SwiftUI

struct MicroInsightView: View {
    @StateObject private var insightManager = MicroInsightManager()
    @State private var currentInsight: MicroInsight = MicroInsight.placeholder
    @State private var showInsight = false
    
    var body: some View {
        VStack(spacing: 0) {
            if showInsight {
                HStack(spacing: 8) {
                    Image(systemName: currentInsight.icon)
                        .font(.system(size: 12))
                        .foregroundColor(.plateUpAccent.opacity(0.8))
                    
                    Text(currentInsight.text)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.plateUpSecondaryText.opacity(0.9))
                        .lineLimit(1)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.plateUpCardBackground.opacity(0.5))
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .onAppear {
            currentInsight = insightManager.getTodaysInsight()
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                showInsight = true
            }
        }
    }
}

// MARK: - Micro Insight Model
struct MicroInsight {
    let id: UUID = UUID()
    let text: String
    let category: InsightCategory
    let icon: String
    
    static let placeholder = MicroInsight(
        text: "Loading insight...",
        category: .motivational,
        icon: "sparkles"
    )
}

enum InsightCategory {
    case motivational
    case educational
    case actionable
    case seasonal
    
    var icon: String {
        switch self {
        case .motivational: return "star.fill"
        case .educational: return "lightbulb.fill"
        case .actionable: return "arrow.right.circle.fill"
        case .seasonal: return "leaf.fill"
        }
    }
}

// MARK: - Insight Manager
class MicroInsightManager: ObservableObject {
    @Published var insights: [MicroInsight] = []
    
    private let motivationalInsights = [
        "Consistency is more important than perfection.",
        "Small changes today lead to big results tomorrow.",
        "Every meal is a new opportunity to nourish your body.",
        "Progress isn't always linear, and that's okay.",
        "You're building habits that will last a lifetime."
    ]
    
    private let educationalInsights = [
        "Did you know? Protein helps keep you full longer.",
        "Hydration tip: Drink water before, during, and after meals.",
        "Fiber fact: Aim for 25-30g daily for optimal digestion.",
        "Sleep and nutrition are closely connected.",
        "Eating slowly can improve satiety and digestion."
    ]
    
    private let actionableInsights = [
        "Try adding a vegetable to your next meal.",
        "A 10-minute walk after dinner aids digestion.",
        "Prep tomorrow's breakfast tonight for success.",
        "Set a water reminder for mid-afternoon.",
        "Take three deep breaths before eating."
    ]
    
    private let seasonalInsights = [
        "Winter tip: Warm foods can boost satisfaction.",
        "Stay hydrated even when it's cold outside.",
        "Seasonal produce is often more nutritious.",
        "Your body may need more calories in colder months.",
        "Indoor activities count as movement too."
    ]
    
    init() {
        loadInsights()
    }
    
    private func loadInsights() {
        // In a real app, these would come from a backend or be AI-generated
        insights = motivationalInsights.map { MicroInsight(text: $0, category: .motivational, icon: InsightCategory.motivational.icon) } +
                   educationalInsights.map { MicroInsight(text: $0, category: .educational, icon: InsightCategory.educational.icon) } +
                   actionableInsights.map { MicroInsight(text: $0, category: .actionable, icon: InsightCategory.actionable.icon) } +
                   seasonalInsights.map { MicroInsight(text: $0, category: .seasonal, icon: InsightCategory.seasonal.icon) }
    }
    
    func getTodaysInsight() -> MicroInsight {
        // Use the day of year to consistently show the same insight throughout the day
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % insights.count
        return insights.isEmpty ? MicroInsight.placeholder : insights[index]
    }
    
    func getInsightForCategory(_ category: InsightCategory) -> MicroInsight? {
        insights.filter { $0.category == category }.randomElement()
    }
}

// MARK: - Preview
struct MicroInsightView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            MicroInsightView()
            
            // Show different categories
            VStack(alignment: .leading, spacing: 12) {
                ForEach([InsightCategory.motivational, .educational, .actionable, .seasonal], id: \.self) { category in
                    HStack {
                        Image(systemName: category.icon)
                            .font(.system(size: 12))
                            .foregroundColor(.plateUpAccent)
                        
                        Text("Sample \(String(describing: category)) insight")
                            .font(.system(size: 14))
                            .foregroundColor(.plateUpSecondaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.plateUpCardBackground.opacity(0.5))
                    )
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.plateUpBackground)
        .preferredColorScheme(.dark)
    }
}