# 이벤트 카드 사진 추가 기능

## 계획 (Planning)
- [x] 기존 코드 구조 분석 (`PosterCard`, `Event` 모델)
- [x] 필요 패키지 조사 (`image_picker`, `image_cropper`)
- [x] 구현 계획서(`implementation_plan.md`) 작성
- [x] 사용자 리뷰 및 승인

## 구현 (Implementation)
- [x] **Domain Layer**: `Event` 모델에 `photoPath` 필드 추가
- [x] **Core Layer**: 이미지 유틸리티 서비스 생성
- [x] **Presentation Layer**:
  - [x] `PosterCard` 레이아웃 수정 (D-Day 좌하단, 사진 우하단)
  - [x] 수정 화면에 사진 선택/크롭 UI 추가
- [x] 저장된 사진 로드 및 표시 로직

## 검증 (Verification)
- [x] iOS/Android 분석 및 Pod 설치 완료
- [x] iOS/Android 실기기 테스트 (Simulator/Emulator)
- [x] 사진 선택 → 크롭 → 저장 → 표시 흐름 확인
- [x] 앱 재시작 후 사진 유지 확인
- [x] **iOS Real-time Preview Fix**: `EditTab`과 `EventDetailPage` 상태 동기화 및 `ValueKey` 적용
- [x] **Refactoring**: `image_cropper` → `crop_your_image`로 교체 (UI 통일)
- [x] **Feature**: 새 이벤트 등록 화면(`EventEditPage`)에 사진 추가 기능 구현
- [x] **Config**: 앱 세로 모드 고정 (`SystemChrome.setPreferredOrientations`)
- [x] **Build**: Android Release APK 빌드
- [x] **Build**: iOS Release Build & Install (Kihoonee iPhone)
