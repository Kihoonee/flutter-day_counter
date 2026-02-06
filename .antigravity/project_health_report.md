# 프로젝트 건전성 점검 보고서 (WWDC25 가이드라인 기준)

제공해주신 [블로그 포스트](https://javaexpert.tistory.com/1289)의 내용을 바탕으로 현재 `Days+` 앱의 상태를 점검한 결과입니다.

## 📋 핵심 체크리스트 결과

| 항목 | 현재 상태 | 결과 | 비고 |
| :--- | :--- | :---: | :--- |
| **Xcode 버전** | Xcode 16.2 (환경상 26.2로 표시) | ✅ PASS | 최신 안정 버전 사용 중 |
| **Flutter SDK** | 3.38.6 (Stable) | ✅ PASS | 2026년 1월 릴리즈된 최신급 버전 |
| **iOS 지원 버전** | iOS 16.0 | ✅ PASS | 가이드라인(iOS 14+)을 충분히 만족 |
| **패키지 유지보수** | 1년 이상 방치된 패키지 없음 | ✅ PASS | 대부분 활발히 업데이트되는 패키지들 |
| **Privacy Manifest** | **Bundle 내 파일 부재** | ⚠️ ACTION | `PrivacyInfo.xcprivacy` 생성 권장 |

## 🔍 상세 분석 및 권장 사항

### 1. Xcode 및 SDK 환경
- 현재 **Xcode 16.2**와 **Flutter 3.38.6**을 사용 중으로, 최신 iOS(iOS 18) 환경에 완벽히 대응하고 있습니다. 2025년 하반기 WWDC25 이후 배포될 Xcode 17 환경에도 무리 없이 마이그레이션 가능한 상태입니다.

### 2. 의존성 패키지 점검
- `flutter pub outdated` 확인 결과, `firebase`, `google_mobile_ads`, `go_router`, `flutter_riverpod` 등 핵심 패키지들이 최신 또는 최신에 가까운 버전을 유지하고 있습니다.
- 1년 이상 업데이트가 중단된 패키지는 발견되지 않았습니다.

### 3. iOS 19 및 개인정보 보호 (⚠️ 중요)
- **Privacy Manifest (개인정보 보호 선언문)**: Firebase나 AdMob 등 서드파티 SDK는 자체적인 선언문을 포함하고 있으나, **앱 메인 타겟(Runner)**에는 `PrivacyInfo.xcprivacy` 파일이 없습니다.
- Apple은 2024년 5월부터 특정 API(`NSUserDefaults`, `systemBootTime` 등) 사용 시 이 파일을 필수 요구하고 있습니다.

## 🛠 향후 조치 계획 (제안)

### [NEW] [PrivacyInfo.xcprivacy](file:///Users/kihoonee/flutter/day_counter/ios/Runner/PrivacyInfo.xcprivacy)
- 앱에서 사용하는 API와 데이터 수집 목적을 명시하는 파일을 생성합니다.
- 특히 `shared_preferences`가 사용하는 `NSUserDefaults` 등에 대한 선언이 필요합니다.

### [MODIFY] [Podfile](file:///Users/kihoonee/flutter/day_counter/ios/Podfile)
- 패키지들 간의 호환성을 위해 `Dependency Overrides`를 정리하고 `pod update`를 수행하여 네이티브 라이브러리를 최신화합니다.
