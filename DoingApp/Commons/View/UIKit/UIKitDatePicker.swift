//
//  UIkitDatePicker.swift
//  DoingApp
//
//  Created by 신이삭 on 5/23/25.
//

import SwiftUI
import UIKit

struct UIKitDatePicker: UIViewRepresentable {
    @Binding var date: Date
    var mode: UIDatePicker.Mode = .date

    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = mode
        picker.preferredDatePickerStyle = .wheels // 스타일 지정 가능
        picker.locale = Locale(identifier: "ko_KR")
        picker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged(_:)), for: .valueChanged)
        return picker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = date
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: UIKitDatePicker

        init(_ parent: UIKitDatePicker) {
            self.parent = parent
        }

        @objc func dateChanged(_ sender: UIDatePicker) {
            parent.date = sender.date
        }
    }
}
