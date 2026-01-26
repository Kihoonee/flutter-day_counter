# 2026-01-27 핸드오버 리포트 (Mac -> Windows)

## 1. 현재 상황 (Current Status)
- **이슈:** 실기기(iOS) 실행 시 Flutter 엔진이 초기화되지 않고 **하얀 화면(White Screen)** 에서 멈추는 현상 지속.
- **테스트 환경:** 외부 플러그인(Firebase, AdMob, HomeWidget)을 모두 제거하고 순수 Flutter UI만 실행했으나 동일 증상 발생. Dart 진입점(`main()`) 이전의 네이티브 초기화 단계에서 멈추는 것으로 추정됨.

## 2. 지금까지 조치한 내용 (Troubleshooting)
1. **UI 개선 v2 완료:** 
   - 메인 카드(`PosterCard`) 레이아웃 좌측 정렬, 아이콘 고정, 높이 축소.
   - 할일 탭(`TodoTab`) 리스트 밀도(Density) 조절.
   - FAB(`+`) 버튼 Mini 사이즈로 변경.
2. **Crash 방어:** `path_provider` 다운그레이드 및 `dependency_overrides`로 `native_assets` 크래시 방지.
3. **White Screen 디버깅:**
   - `main.dart` 초기화 로직 지연 실행 (`Future.delayed`).
   - `pubspec.yaml`에서 모든 주요 플러그인 주석 처리 후 재빌드 (`pod install` 완료).

## 3. 다음 작업 (Next Steps)
- **Xcode 정밀 진단:** Windows에서는 어렵지만, Mac 환경이 다시 갖춰지면 Xcode에서 직접 실행하여 `Debug Gauge`나 `Instruments`로 어디서 스레드가 멈추는지 확인 필요.
- **프로젝트 클린 빌드:** `DerivedData` 폴더 수동 삭제 및 `flutter clean` 재수행.
- **플러그인 복구:** 앱 구동 성공 시, 주석 처리된 `pubspec.yaml`과 `main.dart`의 서비스들 하나씩 복구.

## 4. 참고 파일
- `directives/.task/v2/layout.md`: UI 개선 완료 내역.
- `lib/main.dart`: 현재 디버깅 모드(플러그인 비활성).
- `pubspec.yaml`: 주요 패키지 주석 처리됨.

고생 많으셨습니다! 출근길 조심하시고 내일 뵙겠습니다. 👋
