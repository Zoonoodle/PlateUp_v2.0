//
//  GuidanceLevelView.swift
//  PlateUp
//
//  Guidance level preference selection
//

import SwiftUI

struct GuidanceLevelView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var selectedLevel: GuidanceLevel?
    
    var body: some View {
        OnboardingContainer(
            currentStep: 14
        ) {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Text("How much guidance do you want from PlateUp?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("You can always adjust this later")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Guidance level options
                VStack(spacing: 16) {
                    // Light Touch
                    GuidanceOptionCard(
                        emoji: "✨",
                        title: "Light touch",
                        subtitle: "Occasional tips and insights when I need them",
                        details: "1-2 notifications per week • Simple summaries • Ask when you need help",
                        isSelected: selectedLevel == .lightTouch,
                        action: {
                            selectedLevel = .lightTouch
                            flowManager.guidanceLevel = .lightTouch
                        }
                    )
                    
                    // Balanced Approach
                    GuidanceOptionCard(
                        emoji: "⚖️",
                        title: "Balanced approach",
                        subtitle: "Daily guidance without feeling overwhelmed",
                        details: "Daily check-ins • Weekly reports • Smart reminders • Proactive tips",
                        isSelected: selectedLevel == .balanced,
                        action: {
                            selectedLevel = .balanced
                            flowManager.guidanceLevel = .balanced
                        }
                    )
                    
                    // Deep Dive
                    GuidanceOptionCard(
                        emoji: "🔬",
                        title: "Deep dive",
                        subtitle: "Detailed analysis and comprehensive weekly reviews",
                        details: "Real-time coaching • Detailed analytics • Multiple daily insights • Full reports",
                        isSelected: selectedLevel == .deepDive,
                        action: {
                            selectedLevel = .deepDive
                            flowManager.guidanceLevel = .deepDive
                        }
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Continue button
                Button(action: {
                    flowManager.navigateToNextScreen()
                }) {
                    Text("This feels right")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.green)
                        .cornerRadius(28)
                }
                .disabled(selectedLevel == nil)
                .opacity(selectedLevel == nil ? 0.6 : 1.0)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            selectedLevel = flowManager.guidanceLevel
        }
    }
}

// Guidance option card component
struct GuidanceOptionCard: View {
    let emoji: String
    let title: String
    let subtitle: String
    let details: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                // Main content
                HStack(spacing: 16) {
                    Text(emoji)
                        .font(.system(size: 36))
                        .frame(width: 50)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .green : .gray)
                }
                
                // Details section
                VStack(alignment: .leading, spacing: 8) {
                    Text("What you'll get:")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text(details)
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.green.opacity(0.15) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    GuidanceLevelView(flowManager: OnboardingFlowManager())
}