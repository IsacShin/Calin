//
//  CalendarV.swift
//  DoingApp
//
//  Created by 신이삭 on 6/5/25.
//

import SwiftUI

struct CalendarV: View {
    @Binding var showSheet: Bool
    @Binding var selectedDate: Date
    var isEditing: Bool = false
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    showSheet = false
                }
        }
        .animation(.easeIn, value: showSheet)

        VStack(spacing: 0) {
            Spacer()
            HStack {
                Button("취소") {
                    showSheet = false
                }
                Spacer()
                Button("완료") {
                    showSheet = false
                    // 여기에 날짜 확정 로직 추가 가능
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            
            if isEditing {
                DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                    .environment(\.locale, Locale(identifier: "ko_KR"))
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(width: UIScreen.main.bounds.width, height: 200)
                    .background(Color.white)
            } else {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .environment(\.locale, Locale(identifier: "ko_KR"))
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(width: UIScreen.main.bounds.width, height: 200)
                    .background(Color.white)
            }
                
        }
        .cornerRadius(16)
        .ignoresSafeArea(edges: .bottom)
        .transition(.move(edge: .bottom))
    }
}
//
//#Preview {
//    CalendarV()
//}
