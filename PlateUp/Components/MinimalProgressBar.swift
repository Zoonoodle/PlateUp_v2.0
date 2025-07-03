//
//  MinimalProgressBar.swift
//  PlateUp
//
//  Sleek horizontal progress bar for nutrition tracking
//

import SwiftUI

struct MinimalProgressBar: View {
    let label: String
    let consumed: Double
    let total: Double
    let unit: String
    let showValues: Bool
    var isPositiveGoal: Bool = true // true for protein/fiber, false for sugar/sodium
    
    // Computed properties
    private var progress: Double {
        guard total > 0 else { return 0 }
        return consumed / total
    }
    
    private var isExceeded: Bool {
        progress > 1.0
    }
    
    private var progressColor: Color {
        let baseColor = Color(hex: "10b981") // Emerald green
        
        if isExceeded {
            // Vibrant green for positive goals, dimmer for limiting goals
            return isPositiveGoal ? baseColor : baseColor.opacity(0.5)
        } else if progress > 0.9 {
            return baseColor.opacity(0.85)
        } else if progress > 0.75 {
            return baseColor.opacity(0.9)
        } else {
            return baseColor
        }
    }
    
    private var valueText: String {
        if showValues {
            if isExceeded && isPositiveGoal {
                let excess = Int(consumed - total)
                return "\(Int(consumed)) / \(Int(total))\(unit) (+\(excess)\(unit))"
            } else {
                return "\(Int(consumed)) / \(Int(total))\(unit)"
            }
        } else {
            let percentage = Int(progress * 100)
            return "\(percentage)%"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Label and value
            HStack {
                HStack(spacing: 4) {
                    Text(label)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.plateUpSecondaryText)
                    
                    if isExceeded && isPositiveGoal {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(progressColor)
                    }
                }
                
                Spacer()
                
                Text(valueText)
                    .font(.system(size: 12, weight: isExceeded && isPositiveGoal ? .semibold : .regular))
                    .foregroundColor(isExceeded && isPositiveGoal ? progressColor : .plateUpTertiaryText)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.plateUpBorder.opacity(0.2))
                        .frame(height: 6)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 3)
                        .fill(progressColor)
                        .frame(width: min(geometry.size.width * progress, geometry.size.width), height: 6)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                    
                    // Sparkle indicator at the end for exceeded positive goals
                    if isExceeded && isPositiveGoal {
                        Image(systemName: "sparkle")
                            .font(.system(size: 8))
                            .foregroundColor(.white)
                            .position(x: geometry.size.width - 4, y: 3)
                    }
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Compact Version for Grid Layouts
struct CompactProgressBar: View {
    let label: String
    let consumed: Double
    let total: Double
    let unit: String
    var isPositiveGoal: Bool = true
    
    private var progress: Double {
        guard total > 0 else { return 0 }
        return consumed / total
    }
    
    private var isExceeded: Bool {
        progress > 1.0
    }
    
    private var progressColor: Color {
        let baseColor = Color(hex: "10b981")
        if isExceeded {
            return isPositiveGoal ? baseColor : baseColor.opacity(0.5)
        }
        return baseColor.opacity(progress > 0.9 ? 0.85 : 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                HStack(spacing: 2) {
                    Text(label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.plateUpSecondaryText)
                    
                    if isExceeded && isPositiveGoal {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 9))
                            .foregroundColor(progressColor)
                    }
                }
                
                Spacer()
                
                Text("\(Int(consumed))\(unit)")
                    .font(.system(size: 10, weight: isExceeded && isPositiveGoal ? .semibold : .regular))
                    .foregroundColor(isExceeded && isPositiveGoal ? progressColor : .plateUpTertiaryText)
            }
            
            // Simplified progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.plateUpBorder.opacity(0.15))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(progressColor)
                        .frame(width: min(geometry.size.width * progress, geometry.size.width), height: 4)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Preview
struct MinimalProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("Regular State").font(.headline)
            
            MinimalProgressBar(
                label: "Calories",
                consumed: 1580,
                total: 2000,
                unit: " cal",
                showValues: true,
                isPositiveGoal: false
            )
            
            MinimalProgressBar(
                label: "Protein",
                consumed: 65,
                total: 120,
                unit: "g",
                showValues: true,
                isPositiveGoal: true
            )
            
            Divider()
            
            Text("Exceeded Goals").font(.headline)
            
            MinimalProgressBar(
                label: "Protein",
                consumed: 140,
                total: 120,
                unit: "g",
                showValues: true,
                isPositiveGoal: true
            )
            
            MinimalProgressBar(
                label: "Sugar",
                consumed: 55,
                total: 50,
                unit: "g",
                showValues: true,
                isPositiveGoal: false
            )
            
            CompactProgressBar(
                label: "Fiber",
                consumed: 35,
                total: 30,
                unit: "g",
                isPositiveGoal: true
            )
        }
        .padding()
        .background(Color.plateUpBackground)
        .preferredColorScheme(.dark)
    }
}