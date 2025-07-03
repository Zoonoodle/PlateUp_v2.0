//
//  SuccessVisionView.swift
//  PlateUp v2.0
//
//  Screen 5: Success vision text input with smart suggestions
//

import SwiftUI

struct SuccessVisionView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var visionText: String = ""
    @State private var showContent = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isTextFieldFocused: Bool
    
    let maxCharacters = 200
    
    // Smart suggestions based on primary goal
    var smartSuggestions: [String] {
        guard let primaryGoal = flowManager.primaryGoal else { return [] }
        
        switch primaryGoal {
        case .weightLoss:
            return [
                "My clothes fit better and I feel confident",
                "I have more energy and feel lighter",
                "I've built sustainable healthy habits"
            ]
        case .muscleGain:
            return [
                "I'm stronger and more defined",
                "I feel powerful and capable",
                "My workouts are more effective"
            ]
        case .betterSleep:
            return [
                "I wake up naturally feeling refreshed",
                "I fall asleep easily and sleep through the night",
                "My energy is consistent throughout the day"
            ]
        case .moreEnergy:
            return [
                "I don't need afternoon coffee anymore",
                "I have energy for evening activities",
                "I feel vibrant and alive all day"
            ]
        case .gutHealth:
            return [
                "No more bloating after meals",
                "My digestion feels smooth and comfortable",
                "I can enjoy foods without worry"
            ]
        case .generalHealth:
            return [
                "I feel healthier and more balanced",
                "My overall wellbeing has improved",
                "I'm taking better care of myself"
            ]
        }
    }
    
    var body: some View {
        OnboardingContainer(currentStep: 5) {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text("Paint me a picture...")
                        .font(PlateUpTypography.title1)
                        .foregroundColor(.plateUpPrimaryText)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    Text("It's 90 days from now and you're telling a friend about your success with PlateUp. What are you saying?")
                        .font(PlateUpTypography.body)
                        .foregroundColor(.plateUpSecondaryText)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
                }
                
                // Text input field
                VStack(alignment: .leading, spacing: 8) {
                    ZStack(alignment: .topLeading) {
                        if visionText.isEmpty {
                            Text("I feel amazing because...")
                                .font(PlateUpTypography.body)
                                .foregroundColor(.plateUpPlaceholderText)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .allowsHitTesting(false)
                        }
                        
                        TextEditor(text: $visionText)
                            .font(PlateUpTypography.body)
                            .foregroundColor(.plateUpPrimaryText)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .background(Color.plateUpQuaternaryBackground)
                            .cornerRadius(PlateUpComponentStyle.mediumRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                                    .stroke(isTextFieldFocused ? Color.plateUpGreen : Color.plateUpBorder, lineWidth: 1)
                            )
                            .frame(minHeight: 120, maxHeight: 160)
                            .focused($isTextFieldFocused)
                    }
                    
                    // Character counter
                    HStack {
                        Spacer()
                        Text("\(visionText.count)/\(maxCharacters)")
                            .font(PlateUpTypography.caption1)
                            .foregroundColor(visionText.count > maxCharacters ? .plateUpError : .plateUpTertiaryText)
                    }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                
                // Smart suggestions
                if !smartSuggestions.isEmpty && visionText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Need inspiration? Tap a suggestion:")
                            .font(PlateUpTypography.caption1)
                            .foregroundColor(.plateUpSecondaryText)
                        
                        VStack(spacing: 8) {
                            ForEach(smartSuggestions, id: \.self) { suggestion in
                                SuggestionChip(
                                    text: suggestion,
                                    action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            visionText = suggestion
                                            isTextFieldFocused = false
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
                }
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    NavigationButton(
                        title: "This is my vision",
                        isEnabled: !visionText.isEmpty && visionText.count <= maxCharacters,
                        action: {
                            flowManager.successVision = visionText
                            flowManager.navigateNext()
                        }
                    )
                    
                    NavigationButton(
                        title: "Skip for now",
                        style: .text,
                        action: {
                            flowManager.navigateNext()
                        }
                    )
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
            }
            .padding(.bottom, keyboardHeight)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeOut(duration: 0.3)) {
                    keyboardHeight = keyboardFrame.height - 50
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeOut(duration: 0.3)) {
                keyboardHeight = 0
            }
        }
        .onChange(of: visionText) { _, newValue in
            if newValue.count > maxCharacters {
                visionText = String(newValue.prefix(maxCharacters))
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}

// MARK: - Suggestion Chip Component
struct SuggestionChip: View {
    let text: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.plateUpGreen)
                
                Text(text)
                    .font(PlateUpTypography.subheadline)
                    .foregroundColor(.plateUpPrimaryText)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.plateUpGreen.opacity(0.1))
            .cornerRadius(PlateUpComponentStyle.mediumRadius)
            .overlay(
                RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                    .stroke(Color.plateUpGreen.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents(
            onPress: {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                    isPressed = true
                }
            },
            onRelease: {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                    isPressed = false
                }
            }
        )
    }
}

// MARK: - Preview
struct SuccessVisionView_Previews: PreviewProvider {
    static var previews: some View {
        let flowManager = OnboardingFlowManager.preview
        flowManager.primaryGoal = .moreEnergy
        
        return SuccessVisionView(flowManager: flowManager)
            .applyDarkTheme()
    }
}