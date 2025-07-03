//
//  BodyTypeSelectionView.swift
//  PlateUp
//
//  Body composition selection with descriptive approach
//

import SwiftUI

struct BodyTypeSelectionView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var selectedBodyType: BodyComposition?
    
    enum BodyComposition: String, CaseIterable {
        case lean = "Lean & Defined"
        case athletic = "Athletic Build"
        case average = "Average Build"
        case curvy = "Curvy & Soft"
        case strong = "Strong & Solid"
        case fuller = "Fuller Figure"
        
        var description: String {
            switch self {
            case .lean: return "Low body fat, visible muscle definition"
            case .athletic: return "Toned muscles, active lifestyle"
            case .average: return "Balanced proportions, healthy range"
            case .curvy: return "Natural curves, softer appearance"
            case .strong: return "Muscular build, strong frame"
            case .fuller: return "Comfortable with curves"
            }
        }
        
        var emoji: String {
            switch self {
            case .lean: return "🔥"
            case .athletic: return "💪"
            case .average: return "⚖️"
            case .curvy: return "🌸"
            case .strong: return "🏋️"
            case .fuller: return "🌺"
            }
        }
        
        var color: Color {
            switch self {
            case .lean: return .orange
            case .athletic: return .blue
            case .average: return .green
            case .curvy: return .pink
            case .strong: return .purple
            case .fuller: return .indigo
            }
        }
    }
    
    var body: some View {
        OnboardingContainer(
            currentStep: 9
        ) {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Text("How would you describe your current body?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("This helps us calculate your nutritional needs more accurately")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // 3x2 Grid of body compositions
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(BodyComposition.allCases, id: \.self) { composition in
                        BodyCompositionCard(
                            composition: composition,
                            isSelected: selectedBodyType == composition,
                            action: {
                                selectedBodyType = composition
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Continue button
                Button(action: {
                    flowManager.navigateToNextScreen()
                }) {
                    Text("This describes me best")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.green)
                        .cornerRadius(28)
                }
                .disabled(selectedBodyType == nil)
                .opacity(selectedBodyType == nil ? 0.6 : 1.0)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
}

// Body composition card component
struct BodyCompositionCard: View {
    let composition: BodyTypeSelectionView.BodyComposition
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Emoji representation
                ZStack {
                    Circle()
                        .fill(isSelected ? composition.color.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Text(composition.emoji)
                        .font(.system(size: 30))
                }
                .frame(height: 60)
                
                // Body type name
                Text(composition.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Description
                Text(composition.description)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? composition.color.opacity(0.1) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? composition.color : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    BodyTypeSelectionView(flowManager: OnboardingFlowManager())
}