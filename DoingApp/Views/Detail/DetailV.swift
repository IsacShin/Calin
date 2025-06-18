//
//  DetailV.swift
//  DoingApp
//
//  Created by 신이삭 on 6/9/25.
//

import SwiftUI

struct DetailV: View {
    var todoDay: TodoDay
    @Binding var path: [Route]  // 부모에서 전달받은 path
    var body: some View {
        ZStack {
            Color.secondary
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer().frame(height: 20)
                ToDoItemV(todoDay: todoDay,
                          path: $path,
                          isEditing: true)
                .padding(20)
                
                Spacer()
            }
            
        }
    }
}
//
//#Preview {
//    DetailV()
//}
