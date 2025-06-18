//
//  View+Ext.swift
//  DoingApp
//
//  Created by 신이삭 on 6/10/25.
//

import SwiftUI

extension View {
    func customBackButton(action: @escaping () -> Void) -> some View {
        self.modifier(NavigationBackButtonModifier(action: action))
    }
}
