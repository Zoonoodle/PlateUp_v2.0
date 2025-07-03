//
//  FocusCard.swift
//  PlateUp
//
//  Enhanced Focus Card with maximum impact and clarity
//

import SwiftUI
import UIKit

struct FocusCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var showAnimation = false
    @State private var isDismissed = false
    @State private var dragOffset = CGSize.zero
    @State private var showCompletion = false
    @State private var isLoading = false
    
    // Time-based context
    private var timeContext: TimeContext {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<10: return .morning
        case 10..<12: return .preLunch
        case 12..<14: return .lunch
        case 14..<17: return .afternoon
        case 17..<19: return .preDinner
        case 19..<21: return .dinner
        case 21..<23: return .evening
        default: return .night
        }
    }
    
    private var smartContent: SmartFocusContent {
        // Use AI-generated content if available, otherwise use contextual defaults
        if !viewModel.smartFocusContent.title.isEmpty {
            return viewModel.smartFocusContent
        }
        return generateDefaultContent()
    }
    
    private var isWelcomeState: Bool {
        viewModel.isFirstTimeUser && viewModel.totalMealsLogged == 0
    }
    
    private func generateDefaultContent() -> SmartFocusContent {
        // If user has already completed their daily goal
        if viewModel.todaysMetrics.isComplete {
            return SmartFocusContent(
                title: "Great job today!",
                subtitle: "You've hit your nutrition goals",
                actionText: "View Progress",
                icon: "checkmark.circle.fill",
                quickOptions: [],
                nutritionalContext: "All macros achieved",
                primaryNeed: ""
            )
        }
        
        // Time-based content
        switch timeContext {
        case .morning:
            if !viewModel.hasLoggedBreakfast {
                return SmartFocusContent(
                    title: "Log your breakfast",
                    subtitle: "Start your day with proper nutrition tracking",
                    actionText: "Log Meal",
                    icon: "sun.max.fill",
                    quickOptions: ["Greek Yogurt", "Protein Shake"],
                    nutritionalContext: "Based on your usual 8 AM routine",
                    primaryNeed: "30g protein for sustained morning energy"
                )
            } else {
                return SmartFocusContent(
                    title: "Morning protein: 15g",
                    subtitle: "Add 30g more to optimize energy levels",
                    actionText: "See Suggestions",
                    icon: "bolt.fill",
                    quickOptions: ["Eggs", "Protein Bar"],
                    nutritionalContext: "You need more protein for your goals",
                    primaryNeed: "Reach 45g by noon"
                )
            }
            
        case .preLunch:
            return SmartFocusContent(
                title: "Lunch reminder",
                subtitle: "Aim for 40g protein to avoid afternoon crash",
                actionText: "Plan Lunch",
                icon: "fork.knife",
                quickOptions: ["Chicken Salad", "Salmon Bowl"],
                nutritionalContext: "Based on your energy patterns",
                primaryNeed: "Balanced meal prevents 3 PM fatigue"
            )
            
        case .lunch:
            if !viewModel.hasLoggedLunch {
                return SmartFocusContent(
                    title: "Log your lunch",
                    subtitle: "Track your midday nutrition",
                    actionText: "Log Meal",
                    icon: "sun.max.fill",
                    quickOptions: ["Grilled Chicken", "Tuna Sandwich"],
                    nutritionalContext: "Your usual lunch time",
                    primaryNeed: "40g protein target"
                )
            } else {
                return SmartFocusContent(
                    title: "Great lunch choice!",
                    subtitle: "45g protein will sustain your energy",
                    actionText: "View Analysis",
                    icon: "checkmark.circle.fill",
                    quickOptions: [],
                    nutritionalContext: "Perfect macro balance achieved",
                    primaryNeed: ""
                )
            }
            
        case .afternoon:
            return SmartFocusContent(
                title: "Energy check",
                subtitle: "How's your energy? Log it for insights",
                actionText: "Log Energy",
                icon: "battery.75",
                quickOptions: ["Water Break", "Protein Snack"],
                nutritionalContext: "3 PM is your typical energy dip",
                primaryNeed: "Stay hydrated and add protein"
            )
            
        case .preDinner:
            return SmartFocusContent(
                title: "Dinner planning",
                subtitle: "You need 35g more protein today",
                actionText: "Get Recipe",
                icon: "book.fill",
                quickOptions: ["Salmon", "Lean Beef"],
                nutritionalContext: "Complete your daily protein goal",
                primaryNeed: "35g protein + vegetables"
            )
            
        case .dinner:
            if !viewModel.hasLoggedDinner {
                return SmartFocusContent(
                    title: "Log your dinner",
                    subtitle: "Complete your daily nutrition tracking",
                    actionText: "Log Meal",
                    icon: "moon.fill",
                    quickOptions: [],
                    nutritionalContext: "Final meal of the day",
                    primaryNeed: "Balance your remaining macros"
                )
            } else {
                return SmartFocusContent(
                    title: "Day summary",
                    subtitle: "You're at 85% of your protein goal",
                    actionText: "View Summary",
                    icon: "chart.bar.fill",
                    quickOptions: [],
                    nutritionalContext: "Great job today!",
                    primaryNeed: "15% more protein tomorrow"
                )
            }
            
        case .evening:
            return SmartFocusContent(
                title: "Day reflection",
                subtitle: "Rate your energy and sleep quality",
                actionText: "Complete Check-in",
                icon: "moon.stars.fill",
                quickOptions: [],
                nutritionalContext: "Your nutrition impacts tomorrow",
                primaryNeed: "Rest and recover"
            )
            
        case .night:
            return SmartFocusContent(
                title: "Prepare for tomorrow",
                subtitle: "Plan your breakfast for better energy",
                actionText: "Plan Breakfast",
                icon: "sunrise.fill",
                quickOptions: ["Overnight Oats", "Egg Scramble"],
                nutritionalContext: "Set yourself up for success",
                primaryNeed: "30g morning protein"
            )
        }
    }
    
    var body: some View {
        if !isDismissed {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Main card content
                    VStack(spacing: 20) {
                        // Header with icon
                        HStack {
                            Image(systemName: smartContent.icon)
                                .font(.system(size: 24))
                                .foregroundColor(.plateUpAccent)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(Color.plateUpAccent.opacity(0.1))
                                )
                                .scaleEffect(showAnimation ? 1.0 : 0.8)
                                .opacity(showAnimation ? 1.0 : 0)
                            
                            Spacer()
                            
                            // Context indicator
                            Text(timeContext.label)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.plateUpSecondaryText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.plateUpSecondaryBackground)
                                )
                        }
                        
                        // Main content
                        VStack(alignment: .leading, spacing: 12) {
                            Text(smartContent.title)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.plateUpPrimaryText)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                            
                            Text(smartContent.subtitle)
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.plateUpSecondaryText)
                                .lineLimit(2)
                            
                            if !smartContent.nutritionalContext.isEmpty {
                                Text(smartContent.nutritionalContext)
                                    .font(.system(size: 15))
                                    .foregroundColor(.plateUpAccent.opacity(0.8))
                                    .padding(.top, 4)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Action button
                        Button(action: handleAction) {
                            HStack {
                                Text(smartContent.actionText)
                                    .font(.system(size: 17, weight: .semibold))
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 15, weight: .bold))
                            }
                            .foregroundColor(Color(hex: "0A0A0B")) // Dark text on accent
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                ZStack {
                                    // Glow effect
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.plateUpAccent)
                                        .blur(radius: 8)
                                        .opacity(0.5)
                                    
                                    // Main button background
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.plateUpAccent)
                                }
                            )
                            .shadow(
                                color: Color.plateUpAccent.opacity(0.3),
                                radius: 12,
                                x: 0,
                                y: 4
                            )
                        }
                        .padding(.top, 8)
                        
                        // Quick options (AI-generated suggestions)
                        if !smartContent.quickOptions.isEmpty {
                            HStack(spacing: 12) {
                                ForEach(smartContent.quickOptions.prefix(2), id: \.self) { option in
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.plateUpAccent.opacity(0.7))
                                        
                                        Text(option)
                                            .font(.system(size: 13))
                                            .foregroundColor(.plateUpSecondaryText)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.plateUpSecondaryBackground)
                                    )
                                }
                            }
                        }
                        
                        // Primary need indicator
                        if !smartContent.primaryNeed.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.plateUpAccent.opacity(0.6))
                                
                                Text(smartContent.primaryNeed)
                                    .font(.system(size: 12))
                                    .foregroundColor(.plateUpSecondaryText)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(32)
                    .frame(height: geometry.size.height * 0.65)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            // Subtle gradient background
                            if isWelcomeState {
                                // Special welcome gradient
                                LinearGradient(
                                    colors: [
                                        Color(hex: "0a0a0a"),
                                        Color.plateUpAccent.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            } else {
                                LinearGradient(
                                    colors: [
                                        Color(hex: "0a0a0a"),
                                        Color(hex: "0d0d0d")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            }
                            
                            // Glass morphism effect
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.01))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.plateUpAccent.opacity(showAnimation ? 0.4 : 0.3),
                                        Color.plateUpAccent.opacity(showAnimation ? 0.2 : 0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(
                        color: Color.plateUpAccent.opacity(0.15),
                        radius: 30,
                        x: 0,
                        y: 8
                    )
                    .scaleEffect(showCompletion ? 0.95 : 1.0)
                    .opacity(showCompletion ? 0 : 1)
                    .offset(x: dragOffset.width)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if abs(value.translation.width) > abs(value.translation.height) {
                                    dragOffset = value.translation
                                }
                            }
                            .onEnded { value in
                                if abs(value.translation.width) > 100 {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        isDismissed = true
                                    }
                                } else {
                                    withAnimation(.spring()) {
                                        dragOffset = .zero
                                    }
                                }
                            }
                    )
                    .onAppear {
                        // Subtle one-time entrance animation with spring effect
                        withAnimation(
                            .spring(response: 0.8, dampingFraction: 0.75)
                                .delay(0.1)
                        ) {
                            showAnimation = true
                        }
                        
                        // Update smart content when card appears
                        Task {
                            await viewModel.updateSmartFocusContent()
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private func handleAction() {
        // Haptic feedback
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
        
        // Handle action based on the action text
        // The AI agent will populate these with contextual actions
        switch smartContent.actionText {
        case "Log Meal", "Log Breakfast", "Log Lunch", "Log Dinner", "Log Snack":
            viewModel.navigateToMealLogging()
        case "See Suggestions", "Get Recipe", "Plan Lunch", "Plan Breakfast":
            viewModel.showSuggestions()
        case "Log Energy", "Complete Check-in":
            viewModel.openCheckIn()
        case "View Analysis", "View Summary", "View Progress":
            viewModel.showProgress()
        default:
            // Default navigation
            viewModel.navigateToMealLogging()
        }
        
        // Don't dismiss the card - just refresh content
        Task {
            await viewModel.updateSmartFocusContent()
        }
    }
}

// MARK: - Supporting Types
enum TimeContext {
    case morning, preLunch, lunch, afternoon, preDinner, dinner, evening, night
    
    var label: String {
        switch self {
        case .morning: return "Morning"
        case .preLunch: return "Pre-lunch"
        case .lunch: return "Lunch"
        case .afternoon: return "Afternoon"
        case .preDinner: return "Pre-dinner"
        case .dinner: return "Dinner"
        case .evening: return "Evening"
        case .night: return "Night"
        }
    }
}

// FocusContent and FocusType removed - using SmartFocusContent from DashboardViewModel

// MARK: - Preview
struct FocusCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            FocusCard(viewModel: DashboardViewModel())
                .padding()
        }
        .frame(maxHeight: .infinity)
        .background(Color.plateUpBackground)
    }
}