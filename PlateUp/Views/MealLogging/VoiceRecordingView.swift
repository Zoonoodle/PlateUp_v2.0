//
//  VoiceRecordingView.swift
//  PlateUp
//
//  Standalone voice recording for meal logging
//

import SwiftUI

struct VoiceRecordingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var voiceRecording: Data?
    @State private var voiceTranscript: String = ""
    @State private var selectedMealType: MealType
    @State private var showMealTypeSelector = false
    @State private var showReview = false
    
    init() {
        // Auto-detect meal type based on time
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<11:
            self._selectedMealType = State(initialValue: .breakfast)
        case 11..<15:
            self._selectedMealType = State(initialValue: .lunch)
        case 17..<22:
            self._selectedMealType = State(initialValue: .dinner)
        default:
            self._selectedMealType = State(initialValue: .snack)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.plateUpBackground.ignoresSafeArea()
                
                if !showReview {
                    // Recording view
                    VStack(spacing: 0) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Describe Your Meal")
                                .font(PlateUpTypography.title2)
                                .foregroundColor(.plateUpPrimaryText)
                            
                            Text("Tell us what you're eating")
                                .font(PlateUpTypography.subheadline)
                                .foregroundColor(.plateUpSecondaryText)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        
                        // Meal type selector
                        MealTypeSelector(
                            selectedType: $selectedMealType,
                            isExpanded: $showMealTypeSelector
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                        
                        // Voice recording component
                        VoiceContextView(
                            voiceRecording: $voiceRecording,
                            voiceTranscript: $voiceTranscript,
                            onComplete: {
                                withAnimation {
                                    showReview = true
                                }
                            },
                            onSkip: {
                                dismiss()
                            }
                        )
                    }
                } else {
                    // Review view
                    VoiceReviewView(
                        transcript: voiceTranscript,
                        mealType: selectedMealType,
                        onConfirm: {
                            // Start analysis
                            dismiss()
                        },
                        onReRecord: {
                            withAnimation {
                                voiceTranscript = ""
                                voiceRecording = nil
                                showReview = false
                            }
                        }
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.plateUpGreen)
                }
            }
        }
    }
}

// MARK: - Voice Review View
struct VoiceReviewView: View {
    let transcript: String
    let mealType: MealType
    let onConfirm: () -> Void
    let onReRecord: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Review Your Description")
                    .font(PlateUpTypography.title2)
                    .foregroundColor(.plateUpPrimaryText)
                
                Text("Make sure we heard you correctly")
                    .font(PlateUpTypography.subheadline)
                    .foregroundColor(.plateUpSecondaryText)
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Transcript display
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "quote.opening")
                                .font(.title3)
                                .foregroundColor(.plateUpGreen)
                            
                            Spacer()
                        }
                        
                        Text(transcript)
                            .font(PlateUpTypography.title3)
                            .foregroundColor(.plateUpPrimaryText)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            Spacer()
                            
                            Image(systemName: "quote.closing")
                                .font(.title3)
                                .foregroundColor(.plateUpGreen)
                        }
                    }
                    .padding(24)
                    .background(Color.plateUpCardBackground)
                    .cornerRadius(PlateUpComponentStyle.largeRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: PlateUpComponentStyle.largeRadius)
                            .stroke(Color.plateUpGreen.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Meal type display
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.plateUpTertiaryText)
                        
                        Text("\(mealType.emoji) \(mealType.displayName)")
                            .font(PlateUpTypography.subheadline)
                            .foregroundColor(.plateUpPrimaryText)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.plateUpCardBackground)
                    .cornerRadius(PlateUpComponentStyle.mediumRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                            .stroke(Color.plateUpBorder, lineWidth: 0.5)
                    )
                    .padding(.horizontal)
                }
                .padding(.bottom, 100)
            }
            
            // Bottom actions
            VStack(spacing: 12) {
                Button(action: onConfirm) {
                    HStack {
                        Text("Analyze with AI")
                        Image(systemName: "sparkles")
                    }
                    .font(PlateUpTypography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: PlateUpComponentStyle.largeButtonHeight)
                    .background(Color.plateUpGreen)
                    .cornerRadius(PlateUpComponentStyle.mediumRadius)
                }
                
                Button(action: onReRecord) {
                    Text("Re-record")
                        .font(PlateUpTypography.subheadline)
                        .foregroundColor(.plateUpGreen)
                }
            }
            .padding()
            .background(
                Color.plateUpCardBackground
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .background(Color.plateUpBackground)
    }
}

// MARK: - Preview
struct VoiceRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceRecordingView()
            .applyDarkTheme()
    }
}