//
//  EmptyStateView.swift
//  PlateUp
//
//  Empty state view for nutrition cards
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let icon: String
    let actionText: String?
    let action: (() -> Void)?
    
    init(
        title: String,
        message: String,
        icon: String = "leaf.fill",
        actionText: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.actionText = actionText
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.plateUpAccent.opacity(0.5))
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.plateUpPrimaryText)
                
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(.plateUpSecondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if let actionText = actionText, let action = action {
                Button(action: action) {
                    Text(actionText)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.plateUpAccent)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.plateUpAccent.opacity(0.1))
                        )
                }
                .padding(.top, 8)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Loading State View
struct LoadingStateView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.plateUpBorder.opacity(0.2), lineWidth: 3)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.plateUpAccent, lineWidth: 3)
                    .frame(width: 40, height: 40)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
            
            Text("Loading your nutrition data...")
                .font(.system(size: 14))
                .foregroundColor(.plateUpSecondaryText)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Preview
struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            EmptyStateView(
                title: "No Meals Logged",
                message: "Start logging your meals to see nutrition insights",
                icon: "camera.fill",
                actionText: "Log First Meal",
                action: { print("Log meal tapped") }
            )
            
            EmptyStateView(
                title: "No Data Available",
                message: "We couldn't load your nutrition data. Please try again.",
                icon: "exclamationmark.circle",
                actionText: "Retry",
                action: { print("Retry tapped") }
            )
            
            LoadingStateView()
        }
        .padding()
        .background(Color.plateUpBackground)
        .preferredColorScheme(.dark)
    }
}