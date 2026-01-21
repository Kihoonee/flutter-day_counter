# Flutter Pro 템플릿 적용 계획

day_counter 프로젝트에 flutter-pro-template의 구조와 도구들을 적용합니다.

## Proposed Changes

### 1단계: 스킬/스크립트 폴더 복사

템플릿에서 유용한 도구 폴더들을 프로젝트 루트로 복사합니다.

| 소스 | 대상 | 설명 |
|------|------|------|
| `tmp/flutter-pro-template/admob-skill/` | `./admob-skill/` | AdMob 통합 스킬 |
| `tmp/flutter-pro-template/skill-creator/` | `./skill-creator/` | 스킬 생성 도구 |
| `tmp/flutter-pro-template/directives/` | `./directives/` | SOP 문서 |
| `tmp/flutter-pro-template/scripts/` | `./scripts/` | Dart 유틸리티 스크립트 |
| `tmp/flutter-pro-template/.agent/` | `./.agent/` | AI 워크플로우 |

---

### 2단계: pubspec.yaml 패키지 추가

현재 프로젝트에 없는 템플릿의 패키지들을 추가합니다.

#### [MODIFY] [pubspec.yaml](file:///Users/kihoonee/flutter/day_counter/pubspec.yaml)

**dependencies 추가:**
```yaml
riverpod_annotation: ^4.0.0
dio: ^5.4.0

# Monetization & Analytics
google_mobile_ads: ^7.0.0
firebase_core: ^4.1.1
firebase_analytics: ^12.1.1
firebase_messaging: ^16.1.1
firebase_remote_config: ^6.0.2
```

**dev_dependencies 추가:**
```yaml
riverpod_generator: ^4.0.0+1
change_app_package_name: ^1.5.0
```

---

### 3단계: 템플릿 패턴 적용

#### [NEW] [dio_client.dart](file:///Users/kihoonee/flutter/day_counter/lib/core/network/dio_client.dart)

템플릿의 네트워크 클라이언트 구조를 복사하거나 참고하여 생성합니다.

---

## Verification Plan

### 자동 검증
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

### 수동 검증
- 앱 빌드 및 실행 확인
- 기존 기능 정상 동작 확인
