//
//  RingProgress.swift
//  PlateUp
//
//  Circular ring progress indicator showing remaining amounts
//

import SwiftUI

struct RingProgress: View {
    let label: String
    let consumed: Double
    let total: Double
    let unit: String
    
    // Computed properties
    private var remaining: Double {
        max(0, total - consumed)
    }
    
    private var progress: Double {
        guard total > 0 else { return 0 }
        return min(consumed / total, 1.0)
    }
    
    private var ringColor: Color {
        // Single accent color with opacity variations for different states
        let baseColor = Color(hex: "10b981") // Supabase emerald green
        
        if progress > 0.9 {
            return baseColor.opacity(0.6) // Dimmer when close to limit
        } else if progress > 0.75 {
            return baseColor.opacity(0.8) // Slightly dimmer when getting close
        } else {
            return baseColor // Full brightness for normal state
        }
    }
    
    private var remainingText: String {
        let value = Int(remaining)
        return "\(value)\(unit)"
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // Ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(
                        Color.plateUpBorder.opacity(0.3),
                        lineWidth: 6
                    )
                    .frame(width: 70, height: 70)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        ringColor,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: progress)
                
                // Center content
                VStack(spacing: 0) {
                    Text(remainingText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.plateUpPrimaryText)
                    
                    Text("left")
                        .font(.system(size: 10))
                        .foregroundColor(.plateUpSecondaryText)
                }
            }
            
            // Label
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.plateUpPrimaryText)
                .lineLimit(1)
        }
    }
}

// MARK: - Compact Ring for smaller displays
struct CompactRingProgress: View {
    let label: String
    let consumed: Double
    let total: Double
    let unit: String
    
    private var remaining: Double {
        max(0, total - consumed)
    }
    
    private var progress: Double {
        guard total > 0 else { return 0 }
        return min(consumed / total, 1.0)
    }
    
    private var ringColor: Color {
        // Single accent color with opacity variations for different states
        let baseColor = Color(hex: "10b981") // Supabase emerald green
        
        if progress > 0.9 {
            return baseColor.opacity(0.6) // Dimmer when close to limit
        } else if progress > 0.75 {
            return baseColor.opacity(0.8) // Slightly dimmer when getting close
        } else {
            return baseColor // Full brightness for normal state
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color.plateUpBorder.opacity(0.3), lineWidth: 5)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        ringColor,
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: progress)
                
                VStack(spacing: -2) {
                    Text("\(Int(remaining))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.plateUpPrimaryText)
                    
                    Text(unit)
                        .font(.system(size: 9))
                        .foregroundColor(.plateUpSecondaryText)
                }
            }
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.plateUpPrimaryText)
                .lineLimit(1)
        }
    }
}

// MARK: - Preview
struct RingProgress_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                RingProgress(
                    label: "Calories",
                    consumed: 1580,
                    total: 2000,
                    unit: " cal"
                )
                
                RingProgress(
                    label: "Protein",
                    consumed: 35,
                    total: 50,
                    unit: "g"
                )
            }
            
            HStack(spacing: 20) {
                CompactRingProgress(
                    label: "Carbs",
                    consumed: 180,
                    total: 250,
                    unit: "g"
                )
                
                CompactRingProgress(
                    label: "Fats",
                    consumed: 55,
                    total: 65,
                    unit: "g"
                )
            }
        }
        .padding()
        .background(Color.plateUpBackground)
        .preferredColorScheme(.dark)
    }
}