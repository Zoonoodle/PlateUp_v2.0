//
//  CombinedCheckInCard.swift
//  PlateUp
//
//  Combined check-in card for dashboard
//

import SwiftUI

struct CombinedCheckInCard: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var selectedEnergy: Int = 3
    @State private var selectedSleep: Int = 3
    @State private var hasWorkedOut: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Quick Check-in")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(currentTimeOfDay)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Energy Level
            VStack(alignment: .leading, spacing: 8) {
                Text("Energy Level")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { level in
                        Circle()
                            .fill(level <= selectedEnergy ? themeManager.accentColor : Color.gray.opacity(0.3))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text("\(level)")
                                    .font(.caption2)
                                    .foregroundColor(level <= selectedEnergy ? .white : .gray)
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedEnergy = level
                                    #if os(iOS)
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    #endif
                                }
                            }
                    }
                }
            }
            
            // Sleep Quality
            VStack(alignment: .leading, spacing: 8) {
                Text("Sleep Quality")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { level in
                        Circle()
                            .fill(level <= selectedSleep ? themeManager.accentColor : Color.gray.opacity(0.3))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Image(systemName: sleepIcon(for: level))
                                    .font(.caption)
                                    .foregroundColor(level <= selectedSleep ? .white : .gray)
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedSleep = level
                                    #if os(iOS)
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    #endif
                                }
                            }
                    }
                }
            }
            
            // Workout Toggle
            HStack {
                Text("Did you work out today?")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Toggle("", isOn: $hasWorkedOut)
                    .labelsHidden()
                    .tint(themeManager.accentColor)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var currentTimeOfDay: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Afternoon"
        case 17..<21: return "Evening"
        default: return "Night"
        }
    }
    
    private func sleepIcon(for level: Int) -> String {
        switch level {
        case 1: return "moon.zzz"
        case 2: return "moon"
        case 3: return "moon.fill"
        case 4: return "moon.stars"
        case 5: return "moon.stars.fill"
        default: return "moon"
        }
    }
}