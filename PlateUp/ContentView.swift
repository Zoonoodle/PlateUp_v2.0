    //
//  ContentView.swift
//  PlateUp v2.0
//
//  Main app entry point with enhanced green design
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabItem = .focus
    @State private var showOnboarding = false // Temporarily disabled for testing
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        if showOnboarding {
            OnboardingCoordinator()
        } else {
            ZStack {
                // Background
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                // Main content
                VStack(spacing: 0) {
                    // Content based on selected tab
                    Group {
                        switch selectedTab {
                        case .focus:
                            FocusDashboardViewFixed()
                        case .plateUp:
                            PlateUpMainView()
                        case .momentum:
                            MomentumView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Custom tab bar
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
            .environment(\.appTheme, themeManager.currentTheme)
            .environmentObject(themeManager)
        }
    }
}

// MARK: - Tab Views


// PlateUp Main View
struct PlateUpMainView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var showMealLogging = false
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    Text("PlateUp")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(themeManager.primaryTextColor)
                        .padding(.top, 60)
                    
                    // Action grid
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            ActionCard(
                                title: "Log Meal",
                                subtitle: "Photo + Voice",
                                icon: "camera.fill",
                                themeManager: themeManager
                            ) {
                                showMealLogging = true
                            }
                            
                            ActionCard(
                                title: "Ask Coach",
                                subtitle: "Get instant guidance",
                                icon: "bubble.left.fill",
                                themeManager: themeManager
                            ) {
                                // Navigate to coach
                            }
                        }
                        
                        HStack(spacing: 16) {
                            ActionCard(
                                title: "Get Recipe",
                                subtitle: "Personalized for you",
                                icon: "book.fill",
                                themeManager: themeManager
                            ) {
                                // Navigate to recipes
                            }
                            
                            ActionCard(
                                title: "Quick Add",
                                subtitle: "Water, snack, supplement",
                                icon: "plus.circle.fill",
                                themeManager: themeManager
                            ) {
                                // Quick add sheet
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Recent activity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.headline)
                            .foregroundColor(themeManager.secondaryTextColor)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            RecentActivityRow(text: "Logged breakfast - 320 cal", time: "2h ago", themeManager: themeManager)
                            RecentActivityRow(text: "Water intake - 3/8 glasses", time: "3h ago", themeManager: themeManager)
                            RecentActivityRow(text: "Morning check-in completed", time: "4h ago", themeManager: themeManager)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showMealLogging) {
                MealLoggingHubView()
            }
        }
    }
}

// Momentum View
struct MomentumView: View {
    @Environment(\.appTheme) var theme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text("Your Momentum")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Progress charts
                    VStack(spacing: 16) {
                        MomentumCard(
                            title: "Weekly Progress",
                            value: "+3.2%",
                            trend: .up,
                            theme: theme
                        )
                        
                        MomentumCard(
                            title: "Consistency Score",
                            value: "87%",
                            trend: .neutral,
                            theme: theme
                        )
                        
                        MomentumCard(
                            title: "Goal Achievement",
                            value: "4/5",
                            trend: .up,
                            theme: theme
                        )
                    }
                    .padding(.horizontal)
                    
                    // Progress visualization
                    ProgressTabView()
                        .frame(height: 400)
                        .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color.black)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Supporting Components



// Momentum Card Component
struct MomentumCard: View {
    let title: String
    let value: String
    let trend: Trend
    let theme: AppTheme
    
    enum Trend {
        case up, down, neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return Color(hex: "10b981")
            case .down: return Color(hex: "ef4444")
            case .neutral: return Color(hex: "666666")
            }
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "666666"))
                
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Image(systemName: trend.icon)
                .font(.system(size: 20))
                .foregroundColor(trend.color)
                .padding(12)
                .background(trend.color.opacity(0.1))
                .clipShape(Circle())
        }
        .padding(20)
        .background(Color(hex: "18181B"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "27272A"), lineWidth: 1)
        )
    }
}

// Legacy Logging Option Card (kept for compatibility)
struct LoggingOptionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.plateUpForestGreen)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.plateUpMediumGreen)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.plateUpMediumGreen)
        }
        .padding(20)
        .background(Color.plateUpPaleGreen.opacity(0.3))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Action Card Component
struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let themeManager: ThemeManager
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(themeManager.accentColor)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.primaryTextColor)
                    
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.secondaryTextColor)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(themeManager.surfaceColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(themeManager.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Recent Activity Row
struct RecentActivityRow: View {
    let text: String
    let time: String
    let themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(themeManager.primaryTextColor)
            
            Spacer()
            
            Text(time)
                .font(.system(size: 12))
                .foregroundColor(themeManager.secondaryTextColor)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(themeManager.surfaceColor.opacity(0.5))
        .cornerRadius(8)
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
