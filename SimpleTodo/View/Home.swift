//
//  Home.swift
//  SimpleTodo
//
//  Created by 유상민 on 2023/09/17.
//

import SwiftUI
import CoreData

struct Home: View {
    // View Properties
    // 앱 전체에서 사용되는 중요한 정보를 가지는 변수, 일반적인 예시로 디자인 테마, 라이트모드, 다크모드 등
    // 즉, 이 변수를 통해서 환경에서 가져온 데이터를 읽을 수 있고, 필요할 때 앱의 동작을 조절할 수 있음.
    @Environment(\.self) private var env
    // 현재 날짜와 시간을 가지고 있는 변수, 앱이 시작되면 현재 날짜와 시간으로 초기화 됨.
    @State private var filterDate: Date = .init()
    // 미해결 작업을 표시하는 변수
    @State private var showPendingTasks: Bool = true
    // 해결 완료 작업을 표시하는 변수
    @State private var showCompletedTaks: Bool = true
    
    var body: some View {
        List {
            // DatePicker 는 사용자에게 날짜나 시간을 선택하도록 하는 SwiftUI의 UI 요소
            // selection: $filterDate 는 선택된 날짜나 시간을 나타내는 바인딩 형식 즉, 사용자가 날짜를 선택하면 이 변수에 선택된 날짜가 업데이트
            // displayedComponents: [.date] 는 사용자에게 표시되는 단위를 설정하는 매개변수 여기서는 날짜만 표시되도록 설정
            DatePicker(selection: $filterDate, displayedComponents: [.date]) {
                
            }
            // DatePricker에 의해 생성된 라벨을 숨김
            .labelsHidden()
            // DatePicker의 스타일을 .graphical 설정
            .datePickerStyle(.graphical)
            
            // "미완료 작업"과 "완료 작업"을 보여주기 위한 사용자 정의 필터링 및 표시 뷰.
            // filterDate를 필수 매개변수로 받으며 pendingTasks와 completedTasks 클로저의 결과를 처리하기 위한 클로저도 인자로 받음
            CustomFilteringDataView(filterDate: $filterDate) { pendingTasks, completedTasks in
                // "미완료 작업"을 표시하는 DisclosureGroup 임.
                // DisclosureGroup은 콘텐츠를 펼치거나 접을 수 있는 UI 요소임. isExpanded와 같은 바인딩을 사용하여 그룹의 펼침 상태를 제어할 수 있음.
                // isExpanded 바인딩을 사용하여 사용자가 펼치거나 닫을 수 있음. 내부에는 "미완료 작업" 목록이 표시됨.
                DisclosureGroup(isExpanded: $showPendingTasks) {
                    // Custom Core Data Filter View, Which will Display Only Pending Tasks on this Day
                    // "미완료 작업"이 없으면 No Task's Found 텍스트를 보여줌
                    if pendingTasks.isEmpty {
                        Text("No Task's Found")
                            .font(.caption)
                            .foregroundColor(.gray)
                    // "미완료 작업"이 있으면 ForEach를 사용하여 각 작업을 TaskRow로 표시함.
                    } else {
                        ForEach(pendingTasks) {
                            TaskRow(task: $0, isPendingTask: true)
                        }
                    }
                // Pending Task's의 해당 목록의 갯수에 따라 동적으로 업데이트 되며 목록이 비어있으면 괄호와 함께 "()"로 형태로 나타남.
                } label: {
                    Text("Pending Task's \(pendingTasks.isEmpty ? "" : "(\(pendingTasks.count))")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // 위 내용과 동일 함.
                DisclosureGroup(isExpanded: $showCompletedTaks) {
                    // Custom Core Data Filter View, Which will Display Only Completed Tasks on this Day
                    if completedTasks.isEmpty {
                        Text("No Task's Found")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(completedTasks) {
                            TaskRow(task: $0, isPendingTask: false)
                        }
                    }
                } label: {
                    Text("Completed Task's \(completedTasks.isEmpty ? "" : "(\(completedTasks.count))")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        // 상단 네비게이션 바 또는 하단 바에 추가 요소를 배치하는 데 사용
        .toolbar {
            // Toolbar 내에 아이템을 배치하는 역할 placement 매개변수를 통해서 아이템을 하단 바에 버튼을 배치
            ToolbarItem(placement: .bottomBar) {
                // 버튼을 탭하면 내부 클로저 부분의 코드가 실행
                // 버튼에는 "New Task"를 추가하는 동작이 구현
                Button {
                    // Simply Opening Pending Task View
                    // Then Adding an Empty Task
                    do {
                        // Core Data를 사용하여 Task 인터티의 새로운 인스턴스를 생성
                        let task = Task(context: env.managedObjectContext)
                        // 고유한 ID 값을 할당
                        task.id = .init()
                        // 선택된 날짜로 할당
                        task.date = filterDate
                        // 테스크의 제목을 빈 문자열로 설정
                        task.title = ""
                        // 테스크의 완료 상태를 false 즉 미완료로 설정
                        task.isCompleted = false
                        
                        // 변경된 Core Data 컨텍스트를 저장하여 새로운 태스크를 영구 저장소에 저장
                        try env.managedObjectContext.save()
                        // 상태변수를 true로 설정하여 보류 중인 태스크를 표시하도록 설정
                        showPendingTasks = true
                    } catch {
                        print(error.localizedDescription)
                    }
                } label: {
                    HStack {
                        // 버튼 내의 이미지를 추가
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        // 버튼 내의 텍스트를 추가
                        Text("New Task")
                    }
                    .fontWeight(.bold)
                }
                // 버튼이 최대 너비까지 확장, 텍스트와 아이콘으 왼쪽으로 정렬
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TaskRow: View {
    // task의 데이터가 변경될 때마다 뷰를 다시 그리도록 설정
    @ObservedObject var task: Task
    var isPendingTask: Bool
    // View Properties
    @Environment(\.self) private var env
    // @FocusState 프로퍼티 래퍼는 사용자의 키보드 포커스 상태를 관리함.
    // 특정 뷰가 키보드 포커스를 가질 떄 true로 설정되고, 포커스가 없을 때 false로 설정
    @FocusState private var showKeyboard: Bool
    var body: some View {
        // 요소간의 간격을 12 및 가로로 배치
        HStack(spacing: 12) {
            // 버튼을 탭 하면 클로저 내부의 코드 블록이 실행
            Button {
                task.isCompleted.toggle()
                save()
            } label: {
                // task.isCompleted 가 true면 checkmark.circle.fill 아이콘을, false면 circle 아이콘을 사용하도록 설정.
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            // 버튼의 스타일을 일반적인 버튼으로 나타냄
            .buttonStyle(.plain)
            
            // 요소들을 세로로 배치, 요소의 간격을 4로 지정
            VStack(alignment: .leading, spacing: 4) {
                // 사용자로부터 입력받을 때 타이틀을 지정하고, text 매개변수에 텍스트 바인딩이 전달 즉, 사용자가 입력한 텍스트를 저장하고 관리함
                // get 클로저는 사용자가 텍스트 필드에 표시될 초기 텍스트를 반환
                TextField("Task Title", text: .init(get: {
                    return task.title ?? ""
                // set 클로저는 사용자가 텍스트 필드에 텍스트를 입력할 때 호출되고, 입력된 텍스트를 task.title에 저장.
                }, set: { value in
                    task.title = value
                }))
                // 텍스트 필드가 포커스를 받을 때 어떤 상태를 가질지 제어
                // $showKeyboard가 true일 때 텍스트 필드가 포커스를 받도록 설정
                .focused($showKeyboard)
                // 사용자가 텍스트 필드에서 리턴(완료) 키를 누르면 호출되는 클로저를 정의.
                .onSubmit {
                    removeEmptyTask()
                    save()
                }
                // isPendingTask 값이 true이면 기본 텍스트 색상 false면 .gray 색상
                .foregroundColor(isPendingTask ? .primary : .gray)
                // strikethrough 텍스트에 취소선을 추가하는 기능
                // !isPendingTask 가 true가 아니면 즉, false이면 취소선 추가하고, 스타일은 점선 색상은 기본색
                .strikethrough(!isPendingTask, pattern: .dash, color: .primary)
                
                // Custom Date Picker
                // task.date 가 nill인 경우 기본값으로 현재 날짜와 시간을 사용
                // formatted 함수를 사용하여 텍스트릴 지정된 형식으로 서식화 날짜를 생략하고 시간을 짧게 표시
                Text((task.date ?? .init()).formatted(date: .omitted, time: .shortened))
                    // 폰트 크기는 중간
                    .font(.callout)
                    .foregroundColor(.gray)
                    // 뷰의 위에 다른 뷰를 오버레이 함 즉, DatePicker를 오버레이 함.
                    .overlay {
                        // get은 현재 선택된 날짜를 반환
                        DatePicker(selection: .init(get: {
                            return task.date ?? .init()
                            // set은 DatePicker에서 날자를 변경할 때 호출함.
                            // 그리고 그 때마다 save() 함수를 호출하여 변경 사항을 저장.
                        }, set: { value in
                            task.date = value
                            // Saving Date When ever it's Updated
                            save()
                            // DatePicker에서 시간과 분을 선택할 수 있도록 설정
                        }), displayedComponents: [.hourAndMinute]) {
                            
                        }
                        .labelsHidden()
                        // Hiding View by Utilizing BlendMode Modifier
                        // BlendMode는 뷰와 그 위에 오버레이로 추가된 뷰 간의 블렌딩 모드를 설정
                        // destinationOver 는 오버레이로 추가된 DatePicker가 원래 뷰 위에 표시되도록 설정
                        // 즉, DatePicker는 텍스트 뷰 위에 겹쳐져 표시 됨.
                        .blendMode(.destinationOver)
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        // onAppear는 SwiftUI 뷰가 화면에 나타날 때 실행되는 클로저를 정의
        // task.title이 비어있는 경우에만 showKeyboard 라는 @FocusState 속성을 true로 설정
        .onAppear {
            if (task.title ?? "").isEmpty {
                showKeyboard = true
            }
        }
        // onDisappear는 SwiftUI 뷰가 화면에서 사라질 때 실행되는 클로저를 정의
        // 뷰가 사라지면 아래 함수를 호출
        .onDisappear {
            removeEmptyTask()
            save()
        }
        // Verifiying Content when user leaves the App
        // onChange를 사용하여 환경 변수 env의 scenePhase 프로퍼티를 감시 scenePhase는 앱의 생명주기 상태를 나타내며, 앱의 상태에 따라 코드를 실행
        // scenePhase 프로퍼티의 값이 변경될 때 실행될 클로저를 정의
        // scenePhase가 변경될 때마다 해당 클로저가 실행
        .onChange(of: env.scenePhase) { newValue in
            // scenePhase의 새 값인 newValue가 .active가 아닌 경우에 실행
            // .active는 앱이 활성 상태일 때의 상태를 나타내며, 이 외의 다른 상태는 비활성인 상태인 경우임.
            if newValue != .active {
                // showKeyboard 라는 @FocusState 프로퍼티를 false로 설정
                showKeyboard = false
                // 코드를 메인 스레드에서 비동기적으로 실행
                DispatchQueue.main.async {
                    // Checking if it's Empty
                    // task를 제거
                    removeEmptyTask()
                    // Core Data를 사용하여 데이터를 저장하는 역할. 변경 내용이 영구적으로 저장.
                    save()
                }
            }
        }
        // Adding Swipe to Delete
        // 좌로 스와이핑하면 삭제하는 기능
        // swipeActions는 리스트 항목을 스와이프하여 작업을 수행할 수 있도록 하는 기능
        // 리스트 항목을 오른쪽에서 스와이프했을 떄 나타내는 작업을 정의
        // edge 매개변수는 스와이프 방향을 나타내며 .trailing으로 설정하면 오른쪽에서 스와이프할 때 작업이 표시됨.
        // allowsFullSwipe는 전체 스와이프를 허용할지 여부를 나타냄
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            // 스와이프 작업의 내용을 정의하고, "삭제" 작업을 나타냄
            Button(role: .destructive) {
                // 스와이프 작업이 실행된 후 일정 시간(0.1초)이 지난 후에 실행
                // 이렇게 딜레이를 주는 이유는 사용자가 스와이프를 취소할 수 있는 여유 시간을 주기 위함.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Core Data에서 관리되는 객체 task를 삭제함. 데이터베이스에서 해당 항목을 삭제하는 역할
                    env.managedObjectContext.delete(task)
                    // 데이터베이스 변경 내용을 저장. 삭제된 항목이 영구적으로 삭제
                    save()
                }
            } label: {
                Image(systemName: "trash.fill")
            }
        }
    }
    
    // Context Saving Method
    // 데이터 컨텍스트의 변경 내용을 저장하는 함수
    func save() {
        do {
            // 데이터 컨텍스트의 save() 메서드를 호출하여 변경 내용을 저장
            // try 키워드는 해당 메서드가 오류를 발생시킬 수 있으며, 발생하는 경우 catch 블록에서 오류를 처리
            try env.managedObjectContext.save()
        } catch {
            // 발생한 오류의 로컬라이즈된 설명(문자열)을 출력
            print(error.localizedDescription)
        }
    }
    
    // Removing Empty Task
    // 빈 task를 제거하는 역할을 하는 함수
    func removeEmptyTask() {
        // task.title 속성이 비어 있는지 검사 task.title은 Optional String 형식이며 ?? 연산자는 옵셔널 값이 nil인 경우에 대체값을 사용
        // 따라서 task.title이 nil이거나 비어 있다면 true
        if (task.title ?? "").isEmpty {
            // Removing Empty Task
            // Core Data의 managedObjectContext를 사용하여 task 객체를 삭제
            // 데이터베이스에서 해당 task 객체가 완전히 제거
            env.managedObjectContext.delete(task)
        }
    }
}
