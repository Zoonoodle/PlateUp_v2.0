//
//  PlateUpIcons.swift
//  PlateUp
//
//  Custom icon system for PlateUp - replacing generic emojis with branded icons
//

import SwiftUI

// MARK: - PlateUp Custom Icons
struct PlateUpIcons {
    
    // MARK: - Energy Level Icons
    static func energyIcon(level: Int) -> some View {
        ZStack {
            // Lightning bolt base
            Image(systemName: "bolt.fill")
                .font(.system(size: 20, weight: level > 3 ? .bold : .regular))
                .foregroundColor(energyColor(for: level))
                .opacity(0.3 + (Double(level) * 0.175)) // Increases opacity with energy level
            
            // Glow effect for higher energy
            if level >= 4 {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(energyColor(for: level))
                    .blur(radius: 3)
                    .opacity(0.6)
            }
        }
    }
    
    private static func energyColor(for level: Int) -> Color {
        switch level {
        case 1: return .plateUpError.opacity(0.8)
        case 2: return .plateUpWarning.opacity(0.8)
        case 3: return .plateUpSecondaryText
        case 4: return .plateUpGreen.opacity(0.9)
        case 5: return .plateUpGreen
        default: return .plateUpSecondaryText
        }
    }
    
    // MARK: - Sleep Quality Icons
    static func sleepIcon(hours: Double) -> some View {
        Group {
            if hours < 5 {
                // Crescent moon for poor sleep
                Image(systemName: "moon.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.plateUpTertiaryText)
            } else if hours < 7 {
                // Half moon for moderate sleep
                Image(systemName: "moon.haze.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.plateUpSecondaryText)
            } else {
                // Full moon with stars for good sleep
                ZStack {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.plateUpGreen)
                }
            }
        }
    }
    
    // MARK: - Meal Type Icons
    static func mealIcon(for mealType: MealType) -> some View {
        Group {
            switch mealType {
            case .breakfast:
                Image(systemName: "sun.and.horizon.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.plateUpWarning)
            case .lunch:
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.plateUpGreen)
            case .dinner:
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.plateUpInfo)
            case .snack:
                Image(systemName: "leaf.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.plateUpGreenMedium)
            case .preWorkout:
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 18))
                    .foregroundColor(.plateUpAccent)
            case .postWorkout:
                Image(systemName: "figure.cooldown")
                    .font(.system(size: 18))
                    .foregroundColor(.plateUpSecondary)
            }
        }
    }
    
    // MARK: - Check-in Status Icons
    static func checkInIcon(completed: Bool) -> some View {
        Group {
            if completed {
                ZStack {
                    Circle()
                        .fill(Color.plateUpGreen)
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.plateUpBackground)
                }
            } else {
                Circle()
                    .stroke(Color.plateUpBorder, lineWidth: 2)
                    .frame(width: 24, height: 24)
            }
        }
    }
    
    // MARK: - Nutrition Icons
    static func nutritionIcon(for macro: MacroType) -> some View {
        Group {
            switch macro {
            case .protein:
                Image(systemName: "fish.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "FF6B6B"))
            case .carbs:
                Image(systemName: "leaf.arrow.circlepath")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "4ECDC4"))
            case .fats:
                Image(systemName: "drop.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "FFE66D"))
            }
        }
    }
    
    // MARK: - Water Level Icon
    static func waterIcon(cups: Int, goal: Int = 8) -> some View {
        let fillLevel = min(Double(cups) / Double(goal), 1.0)
        
        return ZStack {
            // Glass outline
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 20))
                .foregroundColor(.plateUpBorder)
            
            // Water fill
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 20))
                .foregroundColor(.plateUpInfo)
                .mask(
                    Rectangle()
                        .frame(height: 20 * fillLevel)
                        .offset(y: 10 - (10 * fillLevel))
                )
        }
    }
    
    // MARK: - Hunger Level Icons
    static func hungerIcon(level: Int) -> some View {
        let fillLevel = Double(level) / 10.0
        
        return ZStack {
            // Plate outline
            Image(systemName: "circle")
                .font(.system(size: 20, weight: .thin))
                .foregroundColor(.plateUpBorder)
            
            // Fill based on hunger
            Circle()
                .fill(hungerColor(for: level))
                .frame(width: 16 * fillLevel, height: 16 * fillLevel)
                .opacity(0.8)
        }
    }
    
    private static func hungerColor(for level: Int) -> Color {
        switch level {
        case 1...3: return .plateUpGreen
        case 4...6: return .plateUpWarning
        case 7...10: return .plateUpError
        default: return .plateUpSecondaryText
        }
    }
    
    // MARK: - Focus Action Icon
    static func focusIcon() -> some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [.plateUpGreen, .plateUpGreenMedium],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 32, height: 32)
            
            Image(systemName: "target")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.plateUpBackground)
        }
    }
    
    // MARK: - Theme Toggle Icons
    static func themeIcon(isDark: Bool) -> some View {
        Image(systemName: isDark ? "moon.fill" : "sun.max.fill")
            .font(.system(size: 16))
            .foregroundColor(.plateUpPrimaryText)
    }
}

// MARK: - Macro Type Extension
extension MacroType {
    static let calories = MacroType.protein // Placeholder for calories type
}