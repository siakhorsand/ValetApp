//
//  ValetLocalApp.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI

@main
struct ValetLocalApp: App {
    @StateObject var shiftStore = ShiftStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(shiftStore)
        }
    }
}
