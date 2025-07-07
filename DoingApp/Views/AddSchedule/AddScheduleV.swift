//
//  AddV.swift
//  DoingApp
//
//  Created by 신이삭 on 6/2/25.
//

import SwiftUI
import Observation
import WidgetKit

@Observable
final class AddScheduleVM {
    var selectedDate: Date? = Date()
    var todo: String = ""
    var todoList: [TodoItem] = []
    var alertMessage: String? = nil
    var todoDay: TodoDay? = nil
    var isUpdateSuccess: Bool = true

    func addTodo() {
        guard !todo.isEmpty else { return }
        let todoItem = TodoItem(title: todo, createdAt: selectedDate ?? Date())
        todoList.append(todoItem)
        todo = ""
    }
    
    func removeTodo(at index: Int) {
        guard index >= 0 && index < todoList.count else { return }
        todoList.remove(at: index)
    }
    
    func insertTodo() async {
        guard let selectedDate = selectedDate else {
            alertMessage = "날짜를 선택해주세요."
            isUpdateSuccess = false
            return
        }

        guard !todoList.isEmpty else {
            alertMessage = "할 일을 추가해주세요."
            isUpdateSuccess = false
            return
        }

        let deviceId = Define.Device.uuid
        let todoDay = TodoDay(date: selectedDate, deviceId: deviceId, items: todoList.sorted(by: { $0.createdAt > $1.createdAt }))

        await SwiftDataManager.shared.insert(todoDay)
        alertMessage = "일정이 추가되었습니다."
    }
    
    func updateTodo(id: UUID) async {
        guard let selectedDate = selectedDate else {
            alertMessage = "날짜를 선택해주세요."
            isUpdateSuccess = false
            return
        }

        guard !todoList.isEmpty else {
            alertMessage = "할 일을 추가해주세요."
            isUpdateSuccess = false
            return
        }

        await SwiftDataManager.shared.update(id: id) { (todoDay: TodoDay) in
            todoDay.items = todoList.sorted(by: { $0.createdAt > $1.createdAt })
            todoDay.date = selectedDate
        }
        self.todoDay = await self.fetchTodo(id: id)
        alertMessage = "일정이 수정되었습니다."
        isUpdateSuccess = true
        return
    }
    
    func deleteTodo() async {
        guard let todoDay = todoDay else {
            return
        }
        
        await SwiftDataManager.shared.delete(todoDay)
        
        alertMessage = "일정이 삭제되었습니다."
    }
    
    func fetchTodo(id: UUID? = nil) async -> TodoDay? {
        guard let id = id else { return nil }
        let result = await SwiftDataManager.shared.fetch(with: #Predicate<TodoDay> { $0.id == id }).first
        return result
    }
}

struct AddScheduleV: View {
    public static let screenName = "AddScheduleV"
    @Bindable private var vm = AddScheduleVM()
    @Binding var path: [Route]  // 부모에서 전달받은 path
    @State private var showSheet: Bool = false
    @State private var editMode: EditMode = .inactive
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var popRootView: Bool = false
    @FocusState private var isTextFieldFocus: Bool
    var id: UUID? = nil
    
    var body: some View {
        ZStack {
            Color.secondary
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    if !isTextFieldFocus {
                        withAnimation {
                            self.showSheet = true
                        }
                    }
                } label: {
                    let placeholder = vm.selectedDate?.toYearMonthDayString() ?? "날짜를 선택하세요"
                    PlaceholderUnderlineView(placeholder: placeholder)
                }

                Spacer().frame(height: 20)
                Text("할 일")
                    .font(.nanumDaHaeng(size: 24))
                    .foregroundColor(.accent)
                
                Spacer().frame(height: 10)

                HStack(spacing:  4) {
                    TextField(text: $vm.todo) {
                        PlaceholderUnderlineView(placeholder: "할 일을 입력하세요")
                    }
                    .font(.nanumDaHaeng(size: 20))
                    .focused($isTextFieldFocus)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            HStack {
                                Spacer()
                                Button {
                                    isTextFieldFocus = false
                                } label: {
                                    Text("완료")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    
                    Button {
                        vm.addTodo()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.accent)
                    }
                    
                    Spacer()
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.8))
                        .shadow(radius: 4)
                    
                    List {
                        ForEach(vm.todoList, id: \.self) { item in
                            VStack {
                                Spacer().frame(height: 10)
                                HStack {
                                    Text(item.title)
                                        .font(.nanumDaHaeng(size: 20))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        if let index = vm.todoList.firstIndex(of: item) {
                                            vm.todoList.remove(at: index)
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                            .frame(width: 30)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                Divider()
                                    .background(Color.white.opacity(0.5))
                            }
                            
                            .listRowBackground(Color.clear)
                        }
                        .onMove(perform: moveItem)
                        
                    }
                    .listStyle(.plain)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .environment(\.editMode, $editMode)

                }
                .padding(.vertical, 8)
                
                Spacer()
                
                if let id = id {
                    HStack(alignment: .center, spacing: 8) {
                        Spacer()
                        Button(action: {
                            Task {
                                await vm.updateTodo(id: id)
                                if let message = vm.alertMessage {
                                    alertMessage = message
                                    showAlert = true
                                }
                            }
                        }) {
                            Text("수정하기")
                                .modifier(AddButtonTextModifier(color: .black))
                        }
                        
                        Button(action: {
                            Task {
                                await vm.deleteTodo()
                                if let message = vm.alertMessage {
                                    alertMessage = message
                                    showAlert = true
                                    popRootView = true
                                }
                            }
                        }) {
                            Text("삭제하기")
                                .modifier(AddButtonTextModifier(color: .red))
                        }
                        Spacer()
                    }
                } else {
                    Button(action: {
                        Task {
                            await vm.insertTodo()
                            if let message = vm.alertMessage {
                                alertMessage = message
                                showAlert = true
                            }
                        }
                    }) {
                        Text("일정 추가하기")
                            .modifier(AddButtonTextModifier(color: .black))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(20)
            
            if showSheet {
                CalendarV(showSheet: $showSheet, selectedDate: Binding(get: {
                    vm.selectedDate ?? Date()
                }, set: { newValue in
                    vm.selectedDate = newValue
                }), isEditing: true)
            }
        }
        .task {
            // 수정할 일정이 있을 경우,
            if let id = id {
                let todoDay = await vm.fetchTodo(id: id)
                vm.todoDay = todoDay
                self.vm.selectedDate = todoDay?.date
                self.vm.todoList = todoDay?.items ?? []
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("알림"), message: Text(alertMessage).font(.nanumDaHaeng(size: 20)), dismissButton: .default(Text("확인"), action: {
                if popRootView {
                    path.removeAll()
                } else {
                    if vm.isUpdateSuccess {
                        path.removeLast()
                    }
                }
            }))
        }
        
    }
    
    func moveItem(from source: IndexSet, to destination: Int) {
        vm.todoList.move(fromOffsets: source, toOffset: destination)
    }
}

struct PlaceholderUnderlineView: View {
    var placeholder: String

    var body: some View {
        HStack {
            Image(systemName: "calendar")
                .resizable()
                .frame(width: 25, height: 25)
                .tint(.accent)
            VStack(alignment: .leading, spacing: 8) {
                Text(placeholder)
                    .foregroundColor(.secondary)
                    .font(.nanumDaHaeng(size: 20))
                Rectangle()
                    .frame(height: 1.5)
                    .foregroundColor(.white)
            }
            
        }
    }
}
//
//#Preview {
//    AddScheduleV()
//}
