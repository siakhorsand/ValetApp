//
//  ValetLocalApp.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI

@main
struct ValetLocalApp: App {
    @StateObject var shiftStore = ShiftStore(withDemoData: true)
    @StateObject var userManager = UserManager.shared
    
    init() {
        // Configure the global appearance for dark mode
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
            .preferredColorScheme(.dark) // Force dark mode throughout the app
        }
    }
    
    private func setupAppearance() {
        // Set navigation bar appearance for dark mode
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(ValetTheme.surfaceVariant)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(ValetTheme.primary)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(ValetTheme.primary)
        ]
        
        // Set appearance for all navigation bars
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Set tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(ValetTheme.surfaceVariant)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
}
