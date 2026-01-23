# 개선 사항 반영 계획 (UI/UX Refinement)

사용자가 요청한 `add2.md`의 UI/UX 개선 사항을 반영하기 위한 계획입니다.

## User Review Required
> [!IMPORTANT]
> **데이터 구조 변경**: 이벤트 아이콘을 테마와 분리하여 독립적으로 선택할 수 있도록 `Event` 엔티티에 `iconIndex` 필드를 추가합니다. 기존 데이터는 기본값(0)으로 설정됩니다.

## Proposed Changes

### 1 데이터 모델 (`domain/event.dart`) [DONE]
#### [MODIFY] `Event` 엔티티
- [x] `iconIndex` 필드 추가 (아이콘 선택용, Default: 0)
- [x] `build_runner` 실행하여 직렬화 코드 업데이트

### 2. 공통 리소스 (`presentation/widgets/poster_card.dart` 등) [DONE]
- [x] `posterThemes` 확장 (5개 추가)
- [x] `eventIcons` 상수 정의 (20개 아이콘 리스트)
- [x] `PosterCard`: 테마의 아이콘 대신 `event.iconIndex`에 해당하는 아이콘 표시

### 3. 수정 탭 (`presentation/widgets/edit_tab.dart`) [DONE]
#### [MODIFY] UI 레이아웃 및 스타일
- [x] **레이아웃 재배치**: 제목 -> [아이콘 선택] -> [테마 선택] -> 목표일 -> [옵션(스위치)]
- [x] **기준일 항목 제거**: 항상 오늘을 기준으로 함 (내부 로직 수정)
- [x] **스타일 개선**:
  - [x] 삭제 버튼: 회색(Grey) 계열, 다크모드 대응
  - [x] 폰트: Bold -> Normal, 통일성 있는 스타일 적용
  - [x] 제목 입력 필드: 더 크고 명확하게 스타일링

### 4. 다이어리 탭 (`presentation/widgets/diary_tab.dart`) [DONE]
#### [MODIFY] UI/UX 개선
- [x] **작성/수정 다이얼로그**:
  - [x] `showDatePicker` 대신 커스텀 버튼 + `pickDate` 사용 (공간 효율화)
  - [x] UI 디자인 개선 (M3 스타일, 세련된 정돈)
- [x] **리스트 아이템**:
  - [x] `PopupMenuButton` 제거
  - [x] 수정: 카드 클릭 시 수정 다이얼로그 (연필 아이콘 표시)
  - [x] 삭제: `Dismissible` (스와이프) 적용
- [x] **빈 상태(Empty State)**:
  - [x] 폰트 사이즈 축소, Gray 컬러 적용
  - [x] 아이콘 교체 (`history_edu_rounded`)
- [x] **작성 버튼 (FAB)**:
  - [x] 메인 화면의 `+` 버튼과 동일한 스타일 및 위치 적용

### 5. 할 일 탭 (`presentation/widgets/todo_tab.dart`) [DONE]
#### [MODIFY] 스타일 개선
- [x] **빈 상태**: 폰트 사이즈/컬러 조정, 아이콘 교체 (`checklist_rounded`)
- [x] **입력 필드**: 힌트 텍스트 스타일(Gray) 조정, 배경색/라운드 적용

## Verification Plan
### Automated Tests
- `flutter analyze`
- `build_runner` 실행 확인

### Manual Verification
- **수정 탭**: 아이콘/테마 선택 동작, 기준일 제거 확인, 스타일 확인
- **다이어리 탭**: 작성 다이얼로그 디자인(달력 크기), 스와이프 삭제, 연필 아이콘 수정 동작
- **할 일 탭**: 스타일 적용 확인
- **데이터 저장**: 아이콘 선택 정보가 앱 재시작 후에도 유지되는지 확인
