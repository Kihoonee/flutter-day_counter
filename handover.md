# 2026-01-27 핸드오버 리포트 (실기기 구동 이슈 해결 중)

## 1. 현재 상황 (Current Status)
- **시뮬레이터:** 모든 기능(Days+ 리스트, 이벤트 상세, 수정, 저장, 테마 등) 완벽 작동 확인.
- **실기기(아이폰):** 실행 즉시 강제 종료 혹은 하얀 화면 현상 발생.
- **핵심 원인:** 
    1. **App Group 권한 충돌:** 위젯 연동용 `group.day_counter` 설정이 아이폰의 개발자 인증서 프로필과 맞지 않아 iOS 보안 정책에 의해 차단됨.
    2. **Native Assets 로드 실패:** 최신 플러터 패키지들의 `objective_c.framework`가 실기기 빌드 시 서명 문제로 로드되지 않음.

## 2. 지금까지 조치한 내용
- **Dependency Downgrade:** `path_provider`, `google_mobile_ads` 등을 Native Assets 기능이 없는 하위 버전으로 고정 (`pubspec.yaml` 확인).
- **Entitlements 수정:** `Runner.entitlements`에서 임시로 App Group 권한을 제거하여 실행 시도.
- **main.dart 최소화:** Firebase/AdMob 초기화를 비동기로 빼서 로딩 행(Hang) 방지.

## 3. 내일 이어할 작업 (Todo List)
- **Xcode 설정 확인:** `Signing & Capabilities` 탭에서 `App Groups`를 실제 사용 가능한 ID로 다시 맞추거나 일시 비활성화.
- **Crash 로그 분석:** 아이폰 앱이 죽을 때의 시스템 로그를 Xcode 'Devices and Simulators' 창에서 확인하여 정확한 크래시 포인트 식별.
- **WidgetService 복구:** 앱이 정상적으로 켜지면, 비활성화해둔 `WidgetService`를 다시 연결.

## 4. 참고 파일
- `lib/main.dart`: 현재 최소 초기화 상태.
- `pubspec.yaml`: 버전 핀 고정 및 override 설정됨.
- `ios/Runner/Runner.entitlements`: 권한 일시 제거됨.

오늘의 고생이 내일의 완성으로 이어질 것입니다. 고생하셨습니다!
