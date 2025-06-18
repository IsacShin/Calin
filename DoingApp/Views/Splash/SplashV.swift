//
//  SplashV.swift
//  DoingApp
//
//  Created by 신이삭 on 5/14/25.
//

import SwiftUI

final class SplashVM: ObservableObject {
    @Published var animFinished: Bool = false
}

struct SplashV: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var vm = SplashVM()
    @State private var isScaled: Bool = false
    var body: some View {
        ZStack {
            Color(red: 250/255, green: 237/255, blue: 125/255)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Image(systemName: "scribble.variable")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .scaleEffect(isScaled ? 1.2 : 1.0)
                    .foregroundStyle(.red)
                    .onAppear {
                        Task {
                            try await Task.sleep(for: .seconds(0.75))
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isScaled = true
                            }
                        }
                    }
            }
        }
        .onChange(of: isScaled, { _, newValue in
            Task { @MainActor in
                if !newValue && vm.animFinished {
                    // 탭뷰 이동
                    appState.isShowSplash = true
                } else {
                    try await Task.sleep(for: .seconds(0.75))
                    vm.animFinished = true
                    withAnimation(.easeInOut(duration: 1.25)) {
                        isScaled = false
                    }
                }
            }
        })
    }
}

#Preview {
    SplashV()
}
