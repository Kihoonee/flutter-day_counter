# iOS 위젯 설정 안내

iOS 위젯은 Xcode 프로젝트에 새로운 **Target**을 추가해야 하므로, Xcode를 통해 수동으로 설정해야 합니다.

### 1. Xcode에서 프로젝트 열기
터미널에서 `open ios/Runner.xcworkspace`를 실행하세요.

### 2. Widget Extension 타겟 추가
1. Xcode에서 **File > New > Target...**으로 이동합니다.
2. **Widget Extension**을 검색하고 **Next**를 클릭합니다.
3. Product Name: `DayCounterWidget` 입력
4. "Include Live Activity" 및 "Include Configuration Intent"가 선택되어 있다면 체크를 해제합니다.
5. **Finish**를 클릭합니다.
6. 스킴(Scheme) 활성화 여부를 묻는 창이 뜨면 **Activate**를 클릭합니다.

### 3. Swift 코드 적용
1. Xcode에서 생성된 `DayCounterWidget/DayCounterWidget.swift` 파일을 찾습니다.
2. 해당 파일의 전체 내용을 Flutter 프로젝트의 `ios/` 폴더에 있는 `ios/DayCounterWidget.swift.template` 파일의 내용으로 교체합니다.

### 4. App Groups 설정 (데이터 공유를 위해 필수)
Flutter 앱과 위젯 간에 데이터를 공유하려면 다음 설정을 해야 합니다:

1. **Runner 타겟**:
    *   루트 프로젝트 노드 선택 -> `Runner` 타겟 선택 -> **Signing & Capabilities** 탭으로 이동합니다.
    *   `+ Capability` 클릭 -> **App Groups**를 추가합니다.
    *   App Groups 섹션에서 `+`를 클릭 -> `group.com.kihoonee.daycounterv2`를 추가합니다. (체크박스가 활성화되어 있는지 확인하세요).
2. **DayCounterWidget 타겟**:
    *   `DayCounterWidget` 타겟 선택 -> **Signing & Capabilities** 탭으로 이동합니다.
    *   `+ Capability` 클릭 -> **App Groups**를 추가합니다.
    *   `+`를 클릭하거나 기존의 `group.com.kihoonee.daycounterv2`를 선택합니다. (체크박스가 활성화되어 있는지 확인하세요).

### 5. 빌드 및 실행
앱을 다시 실행하세요 (`flutter run`). 이제 iOS 위젯 갤러리에서 위젯을 사용할 수 있습니다.
