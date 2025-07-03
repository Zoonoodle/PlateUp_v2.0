//
//  DifferentiationView.swift
//  PlateUp v2.0
//
//  Screen 2: Split-screen comparison showing PlateUp's unique value
//

import SwiftUI

struct DifferentiationView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var showContent = false
    
    var body: some View {
        OnboardingContainer(
            currentStep: 2,
            showSkip: true,
            skipAction: { flowManager.skipToScreen(3) }
        ) {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    Text("PlateUp is Different")
                        .font(PlateUpTypography.largeTitle)
                        .foregroundColor(.plateUpPrimaryText)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    Text("We're not just another calorie counter")
                        .font(PlateUpTypography.title3)
                        .foregroundColor(.plateUpSecondaryText)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
                }
                
                // Comparison view
                HStack(spacing: 16) {
                    // Other apps
                    ComparisonCard(
                        title: "Other Apps",
                        items: [
                            ComparisonItem(icon: "xmark.circle.fill", text: "Generic calorie counting", isPositive: false),
                            ComparisonItem(icon: "xmark.circle.fill", text: "One-size-fits-all advice", isPositive: false),
                            ComparisonItem(icon: "xmark.circle.fill", text: "No pattern recognition", isPositive: false),
                            ComparisonItem(icon: "xmark.circle.fill", text: "Manual food logging only", isPositive: false)
                        ],
                        cardColor: .gray
                    )
                    .opacity(showContent ? 1 : 0)
                    .offset(x: showContent ? 0 : -50)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                    
                    // PlateUp
                    ComparisonCard(
                        title: "PlateUp",
                        items: [
                            ComparisonItem(icon: "checkmark.circle.fill", text: "AI nutrition coach", isPositive: true),
                            ComparisonItem(icon: "checkmark.circle.fill", text: "Personalized to YOUR goals", isPositive: true),
                            ComparisonItem(icon: "checkmark.circle.fill", text: "Finds what affects YOUR energy", isPositive: true),
                            ComparisonItem(icon: "checkmark.circle.fill", text: "Voice & photo logging", isPositive: true)
                        ],
                        cardColor: .plateUpPrimaryGreen
                    )
                    .opacity(showContent ? 1 : 0)
                    .offset(x: showContent ? 0 : 50)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
                }
                
                // Science backing
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.plateUpGreen)
                    Text("Backed by nutrition science")
                        .font(PlateUpTypography.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.plateUpSecondaryText)
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
                
                Spacer()
                
                // Continue button
                NavigationButton(
                    title: "I Want Personalized Coaching",
                    action: { flowManager.navigateNext() }
                )
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)
            }
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
    }
}

struct ComparisonCard: View {
    let title: String
    let items: [ComparisonItem]
    let cardColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(PlateUpTypography.headline)
                .fontWeight(.bold)
                .foregroundColor(cardColor == .gray ? .plateUpSecondaryText : .plateUpPrimaryText)
                .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(items) { item in
                    HStack(spacing: 8) {
                        Image(systemName: item.icon)
                            .font(.caption)
                            .foregroundColor(item.isPositive ? .plateUpGreen : .plateUpError)
                        
                        Text(item.text)
                            .font(PlateUpTypography.caption1)
                            .foregroundColor(cardColor == .gray ? .plateUpSecondaryText : .plateUpPrimaryText)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardColor == .gray ? Color.plateUpTertiaryBackground : Color.plateUpGreen.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            cardColor == .gray ? Color.plateUpBorder : Color.plateUpGreen,
                            lineWidth: cardColor == .gray ? 0.5 : 1
                        )
                )
        )
    }
}

struct ComparisonItem: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
    let isPositive: Bool
}

// MARK: - Preview
struct DifferentiationView_Previews: PreviewProvider {
    static var previews: some View {
        DifferentiationView(flowManager: OnboardingFlowManager())
            .applyDarkTheme()
    }
}