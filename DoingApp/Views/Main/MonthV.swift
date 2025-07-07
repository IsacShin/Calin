//
//  MonthV.swift
//  DoingApp
//
//  Created by 신이삭 on 5/23/25.
//

import SwiftUI
import Observation
import Combine

enum Route: Hashable {
    case add
    case update(id: UUID)
    case detail(todoDay: TodoDay)
}

@Observable
final class MonthVM {
    var selectedDate: CurrentValueSubject<Date, Never> = CurrentValueSubject(Date())
    var todoData: [TodoDay] = []
    var cancellables = Set<AnyCancellable>()
    
    init() {
        selectedDate
            .sink { date in
                Task {
                    self.todoData = await self.fetchToMonthData(date: date)
                }
            }
            .store(in: &cancellables)
    }
    /// 해당월의 일정 데이터 조회 및 이전 미완욜 일정 복사
    func fetchToMonthData(date: Date) async -> [TodoDay] {
        self.todoData = []
        let today = Date().removeTimeStamp()
        let originalTodos = await SwiftDataManager.shared.fetchTodoMonth(forMonthOf: date)

        for todo in originalTodos {
            let outdatedItems = todo.items.filter {
                !$0.isCompleted && todo.date < today
            }
            
            if outdatedItems.count > 0 { // 이전날짜에 미완료된 일정이 있으면
                // 오늘 날짜 TodoDay 존재 여부 확인
                if let todayTodo = originalTodos.first(where: { $0.date.removeTimeStamp() == today }) {
                    // 있으면 append
                    await SwiftDataManager.shared.update(id: todayTodo.id) { (day: TodoDay) in
                        let copiedItems = outdatedItems.map { item in
                            TodoItem(
                                id: UUID(),
                                title: item.title,
                                isCompleted: item.isCompleted,
                                createdAt: item.createdAt,
                                referenceId: item.id
                            )
                        }
                        let existingReferenceIds = Set(day.items.compactMap { $0.referenceId })
                        let newItems = copiedItems
                            .filter { !existingReferenceIds.contains($0.referenceId ?? UUID()) }
                            .sorted { $0.createdAt < $1.createdAt }

                        day.items.append(contentsOf: newItems)
                    }
                } else {
                    // 없으면 새로 생성
                    let copiedItems = outdatedItems.map { item in
                        TodoItem(
                            id: UUID(),
                            title: item.title,
                            isCompleted: item.isCompleted,
                            createdAt: item.createdAt,
                            referenceId: item.id
                        )
                    }

                    let newTodoDay = TodoDay(
                        date: today,
                        deviceId: todo.deviceId,
                        items: copiedItems
                    )
                    await SwiftDataManager.shared.insert(newTodoDay)
                }
            }
        }
        
        return await SwiftDataManager.shared.fetchTodoMonth(forMonthOf: date)
    }
}

struct MonthV: View {
    @State private var vm = MonthVM()
    @State private var showSheet = false
    @State private var path: [Route] = []
    @State private var isSingleColumn: Bool = false
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.secondary
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 20) {
                    Spacer().frame(height: 10)
                    HStack {
                        Spacer().frame(width: 20)
                        Button {
                            withAnimation {
                                showSheet = true
                            }
                        } label: {
                            HStack {
                                Text(vm.selectedDate.value.toYearMonthString())
                                    .modifier(TextModifier())
                                Image(systemName: "calendar")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .tint(.accent)
                            }
                        }
                        Spacer()
                        
                        Button {
                            withAnimation {
                                isSingleColumn.toggle()
                            }
                        } label: {
                            Image(systemName: isSingleColumn ? "rectangle.grid.1x2.fill" : "rectangle.grid.2x2.fill")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .tint(Color.white.opacity(0.8))
                        }
                        
                        Button {
                            vm.selectedDate.send(Date())
                        } label: {
                            Text("오늘")
                                .modifier(TextModifier(font: .nanumDaHaeng(size: 20)))
                                .padding(.init(top: 8, leading: 12, bottom: 8, trailing: 12))
                                .background(Color.white.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))

                        }
                        Spacer().frame(width: 20)
                    }
                    
                    if self.vm.todoData.count > 0 {
                        // 리스트 부분
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: (Define.Device.screenWidth / (isSingleColumn ? 1 : 2)) - 20))], spacing: 10) {
                                ForEach(self.vm.todoData, id: \.id) { item in
                                    Button {
                                        path.append(.detail(todoDay: item))
                                    } label: {
                                        ToDoItemV(todoDay: item,
                                                  path: $path,
                                                  isEditing: false)
                                    }
                                }
                            }
                            .padding(8)
                        }
                        
                    } else {
                        Spacer()
                            .frame(height: 100)
                        // 데이터가 없을 때
                        Text("등록된 일정이 없습니다.")
                            .font(.nanumDaHaeng(size: 20))
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    
                    Spacer()
                }
                
                Button(action: {
                    path.append(.add)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.accent)
                        .opacity(0.7)
                        .padding()
                }
                .offset(x: UIScreen.main.bounds.width / 2 - 55, y: UIScreen.main.bounds.height / 2 - 80)
                
                if showSheet {
                    CalendarV(showSheet: $showSheet, selectedDate: $vm.selectedDate.value, isEditing: false)
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .add:
                    AddScheduleV(path: $path)
                        .customBackButton {
                            path.removeLast()
                        }
                case .detail(todoDay: let item):
                    DetailV(todoDay: item, path: $path)
                        .customBackButton {
                            path.removeLast()
                        }
                case .update(id: let id):
                    AddScheduleV(path: $path, id: id)
                        .customBackButton {
                            path.removeLast()
                        }
                }
            }
        }
        .onAppear {
            if let url = AppDelegate.launchURL {
                handleIncomingURL(url)
                AppDelegate.launchURL = nil
            }
        }
        .onChange(of: path) { oldPath, newPath in
            if newPath.isEmpty {
                Task {
                    let todos = await vm.fetchToMonthData(date: vm.selectedDate.value)
                    await MainActor.run {
                        vm.todoData = []
                        vm.todoData = todos
                    }
                }
            }
        }
        .onOpenURL { url in
            handleIncomingURL(url)
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "todoapp",
              url.host == "todo",
              let idString = url.pathComponents.dropFirst().first,
              let uuid = UUID(uuidString: idString)
        else { return }

        Task {
            let todos = await vm.fetchToMonthData(date: vm.selectedDate.value)
            if let target = todos.first(where: { $0.items.contains(where: { $0.id == uuid }) }) {
                await MainActor.run {
                    vm.todoData = []
                    vm.todoData = todos
                    if !path.contains(.detail(todoDay: target)) { // 해당 화면이 없을 경우에만 진입
                        path.append(.detail(todoDay: target))
                    }
                }
            }
        }
    }
}

#Preview {
    MonthV()
}

