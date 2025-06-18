//
//  DoingAppApp.swift
//  DoingApp
//
//  Created by 신이삭 on 5/14/25.
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var isShowSplash: Bool = false
}

@main
struct DoingAppApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        for family in UIFont.familyNames {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print(" - \(name)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.isShowSplash {
                    MonthV()
                        .transition(.opacity)
                } else {
                    SplashV()
                        .environmentObject(appState)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: appState.isShowSplash)
        }
    }
}
