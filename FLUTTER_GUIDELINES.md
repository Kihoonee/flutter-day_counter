# Flutter 개발 가이드라인 및 안정성 표준

## 1. 앱 초기화 및 수명 주기 (중요)
**규칙:** `runApp()` 호출 전에 메인 스레드를 차단하지 마십시오.
- **나쁨:** `runApp` 호출 전 `main()` 내부에서 무거운 초기화(DB, Firebase 등)를 `await` 하는 것.
  - *위험:* 앱 실행이 20초 이상 걸리면 iOS Watchdog이 앱을 강제 종료함. 실행 어설션 오류 발생 가능.
- **좋음:** `LoadingScreen`이나 `Splash` 화면과 함께 즉시 `runApp()`을 호출하십시오.
- **패턴:**
  ```dart
  void main() {
    WidgetsFlutterBinding.ensureInitialized();
    // 여기서는 가벼운 동기 초기화만 허용 (예: 간단한 prefs)
    runApp(const ProviderScope(child: App()));
  }
  // App 위젯 내부에서 FutureProvider를 통해 무거운 리소스를 로드하십시오.
  ```

## 2. 데이터 영속성 (iOS 특이사항)
**규칙:** 데이터 손실이나 충돌을 방지하기 위해 올바른 저장소 디렉터리를 사용하십시오.
- **경로:** iOS에서는 `Documents`가 아닌 `Library` 디렉터리(`getLibraryDirectory()`)를 사용하십시오.
  - *이유:* `Documents`는 사용자 파일 관리 및 iCloud 동기화 문제에 노출됩니다. `Library`가 앱 내부 데이터베이스에 더 안전합니다.
- **데이터베이스:** Sembast/SQLite의 경우 올바른 I/O 팩토리(예: `databaseFactoryIo`)를 강제하십시오.

## 3. 상태 관리 (Riverpod)
**규칙:** 외부 데이터에는 Async/Future Provider를 사용하십시오.
- 데이터베이스 인스턴스에 `late` 변수 사용을 피하십시오.
- DB 초기화에는 `FutureProvider`를 사용하고 컨트롤러에서는 `ref.watch(provider.future)`를 사용하십시오.
- UI에서 `AsyncValue`(로딩/에러/데이터)를 명시적으로 처리하십시오.

## 4. 디버깅 및 테스트
**규칙:** iOS 실행 모드를 이해하십시오.
- **디버그 모드:** iOS 14+에서는 홈 화면에서 실행할 수 없습니다. 반드시 Xcode나 Flutter 도구를 통해 실행해야 합니다.
- **릴리스 모드:** 반드시 `flutter run --release`를 사용하여 다음을 테스트해야 합니다:
  1. 앱 재시작 동작 (콜드 스타트).
  2. 세션 간 데이터 영속성.
  3. 실제 성능 확인.

## 5. 에러 처리 및 복구
**규칙:** 우아하게 실패하고, 자동으로 복구하십시오.
- `Bootstrap` 로직이나 에러 경계를 구현하십시오.
- 중요한 리소스(DB)가 열리지 않는 경우(손상 등), 앱을 시작 시 충돌시키는 대신 폴백 전략(예: DB 삭제 후 재생성)을 구현하십시오.

## 6. UI/UX 안정성
- **렌더링:** 구버전 SDK 제약을 지원한다면 새로운 SDK 메서드(예: `Color.withValues`) 사용을 피하십시오. 더 넓은 호환성을 위해 `withOpacity`를 사용하십시오.
- **안전 영역:** 메인 화면은 항상 `SafeArea`로 감싸거나 패딩을 수동으로 처리하십시오.
