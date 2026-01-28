# 최신 OS 및 의존성 업데이트 계획

iOS/Android 최신 OS 지원 및 모든 패키지를 최신 버전으로 업데이트합니다.

---

## 현재 플랫폼 설정

| 플랫폼 | 현재 설정 | 권장 설정 |
| :--- | :--- | :--- |
| iOS | 15.0 | **16.0** (Flutter 최신 권장) |
| Android minSdk | flutter.minSdkVersion | **24** (최신 Firebase/AdMob 요구) |
| Android targetSdk | flutter.targetSdkVersion | **35** (Android 15) |

---

## Outdated Dependencies

### 🔴 Major Updates (Breaking Changes 가능)

| 패키지 | 현재 | 최신 | 비고 |
| :--- | :--- | :--- | :--- |
| firebase_core | 3.15.2 | **4.4.0** | Firebase SDK 메이저 업데이트 |
| firebase_analytics | 11.6.0 | **12.1.1** | |
| firebase_messaging | 15.2.10 | **16.1.1** | |
| firebase_remote_config | 5.5.0 | **6.1.4** | |
| google_mobile_ads | 5.2.0 | **7.0.0** | AdMob SDK 메이저 업데이트 |
| image_cropper | 8.1.0 | **11.0.0** | API 변경 가능 |
| flutter_local_notifications | 19.5.0 | **20.0.0** | |
| home_widget | 0.7.0 | **0.9.0** | |
| hooks | 0.20.5 | **1.0.0** | |

### 🟡 Minor/Patch Updates

| 패키지 | 현재 | 최신 |
| :--- | :--- | :--- |
| dio | 5.9.0 | 5.9.1 |
| path_provider | 2.1.3 | 2.1.5 |
| sembast_web | 2.4.3 | 2.4.4 |
| timezone | 0.10.1 | 0.11.0 |
| riverpod_annotation | 4.0.0 | 4.0.1 |
| freezed | 3.2.3 | 3.2.4 |
| json_serializable | 6.11.2 | 6.11.4 |
| riverpod_generator | 4.0.0+1 | 4.0.2 |

---

## User Review Required

> [!CAUTION]
> **Major 업데이트**는 API 변경이 있을 수 있습니다. 특히:
> - `firebase_core` 4.x: 초기화 방식 변경 가능
> - `google_mobile_ads` 7.x: AdWidget 사용법 변경 가능
> - `image_cropper` 11.x: 크롭 설정 API 변경

**선택지:**
1. **전체 업데이트**: 모든 패키지를 최신으로 (권장, 시간 소요)
2. **Minor만 업데이트**: Breaking changes 없이 안전하게 업데이트
3. **선택적 업데이트**: 특정 패키지만 지정

---

## Proposed Changes

### [Platform Configuration]

#### [MODIFY] [Podfile](file:///Users/kihoonee/flutter/day_counter/ios/Podfile)
- iOS deployment target: `15.0` → `16.0`

#### [MODIFY] [build.gradle.kts](file:///Users/kihoonee/flutter/day_counter/android/app/build.gradle.kts)
- 명시적 minSdk: `24`, targetSdk: `35`

---

### [Dependencies]

#### [MODIFY] [pubspec.yaml](file:///Users/kihoonee/flutter/day_counter/pubspec.yaml)
- 모든 outdated 패키지 버전 업데이트
- `dependency_overrides` 섹션 제거 (호환성 확인 후)

---

## Verification Plan

1. `flutter pub upgrade --major-versions`
2. `flutter analyze` - 에러 확인
3. `dart run build_runner build` - 코드 생성
4. iOS/Android 빌드 테스트
5. 앱 실행 및 기능 테스트
