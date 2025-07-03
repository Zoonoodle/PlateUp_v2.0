//
//  HealthConsiderationsView.swift
//  PlateUp v2.0
//
//  Screen 11: Health considerations and dietary preferences (conditional)
//

import SwiftUI

struct HealthConsiderationsView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var showContent = false
    @State private var selectedConditions: Set<String> = []
    @State private var selectedPreferences: Set<String> = []
    @State private var allergyText: String = ""
    @State private var showAllergyField = false
    @FocusState private var isAllergyFieldFocused: Bool
    
    let healthConditions = [
        ("💉", "Type 1 or 2 Diabetes"),
        ("❤️", "High blood pressure"),
        ("🩸", "High cholesterol"),
        ("🌸", "PCOS"),
        ("🧠", "IBS or digestive issues"),
        ("💭", "ADHD or mood disorders"),
        ("🫀", "Heart disease"),
        ("🦋", "Thyroid issues"),
        ("🥜", "Food allergies or intolerances"),
        ("✅", "None of these")
    ]
    
    let dietaryPreferences = [
        ("🌱", "Vegetarian"),
        ("🌿", "Vegan"),
        ("🐟", "Pescatarian"),
        ("🥛", "Dairy-free"),
        ("🌾", "Gluten-free"),
        ("🥓", "Keto/Low-carb"),
        ("🫒", "Mediterranean"),
        ("🕌", "Halal"),
        ("✡️", "Kosher"),
        ("🍽️", "No specific preferences")
    ]
    
    var body: some View {
        OnboardingContainer(currentStep: 11) {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Any health considerations we should know about?")
                            .font(PlateUpTypography.title1)
                            .foregroundColor(.plateUpPrimaryText)
                            .multilineTextAlignment(.center)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        Text("This helps us provide safer, more relevant recommendations")
                            .font(PlateUpTypography.body)
                            .foregroundColor(.plateUpSecondaryText)
                            .multilineTextAlignment(.center)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
                    }
                    
                    // Health Conditions Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Health Conditions")
                            .font(PlateUpTypography.headline)
                            .foregroundColor(.plateUpPrimaryText)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(healthConditions.indices, id: \.self) { index in
                                let condition = healthConditions[index]
                                HealthOptionCard(
                                    emoji: condition.0,
                                    title: condition.1,
                                    isSelected: selectedConditions.contains(condition.1),
                                    action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            if condition.1 == "None of these" {
                                                selectedConditions.removeAll()
                                                selectedConditions.insert("None of these")
                                                showAllergyField = false
                                            } else {
                                                selectedConditions.remove("None of these")
                                                if selectedConditions.contains(condition.1) {
                                                    selectedConditions.remove(condition.1)
                                                    if condition.1 == "Food allergies or intolerances" {
                                                        showAllergyField = false
                                                        allergyText = ""
                                                    }
                                                } else {
                                                    selectedConditions.insert(condition.1)
                                                    if condition.1 == "Food allergies or intolerances" {
                                                        showAllergyField = true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                )
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.5).delay(0.2 + Double(index) * 0.03), value: showContent)
                            }
                        }
                        
                        // Allergy text field
                        if showAllergyField {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Please specify your allergies or intolerances")
                                    .font(PlateUpTypography.caption1)
                                    .foregroundColor(.plateUpSecondaryText)
                                
                                TextField("e.g., nuts, dairy, eggs", text: $allergyText)
                                    .textFieldStyle(PlateUpTextFieldStyle())
                                    .focused($isAllergyFieldFocused)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    // Dietary Preferences Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Dietary Preferences")
                            .font(PlateUpTypography.headline)
                            .foregroundColor(.plateUpPrimaryText)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(dietaryPreferences.indices, id: \.self) { index in
                                let preference = dietaryPreferences[index]
                                HealthOptionCard(
                                    emoji: preference.0,
                                    title: preference.1,
                                    isSelected: selectedPreferences.contains(preference.1),
                                    action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            if preference.1 == "No specific preferences" {
                                                selectedPreferences.removeAll()
                                                selectedPreferences.insert("No specific preferences")
                                            } else {
                                                selectedPreferences.remove("No specific preferences")
                                                if selectedPreferences.contains(preference.1) {
                                                    selectedPreferences.remove(preference.1)
                                                } else {
                                                    selectedPreferences.insert(preference.1)
                                                }
                                            }
                                        }
                                    }
                                )
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.5).delay(0.3 + Double(index) * 0.03), value: showContent)
                            }
                        }
                    }
                    
                    // Important Note
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.plateUpAccent.opacity(0.7))
                            .font(.caption)
                        
                        Text("PlateUp provides educational information, not medical advice. Always consult healthcare providers for medical concerns.")
                            .font(PlateUpTypography.caption2)
                            .foregroundColor(.plateUpSecondaryText)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.plateUpAccent.opacity(0.1))
                    )
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)
                    
                    // Navigation buttons
                    VStack(spacing: 12) {
                        NavigationButton(
                            title: "Continue",
                            isEnabled: true,
                            action: {
                                // Save the data to flow manager
                                // Note: In a real app, you'd map these to proper enums
                                flowManager.navigateNext()
                            }
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.6), value: showContent)
                        
                        NavigationButton(
                            title: "Back",
                            style: .text,
                            action: { flowManager.navigateBack() }
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.7), value: showContent)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }
}

// MARK: - Health Option Card Component
struct HealthOptionCard: View {
    let emoji: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 24))
                
                Text(title)
                    .font(PlateUpTypography.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(.plateUpPrimaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.plateUpAccent.opacity(0.15) : Color.plateUpSecondary.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.plateUpAccent : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
    }
}

// MARK: - Text Field Style
struct PlateUpTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.plateUpSecondary.opacity(0.3))
            )
            .foregroundColor(.plateUpPrimaryText)
            .font(PlateUpTypography.body)
    }
}

// MARK: - Preview
struct HealthConsiderationsView_Previews: PreviewProvider {
    static var previews: some View {
        HealthConsiderationsView(flowManager: OnboardingFlowManager.preview)
            .applyDarkTheme()
    }
}