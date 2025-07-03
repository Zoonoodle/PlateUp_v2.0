//
//  SwipeableNutritionCard.swift
//  PlateUp v2.0
//
//  Multi-page swipeable nutrition visualization with minimal design
//

import SwiftUI

struct SwipeableNutritionCard: View {
    let nutritionData: NutritionData
    @State private var currentPage = 0
    @State private var dragAmount: CGFloat = 0
    @State private var showContent = false
    
    // Haptic feedback generator
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Content
            TabView(selection: $currentPage) {
                MacrosPage(data: nutritionData)
                    .tag(0)
                
                MicronutrientsPage(data: nutritionData)
                    .tag(1)
                
                VitaminsPage(data: nutritionData)
                    .tag(2)
                
                MetricsPage(data: nutritionData)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: currentPage) { _, _ in
                impactFeedback.prepare()
                impactFeedback.impactOccurred()
            }
            
            // Page Indicators
            PageIndicators(currentPage: currentPage, totalPages: 4)
                .padding(.top, 12)
                .padding(.bottom, 8)
        }
        .background(Color.clear)
        .opacity(showContent ? 1 : 0)
        .scaleEffect(showContent ? 1 : 0.95)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                showContent = true
            }
        }
    }
}

// MARK: - Page 1: Macros
struct MacrosPage: View {
    let data: NutritionData
    
    var body: some View {
        VStack(spacing: 20) {
            Text("TODAY'S NUTRITION")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.plateUpSecondaryText.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Vertical stack of progress bars
            VStack(spacing: 16) {
                MinimalProgressBar(
                    label: "Calories",
                    consumed: Double(data.calories),
                    total: Double(data.goals.calories),
                    unit: "",
                    showValues: true,
                    isPositiveGoal: false // Usually want to stay at or under calorie goal
                )
                
                MinimalProgressBar(
                    label: "Protein",
                    consumed: data.protein,
                    total: data.goals.protein,
                    unit: "g",
                    showValues: true,
                    isPositiveGoal: true // Celebrate exceeding protein goals
                )
                
                MinimalProgressBar(
                    label: "Carbs",
                    consumed: data.carbs,
                    total: data.goals.carbs,
                    unit: "g",
                    showValues: true,
                    isPositiveGoal: false // Most users want to manage carb intake
                )
                
                MinimalProgressBar(
                    label: "Fats",
                    consumed: data.fats,
                    total: data.goals.fats,
                    unit: "g",
                    showValues: true,
                    isPositiveGoal: false // Most users want to manage fat intake
                )
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Page 2: Micronutrients
struct MicronutrientsPage: View {
    let data: NutritionData
    
    var body: some View {
        VStack(spacing: 20) {
            Text("MICRONUTRIENTS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.plateUpSecondaryText.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Grid layout with compact progress bars
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    if let fiber = data.fiber {
                        CompactProgressBar(
                            label: "Fiber",
                            consumed: fiber,
                            total: data.goals.fiber,
                            unit: "g"
                        )
                    }
                    
                    if let sugar = data.sugar {
                        CompactProgressBar(
                            label: "Sugar",
                            consumed: sugar,
                            total: data.goals.sugar,
                            unit: "g"
                        )
                    }
                }
                
                if let sodium = data.sodium {
                    HStack {
                        CompactProgressBar(
                            label: "Sodium",
                            consumed: sodium,
                            total: data.goals.sodium,
                            unit: "mg"
                        )
                        .frame(maxWidth: .infinity)
                        
                        Spacer()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Page 3: Vitamins
struct VitaminsPage: View {
    let data: NutritionData
    
    var body: some View {
        VStack(spacing: 20) {
            Text("VITAMINS & MINERALS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.plateUpSecondaryText.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 2x2 Grid layout with compact progress bars
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    if let iron = data.iron {
                        CompactProgressBar(
                            label: "Iron",
                            consumed: iron,
                            total: data.goals.iron,
                            unit: "mg"
                        )
                    }
                    
                    if let vitaminD = data.vitaminD {
                        CompactProgressBar(
                            label: "Vitamin D",
                            consumed: vitaminD,
                            total: data.goals.vitaminD,
                            unit: "mcg"
                        )
                    }
                }
                
                HStack(spacing: 16) {
                    if let magnesium = data.magnesium {
                        CompactProgressBar(
                            label: "Magnesium",
                            consumed: magnesium,
                            total: data.goals.magnesium,
                            unit: "mg"
                        )
                    }
                    
                    if let calcium = data.calcium {
                        CompactProgressBar(
                            label: "Calcium",
                            consumed: calcium,
                            total: data.goals.calcium,
                            unit: "mg"
                        )
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Page 4: Metrics
struct MetricsPage: View {
    let data: NutritionData
    
    var body: some View {
        VStack(spacing: 20) {
            Text("HEALTH METRICS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.plateUpSecondaryText.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 2x2 Grid layout with compact progress bars
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    if let glucoseImpact = data.glucoseImpact {
                        CompactProgressBar(
                            label: "Glucose",
                            consumed: glucoseImpact,
                            total: data.goals.glucoseImpact,
                            unit: ""
                        )
                    }
                    
                    if let qualityScore = data.qualityScore {
                        CompactProgressBar(
                            label: "Quality",
                            consumed: qualityScore,
                            total: data.goals.qualityScore,
                            unit: ""
                        )
                    }
                }
                
                HStack(spacing: 16) {
                    if let hydration = data.hydration {
                        CompactProgressBar(
                            label: "Hydration",
                            consumed: Double(hydration),
                            total: Double(data.goals.hydration),
                            unit: " cups"
                        )
                    }
                    
                    if let steps = data.steps {
                        CompactProgressBar(
                            label: "Steps",
                            consumed: Double(steps),
                            total: Double(data.goals.steps),
                            unit: ""
                        )
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// NutritionRow removed - using RingProgress components instead

// MARK: - Page Indicators
struct PageIndicators: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalPages, id: \.self) { page in
                Capsule()
                    .fill(page == currentPage ? Color.plateUpAccent : Color.plateUpBorder.opacity(0.2))
                    .frame(width: page == currentPage ? 20 : 6, height: 6)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }
}

// MARK: - Preview
struct SwipeableNutritionCard_Previews: PreviewProvider {
    static var previews: some View {
        SwipeableNutritionCard(nutritionData: .mockData)
            .frame(height: 300)
            .padding()
            .background(Color.black)
            .preferredColorScheme(.dark)
    }
}