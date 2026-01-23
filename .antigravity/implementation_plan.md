# 이벤트 상세 화면 구현 계획

## 목표 설명
"MyDays" 앱의 UX를 벤치마킹하여 새로운 "이벤트 상세(Event Detail)" 화면을 구현합니다.
기존에는 카드를 탭하면 바로 수정 페이지로 이동했지만, 변경 후에는 상세 조회 페이지로 이동합니다. 상세 페이지 상단에는 디데이 카드가, 하단에는 할 일(To-Do) 리스트와 다이어리(Diary) 탭이 위치합니다.

## 변경 제안

### 도메인 레이어 (Domain Layer)
#### [MODIFY] [event.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/domain/event.dart)
- `List<TodoItem> todos` 필드 추가
- `List<DiaryEntry> diaryEntries` 필드 추가
- `TodoItem` 및 `DiaryEntry` 데이터 클래스 정의 (Freezed 활용)

### 데이터 레이어 (Data Layer)
- `build_runner` 실행을 통해 JSON 직렬화 및 불변 객체 코드 재생성 (`event.g.dart`, `event.freezed.dart`)

### 프레젠테이션 레이어 (Presentation Layer)
#### [NEW] [event_detail_page.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/pages/event_detail_page.dart)
- `Event` 객체(또는 ID)를 인자로 받는 새로운 상세 페이지
- 구조:
    - **AppBar**: 투명 처리, 뒤로가기 버튼
    - **Header**: 기존 `PosterCard` 재사용 (상단 배치)
    - **Body**: `TabBar` (To-Do / Diary) 및 `TabBarView`
    - **FAB**: 탭에 따라 할 일 추가 또는 일기 쓰기 동작

#### [NEW] [todo_tab.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/widgets/todo_tab.dart)
- 체크박스가 있는 할 일 목록 `ListView`
- 완료/미완료 토글 기능
- 항목 삭제 기능

#### [NEW] [diary_tab.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/widgets/diary_tab.dart)
- 날짜별 일기 목록 `ListView`
- 일기 작성 및 수정 다이얼로그 또는 페이지 연결

#### [MODIFY] [event_list_page.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/pages/event_list_page.dart)
- 리스트 아이템 탭(`onTap`) 시 `/edit`이 아닌 `/detail`로 이동하도록 라우팅 변경

#### [MODIFY] [router.dart](file:///Users/kihoonee/flutter/day_counter/lib/core/router/router.dart)
- 새로운 상세 페이지(`/detail`) 경로 추가

## 검증 계획

### 수동 검증
1.  **화면 이동**:
    -   홈 화면에서 이벤트 카드를 탭했을 때 상세 페이지로 올바르게 이동하는지 확인.
2.  **To-Do 기능**:
    -   "To-Do" 탭에서 할 일을 추가하고, 체크박스를 눌러 상태가 변경되는지 확인.
    -   앱 재실행 후에도 데이터가 유지되는지 확인.
3.  **Diary 기능**:
    -   "Diary" 탭에서 일기를 작성하고 목록에 표시되는지 확인.
4.  **기존 기능 확인**:
    -   상세 페이지에서 "수정" 버튼(또는 메뉴)을 통해 기존 수정 페이지로 이동 가능한지 확인.
