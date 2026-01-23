# 개선 사항 반영 계획 (UI/UX Refinement)

사용자가 요청한 `add2.md`의 UI/UX 개선 사항을 반영하기 위한 계획입니다.

## User Review Required
> [!IMPORTANT]
> **데이터 구조 변경**: 이벤트 아이콘을 테마와 분리하여 독립적으로 선택할 수 있도록 `Event` 엔티티에 `iconIndex` 필드를 추가합니다. 기존 데이터는 기본값(0)으로 설정됩니다.

## Proposed Changes

### 1 데이터 모델 (`domain/event.dart`)
#### [MODIFY] `Event` 엔티티
- `iconIndex` 필드 추가 (아이콘 선택용, Default: 0)
- `build_runner` 실행하여 직렬화 코드 업데이트

### 2. 공통 리소스 (`presentation/widgets/poster_card.dart` 등)
- `posterThemes` 확장 (5개 추가)
- `eventIcons` 상수 정의 (10개 이상 아이콘 리스트)
- `PosterCard`: 테마의 아이콘 대신 `event.iconIndex`에 해당하는 아이콘 표시

### 3. 수정 탭 (`presentation/widgets/edit_tab.dart`)
#### [MODIFY] UI 레이아웃 및 스타일
- **레이아웃 재배치**: 제목 -> [아이콘 선택] -> [테마 선택] -> 목표일 -> [옵션(스위치)]
- **기준일 항목 제거**: 항상 오늘을 기준으로 함 (내부 로직 수정)
- **스타일 개선**:
  - 삭제 버튼: 회색(Grey) 계열, 다크모드 대응
  - 폰트: Bold -> Normal, 통일성 있는 스타일 적용
  - 제목 입력 필드: 더 크고 명확하게 스타일링

### 4. 다이어리 탭 (`presentation/widgets/diary_tab.dart`)
#### [MODIFY] UI/UX 개선
- **작성/수정 다이얼로그**:
  - `showDatePicker` 대신 커스텀 `CalendarDatePicker` 사용 (크기 조절 및 디자인 통일)
  - UI 디자인 개선 (MyDays 스타일 참고)
- **리스트 아이템**:
  - `PopupMenuButton` 제거
  - 수정: 연필 아이콘 버튼 (카드 내 배치)
  - 삭제: `Dismissible` (스와이프) 적용
- **빈 상태(Empty State)**:
  - 폰트 사이즈 축소, Gray 컬러 적용
  - 아이콘 교체 (더 세련된 디자인)
- **작성 버튼 (FAB)**:
  - 메인 화면의 `+` 버튼과 동일한 스타일 및 위치 적용

### 5. 할 일 탭 (`presentation/widgets/todo_tab.dart`)
#### [MODIFY] 스타일 개선
- **빈 상태**: 폰트 사이즈/컬러 조정, 아이콘 교체
- **입력 필드**: 힌트 텍스트 스타일(Gray) 조정

## Verification Plan
### Automated Tests
- `flutter analyze`
- `build_runner` 실행 확인

### Manual Verification
- **수정 탭**: 아이콘/테마 선택 동작, 기준일 제거 확인, 스타일 확인
- **다이어리 탭**: 작성 다이얼로그 디자인(달력 크기), 스와이프 삭제, 연필 아이콘 수정 동작
- **할 일 탭**: 스타일 적용 확인
- **데이터 저장**: 아이콘 선택 정보가 앱 재시작 후에도 유지되는지 확인
