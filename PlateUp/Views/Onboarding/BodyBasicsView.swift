//
//  BodyBasicsView.swift
//  PlateUp v2.0
//
//  Screen 6: Body basics input (height, weight, age, biological sex)
//

import SwiftUI

struct BodyBasicsView: View {
    @Bindable var flowManager: OnboardingFlowManager
    @State private var showContent = false
    @State private var heightFeet: String = ""
    @State private var heightInches: String = ""
    @State private var heightCm: String = ""
    @State private var weightLbs: String = ""
    @State private var weightKg: String = ""
    @State private var ageText: String = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case heightFeet, heightInches, heightCm, weightLbs, weightKg, age
    }
    
    var body: some View {
        OnboardingContainer(currentStep: 6) {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text("Help us calculate your needs")
                        .font(PlateUpTypography.title1)
                        .foregroundColor(.plateUpPrimaryText)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    Text("These basics help us personalize your nutrition plan")
                        .font(PlateUpTypography.body)
                        .foregroundColor(.plateUpSecondaryText)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
                }
                
                // Unit toggle
                VStack(spacing: 16) {
                    HStack {
                        Text("Units")
                            .font(PlateUpTypography.headline)
                            .foregroundColor(.plateUpPrimaryText)
                        Spacer()
                    }
                    
                    HStack(spacing: 0) {
                        Button("Imperial") {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                flowManager.useMetricUnits = false
                            }
                        }
                        .font(PlateUpTypography.subheadline)
                        .foregroundColor(flowManager.useMetricUnits ? .plateUpSecondaryText : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(flowManager.useMetricUnits ? Color.clear : Color.plateUpGreen)
                        
                        Button("Metric") {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                flowManager.useMetricUnits = true
                            }
                        }
                        .font(PlateUpTypography.subheadline)
                        .foregroundColor(flowManager.useMetricUnits ? .white : .plateUpSecondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(flowManager.useMetricUnits ? Color.plateUpGreen : Color.clear)
                    }
                    .background(Color.plateUpTertiaryBackground)
                    .cornerRadius(PlateUpComponentStyle.mediumRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                            .stroke(Color.plateUpBorder, lineWidth: 1)
                    )
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                
                // Form fields
                VStack(spacing: 20) {
                    // Height
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Height")
                            .font(PlateUpTypography.headline)
                            .foregroundColor(.plateUpPrimaryText)
                        
                        if flowManager.useMetricUnits {
                            HStack {
                                TextField("cm", text: $heightCm)
                                    .font(PlateUpTypography.body)
                                    .foregroundColor(.plateUpPrimaryText)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .heightCm)
                                    .padding()
                                    .background(Color.plateUpQuaternaryBackground)
                                    .cornerRadius(PlateUpComponentStyle.mediumRadius)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                                            .stroke(focusedField == .heightCm ? Color.plateUpGreen : Color.plateUpBorder, lineWidth: 1)
                                    )
                                
                                Text("cm")
                                    .font(PlateUpTypography.body)
                                    .foregroundColor(.plateUpSecondaryText)
                            }
                        } else {
                            HStack(spacing: 12) {
                                TextField("ft", text: $heightFeet)
                                    .font(PlateUpTypography.body)
                                    .foregroundColor(.plateUpPrimaryText)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .heightFeet)
                                    .padding()
                                    .background(Color.plateUpQuaternaryBackground)
                                    .cornerRadius(PlateUpComponentStyle.mediumRadius)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                                            .stroke(focusedField == .heightFeet ? Color.plateUpGreen : Color.plateUpBorder, lineWidth: 1)
                                    )
                                
                                Text("ft")
                                    .font(PlateUpTypography.body)
                                    .foregroundColor(.plateUpSecondaryText)
                                
                                TextField("in", text: $heightInches)
                                    .font(PlateUpTypography.body)
                                    .foregroundColor(.plateUpPrimaryText)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .heightInches)
                                    .padding()
                                    .background(Color.plateUpQuaternaryBackground)
                                    .cornerRadius(PlateUpComponentStyle.mediumRadius)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                                            .stroke(focusedField == .heightInches ? Color.plateUpGreen : Color.plateUpBorder, lineWidth: 1)
                                    )
                                
                                Text("in")
                                    .font(PlateUpTypography.body)
                                    .foregroundColor(.plateUpSecondaryText)
                            }
                        }
                    }
                    
                    // Weight
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Weight")
                            .font(PlateUpTypography.headline)
                            .foregroundColor(.plateUpPrimaryText)
                        
                        HStack {
                            if flowManager.useMetricUnits {
                                TextField("kg", text: $weightKg)
                                    .font(PlateUpTypography.body)
                                    .foregroundColor(.plateUpPrimaryText)
                                    .keyboardType(.decimalPad)
                                    .focused($focusedField, equals: .weightKg)
                                    .padding()
                                    .background(Color.plateUpQuaternaryBackground)
                                    .cornerRadius(PlateUpComponentStyle.mediumRadius)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                                            .stroke(focusedField == .weightKg ? Color.plateUpGreen : Color.plateUpBorder, lineWidth: 1)
                                    )
                                
                                Text("kg")
                                    .font(PlateUpTypography.body)
                                    .foregroundColor(.plateUpSecondaryText)
                            } else {
                                TextField("lbs", text: $weightLbs)
                                    .font(PlateUpTypography.body)
                                    .foregroundColor(.plateUpPrimaryText)
                                    .keyboardType(.decimalPad)
                                    .focused($focusedField, equals: .weightLbs)
                                    .padding()
                                    .background(Color.plateUpQuaternaryBackground)
                                    .cornerRadius(PlateUpComponentStyle.mediumRadius)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                                            .stroke(focusedField == .weightLbs ? Color.plateUpGreen : Color.plateUpBorder, lineWidth: 1)
                                    )
                                
                                Text("lbs")
                                    .font(PlateUpTypography.body)
                                    .foregroundColor(.plateUpSecondaryText)
                            }
                        }
                    }
                    
                    // Age
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Age")
                            .font(PlateUpTypography.headline)
                            .foregroundColor(.plateUpPrimaryText)
                        
                        HStack {
                            TextField("years", text: $ageText)
                                .font(PlateUpTypography.body)
                                .foregroundColor(.plateUpPrimaryText)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .age)
                                .padding()
                                .background(Color.plateUpQuaternaryBackground)
                                .cornerRadius(PlateUpComponentStyle.mediumRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                                        .stroke(focusedField == .age ? Color.plateUpGreen : Color.plateUpBorder, lineWidth: 1)
                                )
                            
                            Text("years")
                                .font(PlateUpTypography.body)
                                .foregroundColor(.plateUpSecondaryText)
                        }
                    }
                    
                    // Biological Sex
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Biological Sex")
                            .font(PlateUpTypography.headline)
                            .foregroundColor(.plateUpPrimaryText)
                        
                        VStack(spacing: 8) {
                            ForEach(BiologicalSex.allCases, id: \.self) { sex in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        flowManager.biologicalSex = sex
                                    }
                                }) {
                                    HStack {
                                        Text(sex.rawValue)
                                            .font(PlateUpTypography.body)
                                            .foregroundColor(.plateUpPrimaryText)
                                        
                                        Spacer()
                                        
                                        if flowManager.biologicalSex == sex {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.plateUpGreen)
                                        }
                                    }
                                    .padding()
                                    .background(Color.plateUpQuaternaryBackground)
                                    .cornerRadius(PlateUpComponentStyle.mediumRadius)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                                            .stroke(flowManager.biologicalSex == sex ? Color.plateUpGreen : Color.plateUpBorder, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    NavigationButton(
                        title: "Continue",
                        isEnabled: flowManager.canProceed(),
                        action: {
                            saveData()
                            flowManager.navigateNext()
                        }
                    )
                    
                    NavigationButton(
                        title: "Back",
                        style: .text,
                        action: {
                            flowManager.navigateBack()
                        }
                    )
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
            }
        }
        .onAppear {
            loadData()
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
        .onTapGesture {
            focusedField = nil
        }
        .onChange(of: [heightFeet, heightInches, heightCm, weightLbs, weightKg, ageText]) { _, _ in
            updateFlowManagerData()
        }
    }
    
    private func loadData() {
        if flowManager.height > 0 {
            if flowManager.useMetricUnits {
                heightCm = String(Int(flowManager.height))
            } else {
                let totalInches = flowManager.height / 2.54
                heightFeet = String(Int(totalInches / 12))
                heightInches = String(Int(totalInches.truncatingRemainder(dividingBy: 12)))
            }
        }
        
        if flowManager.weight > 0 {
            if flowManager.useMetricUnits {
                weightKg = String(format: "%.1f", flowManager.weight)
            } else {
                weightLbs = String(format: "%.1f", flowManager.weight * 2.205)
            }
        }
        
        if flowManager.age > 0 {
            ageText = String(flowManager.age)
        }
    }
    
    private func updateFlowManagerData() {
        // Update height
        if flowManager.useMetricUnits {
            flowManager.height = Double(heightCm) ?? 0
        } else {
            let feet = Double(heightFeet) ?? 0
            let inches = Double(heightInches) ?? 0
            flowManager.height = (feet * 12 + inches) * 2.54
        }
        
        // Update weight
        if flowManager.useMetricUnits {
            flowManager.weight = Double(weightKg) ?? 0
        } else {
            flowManager.weight = (Double(weightLbs) ?? 0) / 2.205
        }
        
        // Update age
        flowManager.age = Int(ageText) ?? 0
    }
    
    private func saveData() {
        updateFlowManagerData()
    }
}

// MARK: - Preview
struct BodyBasicsView_Previews: PreviewProvider {
    static var previews: some View {
        BodyBasicsView(flowManager: OnboardingFlowManager.preview)
            .applyDarkTheme()
    }
}