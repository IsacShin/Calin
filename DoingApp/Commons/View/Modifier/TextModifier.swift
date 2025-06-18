//
//  TextModifier.swift
//  DoingApp
//
//  Created by 신이삭 on 5/23/25.
//

import Foundation
import SwiftUI

struct TextModifier: ViewModifier {
    var font: Font = .nanumDaHaeng(size: 26)
    var color: Color = .accent
    var weight: Font.Weight = .bold
    
    func body(content: Content) -> some View {
        content
            .font(font.weight(weight))
            .foregroundStyle(color)
    }
    
}

struct AddButtonTextModifier: ViewModifier {
    var color: Color = .accent
    func body(content: Content) -> some View {
        content
            .font(.nanumDaHaeng(size: 18))
            .padding()
            .background(Color.white)
            .foregroundColor(color.opacity(0.8))
            .cornerRadius(10)
            .shadow(radius: 4)
    }
    
}
