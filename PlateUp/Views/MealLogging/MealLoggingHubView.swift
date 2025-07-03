//
//  MealLoggingHubView.swift
//  PlateUp
//
//  Enhanced meal logging hub with photo+voice recommendation
//

import SwiftUI

struct MealLoggingHubView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedMethod: LoggingMethod?
    @State private var showCamera = false
    @State private var showVoiceRecording = false
    @State private var showManualEntry = false
    @State private var showBarcode = false
    
    enum LoggingMethod {
        case photoVoice
        case photoOnly
        case voiceOnly
        case barcode
        case manual
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("What are you eating?")
                        .font(PlateUpTypography.title2)
                        .foregroundColor(.plateUpPrimaryText)
                    
                    Text(mealTypeText)
                        .font(PlateUpTypography.subheadline)
                        .foregroundColor(.plateUpSecondaryText)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Logging Options
                ScrollView {
                    VStack(spacing: PlateUpComponentStyle.mediumSpacing) {
                        // Primary Option - Photo + Voice (Recommended)
                        LoggingMethodCard(
                            method: .photoVoice,
                            isRecommended: true,
                            action: {
                                selectedMethod = .photoVoice
                                showCamera = true
                            }
                        )
                        
                        // Secondary Options
                        HStack(spacing: PlateUpComponentStyle.mediumSpacing) {
                            LoggingMethodCard(
                                method: .photoOnly,
                                isCompact: true,
                                action: {
                                    selectedMethod = .photoOnly
                                    showCamera = true
                                }
                            )
                            
                            LoggingMethodCard(
                                method: .voiceOnly,
                                isCompact: true,
                                action: {
                                    selectedMethod = .voiceOnly
                                    showVoiceRecording = true
                                }
                            )
                        }
                        
                        // Additional Options
                        HStack(spacing: PlateUpComponentStyle.mediumSpacing) {
                            LoggingMethodCard(
                                method: .barcode,
                                isCompact: true,
                                action: {
                                    selectedMethod = .barcode
                                    showBarcode = true
                                }
                            )
                            
                            LoggingMethodCard(
                                method: .manual,
                                isCompact: true,
                                action: {
                                    selectedMethod = .manual
                                    showManualEntry = true
                                }
                            )
                        }
                        
                        // Recent Meals Quick Log
                        RecentMealsQuickLog()
                            .padding(.top)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .background(Color.plateUpBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.plateUpGreen)
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                PhotoCaptureFlow(
                    includesVoice: selectedMethod == .photoVoice
                )
            }
            .sheet(isPresented: $showVoiceRecording) {
                VoiceRecordingView()
            }
            .sheet(isPresented: $showManualEntry) {
                Text("Manual Entry - Coming Soon")
            }
            .sheet(isPresented: $showBarcode) {
                Text("Barcode Scanner - Coming Soon")
            }
        }
    }
    
    private var mealTypeText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<11:
            return "Breakfast time"
        case 11..<15:
            return "Lunch time"
        case 15..<17:
            return "Snack time"
        case 17..<22:
            return "Dinner time"
        default:
            return "Late night snack"
        }
    }
}

// MARK: - Logging Method Card
struct LoggingMethodCard: View {
    let method: MealLoggingHubView.LoggingMethod
    var isRecommended: Bool = false
    var isCompact: Bool = false
    let action: () -> Void
    
    var title: String {
        switch method {
        case .photoVoice:
            return "Photo + Voice"
        case .photoOnly:
            return "Photo"
        case .voiceOnly:
            return "Voice"
        case .barcode:
            return "Barcode"
        case .manual:
            return "Manual"
        }
    }
    
    var subtitle: String {
        switch method {
        case .photoVoice:
            return "Most accurate analysis"
        case .photoOnly:
            return "Visual scan"
        case .voiceOnly:
            return "Quick description"
        case .barcode:
            return "Packaged foods"
        case .manual:
            return "Type details"
        }
    }
    
    var icon: String {
        switch method {
        case .photoVoice:
            return "camera.fill.badge.ellipsis"
        case .photoOnly:
            return "camera.fill"
        case .voiceOnly:
            return "mic.fill"
        case .barcode:
            return "barcode"
        case .manual:
            return "keyboard"
        }
    }
    
    var body: some View {
        Button(action: action) {
            if isRecommended {
                // Large featured card
                HStack(spacing: 20) {
                    Image(systemName: icon)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.plateUpGreen)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(title)
                                .font(PlateUpTypography.headline)
                                .foregroundColor(.plateUpPrimaryText)
                            
                            Text("RECOMMENDED")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.plateUpGreen)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.plateUpGreen.opacity(0.1))
                                .cornerRadius(4)
                        }
                        
                        Text(subtitle)
                            .font(PlateUpTypography.subheadline)
                            .foregroundColor(.plateUpSecondaryText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.plateUpTertiaryText)
                }
                .padding(20)
                .background(Color.plateUpCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: PlateUpComponentStyle.largeRadius)
                        .stroke(Color.plateUpGreen.opacity(0.3), lineWidth: 2)
                )
                .cornerRadius(PlateUpComponentStyle.largeRadius)
            } else if isCompact {
                // Compact square card
                VStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.plateUpGreen)
                    
                    Text(title)
                        .font(PlateUpTypography.subheadline)
                        .foregroundColor(.plateUpPrimaryText)
                    
                    Text(subtitle)
                        .font(PlateUpTypography.caption2)
                        .foregroundColor(.plateUpSecondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(Color.plateUpCardBackground)
                .cornerRadius(PlateUpComponentStyle.largeRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: PlateUpComponentStyle.largeRadius)
                        .stroke(Color.plateUpBorder, lineWidth: 0.5)
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Recent Meals Quick Log
struct RecentMealsQuickLog: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Log Again")
                .font(PlateUpTypography.headline)
                .foregroundColor(.plateUpPrimaryText)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<5) { _ in
                        RecentMealCard()
                    }
                }
            }
        }
    }
}

struct RecentMealCard: View {
    var body: some View {
        VStack(spacing: 8) {
            // Placeholder meal image
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.plateUpTertiaryBackground)
                .frame(width: 80, height: 80)
                .overlay(
                    Text("🥗")
                        .font(.largeTitle)
                )
            
            Text("Chicken Salad")
                .font(PlateUpTypography.caption1)
                .foregroundColor(.plateUpPrimaryText)
                .lineLimit(1)
            
            Text("450 cal")
                .font(PlateUpTypography.caption2)
                .foregroundColor(.plateUpSecondaryText)
        }
        .frame(width: 100)
    }
}

// MARK: - Preview
struct MealLoggingHubView_Previews: PreviewProvider {
    static var previews: some View {
        MealLoggingHubView()
            .applyDarkTheme()
    }
}