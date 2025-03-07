//
//  ValetLocalApp.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

//
//  ValetLocalApp.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.


import SwiftUI

@main
struct ValetLocalApp: App {
    @StateObject var shiftStore = ShiftStore(withDemoData: true)
    @StateObject var userManager = UserManager.shared
    
    init() {
        // Configure the global appearance for app
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if userManager.isLoggedIn {
                    // Show main app content when logged in
                    ContentView()
                        .environmentObject(shiftStore)
                        .environmentObject(userManager)
                } else {
                    // Show login screen when not logged in
                    LoginView()
                        .environmentObject(userManager)
                }
            }
            // Now using system color scheme instead of forcing dark mode
        }
    }
    
    private func setupAppearance() {
        // Create two separate appearances for light and dark mode
        setupAppearanceForMode(.light)
        setupAppearanceForMode(.dark)
        
        // Register for theme change notifications to update appearances when user switches modes
        NotificationCenter.default.addObserver(
                   forName: UIApplication.significantTimeChangeNotification,
                   object: nil,
                   queue: .main
               ) { _ in
                   self.setupAppearanceForMode(.dark)
                   self.setupAppearanceForMode(.light)
               }
    }
    
    private func setupAppearanceForMode(_ colorScheme: ColorScheme) {
        let colors = ValetTheme.dynamicColors(for: colorScheme)
        
        // Set navigation bar appearance that adapts to color scheme
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(colors.surfaceVariant)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(colors.primary)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(colors.primary)
        ]
        
        // Set tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(colors.surfaceVariant)
        
        // Apply appearances for specific modes
        if colorScheme == .dark {
            UINavigationBar.appearance(for: .current).standardAppearance = appearance
            UINavigationBar.appearance(for: .current).scrollEdgeAppearance = appearance
            UINavigationBar.appearance(for: .current).compactAppearance = appearance
            
            UITabBar.appearance(for: .current).standardAppearance = tabBarAppearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance(for: .current).scrollEdgeAppearance = tabBarAppearance
            }
        } else {
            UINavigationBar.appearance(for: .current).standardAppearance = appearance
            UINavigationBar.appearance(for: .current).scrollEdgeAppearance = appearance
            UINavigationBar.appearance(for: .current).compactAppearance = appearance
            
            UITabBar.appearance(for: .current).standardAppearance = tabBarAppearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance(for: .current).scrollEdgeAppearance = tabBarAppearance
            }
        }
    }
}
