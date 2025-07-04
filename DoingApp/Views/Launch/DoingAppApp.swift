//
//  DoingAppApp.swift
//  DoingApp
//
//  Created by 신이삭 on 5/14/25.
//

import SwiftUI
import Combine

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    static var launchURL: URL?

    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        AppDelegate.launchURL = url
        return true
    }
}

class AppState: ObservableObject {
    @Published var isShowSplash: Bool = false
}

@main
struct DoingAppApp: App {
    @StateObject private var appState = AppState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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
