# 워크플로우 패턴

## 순차적 워크플로우

복잡한 작업의 경우 작업을 명확하고 순차적인 단계로 나눕니다. SKILL.md의 시작 부분에서 Claude에게 프로세스 개요를 제공하는 것이 종종 도움이 됩니다:

```markdown
PDF 양식 채우기는 다음 단계를 포함합니다:

1. 양식 분석 (analyze_form.py 실행)
2. 필드 매핑 생성 (fields.json 편집)
3. 매핑 검증 (validate_fields.py 실행)
4. 양식 채우기 (fill_form.py 실행)
5. 출력 확인 (verify_output.py 실행)
```

## 조건부 워크플로우

분기 로직이 있는 작업의 경우 Claude를 결정 지점을 통해 안내합니다:

```markdown
1. 수정 유형을 결정합니다:
   **새 콘텐츠를 만드는가?** → 아래 "생성 워크플로우"를 따르세요
   **기존 콘텐츠를 편집하는가?** → 아래 "편집 워크플로우"를 따르세요

2. 생성 워크플로우: [단계들]
3. 편집 워크플로우: [단계들]
```

---

## Flutter 전용 워크플로우 패턴

### 새 기능(Feature) 추가 워크플로우

```markdown
새 기능 추가는 다음 단계를 포함합니다:

1. 기능 폴더 구조 생성 (`lib/features/[feature_name]/`)
2. Domain 레이어 구현 (Entity, Repository 인터페이스, Use Case)
3. Data 레이어 구현 (Repository 구현체, Data Source)
4. Presentation 레이어 구현 (Screen, ViewModel/Provider)
5. 코드 생성 실행 (`dart run build_runner build`)
6. 라우터에 화면 등록 (`core/router/`)
7. 테스트 작성 및 실행
```

### Riverpod 프로바이더 선택 워크플로우

```markdown
1. 데이터 특성을 결정합니다:
   **단순 값/객체?** → `Provider` 또는 `StateProvider` 사용
   **비동기 데이터(API 호출)?** → 아래 비동기 워크플로우
   **복잡한 상태 로직?** → `Notifier` 또는 `AsyncNotifier` 사용

2. 비동기 데이터 워크플로우:
   **일회성 데이터 fetch?** → `FutureProvider` 사용
   **실시간 스트림?** → `StreamProvider` 사용
   **캐싱/갱신 필요?** → `AsyncNotifierProvider` 사용

3. 코드 생성 사용 시:
   - `@riverpod` 애노테이션 추가
   - `build_runner` 실행하여 `.g.dart` 생성
```

### Firebase 서비스 통합 워크플로우

```markdown
Firebase 연동은 다음 단계를 포함합니다:

1. 플랫폼 결정:
   **Android?** → `references/android.md` 참조
   **iOS?** → `references/ios.md` 참조
   **둘 다?** → 각 플랫폼 가이드를 순서대로 진행

2. Android 설정:
   - `google-services.json`을 `android/app/`에 복사
   - `android/build.gradle`에 Google Services 플러그인 추가
   - `android/app/build.gradle`에 플러그인 적용

3. iOS 설정:
   - `GoogleService-Info.plist`를 `ios/Runner/`에 복사
   - Xcode에서 파일 참조 추가
   - 필요 시 `ios/Podfile` 수정

4. Dart 코드 초기화:
   - `main.dart`에서 `Firebase.initializeApp()` 호출
```

### 앱 배포 워크플로우

```markdown
앱 배포는 다음 단계를 포함합니다:

1. 버전 업데이트 (`pubspec.yaml`의 version 필드)
2. 플랫폼별 빌드:
   **Android?** → `flutter build appbundle` 실행
   **iOS?** → `flutter build ipa` 실행

3. 서명 및 업로드:
   **Android**: Google Play Console에 AAB 업로드
   **iOS**: App Store Connect에 IPA 업로드 (Transporter 또는 Xcode)

4. 스토어 심사 제출
```