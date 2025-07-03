//
//  AgeSelectionView.swift
//  PlateUp
//
//  Age selection screen with circular display and clean horizontal picker
//

import SwiftUI

struct AgeSelectionView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var selectedAge: Int = 25
    
    private let ageRange = 13...100
    
    var body: some View {
        OnboardingContainer(
            currentStep: 6
        ) {
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 16) {
                    Text("What's your age?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Your age helps us calculate accurate nutritional needs")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Circular age display
                ZStack {
                    Circle()
                        .stroke(Color.green.opacity(0.3), lineWidth: 3)
                        .frame(width: 200, height: 200)
                    
                    VStack(spacing: 4) {
                        Text("\(selectedAge)")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(.green)
                        
                        Text("years old")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Smart holdable age picker
                AgeSliderView(selectedAge: $selectedAge, ageRange: ageRange)
                
                Spacer()
                    .frame(height: 40)
                
                // Continue button
                Button(action: {
                    flowManager.age = selectedAge
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
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            if flowManager.age > 0 {
                selectedAge = flowManager.age
            }
        }
    }
}

// Smart Age Slider with hold functionality
struct AgeSliderView: View {
    @Binding var selectedAge: Int
    let ageRange: ClosedRange<Int>
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    @State private var holdTimer: Timer?
    @State private var isHolding: Bool = false
    @State private var holdDirection: Int = 0 // -1 for left, 1 for right
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(selectedAge - 3...selectedAge + 3), id: \.self) { age in
                if age >= ageRange.lowerBound && age <= ageRange.upperBound {
                    Text("\(age)")
                        .font(.system(size: age == selectedAge ? 24 : 18, weight: age == selectedAge ? .semibold : .regular))
                        .foregroundColor(age == selectedAge ? .green : .gray)
                        .frame(width: 50)
                        .scaleEffect(age == selectedAge ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: selectedAge)
                } else {
                    Color.clear
                        .frame(width: 50)
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.green, lineWidth: 2)
                .frame(width: 50, height: 40)
                .allowsHitTesting(false)
        )
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        dragOffset = value.translation.width
                    } else {
                        let newOffset = value.translation.width
                        let distance = abs(newOffset - dragOffset)
                        
                        if distance > 30 {
                            if newOffset > dragOffset {
                                // Dragging right (decrease age)
                                if selectedAge > ageRange.lowerBound {
                                    selectedAge -= 1
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                }
                            } else {
                                // Dragging left (increase age)
                                if selectedAge < ageRange.upperBound {
                                    selectedAge += 1
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                }
                            }
                            dragOffset = newOffset
                        }
                    }
                }
                .onEnded { _ in
                    isDragging = false
                    dragOffset = 0
                }
        )
        .simultaneousGesture(
            // Hold gesture for continuous scrolling
            LongPressGesture(minimumDuration: 0.5)
                .sequenced(before: DragGesture(minimumDistance: 0))
                .onChanged { value in
                    switch value {
                    case .first(true):
                        // Long press detected, start holding
                        isHolding = true
                        startHoldTimer()
                    case .second(true, let drag):
                        if let drag = drag, isHolding {
                            // Determine direction based on drag
                            if drag.translation.width > 20 {
                                holdDirection = -1 // Decrease age
                            } else if drag.translation.width < -20 {
                                holdDirection = 1 // Increase age
                            }
                        }
                    default:
                        break
                    }
                }
                .onEnded { _ in
                    stopHolding()
                }
        )
        .onTapGesture { location in
            let width: CGFloat = 350
            let position = location.x
            if position < width / 3 {
                if selectedAge > ageRange.lowerBound {
                    selectedAge -= 1
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
            } else if position > 2 * width / 3 {
                if selectedAge < ageRange.upperBound {
                    selectedAge += 1
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
            }
        }
    }
    
    private func startHoldTimer() {
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if isHolding {
                if holdDirection == -1 && selectedAge > ageRange.lowerBound {
                    selectedAge -= 1
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                } else if holdDirection == 1 && selectedAge < ageRange.upperBound {
                    selectedAge += 1
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
            }
        }
    }
    
    private func stopHolding() {
        isHolding = false
        holdDirection = 0
        holdTimer?.invalidate()
        holdTimer = nil
    }
}

#Preview {
    AgeSelectionView(flowManager: OnboardingFlowManager())
}