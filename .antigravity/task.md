# Flutter Pro 템플릿 적용

## 태스크 목록

### 1. 템플릿 적용 계획
- [x] 템플릿 구조 분석
- [x] 현재 프로젝트와 비교
- [x] 구현 계획서 작성

### 2. 스킬/스크립트 폴더 복사
- [x] `admob-skill/` 복사
- [x] `skill-creator/` 복사
- [x] `directives/` 복사
- [x] `scripts/` 복사
- [x] `.agent/` 복사

### 3. 패키지 추가
- [x] `pubspec.yaml`에 누락된 패키지 추가
  - riverpod_annotation, riverpod_generator
  - dio
  - google_mobile_ads
  - firebase_core, firebase_analytics, firebase_messaging, firebase_remote_config
- [x] `flutter pub get` 실행
- [x] `dart run build_runner build` 실행

### 4. 템플릿 패턴 점진적 적용
- [x] core/network 구조 추가
- [x] core/router 구조 확인 및 업데이트
- [x] 컴파일 에러 체크

### 5. 빌드 및 배포
- [x] Chrome으로 앱 실행 (`flutter run -d chrome`)
- [x] Git Push (완료)
