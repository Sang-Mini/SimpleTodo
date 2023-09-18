//
//  CustomFilteringDataView.swift
//  SimpleTodo
//
//  Created by 유상민 on 2023/09/17.
//

import SwiftUI
import CoreData

// 제네릭을 사용한 SwiftUI 뷰
// 사용자가 정의한 Content라는 형식의 뷰를 포함하는 커스텀 뷰를 생성
// Content는 제네릭 형식 Content를 사용하여 내부에 다른 뷰나 뷰 계층 구조를 포함할 수 있음
// Content 형식의 뷰는 이 커스텀 뷰의 내용으로 사용
struct CustomFilteringDataView<Content: View>: View {
    // 클로저 타입을 가지며, 두 개의 [Task] 배열을 통해서 Content형식의 반환
    var content: ([Task], [Task]) -> Content
    
    // @FetchRequest는 Core Data에서 데이터를 가져오는 데 사용되는 속성 래퍼임
    // SwiftUI 뷰가 Core Data에서 데이터를 검색하고 해당 데이터의 변경 사항을 모니터링할 수 있음.
    // 즉 Core Data에서 검색한 결과가 변수에 저장됨.
    // FetchedResults는 Core Data에서 가져온 데이터의 컬렉션, SwiftUI에서 사용할 수 있는 데이터 바인딩에 최적화되어 있음.
    // 즉, result 변수는 Core Data에서 Task 엔터티의 모든 객체를 가져와서 관리하는 변수임.
    @FetchRequest private var result: FetchedResults<Task>
    
    // @Binding은 양방향 바인등을 생성하기 위해 사용되는 속성 래퍼임 데이터를 읽고 수정한느 바인딩이 생성됨.
    // 즉 데이터 변경이 SwiftUI 뷰에 반영되고 뷰에서 변경 사항이 데이터에 반영되도록 함.
    // 여기서 filterDate는 DatePicker의 선택된 날짜는 나타냄. 사용자가 날짜를 변경하면 이 바인딩을 통해 해당 변경 사항이 filterDate 변수에 반영됨
    // 반대로 filterDate변수를 변경하면 DatePicker의 표시된 날자가 업데이트 됨. 이렇게 양방향 데이터 흐름을 구현함
    @Binding private var filterDate: Date
    
    // filterDate: Binding<Date> 타입의 매개변수로, 날짜 데이터를 읽고 수정할 수 있는 양방향 바인딩. 이 바인딩은 날짜 범위를 필터링하는 데 사용
    // content은 @ViewBuilder 속성을 사용하여 클로저 형태로 전달, 이 클로저는 CustomFilteringDataView의 본문으로 사용됨. 이 클로저는 두 개의 [Task] 매개변수를 받아서 콘텐츠를 빌드하고 반환.
    init(filterDate: Binding<Date>, @ViewBuilder content: @escaping ([Task], [Task]) -> Content) {
        // Calendar.current를 사용하여 현재 달력을 가져옴.
        let calendar = Calendar.current
        // filterDate 바인딩의 값에서 해당 날짜의 시작 시간을 가져옴
        let startOfDay = calendar.startOfDay(for: filterDate.wrappedValue)
        // startOfDay에 23시 59분 59초를 설정하여 해당 날짜의 끝 시간을 계산함.
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
        // Core Data의 NSPredicate 클래스를 사용하여 데이터를 필터링하기 위한 조건을 정의
        // date는 Core Data 엔터티의 Task 속성 이름 조건은 해당 날짜가 startOfDay와 endOfDay 사이인 경우를 나타냄.
        // argumentArray 는 %@와 %@에 각각 해당하는 값을 제공함. startOfDay는 필터링할 벙위의 시작 날짜, endOfDay는 필터링할 범위의 끝 날짜임.
        // 이러한 값들은 argumentArray 배열에 순서대로 들어감.
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [startOfDay, endOfDay])
        
