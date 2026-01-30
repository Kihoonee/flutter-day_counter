# 위젯 이벤트 선택 기능 상세 계획

## 1. 개요

사용자가 홈 화면에 위젯을 추가할 때, **어떤 이벤트를 표시할지 직접 선택**할 수 있게 하는 기능.

---

## 2. 플랫폼별 구현 메커니즘

### 2.1 Android: Configuration Activity

| 항목 | 설명 |
|---|---|
| **개념** | 위젯 추가 시 자동으로 실행되는 Activity |
| **역할** | 앱 데이터(이벤트 목록) 로드 → 사용자가 선택 → `SharedPreferences`에 저장 → 위젯 업데이트 |
| **핵심 파일** | `widget_info.xml`, `DaysPlusWidgetConfigureActivity.kt`, `AndroidManifest.xml` |

#### 구현 단계:
1.  `widget_info.xml`에 `android:configure` 속성 추가
2.  `DaysPlusWidgetConfigureActivity.kt` 생성 (이벤트 목록 UI, 선택 로직)
3.  `AndroidManifest.xml`에 Activity 등록
4.  선택된 이벤트 ID를 `SharedPreferences`에 저장 (위젯 ID별로)
5.  `DaysPlusWidget.kt`에서 저장된 이벤트 ID로 데이터 표시

---

### 2.2 iOS: AppIntentConfiguration (iOS 17+)

| 항목 | 설명 |
|---|---|
| **개념** | `WidgetConfigurationIntent`를 정의하여 시스템이 위젯 편집 UI를 자동 생성 |
| **역할** | 앱에서 `EntityQuery`로 이벤트 목록 제공 → 사용자가 편집 화면에서 선택 |
| **핵심 파일** | `SelectEventIntent.swift`, `EventEntity.swift`, `DaysPlusWidget.swift` |

#### 구현 단계:
1.  `EventEntity.swift`: `AppEntity` 프로토콜 준수, 이벤트 데이터 표현
2.  `SelectEventIntent.swift`: `WidgetConfigurationIntent` 정의, `@Parameter` 추가
3.  `EntityQuery` 구현: App Group `UserDefaults`에서 이벤트 목록 읽기
4.  `DaysPlusWidget.swift`를 `AppIntentConfiguration`으로 변경
5.  선택된 이벤트에 따라 타임라인 생성

---

## 3. 데이터 공유 전략

| 플랫폼 | 방법 |
|---|---|
| **Android** | `SharedPreferences` (`HomeWidgetPreferences`) |
| **iOS** | `UserDefaults(suiteName: appGroupId)` |
| **Flutter ↔ Native** | `home_widget` 패키지로 이벤트 목록 JSON 저장 |

---

## 4. 필요한 파일 변경

### Android
| 파일 | 작업 |
|---|---|
| [NEW] `DaysPlusWidgetConfigureActivity.kt` | Configuration Activity 구현 |
| [NEW] `activity_widget_configure.xml` | 이벤트 선택 UI 레이아웃 |
| [MODIFY] `widget_info.xml` | `android:configure` 속성 추가 |
| [MODIFY] `AndroidManifest.xml` | Activity 등록 |
| [MODIFY] `DaysPlusWidget.kt` | 위젯별 이벤트 ID 조회 |

### iOS
| 파일 | 작업 |
|---|---|
| [NEW] `SelectEventIntent.swift` | `WidgetConfigurationIntent` 정의 |
| [NEW] `EventEntity.swift` | `AppEntity` 정의 |
| [MODIFY] `DaysPlusWidget.swift` | `AppIntentConfiguration` 사용 |

### Flutter
| 파일 | 작업 |
|---|---|
| [MODIFY] `widget_service.dart` | 이벤트 목록 JSON을 `HomeWidget`에 저장 |

---

## 5. 개발 복잡도 평가

| 항목 | 난이도 | 예상 시간 |
|---|---|---|
| Android Configuration Activity | 중 | 2-3시간 |
| iOS AppIntentConfiguration | 상 | 3-5시간 |
| Flutter 데이터 동기화 | 하 | 1시간 |

> [!WARNING]
> iOS 17 이전 버전은 `IntentConfiguration` + Siri Intents Definition File 사용 필요 (더 복잡)

---

## 6. 검증 계획

-   Android Emulator에서 위젯 추가 시 Configuration Activity 표시 확인
-   iOS Simulator에서 위젯 편집 화면에서 이벤트 목록 표시 확인
-   선택된 이벤트가 위젯에 정확히 반영되는지 확인
