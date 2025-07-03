//
//  SmartCheckInSection.swift
//  PlateUp
//
//  Smart, dismissible check-in cards that adapt to time of day
//

import SwiftUI

struct SmartCheckInSection: View {
    @ObservedObject var viewModel: DashboardViewModel
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var showMorningCheckIn = true
    @State private var showAfternoonCheckIn = true
    @State private var showEveningCheckIn = true
    
    private var currentCheckIn: CheckInType? {
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Determine which check-in to show based on time and completion status
        switch hour {
        case 5..<12:
            return showMorningCheckIn && !viewModel.morningCheckInCompleted ? .morning : nil
        case 12..<17:
            return showAfternoonCheckIn && !viewModel.afternoonCheckInCompleted ? .hydration : nil
        case 17..<23:
            return showEveningCheckIn && !viewModel.eveningCheckInCompleted ? .evening : nil
        default:
            return nil
        }
    }
    
    var body: some View {
        if let checkIn = currentCheckIn {
            CheckInCard(
                type: checkIn,
                onSubmit: { response in
                    handleCheckInSubmit(type: checkIn, response: response)
                }
            )
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
            ))
        }
    }
    
    private func handleCheckInSubmit(type: CheckInType, response: String) {
        // Haptic feedback
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        #endif
        
        // Update view model based on check-in type
        switch type {
        case .morning:
            viewModel.morningCheckInCompleted = true
            viewModel.currentEnergyLevel = response
            withAnimation(.easeOut(duration: 0.3)) {
                showMorningCheckIn = false
            }
        case .hydration:
            viewModel.afternoonCheckInCompleted = true
            viewModel.currentHydrationLevel = response
            withAnimation(.easeOut(duration: 0.3)) {
                showAfternoonCheckIn = false
            }
        case .evening:
            viewModel.eveningCheckInCompleted = true
            viewModel.dailyRating = response
            withAnimation(.easeOut(duration: 0.3)) {
                showEveningCheckIn = false
            }
        }
        
        // This is where AI agent would process the check-in data
        viewModel.processCheckInForAI(type: type, response: response)
    }
}

// MARK: - Check-In Card
struct CheckInCard: View {
    let type: CheckInType
    let onSubmit: (String) -> Void
    
    @State private var selectedOption: String = ""
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: type.icon)
                    .font(.system(size: 18))
                    .foregroundColor(.plateUpAccent)
                
                Text(type.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.plateUpPrimaryText)
                
                Spacer()
                
                Text(type.timeLabel)
                    .font(.system(size: 12))
                    .foregroundColor(.plateUpSecondaryText)
            }
            
            // Options
            HStack(spacing: 12) {
                ForEach(type.options, id: \.self) { option in
                    CheckInOption(
                        label: option,
                        isSelected: selectedOption == option,
                        action: {
                            selectedOption = option
                            // Auto-submit after selection
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onSubmit(option)
                            }
                        }
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "0a0a0a"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.plateUpBorder.opacity(0.3), lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
    }
}

// MARK: - Check-In Option Button
struct CheckInOption: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? Color(hex: "0A0A0B") : .plateUpPrimaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.plateUpAccent : Color.plateUpSecondaryBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isSelected ? Color.clear : Color.plateUpBorder.opacity(0.2),
                            lineWidth: 1
                        )
                )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}

// MARK: - Check-In Types
enum CheckInType {
    case morning
    case hydration
    case evening
    
    var title: String {
        switch self {
        case .morning: return "How's your energy?"
        case .hydration: return "Hydration check"
        case .evening: return "Rate today's nutrition"
        }
    }
    
    var icon: String {
        switch self {
        case .morning: return "sun.max.fill"
        case .hydration: return "drop.fill"
        case .evening: return "moon.stars.fill"
        }
    }
    
    var timeLabel: String {
        switch self {
        case .morning: return "Morning"
        case .hydration: return "Afternoon"
        case .evening: return "Evening"
        }
    }
    
    var options: [String] {
        switch self {
        case .morning:
            return ["😴 Tired", "😐 Okay", "😊 Good", "🚀 Great"]
        case .hydration:
            return ["2 cups", "4 cups", "6 cups", "8+ cups"]
        case .evening:
            return ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
        }
    }
}