        // SwiftUI에서 Core Data와 함께 데이터를 검색하는데 사용되는 @FetchRequest 속성 래퍼를 초기화하는 영역
        // FetchRequest는 SwiftUI에서 Core Data와 함께 데이터를 검색하는 데 사용되는 속성 래퍼임. @FetchRequest는 Core Data 엔터티의 데이터를 검색하고 화면에 표시하기 위한 중요한 기능 제공
        // entity: Task.entity()는 검색 대상이 되는 Core Data 엔터티를 지정. Core Data 모델에서 Task 엔터티에 대한 정보를 가져오는 메서드
        // sortDescriptors 는 검색 결과를 어떤 기준으로 정렬할지를 지정. 여기서 NSSortDescriptor를 사용하여 Task.date 속성을 기준으로 내림차순으로 정렬함. 가장 최근의 날짜가 먼저 표시되도록 함.
        // predicate는 데이터를 필터링하는 조건을 지정함. 이전에 설명한대로 NSPredicate를 사용하여 date 속성이 startOfDay와 endOfDay 사이인 데이터만 검색하도록 조건을 설정
        // animation은 검색 결과의 변경을 애니메이션화화는 데 사용됨. 여기서는 데이터가 변경될 때 .easeInOut 애니메이션을 적용하며, 지속시간은 0.25초로 설정
        _result = FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Task.date, ascending: false)], predicate: predicate, animation: .easeInOut(duration: 0.25))
        
        // 클로저 형태로 전달된 content를 CustomFilteringDataView의 내부 속성인 content에 저장
        self.content = content
        // 날짜 바인딩을 CustomFilteringDataView의 내부 속성인 _filterDate에 저장
        self._filterDate = filterDate
    }
    // content 함수를 호출하여 뷰 내용을 생성하고, onChange 블록을 사용하여 filterDate가 변경될 때마다 새로운 Core Data를 검색하도록 구현되어 있음.
    var body: some View {
        // content 함수를 호출하여 뷰 내용을 생성
        // 두 개의 인수가 전달되는데, separateTasks().0 과 separateTasks().1로, 화면에 표시할 데이터를 나타냄.
        // separateTasks() 함수는 현재 필터 및 정렬 조건에 따라 데이터를 필터링하고 분류하는 역할을 함.
        content(separateTasks().0, separateTasks().1)
            // filterDate의 값이 변경될 때마다 실행되는 클로저를 정의함. 이 클로저는 사용자가 DatePicker에서 날짜를 변경할 때 호춯함.
            .onChange(of: filterDate) { newValue in
                // Clearing Old Predicate
                // 이전에 설정된 NSPredicate를 제거하여 이전 필터를 해제함.
                result.nsPredicate = nil
                
                // Calendar.current를 사용하여 현재 달력을 가져옴.
                let calendar = Calendar.current
                // newValue(사용자가 선택한 날짜)를 해당 날의 시작 시간으로 변환. 즉, 선택한 날짜의 자정을 나타내는 변수
                let startOfDay = calendar.startOfDay(for: newValue)
                // startOfDay에 23시 59분 59초까지의 범위를 얻게 됨.
                let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
                // NSPredicate를 생성, Core Data에서 날짜 date 속성이 startOfDay와 endOfDay 사이에 있는 항목만선택
                let predicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [startOfDay, endOfDay])
                
                // Assigning New Predicate
                // 새로 생성한 NSPredicate를 @FetchRequest의 nsPredicate속성에 할당하여 변경된 조건으로 데이터를 필터링.
                result.nsPredicate = predicate
            }
    }
    
    // result 속성에서 가져온 Task 목록을 "미완료된 작업" 과 "완료된 작업"으로 분리하고 이 두 목록을 반환함.
    // 이 함수는 SwiftUI 뷰 내에서 작업 목록을 필터링하여 분리하고 나누는 데 사용된.
    func separateTasks() -> ([Task], [Task]) {
        // result 속성에서 isCompleted 속성이 fasle인 Task를 필터링하여 "미완료된 작업(pendingTasks)" 목록을 생성
        // result에 있는 모든 작업을 확인하고 "미완료된 작업"만 선택함.
        let pendingTasks = result.filter { !$0.isCompleted }
        // reuslt 속성에서 isCompleted 속성이 true인 Task를 필터링하여 "완료된 작업(completedTask)" 목록을 생성
        // result에 있는 모든 작업을 확인하고 "완료된 작업"만 선택함.
        let completedTasks = result.filter { $0.isCompleted }
        
        // 미완료 작업, 완료 작업을 튜플 형태로 반환함.
        return (pendingTasks, completedTasks)
    }
}

struct CustomFilteringDataView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
