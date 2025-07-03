//
//  ElevatedTabButton.swift
//  PlateUp
//
//  Elevated center button with glow effect for PlateUp
//

import SwiftUI

struct ElevatedTabButton: View {
    let isSelected: Bool
    let theme: AppTheme
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var glowAnimation = false
    
    private let buttonSize: CGFloat = 56
    private let elevation: CGFloat = -8
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Glow aura effect
                if isSelected {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    accentColor.opacity(0.3),
                                    accentColor.opacity(0.1),
                                    accentColor.opacity(0.0)
                                ]),
                                center: .center,
                                startRadius: buttonSize / 4,
                                endRadius: buttonSize
                            )
                        )
                        .frame(width: buttonSize * 2, height: buttonSize * 2)
                        .blur(radius: 8)
                        .scaleEffect(glowAnimation ? 1.2 : 1.0)
                        .opacity(glowAnimation ? 0.8 : 0.6)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true),
                            value: glowAnimation
                        )
                }
                
                // Shadow layers for depth
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: buttonSize, height: buttonSize)
                    .offset(y: 4)
                    .blur(radius: 4)
                
                // Main button container
                Circle()
                    .fill(backgroundColor)
                    .frame(width: buttonSize, height: buttonSize)
                    .overlay(
                        Circle()
                            .stroke(borderColor, lineWidth: 2)
                    )
                    .shadow(
                        color: shadowColor,
                        radius: 10,
                        x: 0,
                        y: 2
                    )
                
                // Icon
                Image(systemName: "leaf.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(iconColor)
                    .rotationEffect(.degrees(isSelected ? 0 : -5))
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .offset(y: elevation)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: {
                action()
                #if os(iOS)
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                #endif
            }
        )
        .onAppear {
            glowAnimation = true
        }
    }
    
    // MARK: - Colors
    private var accentColor: Color {
        theme == .supabase ? Color(hex: "10b981") : .white
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return theme == .supabase ? Color(hex: "10b981") : .white
        }
        return Color(hex: "18181B")
    }
    
    private var borderColor: Color {
        if isSelected {
            return theme == .supabase ? Color(hex: "10b981").opacity(0.5) : Color.white.opacity(0.5)
        }
        return Color(hex: "27272A")
    }
    
    private var iconColor: Color {
        if isSelected {
            return theme == .supabase ? .white : .black
        }
        return Color(hex: "666666")
    }
    
    private var shadowColor: Color {
        if isSelected {
            return accentColor.opacity(0.4)
        }
        return Color.black.opacity(0.2)
    }
}

// MARK: - Preview
struct ElevatedTabButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            // Supabase theme
            HStack {
                ElevatedTabButton(isSelected: true, theme: .supabase) {
                    print("Tapped")
                }
                
                ElevatedTabButton(isSelected: false, theme: .supabase) {
                    print("Tapped")
                }
            }
            
            // Vercel theme
            HStack {
                ElevatedTabButton(isSelected: true, theme: .vercel) {
                    print("Tapped")
                }
                
                ElevatedTabButton(isSelected: false, theme: .vercel) {
                    print("Tapped")
                }
            }
        }
        .padding()
        .background(Color.black)
    }
}