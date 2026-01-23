# Flutter Pro 템플릿 적용 완료

## 세션 요약 (2026-01-22)

### ✅ 완료된 작업

1. **Flutter Pro 템플릿 적용**
   - `admob-skill/`, `skill-creator/`, `directives/`, `scripts/`, `.agent/` 복사
   - `pubspec.yaml`에 패키지 추가 (Riverpod Generator, Dio, Firebase, AdMob)
   - `lib/core/network/dio_provider.dart` 생성

2. **문서 한국어화**
   - `FLUTTER_GUIDELINES.md` 한글 번역
   - `GEMINI.md` 3-Layer 아키텍처 가이드라인으로 업데이트

3. **Git 저장소 설정**
   - `git init` 및 첫 커밋
   - `origin` 설정: `https://github.com/Kihoonee/flutter-day_counter.git`
   - `main` 브랜치로 push 완료

4. **iOS 빌드 설정**
   - `ios/Podfile` iOS deployment target 14.0 → 15.0 업데이트 (Firebase 요구사항)
   - iPhone 15 Pro 시뮬레이터에서 앱 실행 성공 (2026-01-22 재검증 완료)

5. **릴리즈 빌드 크래시 해결 (2026-01-22)**
   - **증상**: 릴리즈 모드로 실행 시 앱이 바로 종료됨
   - **원인**: Firebase 설정 파일(`google-services.json`, `GoogleService-Info.plist`) 및 초기화 코드 누락
   - **해결**:
     - `flutterfire configure` 실행하여 프로젝트 연결 및 파일 생성
     - `lib/main.dart`에 `Firebase.initializeApp()` 추가
     - `ios/Runner.xcodeproj` 설정 자동 업데이트 (gem `xcodeproj` 설치)

6. **시뮬레이터 실행 크래시 해결 (2026-01-22)**
   - **증상**: 앱 실행 직후 종료 (Splash 화면 후 꺼짐)
   - **원인**: `google_mobile_ads` 패키지 사용 시 필수인 AdMob App ID 설정 누락
   - **해결**:
     - `ios/Runner/Info.plist`: `GADApplicationIdentifier` 키 추가
     - `android/app/src/main/AndroidManifest.xml`: `com.google.android.gms.ads.APPLICATION_ID` 메타데이터 추가
     - (테스트용 샘플 ID 사용)
     - `objective_c.dylib` 로드 에러 발생하여 `flutter clean` 및 `pod install --repo-update`로 해결

7.  **UI 리디자인 (2026-01-23)**
    *   **스타일 변경**: Glassmorphism/Gradient 제거 → **Clean Minimalist (Off-white/Dark-grey)** 스타일로 전면 교체
    *   **테마 적용**: 달력 디자인과 동일한 톤앤매너 (Solid Color, Soft Shadow, Orange/Coral Accent)
    *   **커스텀 달력**:
        *   `CustomCalendar` 위젯 구현 및 적용
        *   **연도 선택 기능 추가**: 헤더 클릭 시 연도 그리드로 전환하여 빠른 연도 변경 지원
        *   **UX 개선**: 연도 선택 화면 진입 시 **현재 선택된 연도가 중앙에 오도록 자동 스크롤** 기능 구현
    *   **PosterCard**:
        *   깔끔한 카드 디자인으로 변경 및 가독성 개선
        *   **솔리드 파스텔 배경 w/ 화이트 오버레이**:
            *   **Random Wild Wave**: 카드마다 물결의 곡률과 모양이 랜덤하게 생성되어 고유한 디자인 제공
            *   **Clean D-Day Text**: "D" 접두사를 제거하고 숫자 부호만 표시 (예: +23, -10)하여 미니멀한 디자인 강화
            *   **Tight Shadow**: 그림자 퍼짐을 줄이고 하단으로 집중시켜 깔끔하고 선명한 입체감 구현
       - **Expanded Themes**: 파스텔 테마 5종 추가 (Blue, Pink, Yellow, BlueGrey, Brown)하여 총 10종 지원 (Medium Pastel)
       - **Clean Edit UI**: 삭제/저장 버튼의 테두리를 제거하고 플랫한 디자인으로 변경하여 깔끔함 강조
       - **Transparent Header**: `extendBodyBehindAppBar`를 적용하여 리스트가 상단 App Bar 영역 뒤로 스크롤되도록 시각적 개방감 확보
       - **Custom FAB**: 광고 영역과 겹치지 않도록 추가(+) 버튼 위치를 조정(`bottom: 120`)하고 원형 디자인 유지
       - **Shadow Clipping Fix**: 리스트 화면에서 그림자가 잘리는 현상을 방지하기 위해 카드 하단/좌우에 `Padding` 추가
       - **물방울 효과 강화**: 물방울의 크기와 분포 범위를 확대하여 더욱 드라마틱한 연출

8.  **Physical Device Deployment (2026-01-23)**
    *   **Target**: Kihoonee iPhone (iOS 17+)
    *   **Build Mode**: Release
    *   **Signing**: Automatic Signing (Team: G3578Y7NMA)
    *   **Status**: Running...

---

## 다음 단계


1. **AdMob 설정** - `admob-skill/` 폴더의 가이드 참고
2. **AdMob 설정** - `admob-skill/` 폴더의 가이드 참고
3. **웹 빌드 수정** - `database_service.dart`의 `dart:io` 사용을 조건부 import로 변경 필요

---

## 알려진 이슈

- **Chrome 빌드 실패**: `database_service.dart`에서 `dart:io`와 `Platform` 직접 사용으로 웹 호환성 문제
  - 해결: 기존 `db_factory.dart`, `db_path.dart` 조건부 export 패턴 활용 필요
