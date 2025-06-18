//
//  ToDoListV.swift
//  DoingApp
//
//  Created by 신이삭 on 5/27/25.
//

import SwiftUI
import Observation

struct ToDoCheckedV: View {
    var title: String = ""
    @State var isCompleted: Bool
    var isEditing: Bool = false
    var checkedIndex: Int = -1
    var checkedId: UUID
    @Binding var vm: TodoItemVM
    var body: some View {
        VStack(spacing: isEditing ? 10 : 5) {
            HStack(spacing: 10) {
                if isEditing {
                    Button(action: {
                        self.isCompleted.toggle()
                        Task {
                            await vm.updateTodoItem(id: checkedId, index: checkedIndex, isCompleted: isCompleted)
                        }
                    }) {
                        Image(systemName: isCompleted ? "checkmark.square.fill" : "square")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.red)
                    }
                    .disabled(!isEditing)
                } else {
                    Image(systemName: isCompleted ? "checkmark.square.fill" : "square")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.red)
                }
                
                Text(title)
                    .font(.nanumDaHaeng(size: isEditing ? 18 : 16))
                    .foregroundStyle(.accent)
                    .lineLimit(isEditing ? .max : 2)
                    .truncationMode(.tail)
                Spacer()
            }
            .padding(.init(top: 5, leading: 5, bottom: 5, trailing: 5))
        }
    }
}

@Observable
class TodoItemVM {
    
    func fetchTodo(id: UUID? = nil) async -> TodoDay? {
        guard let id = id else { return nil }
        let result = await SwiftDataManager.shared.fetch(with: #Predicate<TodoDay> { $0.id == id }).first
        return result
    }
    
    func updateTodoItem(id: UUID,
                        index: Int,
                        isCompleted: Bool) async {
        await SwiftDataManager.shared.update(id: id) { (todoDay: TodoDay) in
            todoDay.items[index].isCompleted = isCompleted
        }
    }
}

struct ToDoItemV: View {
    @State var todoDay: TodoDay
    @Binding var path: [Route]  // 부모에서 전달받은 path
    @State var vm = TodoItemVM()
    var id: UUID {
        todoDay.id
    }
    var isEditing: Bool = false
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                Text((isEditing ? todoDay.date.toYearMonthDayString() : todoDay.date.toMonthDayString()))
                    .foregroundStyle(.accent)
                    .bold()
                    .font(.nanumDaHaeng(size: isEditing ? 20 : 18))
                    .padding()
                    .background(
                            GeometryReader { geometry in
                                VStack(spacing: 2) {
                                    Spacer()
                                    Rectangle()
                                        .fill(Color.red)
                                        .frame(height: 1)
                                        .frame(width: geometry.size.width)
                                    Rectangle()
                                        .fill(Color.red)
                                        .frame(height: 1)
                                        .frame(width: geometry.size.width)
                                }
                            }
                        )
                List {
                    ForEach(
                        Array(todoDay.items.sorted(by: { $0.createdAt > $1.createdAt }).enumerated()),
                        id: \.element.id
                    ) { index, item in
                        ToDoCheckedV(title: item.title,
                                     isCompleted: item.isCompleted,
                                     isEditing: isEditing,
                                     checkedIndex: index,
                                     checkedId: todoDay.id,
                                     vm: $vm)
                        .background {
                            if self.todoDay.date.removeTimeStamp() < Date().removeTimeStamp() && !item.isCompleted {
                                GeometryReader { geometry in
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.5))
                                        .frame(height: 1.5)
                                        .position(x: geometry.size.width / 2,
                                                  y: geometry.size.height / 2)
                                }
                            } else {
                                EmptyView()
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .padding()
                .frame(height: isEditing ? nil : Define.Device.screenHeight / 3.1)
                .frame(maxHeight: isEditing ? .infinity : nil)
                
                if isEditing {
                    Spacer()

                    Button {
                        path.append(.update(id: todoDay.id))
                    } label: {
                        Text("편집하기")
                            .font(.nanumDaHaeng(size: 20))
                            .foregroundStyle(.white)
                            .bold()
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.red.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))
                    }
                    Spacer()
                        .frame(height: 20)
                }
            }
            .padding(.vertical, 5)

            Circle()
                    .fill(Color.red)
                    .frame(width: isEditing ? 20 : 16, height: isEditing ? 20 : 16)
                    .offset(x: 6, y: -6)
        }
        .onChange(of: path) { oldPath, newPath in
            Task {
                if isEditing {
                    if let todoDay = await vm.fetchTodo(id: self.id) {
                        self.todoDay = todoDay
                    }
                }
            }
        }
        .background(
            FoldedCornerV()
        )
    }
}

//#Preview {
//    ToDoItemV(todoDay: .constant(TodoDay(date: Date(), deviceId: "디바이스 아이디", items: [
//        TodoItem(id: UUID(), title: "타이틀", isCompleted: true, createdAt: Date()),
//        TodoItem(id: UUID(), title: "타이틀", isCompleted: true, createdAt: Date()),
//        TodoItem(id: UUID(), title: "타이틀", isCompleted: true, createdAt: Date())
//    ])), isEditing: false)
//}
