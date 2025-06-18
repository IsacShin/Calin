//
//  NavigationBackButtonModifier.swift
//  DoingApp
//
//  Created by 신이삭 on 6/10/25.
//

import SwiftUI

struct NavigationBackButtonModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: action) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
    }
}
