//
//  QuickActionsGrid.swift
//  PlateUp
//
//  Quick action cards for common tasks
//

import SwiftUI

struct QuickActionsGrid: View {
    private let columns = [
        GridItem(.flexible(), spacing: PlateUpComponentStyle.mediumSpacing),
        GridItem(.flexible(), spacing: PlateUpComponentStyle.mediumSpacing)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: PlateUpComponentStyle.mediumSpacing) {
            Text("Quick Actions")
                .font(PlateUpTypography.headline)
                .foregroundColor(.plateUpPrimaryText)
            
            LazyVGrid(columns: columns, spacing: PlateUpComponentStyle.mediumSpacing) {
                // Log Meal - Primary CTA
                QuickActionCard(
                    title: "Log Meal",
                    subtitle: "Photo or voice",
                    icon: "camera.fill",
                    color: .plateUpGreen,
                    isPrimary: true,
                    action: {
                        // Navigate to meal logging
                    }
                )
                
                // View Plan
                QuickActionCard(
                    title: "Today's Plan",
                    subtitle: "Meal suggestions",
                    icon: "list.bullet",
                    color: .plateUpSecondaryText,
                    action: {
                        // Show today's plan
                    }
                )
                
                // Water Log
                QuickActionCard(
                    title: "Log Water",
                    subtitle: "Quick +1 glass",
                    icon: "drop.fill",
                    color: .plateUpInfo,
                    action: {
                        // Quick water log
                    }
                )
                
                // AI Coach
                QuickActionCard(
                    title: "AI Coach",
                    subtitle: "Get advice",
                    icon: "message.fill",
                    color: .plateUpWarning,
                    action: {
                        // Open AI coach
                    }
                )
            }
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var isPrimary: Bool = false
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Icon
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isPrimary ? .white : color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isPrimary ? color : color.opacity(0.1))
                    )
                
                // Text
                VStack(spacing: 2) {
                    Text(title)
                        .font(PlateUpTypography.subheadline)
                        .fontWeight(isPrimary ? .semibold : .regular)
                        .foregroundColor(.plateUpPrimaryText)
                    
                    Text(subtitle)
                        .font(PlateUpTypography.caption2)
                        .foregroundColor(.plateUpSecondaryText)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PlateUpComponentStyle.mediumSpacing)
            .background(
                Color.plateUpCardBackground
                    .overlay(
                        isPrimary ? color.opacity(0.05) : Color.clear
                    )
            )
            .cornerRadius(PlateUpComponentStyle.largeRadius)
            .overlay(
                RoundedRectangle(cornerRadius: PlateUpComponentStyle.largeRadius)
                    .stroke(
                        isPrimary ? color.opacity(0.3) : Color.plateUpBorder,
                        lineWidth: isPrimary ? 1.5 : 0.5
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
    }
}