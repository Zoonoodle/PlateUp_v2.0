//
//  SplashView.swift
//  PlateUp v2.0
//
//  Screen 1: Auto-transition splash with value preview
//

import SwiftUI

struct SplashView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var logoScale: CGFloat = 0.8
    @State private var showValueText = false
    @State private var valueMessageOpacity = 0.0
    
    var body: some View {
        OnboardingContainer(showProgress: false) {
            VStack(spacing: 40) {
                Spacer()
                
                // Logo with animation
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.plateUpGreen)
                            .frame(width: 120, height: 120)
                            .scaleEffect(logoScale)
                        
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 60, weight: .medium))
                            .foregroundColor(.white)
                            .scaleEffect(logoScale)
                    }
                    
                    Text("PlateUp")
                        .font(PlateUpTypography.largeTitle)
                        .foregroundColor(.plateUpPrimaryText)
                    
                    Text("Your AI Nutrition Coach")
                        .font(PlateUpTypography.title3)
                        .foregroundColor(.plateUpSecondaryText)
                        .opacity(showValueText ? 1 : 0)
                }
                
                Spacer()
                
                // Value preview messages
                VStack(spacing: 12) {
                    ValuePreviewMessage(
                        icon: "brain.head.profile",
                        text: "Personalized coaching based on your unique goals"
                    )
                    .opacity(valueMessageOpacity)
                    .offset(y: valueMessageOpacity == 0 ? 20 : 0)
                    
                    ValuePreviewMessage(
                        icon: "chart.line.uptrend.xyaxis",
                        text: "Track progress with science-backed insights"
                    )
                    .opacity(valueMessageOpacity)
                    .offset(y: valueMessageOpacity == 0 ? 20 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: valueMessageOpacity)
                    
                    ValuePreviewMessage(
                        icon: "sparkles",
                        text: "Achieve your health goals in 90 days"
                    )
                    .opacity(valueMessageOpacity)
                    .offset(y: valueMessageOpacity == 0 ? 20 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: valueMessageOpacity)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Logo entrance
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            logoScale = 1.0
        }
        
        // Show subtitle
        withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
            showValueText = true
        }
        
        // Show value messages
        withAnimation(.easeOut(duration: 0.5).delay(1.0)) {
            valueMessageOpacity = 1.0
        }
        
        // Auto-transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            flowManager.navigateNext()
        }
    }
}

struct ValuePreviewMessage: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.plateUpGreen)
                .frame(width: 30)
            
            Text(text)
                .font(PlateUpTypography.subheadline)
                .foregroundColor(.plateUpSecondaryText)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Preview
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(flowManager: OnboardingFlowManager())
            .applyDarkTheme()
    }
}