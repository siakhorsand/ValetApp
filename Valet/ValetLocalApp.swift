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
        // Get the current color scheme from the app
        let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        let colors = ValetTheme.dynamicColors(for: isDarkMode ? .dark : .light)
        
        // Set navigation bar appearance that adapts to color scheme
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(isDarkMode ? ValetTheme.surfaceVariant : colors.surfaceVariant)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(colors.primary)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(colors.primary)
        ]
        
        // Set appearance for all navigation bars
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Set tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(isDarkMode ? ValetTheme.surfaceVariant : colors.surfaceVariant)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
}
