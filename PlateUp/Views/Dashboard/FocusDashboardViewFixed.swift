//
//  FocusDashboardViewFixed.swift
//  PlateUp
//
//  Fixed version of Focus Dashboard with proper component integration
//

import SwiftUI

struct FocusDashboardViewFixed: View {
    @StateObject private var viewModel = DashboardViewModel()
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var scrollOffset: CGFloat = 0
    @State private var greetingOpacity: Double = 1
    @State private var focusCardScale: CGFloat = 1
    @State private var isRefreshing = false
    
    // Constants
    private let componentSpacing: CGFloat = 28
    private let horizontalPadding: CGFloat = 20
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Background
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                // Main scrollable content
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: componentSpacing) {
                            // Spacer for fixed header
                            Color.clear.frame(height: 60)
                            
                            // Greeting (fades on scroll)
                            GreetingSection(viewModel: viewModel)
                                .padding(.horizontal, horizontalPadding)
                                .opacity(greetingOpacity)
                            
                            // Micro Insight of the Day
                            MicroInsightView()
                                .opacity(greetingOpacity)
                            
                            // Focus Card
                            FocusCard(viewModel: viewModel)
                                .frame(height: geometry.size.height * 0.65)
                                .padding(.horizontal, horizontalPadding)
                                .scaleEffect(focusCardScale)
                            
                            // Swipeable Nutrition Card
                            SwipeableNutritionCard(nutritionData: viewModel.nutritionData)
                                .frame(height: 220)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(themeManager.surfaceColor)
                                        .shadow(
                                            color: Color.black.opacity(0.1),
                                            radius: 10,
                                            x: 0,
                                            y: 4
                                        )
                                )
                                .padding(.horizontal, horizontalPadding)
                            
                            // Smart Check-in Cards
                            SmartCheckInSection(viewModel: viewModel)
                                .padding(.horizontal, horizontalPadding)
                            
                            // Bottom padding for tab bar
                            Color.clear.frame(height: 100)
                        }
                    }
                    .refreshable {
                        await performRefresh()
                    }
                }
                
                // Fixed header
                FixedHeaderView(themeManager: themeManager)
                    .background(
                        themeManager.backgroundColor.opacity(scrollOffset < -20 ? 0.95 : 0)
                    )
            }
            .navigationBarHidden(true)
        }
        // Environment is set at app level
    }
    
    private func performRefresh() async {
        isRefreshing = true
        
        // Haptic feedback
        #if os(iOS)
        await MainActor.run {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        #endif
        
        // Simulate refresh
        await viewModel.refreshData()
        
        isRefreshing = false
    }
}

// MARK: - Fixed Header
struct FixedHeaderView: View {
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Text("Focus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(themeManager.primaryTextColor)
                .frame(maxWidth: .infinity)
            
            // Profile Button
            Button(action: {}) {
                Circle()
                    .fill(themeManager.surfaceColor)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text("A")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.accentColor)
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .padding(.top, 44) // Safe area
    }
}

// MARK: - Greeting Section
struct GreetingSection: View {
    let viewModel: DashboardViewModel
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Text(viewModel.currentGreeting)
            .font(.system(size: 28, weight: .light, design: .rounded))
            .foregroundColor(themeManager.secondaryTextColor.opacity(0.9))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 8)
    }
}

// MARK: - Yesterday's Impact Card
struct YesterdaysImpactCard: View {
    let viewModel: DashboardViewModel
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Yesterday's Impact")
                .font(.headline)
                .foregroundColor(themeManager.primaryTextColor)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(themeManager.accentColor)
                        .frame(width: 6, height: 6)
                        .offset(y: 6)
                    Text(viewModel.yesterdaysImpact.positiveImpact)
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(themeManager.accentColor.opacity(0.5))
                        .frame(width: 6, height: 6)
                        .offset(y: 6)
                    Text(viewModel.yesterdaysImpact.negativeImpact)
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
            }
            
            Text(viewModel.yesterdaysImpact.suggestion)
                .font(.caption)
                .foregroundColor(themeManager.accentColor)
                .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
}


// Preview
struct FocusDashboardViewFixed_Previews: PreviewProvider {
    static var previews: some View {
        FocusDashboardViewFixed()
            .preferredColorScheme(.dark)
    }
}