//
//  CustomTabBar.swift
//  PlateUp
//
//  Custom tab bar with elevated center button
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    @Environment(\.appTheme) var theme
    @StateObject private var haptics = HapticManager()
    
    var body: some View {
        ZStack {
            // Background blur effect
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
                .frame(height: 49 + safeAreaBottom)
                .overlay(
                    Rectangle()
                        .fill(Color.black.opacity(0.8))
                        .ignoresSafeArea(edges: .bottom)
                )
            
            // Tab bar content
            HStack(spacing: 0) {
                // Focus Tab
                TabButton(
                    item: .focus,
                    selectedTab: $selectedTab,
                    theme: theme
                )
                
                Spacer()
                
                // PlateUp Elevated Button
                ElevatedTabButton(
                    isSelected: selectedTab == .plateUp,
                    theme: theme
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = .plateUp
                    }
                    haptics.impact(.medium)
                }
                
                Spacer()
                
                // Momentum Tab
                TabButton(
                    item: .momentum,
                    selectedTab: $selectedTab,
                    theme: theme
                )
            }
            .padding(.horizontal, 30)
            .frame(height: 49)
            .padding(.bottom, safeAreaBottom)
        }
        .frame(height: 49 + safeAreaBottom)
    }
    
    private var safeAreaBottom: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets.bottom
        }
        return 0
    }
}

// MARK: - Tab Items
enum TabItem: Int, CaseIterable {
    case focus = 0
    case plateUp = 1
    case momentum = 2
    
    var icon: String {
        switch self {
        case .focus:
            return "scope"
        case .plateUp:
            return "leaf.fill"
        case .momentum:
            return "flame.fill"
        }
    }
    
    var title: String {
        switch self {
        case .focus:
            return "Focus"
        case .plateUp:
            return "PlateUp"
        case .momentum:
            return "Momentum"
        }
    }
}

// MARK: - Regular Tab Button
struct TabButton: View {
    let item: TabItem
    @Binding var selectedTab: TabItem
    let theme: AppTheme
    @StateObject private var haptics = HapticManager()
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = item
            }
            haptics.impact(.light)
        }) {
            VStack(spacing: 4) {
                Image(systemName: item.icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? accentColor : Color(hex: "666666"))
                
                Text(item.title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? accentColor : Color(hex: "666666"))
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
    
    private var isSelected: Bool {
        selectedTab == item
    }
    
    private var accentColor: Color {
        theme == .supabase ? Color(hex: "10b981") : .white
    }
}

// MARK: - Haptic Manager
class HapticManager: ObservableObject {
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
        #endif
    }
}

// MARK: - Preview
struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            CustomTabBar(selectedTab: .constant(.plateUp))
                .environment(\.appTheme, .supabase)
        }
        .background(Color.black)
        
        VStack {
            Spacer()
            CustomTabBar(selectedTab: .constant(.plateUp))
                .environment(\.appTheme, .vercel)
        }
        .background(Color.black)
    }
}