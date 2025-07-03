//
//  PhotoReviewView.swift
//  PlateUp
//
//  Review captured photos and voice context before analysis
//

import SwiftUI
import UIKit

struct PhotoReviewView: View {
    let photos: [UIImage]
    let voiceTranscript: String
    let includesVoice: Bool
    let onConfirm: () -> Void
    let onRetake: () -> Void
    
    @State private var selectedPhotoIndex = 0
    @State private var selectedMealType: MealType
    @State private var showMealTypeSelector = false
    
    init(photos: [UIImage], voiceTranscript: String, includesVoice: Bool, onConfirm: @escaping () -> Void, onRetake: @escaping () -> Void) {
        self.photos = photos
        self.voiceTranscript = voiceTranscript
        self.includesVoice = includesVoice
        self.onConfirm = onConfirm
        self.onRetake = onRetake
        
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
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Review Your Meal")
                    .font(PlateUpTypography.title2)
                    .foregroundColor(.plateUpPrimaryText)
                
                Text("\(photos.count) photo\(photos.count > 1 ? "s" : "") captured")
                    .font(PlateUpTypography.subheadline)
                    .foregroundColor(.plateUpSecondaryText)
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Photo carousel
                    PhotoCarousel(
                        photos: photos,
                        selectedIndex: $selectedPhotoIndex
                    )
                    .frame(height: 300)
                    
                    // Voice transcript (if available)
                    if includesVoice && !voiceTranscript.isEmpty {
                        VoiceTranscriptCard(transcript: voiceTranscript)
                            .padding(.horizontal)
                    }
                    
                    // Meal type selector
                    MealTypeSelector(
                        selectedType: $selectedMealType,
                        isExpanded: $showMealTypeSelector
                    )
                    .padding(.horizontal)
                    
                    // Meal time
                    MealTimeDisplay()
                        .padding(.horizontal)
                }
                .padding(.bottom, 100)
            }
            
            // Bottom action buttons
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
                
                Button(action: onRetake) {
                    Text("Retake Photos")
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

// MARK: - Photo Carousel
struct PhotoCarousel: View {
    let photos: [UIImage]
    @Binding var selectedIndex: Int
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: PlateUpComponentStyle.largeRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: PlateUpComponentStyle.largeRadius)
                            .stroke(Color.plateUpBorder, lineWidth: 0.5)
                    )
                    .padding(.horizontal)
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

// MARK: - Voice Transcript Card
struct VoiceTranscriptCard: View {
    let transcript: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "mic.fill")
                    .font(.caption)
                    .foregroundColor(.plateUpGreen)
                
                Text("Your description")
                    .font(PlateUpTypography.caption1)
                    .foregroundColor(.plateUpSecondaryText)
            }
            
            Text(transcript)
                .font(PlateUpTypography.body)
                .foregroundColor(.plateUpPrimaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.plateUpCardBackground)
        .cornerRadius(PlateUpComponentStyle.mediumRadius)
        .overlay(
            RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                .stroke(Color.plateUpGreen.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Meal Type Selector
struct MealTypeSelector: View {
    @Binding var selectedType: MealType
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Meal Type")
                .font(PlateUpTypography.caption1)
                .foregroundColor(.plateUpSecondaryText)
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(selectedType.emoji)
                        .font(.title2)
                    
                    Text(selectedType.rawValue)
                        .font(PlateUpTypography.subheadline)
                        .foregroundColor(.plateUpPrimaryText)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.plateUpTertiaryText)
                }
                .padding()
                .background(Color.plateUpCardBackground)
                .cornerRadius(PlateUpComponentStyle.mediumRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                        .stroke(Color.plateUpBorder, lineWidth: 0.5)
                )
            }
            
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(MealType.allCases, id: \.self) { type in
                        Button(action: {
                            selectedType = type
                            withAnimation {
                                isExpanded = false
                            }
                        }) {
                            HStack {
                                Text(type.emoji)
                                    .font(.title3)
                                
                                Text(type.rawValue)
                                    .font(PlateUpTypography.subheadline)
                                    .foregroundColor(.plateUpPrimaryText)
                                
                                Spacer()
                                
                                if type == selectedType {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.plateUpGreen)
                                }
                            }
                            .padding()
                        }
                        
                        if type != MealType.allCases.last {
                            Divider()
                                .background(Color.plateUpSeparator)
                        }
                    }
                }
                .background(Color.plateUpCardBackground)
                .cornerRadius(PlateUpComponentStyle.mediumRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                        .stroke(Color.plateUpBorder, lineWidth: 0.5)
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
            }
        }
    }
}

// MARK: - Meal Time Display
struct MealTimeDisplay: View {
    @State private var selectedTime = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Meal Time")
                .font(PlateUpTypography.caption1)
                .foregroundColor(.plateUpSecondaryText)
            
            HStack {
                Image(systemName: "clock")
                    .font(.body)
                    .foregroundColor(.plateUpTertiaryText)
                
                Text("Today at \(timeFormatter.string(from: selectedTime))")
                    .font(PlateUpTypography.subheadline)
                    .foregroundColor(.plateUpPrimaryText)
                
                Spacer()
                
                Text("Edit")
                    .font(PlateUpTypography.caption1)
                    .foregroundColor(.plateUpGreen)
            }
            .padding()
            .background(Color.plateUpCardBackground)
            .cornerRadius(PlateUpComponentStyle.mediumRadius)
            .overlay(
                RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                    .stroke(Color.plateUpBorder, lineWidth: 0.5)
            )
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

// MARK: - Preview
struct PhotoReviewView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoReviewView(
            photos: [UIImage(systemName: "photo")!],
            voiceTranscript: "Two grilled chicken tacos with salsa",
            includesVoice: true,
            onConfirm: {},
            onRetake: {}
        )
        .applyDarkTheme()
    }
}