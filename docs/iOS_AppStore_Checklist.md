# Days+ iOS 앱스토어 심사 점검 리포트 (2025)

이 문서는 WWDC25 가이드라인 및 최신 Apple 정책에 따른 프로젝트 상태를 기록합니다.

## 📋 핵심 체크리스트 결과

- **Xcode 버전**: Xcode 16.2 (최신 대응 중)
- **Flutter SDK**: 3.38.6 (Stable)
- **iOS 지원 버전**: iOS 16.0 (iOS 14+ 기준 충족)
- **Privacy Manifest**: ✅ `ios/Runner/PrivacyInfo.xcprivacy` 생성 완료

## 🔍 상세 분석

### 1. Xcode 및 SDK 환경
현재 **Xcode 16.2**와 **Flutter 3.38.6**을 사용 중으로, 최신 iOS(iOS 18) 환경에 완벽히 대응하고 있습니다. 2025년 하반기 WWDC25 이후 배포될 Xcode 17 환경에도 마이그레이션이 용이한 상태입니다.

### 2. Privacy Manifest (개인정보 보호 선언문)
최근 Apple 정책에 따라 `NSUserDefaults`(shared_preferences 사용) 등의 필수 명시 API 사유를 포함한 선언문을 `ios/Runner/PrivacyInfo.xcprivacy`에 반영했습니다.

---
*작성일: 2025년 2월 5일*
