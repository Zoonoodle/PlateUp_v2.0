//
//  HeightSelectionView.swift
//  PlateUp
//
//  Height selection with interactive draggable ruler
//

import SwiftUI

struct HeightSelectionView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var selectedFeet: Int = 5
    @State private var selectedInches: Int = 10
    @State private var selectedCm: Int = 178
    @State private var useMetric: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var totalDragOffset: CGFloat = 0
    
    private let feetRange = 4...7
    private let inchesRange = 0...11
    private let cmRange = 120...220
    
    private var heightInCm: Int {
        if useMetric {
            return selectedCm
        } else {
            return Int(Double(selectedFeet * 12 + selectedInches) * 2.54)
        }
    }
    
    private var heightDisplay: String {
        if useMetric {
            return "\(selectedCm)cm"
        } else {
            return "\(selectedFeet)'\(selectedInches)\""
        }
    }
    
    private var personScale: CGFloat {
        let normalizedHeight = (Double(heightInCm) - 120) / 100 // 120cm to 220cm range
        return 0.7 + (normalizedHeight * 0.5) // Scale from 0.7x to 1.2x
    }
    
    var body: some View {
        OnboardingContainer(
            currentStep: 7
        ) {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Text("How tall are you?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Drag the ruler to adjust your height")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Unit toggle
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            useMetric = false
                        }
                    }) {
                        Text("ft/in")
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
                        Text("cm")
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
                
                // Height display
                ZStack {
                    Capsule()
                        .stroke(Color.green, lineWidth: 2)
                        .frame(width: 120, height: 50)
                    
                    Text(heightDisplay)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.green)
                }
                
                // Interactive ruler and person
                HStack(spacing: 40) {
                    // Ruler
                    ZStack(alignment: .leading) {
                        // Ruler background
                        VStack(spacing: 0) {
                            ForEach(0..<20, id: \.self) { index in
                                HStack {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: index % 5 == 0 ? 40 : 20, height: 1)
                                    Spacer()
                                }
                                .frame(height: 20)
                            }
                        }
                        .frame(width: 60)
                        
                        // Green height marker
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: 50, height: 3)
                            .offset(x: -5, y: totalDragOffset + dragOffset)
                    }
                    .frame(width: 60, height: 400)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.height
                                updateHeightFromDrag()
                            }
                            .onEnded { _ in
                                totalDragOffset += dragOffset
                                dragOffset = 0
                            }
                    )
                    
                    // Person icon that scales with height
                    Image(systemName: "figure.stand")
                        .font(.system(size: 120))
                        .foregroundColor(.green)
                        .scaleEffect(personScale)
                        .animation(.easeInOut(duration: 0.2), value: personScale)
                }
                .frame(height: 400)
                
                Spacer()
                
                // Footer with Feet/Inches selectors (hidden when metric)
                if !useMetric {
                    HStack(spacing: 40) {
                        VStack {
                            Text("Feet")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            
                            HStack {
                                ForEach([selectedFeet - 1, selectedFeet, selectedFeet + 1], id: \.self) { feet in
                                    if feetRange.contains(feet) {
                                        Text("\(feet)")
                                            .font(.system(size: feet == selectedFeet ? 24 : 18, weight: feet == selectedFeet ? .semibold : .regular))
                                            .foregroundColor(feet == selectedFeet ? .white : .gray)
                                            .frame(width: 40)
                                            .onTapGesture {
                                                selectedFeet = feet
                                                updateRulerPosition()
                                            }
                                    }
                                }
                            }
                        }
                        
                        VStack {
                            Text("Inches")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            
                            HStack {
                                ForEach([selectedInches - 1, selectedInches, selectedInches + 1], id: \.self) { inches in
                                    if inchesRange.contains(inches) {
                                        Text("\(inches)")
                                            .font(.system(size: inches == selectedInches ? 24 : 18, weight: inches == selectedInches ? .semibold : .regular))
                                            .foregroundColor(inches == selectedInches ? .white : .gray)
                                            .frame(width: 40)
                                            .onTapGesture {
                                                selectedInches = inches
                                                updateRulerPosition()
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Continue button
                Button(action: {
                    flowManager.height = Double(heightInCm)
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
            if flowManager.height > 0 {
                selectedCm = Int(flowManager.height)
                let totalInches = Int(flowManager.height / 2.54)
                selectedFeet = totalInches / 12
                selectedInches = totalInches % 12
            }
            useMetric = flowManager.useMetricUnits
            updateRulerPosition()
        }
    }
    
    private func updateHeightFromDrag() {
        let dragAmount = totalDragOffset + dragOffset
        let pixelsPerCm: CGFloat = 2.0
        let cmChange = Int(-dragAmount / pixelsPerCm)
        
        if useMetric {
            selectedCm = max(cmRange.lowerBound, min(cmRange.upperBound, 178 + cmChange))
        } else {
            let newCm = max(120, min(220, 178 + cmChange))
            let totalInches = Int(Double(newCm) / 2.54)
            selectedFeet = max(feetRange.lowerBound, min(feetRange.upperBound, totalInches / 12))
            selectedInches = max(inchesRange.lowerBound, min(inchesRange.upperBound, totalInches % 12))
        }
    }
    
    private func updateRulerPosition() {
        let targetCm = heightInCm
        let baseCm = 178
        let cmDifference = targetCm - baseCm
        let pixelsPerCm: CGFloat = 2.0
        totalDragOffset = -CGFloat(cmDifference) * pixelsPerCm
    }
}

#Preview {
    HeightSelectionView(flowManager: OnboardingFlowManager())
}