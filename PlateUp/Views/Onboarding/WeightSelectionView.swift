//
//  WeightSelectionView.swift
//  PlateUp
//
//  Weight selection with circular scale and unit toggle
//

import SwiftUI

struct WeightSelectionView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var selectedWeight: Double = 143.0 // Default weight in lbs
    @State private var useMetric: Bool = false
    @State private var dragAngle: Double = 0
    
    private let minWeightLbs: Double = 66
    private let maxWeightLbs: Double = 440
    private let minWeightKg: Double = 30
    private let maxWeightKg: Double = 200
    
    private var displayWeight: Double {
        if useMetric {
            return selectedWeight / 2.205 // Convert lbs to kg
        } else {
            return selectedWeight
        }
    }
    
    private var weightText: String {
        if useMetric {
            return String(format: "%.0f", displayWeight)
        } else {
            return String(format: "%.0f", displayWeight)
        }
    }
    
    private var unitText: String {
        useMetric ? "kg" : "lbs"
    }
    
    var body: some View {
        OnboardingContainer(
            currentStep: 8
        ) {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Text("What's your current weight?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Swipe the scale to adjust")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Circular weight scale
                ZStack {
                    // Scale marks
                    ForEach(0..<60) { index in
                        Rectangle()
                            .fill(index % 10 == 0 ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: index % 10 == 0 ? 3 : 1, height: index % 10 == 0 ? 20 : 10)
                            .offset(y: -140)
                            .rotationEffect(.degrees(Double(index) * 6))
                    }
                    
                    // Inner circle
                    Circle()
                        .fill(Color.black)
                        .frame(width: 220, height: 220)
                    
                    // White arrow pointing to current weight
                    Image(systemName: "arrowtriangle.up.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .offset(y: -100)
                        .rotationEffect(.degrees(dragAngle))
                    
                    // Weight display
                    VStack(spacing: 8) {
                        Text(weightText)
                            .font(.system(size: 56, weight: .bold))
                            .foregroundColor(.green)
                        
                        Text(unitText)
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                        
                        Text("Current weight")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 300, height: 300)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let center = CGSize(width: 150, height: 150)
                            let angle = atan2(value.location.x - center.width, center.height - value.location.y)
                            dragAngle = angle * 180 / .pi
                            updateWeightFromAngle()
                        }
                )
                
                // Weight slider
                HStack {
                    Text(useMetric ? "30 kg" : "66 lbs")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Slider(value: $selectedWeight, in: minWeightLbs...maxWeightLbs)
                        .accentColor(.green)
                        .onChange(of: selectedWeight) { _, newValue in
                            updateAngleFromWeight()
                        }
                    
                    Text(useMetric ? "200 kg" : "440 lbs")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 40)
                
                // Unit toggle
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            useMetric = false
                        }
                    }) {
                        Text("lbs")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(useMetric ? .gray : .black)
                            .frame(width: 60, height: 36)
                            .background(useMetric ? Color.gray.opacity(0.2) : Color.green)
                            .animation(.easeInOut(duration: 0.2), value: useMetric)
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            useMetric = true
                        }
                    }) {
                        Text("kg")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(useMetric ? .black : .gray)
                            .frame(width: 60, height: 36)
                            .background(useMetric ? Color.green : Color.gray.opacity(0.2))
                            .animation(.easeInOut(duration: 0.2), value: useMetric)
                    }
                }
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                
                Spacer()
                
                // Continue button
                Button(action: {
                    flowManager.weight = selectedWeight / 2.205 // Store in kg
                    flowManager.useMetricUnits = useMetric
                    flowManager.navigateToNextScreen()
                }) {
                    HStack {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.green)
                    .cornerRadius(28)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            if flowManager.weight > 0 {
                selectedWeight = flowManager.weight * 2.205 // Convert from kg to lbs
            }
            useMetric = flowManager.useMetricUnits
            updateAngleFromWeight()
        }
    }
    
    private func updateWeightFromAngle() {
        // Normalize angle to 0-360
        var normalizedAngle = dragAngle
        while normalizedAngle < 0 { normalizedAngle += 360 }
        while normalizedAngle > 360 { normalizedAngle -= 360 }
        
        // Map angle to weight
        let percentage = normalizedAngle / 360
        selectedWeight = minWeightLbs + (maxWeightLbs - minWeightLbs) * percentage
    }
    
    private func updateAngleFromWeight() {
        let percentage = (selectedWeight - minWeightLbs) / (maxWeightLbs - minWeightLbs)
        dragAngle = percentage * 360
    }
}

#Preview {
    WeightSelectionView(flowManager: OnboardingFlowManager())
}