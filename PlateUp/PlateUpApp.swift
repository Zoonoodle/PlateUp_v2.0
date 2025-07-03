//
//  PlateUpApp.swift
//  PlateUp v2.0
//
//  Created by Brennen Price on 6/30/25.
//

import SwiftUI
#if canImport(FirebaseCore)
import FirebaseCore
#endif

@main
struct PlateUpApp: App {
    init() {
        // Configure Firebase
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #endif
        
        // Configure global appearance for dark theme
        configureGlobalAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .applyDarkTheme()
                .onAppear {
                    // Force dark mode
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowScene.windows.forEach { window in
                            window.overrideUserInterfaceStyle = .dark
                        }
                    }
                }
        }
    }
    
    private func configureGlobalAppearance() {
        // Navigation Bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(Color.plateUpBackground)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        navAppearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = UIColor(Color.plateUpGreen)
        
        // Tab Bar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(Color.plateUpSecondaryBackground)
        tabAppearance.shadowColor = UIColor(Color.plateUpBorder)
        
        // Tab bar item colors
        tabAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.plateUpTertiaryText)
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.plateUpTertiaryText)
        ]
        
        tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.plateUpGreen)
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.plateUpGreen)
        ]
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        
        // Other UI elements
        UITextField.appearance().tintColor = UIColor(Color.plateUpGreen)
        UISwitch.appearance().onTintColor = UIColor(Color.plateUpGreen)
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.plateUpGreen)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.plateUpTertiaryText)
        UISlider.appearance().minimumTrackTintColor = UIColor(Color.plateUpGreen)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.plateUpGreen)
        UIActivityIndicatorView.appearance().color = UIColor(Color.plateUpGreen)
        UITableView.appearance().backgroundColor = UIColor(Color.plateUpBackground)
        UITableView.appearance().separatorColor = UIColor(Color.plateUpSeparator)
        UICollectionView.appearance().backgroundColor = UIColor(Color.plateUpBackground)
    }
}